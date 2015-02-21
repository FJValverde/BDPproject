#### !/usr/bin/R #Not to be run by direct invokation! (see below)
#
# The server part of a Shiny applications
#
# Remember to run it with: runApp() in the dir where ui.R and server.R are defined.
library(mlbench)  # Many databases for ML tasks: Ionosphere
library(arm)      # Not actually loaded by caret: for"Bayesian Generalized Linear Model",
library(shiny)
library(ggtern)   # To print the entropy ternary variable
library(entropy)  # To work out the appropriate coordinates.
library(caret)    # To build the classifiers.

#load the data common to ui.R and server.R
source("helpers.R")


# Some utility functions to carry out entropic analysis of contingency matrices.
#Given a contingency matrix, provide one row of entropy coordinates
entropies <- function(N,unit="log2",...){
    Ni <- apply(N,1,sum); Hx <- entropy(Ni,unit="log2",...)
    Nj <- apply(N,2,sum); Hy <- entropy(Nj,unit="log2",...)
    dims <- dim(N)
    Ux <- entropy(rep(1/dims[1],dims[1]),unit="log2",...)
    Uy <- entropy(rep(1/dims[2],dims[2]),unit="log2",...)
    Hxy <- entropy(N,unit="log2",...)
    return(list(
        Ux = Ux, Uy = Uy, 
        Hx = Hx, Hy = Hy,
        Hxy = Hxy
    )
    )
}
# Generate the entropic coordinates from the component entropies
# - with split=TRUE, generate independen coordinates for X and Y distributions.
entropicCoordinates <- function(df,split=FALSE){
    with(df,
         if (split){#split coordinates
             splitDF <- data.frame(
                 Ux = Ux, Uy = Uy,
                 DeltaHx = Ux - Hx,
                 DeltaHy = Uy - Hy,
                 MIxy = Hx + Hy - Hxy,
                 VIx = Hxy - Hy,
                 VIy = Hxy - Hx
             )
             #               splitDF["VIx"] <- Hx - splitDF$MIxy
             #               splitDF["VIy"] <- Hy - splitDF$MIxy
             return(splitDF)
         } else{#not split
             newDF <- data.frame(
                 Uxy = Ux + Uy,
                 DeltaHxy = Ux - Hx + Uy -Hy,
                 MIxy2 = 2*(Hx + Hy - Hxy),
                 VIxy = Hxy + Hxy - Hx - Hy
             )
             #            newDF["VIxy"] <- 2*Hxy - Hx - Hy 
             return(newDF)
         }
    )
}
#coords <- entropicCoords(entropies(N, unit="log2"))
#splitCoords <- entropicCoords(entropies(N, unit="log2"), split=TRUE)


# To select the model based on the prompt given by the user...
evalModel <- function(mPrompt){modelDF$model[which(mInventory==mPrompt)]}

#To select the dataset by name
evalDataset <- function(dsName){
    switch(dsName,
           "iris 50/50/50" = iris,
           "Ionosphere" = {data(Ionosphere); Ionosphere}, # force loading
           "segmentationData" = {data(segmentationData); segmentationData},
           "GermanCredit" = {data(GermanCredit); GermanCredit},
           "oil" = {data(oil); oil},
           "PimaIndiansDiabetes"={data(PimaIndiansDiabetes); PimaIndiansDiabetes}, # from mlbench package
           "iris 50/25/25" =iris2,
           "iris 50/20/10" =iris3,
           "iris 50/10/05" =iris4
    )
}

# Returns the coordinates of the evaluation, unfortunately... Could it also return
# the confusion matrices?
evalModelOnDataset <- function(model,dataset){
    set.seed(1117)
    realModel <- evalModel(model)  # Validates as a method name in caret.
    realDataset <- evalDataset(dataset)  # Get the real dataset
    #data(realDataset) # force loading the data!
    #find out model and dataset parameters in databases table
    #numRowDataset <- grepl(dataset,dfDS$dsName,fixed=TRUE)
    numRowDataset <- dataset == dfDS$dsName
    thisDataset <- dfDS[numRowDataset,]
    thisClass <- thisDataset$classVar
    
    numRowMethod <- grepl(realModel,modelDF$model,fixed=TRUE)

    cat(sprintf("Training %s on %s...", model, dataset))
#     expression <- 
#         sprintf('train(x=realDataset[,-thisClass], y=realDataset[,thisClass],method=realModel,
#                  trControl=trainControl(method="cv"),
#                  tuneLength = 15)')
#     cat(expression)
#     fit <- evalq(parse(text=expression))
    fit <- train(x=realDataset[,-thisClass], y=realDataset[,thisClass], 
                 method=realModel,#,
                 trControl=trainControl(
                     method="cv"
                     ),
                 tuneLength = 15
                 #preProcess = c("center", "scale")
                 ) # What about the parameters for each method?
    cat("Done!\n")
    confMat <- confusionMatrix(fit) 
            #predict(fit,realDataset[,-class]), realDataset[,class])
    print(confMat)
    #find the confusion table of the experiment.
    expTable <- confMat$table # table(predict(fit1,training[,-5]), training[,5])
    #expTable <- matrix(rexp(3^2), 3); expTable <- expTable/sum(expTable)
    # find the entropic coordinates and return them
    expEntropies <- entropies(expTable)
    ec <- entropicCoordinates(expEntropies)
    # Return as a list to be included 
    return(list(mExp=model,
                dsExp=dataset,
                tableExp=expTable, # Bof!
                MIxy=ec$MIxy2/ec$Uxy,
                VIxy=ec$VIxy/ec$Uxy,
                DeltaHxy=ec$DeltaHxy/ec$Uxy))
#           VIxy=d[1], MIxy=d[2], DeltaHxy=d[3]))
}

# a function to go over two lists generating their cases 
applyModelsDatasets <- function(models,datasets){
    I <- length(models); J <- length(datasets)
    n <- I * J
#     dsExp <- rep(datasets,I)      #these
#     print(dsExp)
#     mExp <- rep(models,each=J)
#     VIxy <- rep(0, I*J)
#     MIxy <- rep(0, I*J)
#     DeltaHxy <- rep(0, I*J)
    #preallocation is advised.
    exp <- data.frame(mExp = rep(models,each=J), dsExp=rep(datasets,I),
                      VIxy=numeric(n),
                      MIxy=numeric(n),
                      DeltaHxy=numeric(n))
    #rowNames <- c("mExp", "dsExp", "VIxy", "MIxy", "DeltaHxy")
    for(i in 1:I){
        for(j in 1:J){
            res <- evalModelOnDataset(models[i],datasets[j])
#             d <- runif(3); d <- d/sum(d)     
#             # Store the results
#             exp$VIxy[(i-1)*J+j] <- d[1]
#             exp$MIxy[(i-1)*J+j] <- d[2]
#             exp$DeltaHxy[(i-1)*J+j] <- d[3]
            # Store the results
            exp$VIxy[(i-1)*J+j] <- res$VIxy
            exp$MIxy[(i-1)*J+j] <- res$MIxy
            exp$DeltaHxy[(i-1)*J+j] <- res$DeltaHxy
        }
    }
    return(exp)
    #return(data.frame(mExp,dsExp,VIxy,MIxy,DeltaHxy))
}
# The dummy code from the slides
shinyServer(
    function(input,output){
        chosenDatasetNames <- reactive({input$datasets})
        chosenModelNames <- reactive({input$models})
        experimentsText <- reactive({
            models <- chosenModelNames(); datasets <- chosenDatasetNames()
            #sprintf("Evaluating \\(%s) on dataset %s",chosenModel(),chosenDataset())
            sprintf("Evaluating %s on datasets %s.",
                    paste(models, collapse=", "),
                    paste(datasets, collapse=", "))
        })
        
#         #Provide the chosen name and method to be printed in the UI
#         chosenDataset <- reactive({input$dataset})
#         chosenModel <- reactive({input$model})
#         # Compute the formula text in a reactive expression since it is
#         # shared by the output$caption and output$mpgPlot functions
#         experimentText <- reactive({
#             #sprintf("Evaluating %s on dataset %s",chosenModel(),chosenDataset())
#             sprintf("Evaluating %s on dataset %s",input$model,input$dataset)
#         })
        
        # Return the formula text for printing as a caption
        output$caption <- renderText({
            experimentsText()
        })
        
        # Return the requested datasets
        #datasetInputs <- reactive({lapply(input$datasets, evalDataset)})
#         datasetInput <- reactive({
#             switch(input$dataset,
#                    "iris" = iris,
#                    "Ionosphere" = Ionosphere)
#         })
        #modelInputs <- reactive({lapply(input$models, evalModel)})

        # Everything that needs to be reevaluated comes here!
        output$etPlot <- renderPlot({
            datasets <- chosenDatasetNames() #datasetInputs()  # Reevaluates dataset on a change of input
            models <- chosenModelNames() #modelInputs()
                
            # Carry an experiment and generate a plot of it!
            # The code developing this is from ETUseCase.Rmd to be found in this project. 
            # Dummy points to test the plotting function!
#             VIxy = c(1,0,0)
#             MIxy = c(0,1,0)
#             DeltaHxy = c(0,0,1)
#             dsExp <- c("iris","Ionosphere")
#             mExp <- c("knn","logreg","svm")
#             experiments <- data.frame(dsExp,mExp,VIxy,MIxy,DeltaHxy)
            experiments <- applyModelsDatasets(models,datasets)

            # generate a dummy ternary plot
            plot <- ggtern() +  
                theme_rgbw() + 
                theme(complete=FALSE, 
                      axis.tern.showlabels=FALSE,
                      axis.tern.showarrows=TRUE,
                      axis.tern.clockwise=FALSE)

            #Plot training points in a certain colour, test in another
            plot + geom_point(data=experiments,
                              aes(VIxy,MIxy,DeltaHxy,colour=dsExp,shape=mExp),
                              size=3) +
                labs(colour="Dataset", shape="Classifier") + # Recipe 10.5, Chang
                scale_colour_brewer(palette="Set1")
        })
              
#         # Generate a summary of the dataset
#         output$summary <- renderPrint({
#             dataset <- datasetInput()  # eval the reactive value, since it is a closure
#             summary(dataset)
#         })
        
    }
)