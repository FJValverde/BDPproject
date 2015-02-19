#### !/usr/bin/R #Not to be run by direct invokation! (see below)
#
# The user interface script in a shiny application
#
# Remember to run it with: runApp() in the dir where ui.R and server.R are defined.
library(shiny)

# The basic code
shinyUI(pageWithSidebar(
    headerPanel("Evaluating Classifiers with the Entropy Triangle"),
    sidebarPanel(
        h3("A bit of theory")
        ),
    mainPanel(
        h3("Evaluate a classifier")
        )
))