#### !/usr/bin/R #Not to be run by direct invokation! (see below)
#
# The user interface script in a shiny application
#
# Remember to run it with: runApp() in the dir where ui.R and server.R are defined.
library(shiny)

name <<- c("Ionosphere", "iris") # 
model <- c("knn")

# The basic code
shinyUI(pageWithSidebar(
    headerPanel("Evaluating Classifiers with the Entropy Triangle"),
    sidebarPanel(
        h1("Data input"),
        selectInput("dataset", "Select dataset:", 
                    choices = name, selected = name[1], multiple = FALSE),
        selectInput("model", "Select type of classifier:", 
                    choices = model, selected = model[1], multiple = FALSE),
#        numericInput("delta", "Price Change (%):", 10),
        submitButton("Run Simulation")
        ),
     mainPanel(
         h3(textOutput("caption")),
         plotOutput("etPlot")
         #verbatimTextOutput("summary")
     )
    )
)