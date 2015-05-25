# server.R

library(quantmod)

shinyServer(function(input, output) {

  output$plot1 <- renderPlot({
    data <- getSymbols(input$symb, src = "google", 
      from = input$dates[1],
      to = input$dates[2],
      auto.assign = FALSE)
     
    chartSeries(data, theme = "white", multi.col=TRUE,
     type = "candles", TA = NULL)
    addMACD()
    
  })
  
  output$plot2 <- renderPlot({
    data <- getSymbols(input$symb, src = "google", 
                       from = input$dates[1],
                       to = input$dates[2],
                       auto.assign = FALSE)
    
    barChart(data, theme="white", multi.col=TRUE)
    addEMA()
  })
  
})