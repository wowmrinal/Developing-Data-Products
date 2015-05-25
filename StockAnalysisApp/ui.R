
# ui.R
# Developing Data Products - Course Project 1

library(shiny)

shinyUI(fluidPage(
  titlePanel("Stock Analysis App"),
  helpText("The StockAnalysisApp is a Shiny Application that accepts a stock ticker symbol
and a date range from the user.  Then it pulls out the details of the stock
from Google Finance Source and provide two stock analysis charts for that
           particular ticker symbol.
           More Information can be found at: "),
  h5("Stock Analysis App Presentation", a("http://rpubs.com/hpariyaram/StockAnalysisApp", href="http://rpubs.com/hpariyaram/StockAnalysisApp")),
  
  fluidRow(
    column(6, 
           h3("Enter Ticker Symbol"),
           helpText("Select a stock to examine. 
                      Information will be collected from Google finance."),
           textInput("symb", "Symbol", "GOOG")
           
           ),
    column(6,
           h3("Enter a Date Range"),
           helpText("Select a date range for 
                      the stock information to be collected from Google finance."),
           dateRangeInput("dates", 
                          "Date range",
                          start = "2014-01-01", 
                          end = as.character(Sys.Date()))
           )    
  ),

fluidRow(
  
    mainPanel(plotOutput("plot1")),
    mainPanel(plotOutput("plot2"))
    )
  )
)