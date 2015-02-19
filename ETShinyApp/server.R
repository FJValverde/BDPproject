#### !/usr/bin/R #Not to be run by direct invokation! (see below)
#
# The server part of a Shiny applications
#
# Remember to run it with: runApp() in the dir where ui.R and server.R are defined.
library(shiny)
library(ggtern)   # To print the entropy ternary variable
library(entropy)  # To work out the appropriate coordinates.
library(caret)    # To build the classifiers.
library(mlbench)  # Many databases for ML tasks: Ionosphere

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

# the inventory of databases you can access
dsName <- c("Ionosphere", "iris") # 
classVar <- c(35,5)   # ordinal of the class attribute
className <- c("Class","Species")  # Name of class attribute
K <- c(2, 3)  # No. of classes
dfDS <- data.frame(dsName,classVar,className,K)

#To select the dataset by name
evalDataset <- function(dsName){
    switch(dsName,
           "iris" = iris,
           "Ionosphere" = Ionosphere)
}

# THe inventory of models you can access
modelName <- c("knn")
dfModels <- data.frame(modelName)

#To select the classifier by name
evalModel <- function(mName){
    switch(mName,
           "knn" = "knn")  # The second term is the model name for caret::train
}

# The dummy code from the slides
shinyServer(
    function(input,output){
        #Provide the chosen name and method to be printed in the UI
        chosenDataset <- reactive({input$dataset})
        chosenModel <- reactive({input$model})

        # Compute the formula text in a reactive expression since it is
        # shared by the output$caption and output$mpgPlot functions
        experimentText <- reactive({
            #sprintf("Evaluating %s on dataset %s",chosenModel(),chosenDataset())
            sprintf("Evaluating %s on dataset %s",input$model,input$dataset)
        })
        
        # Return the formula text for printing as a caption
        output$caption <- renderText({
            experimentText()
        })
        
        # Return the requested dataset
        datasetInput <- reactive({evalDataset(input$dataset)})
#         datasetInput <- reactive({
#             switch(input$dataset,
#                    "iris" = iris,
#                    "Ionosphere" = Ionosphere)
#         })
        modelInput <- reactive({evalModel(input$model)})

        # Everything that needs to be reevaluated comes here!
        output$etPlot <- renderPlot({
            datasets <- datasetInput()  # Reevaluates dataset on a change of input
            models <- modelInput()
            
            # generate a dummy ternary plot
            plot <- ggtern() +  
                theme_rgbw() + 
                theme(complete=FALSE, 
                      axis.tern.showlabels=FALSE,
                      axis.tern.showarrows=TRUE,
                      axis.tern.clockwise=FALSE)
            
            # Dummy points to test the plotting function!
            VIxy = c(1,0,0)
            MIxy = c(0,1,0)
            DeltaHxy = c(0,0,1)
            dataset <- c("iris","iris","iris")
            model <- c("knn","logreg","svm")
            experiments <- data.frame(dataset,model,VIxy,MIxy,DeltaHxy)
            
            #Plot training points in a certain colour, test in another
            plot + geom_point(data=experiments,
                              aes(VIxy,MIxy,DeltaHxy,colour=dataset,shape=model),
                              size=3) +
                scale_colour_brewer(palette="Set1")
        })
        
        # Carry an experiment and generate a plot of it!
        # The code developing this is from ETUseCase.Rmd to be found in this project. 
        
        # Generate a summary of the dataset
        output$summary <- renderPrint({
            dataset <- datasetInput()  # eval the reactive value, since it is a closure
            summary(dataset)
        })
        
    }
)