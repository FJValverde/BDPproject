# This file hosts the data and functions shared by the ui.R and server.R scripts
# as per the tutorial on
#http://shiny.rstudio.com/tutorial/lesson5/
library(caret)    # To build the classifiers.
library(mlbench)  # Many databases for ML tasks: Ionosphere
library(C50)
library(e1071)
library(RWeka)
library(klaR)

cat('Building the database of models...')
automatic <- {FALSE}#;TRUE}
modelDF <- modelLookup()
chosenModels <- if (automatic){
    modelDF$forClass & modelDF$label=="none"  # Only 5 models, all in all
} else { # Manual, to better control what is modelled.
    modelDF$model %in% c("knn", "nb", "OneR", "C5.0Tree")
}
modelDF <- modelDF[chosenModels,] #Select those for classification
#modelInfo <- getModelInfo(modelDF$model,regex=FALSE)  #All the information from the models
getModelLabel <- function(m){
    info <- getModelInfo(m,regex=FALSE)
    return(info[[m]]$label)
}
mInventory <- as.vector(sapply(X=modelDF$model, FUN=getModelLabel)) #modelDF$model
cat('Done!\n')

# The following tries to simulate  the approach taken by caret on the models.
# the inventory of databases you can access
cat('Building the database of datasets...')
dsName <-  c(
    "Ionosphere",
    "iris 50/50/50", 
    "segmentationData",
    "GermanCredit",
    "PimaIndiansDiabetes",
    "iris 50/25/25",
    "iris 50/20/10",
    "iris 50/10/05"
)
#oil <- cbind(oilType, fattyAcids)  # Difficult to work with!
# The next should be automatized!!!
classVar <- c(35,5,3,21,9,5,5,5)   # ordinal of the class attribute
className <- c("Class","Species",
               "Class","credit_risk", "diabetes",
               "Species", "Species", "Species")  # Name of class attribute
K <- c(2, 3, 2, 2, 2, 3, 3, 3)  # No. of classes
dfDS <- data.frame(dsName,classVar,className,K)
print(dfDS)
iris2 <- iris[c(1:50,51:75,101:125),]  # iris 50/25/25
iris3 <- iris[c(1:50,51:70,101:110),]  # iris 50/20/10
iris4 <- iris[c(1:50,51:60,101:105),]  # iris 50/10/05
# We have to create this type of data
dsInventory <- dsName[grepl("iris",dfDS$dsName,fixed=TRUE)]
cat('Done!\n')

