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
        h1("Data input"),
        checkboxGroupInput("datasets", "Select ALL datasets to classify:",
                           choices=dsInventory,selected=dsInventory[1]),
        p("The proportions make these versions of iris more and more unbalanced."),
    #         selectInput("dataset", "Select dataset:", 
#                     choices = dsInventory, selected = dsInventory[1], 
#                     multiple = TRUE),
        checkboxGroupInput("models", "Select ALL classifiers to apply:",
                           choices=mInventory,selected=mInventory[1]),
#         selectInput("model", "Select type of classifier:", 
#                     choices = mInventory, selected = mInventory[1], multiple = FALSE),
        submitButton("Run Simulation"),
        p("Note: Some classifiers may have the same name but differ in the parameters used to train them.")
        ),
     mainPanel(
         h3(textOutput("caption")),
         plotOutput("etPlot")
         #verbatimTextOutput("summary")
     )
    )
)