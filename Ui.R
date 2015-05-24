rm(list=ls())
library(shiny)

shinyUI(
  pageWithSidebar(
    headerPanel("Optimal Portfolio for the Indian Market"),
    
    sidebarPanel(
      sliderInput('Risk.Premium','Enter the coefficient of your risk premium',value=1, min=0, max=0.3, step=0.001,)
      #actionButton("goButton", "Go!")
    ),
    mainPanel(
      #verbatimTextOutput("text1"),
      h3("Your optimal portfolio corresponds to the point shown in the graph below"),
      plotOutput("eff.frontier"),
      
      p("We select 9 ETF's traded in the Indian stock exchanges"),
      p("We create an efficient frontier using the asset classes"),
      p("The efficient frontier is created using the Mean Variance optimization technique"),
      p("In R we deploy the", code('quadprog')),
      p("package to recreate the algorithm"),
      p("The optimal point for a user corresponds to his/her chosen risk premium")
    )
  )
)
