#### !/usr/bin/R #Not to be run by direct invokation! (see below)
#
# The user interface script in a shiny application
#
# Remember to run it with: runApp() in the dir where ui.R and server.R are defined.
library(shiny)

#load the data common to ui.R and server.R
source("helpers.R")

# The basic code
shinyUI(pageWithSidebar(
    headerPanel("Evaluating Classifiers with the Entropy Triangle"),
    sidebarPanel(
        h1("Purpose"),
        p("To show how classifiers loose performance with increasing unbalance in the dataset, despite increasing accuracy."),
        h1("Data input"),
        checkboxGroupInput("datasets", "Select ALL datasets to classify:",
                           choices=dsInventory,selected=dsInventory[1:4]),
        p("The proportions indicate more and more unbalanced versions of iris."),
    #         selectInput("dataset", "Select dataset:", 
#                     choices = dsInventory, selected = dsInventory[1], 
#                     multiple = TRUE),
        checkboxGroupInput("models", "Select ALL classifiers to apply:",
                           choices=mInventory,selected=mInventory[1]),
#         selectInput("model", "Select type of classifier:", 
#                     choices = mInventory, selected = mInventory[1], multiple = FALSE),
        p("Note: Some classifiers may have the same name but differ in the parameters used to train them."),
        submitButton("Run Simulation")
        ),
     mainPanel(
         h3(textOutput("caption")),
         plotOutput("etPlot"),
         #verbatimTextOutput("summary")
         p("* The higher the classifier, the more mutual information between real and predicted labels it transmits."),
         p("* The more to the right, the higher the classifier accuracy!"),
         p("* The more to the left, the more balanced the dataset!"),
         p("* As the database gets more unbalanced, the classifier loses the capability to 'transmit' information but gains in accuracy!"),
         h4("Note: the deployed application in shinyapps does not seem to be able to load the package for all classifiers. The full set of experiments run on local can be found in the accompanying presentation.")
     )
    )
)