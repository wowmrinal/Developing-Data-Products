rm(list=ls())

# Function to calcualte the optimal portfolio
# This file uses the solve.QP function in the quadprog package to solve for the efficient frontier.
# Since the efficient frontier is a parabolic function, we can find the solution
# that minimizes portfolio variance and then vary the risk premium to find
# points along the efficient frontier. Then simply find the portfolio with the
# largest Sharpe ratio (expected return / sd) to identify the most efficient portfolio
library(stockPortfolio)
library(quadprog)
library(reshape2)
library(ggplot2)
library(shiny)

# Create the portfolio using ETFs, incl. hypothetical non-efficient allocation
stocks <- c( "GOLDBEES.NS" = .0,"HNGSNGBEES.BO" = .0, "KOTAKNIFTY.BO" = .0, "LICNMFET.NS" = .10,"LIQUIDBEES.BO" = .30,
             "M100.BO" = .20, "N100.NS" = .20, "RELCONS.NS" = .10, "RELDIVOPP.NS" = .10)

# Retrieve returns, from earliest start date possible (where all stocks have data) through most recent date
returns <- getReturns(names(stocks), freq="daily") 

#### Efficient Frontier function ####
eff.frontier <- function (returns, short="no", max.allocation=NULL, risk.premium.up=1, 
                          risk.increment=.005){
  # return argument should be a m x n matrix with one column per security
  # short argument is whether short-selling is allowed; default is no (short selling prohibited)
  # max.allocation is the maximum % allowed for any one security (reduces concentration) 
  # risk.premium.up is the upper limit of the risk premium modeled (see for loop below) and 
  # risk.increment is the increment (by) value used in the for loop
  # ret_series <- returns[[1]] # The 1st element in the structure contains the returns series
  covariance <- cov(returns)
  #print(covariance)
  n <- ncol(covariance)
  
  # Create initial Amat and bvec assuming only equality constraint
  # (short-selling is allowed, no allocation constraints)
  Amat <- matrix (1, nrow=n)
  bvec <- 1
  meq <- 1
  
  # Then modify the Amat and bvec if short-selling is prohibited
  if(short=="no"){
    Amat <- cbind(1, diag(n))
    bvec <- c(bvec, rep(0, n))
  }
  
  # And modify Amat and bvec if a max allocation (concentration) is specified
  if(!is.null(max.allocation)){
    if(max.allocation > 1 | max.allocation <0){
      stop("max.allocation must be greater than 0 and less than 1")
    }
    if(max.allocation * n < 1){
      stop("Need to set max.allocation higher; not enough assets to add to 1")
    }
    Amat <- cbind(Amat, -diag(n))
    bvec <- c(bvec, rep(-max.allocation, n))
  }
  # Calculate the number of loops
  loops <- risk.premium.up / risk.increment+1
  loop <- 1
  
  # Initialize a matrix to contain allocation and statistics
  # This is not necessary, but speeds up processing and uses less memory
  eff <- matrix(nrow=loops, ncol=n+4)
  # Now I need to give the matrix column names
  # The second element of the returns array contaains the names of the asset classes
  colnames(eff) <- c(colnames(returns), "Std.Dev", "Exp.Return", "sharpe", "Risk.Premium")
  
  
  # Loop through the quadratic program solver
  for (i in seq(from=0, to=risk.premium.up, by=risk.increment)){
    dvec <- colMeans(returns)*i # This moves the solution along the EF
    sol <- solve.QP(Dmat=covariance, dvec=dvec, Amat=Amat, bvec=bvec, meq=meq)
    sol$solution <- zapsmall(sol$solution)
    eff[loop,"Std.Dev"] <- sqrt(sum(sol$solution*colSums((covariance*sol$solution))))
    eff[loop,"Exp.Return"] <- as.numeric(sol$solution %*% colMeans(returns))
    eff[loop,"sharpe"] <- eff[loop,"Exp.Return"] / eff[loop,"Std.Dev"]
    eff[loop,"Risk.Premium"] <- i
    eff[loop,1:n] <- sol$solution
    loop <- loop+1
  }
  return(as.data.frame(eff))
}

eff.frontier.plot <- function(eff, eff.optimal.point) { 
  # graph efficient frontier
  # Start with color scheme
  ealred <- "#7D110C"
  ealtan <- "#CDC4B6"
  eallighttan <- "#F7F6F0"
  ealdark <- "#423C30"
  ggplot(eff, aes(x=Std.Dev, y=Exp.Return)) + geom_point(alpha=.1, color=ealdark) + 
    coord_cartesian(xlim = c(0,0.05),ylim = c(0,0.01)) +
    geom_point(data=eff.optimal.point, aes(x=Std.Dev, y=Exp.Return, label=sharpe),color=ealred, size=5) +
    annotate(geom="text", x=eff.optimal.point$Std.Dev,
             y=eff.optimal.point$Exp.Return,
             label=paste("Risk: ",
                         round(eff.optimal.point$Std.Dev*100, digits=3),"\nReturn: ",
                         round(eff.optimal.point$Exp.Return*100, digits=4),"%\nSharpe: ",
                         round(eff.optimal.point$sharpe*100, digits=2), "%", sep=""),
             hjust=0, vjust=1) +
    ggtitle("Efficient Frontier\nand Optimal Portfolio") +
    labs(x="Risk (standard deviation of portfolio)", y="Return") +
    theme(panel.background=element_rect(fill=eallighttan),
          text=element_text(color=ealdark),
          plot.title=element_text(size=24, color=ealred))
}




shinyServer( 
  function(input,output) { 
    
    # Run the eff.frontier function based on no short and 30% alloc. restrictions
    eff <- reactive({
      eff.frontier(returns=returns$R, short="no", max.allocation=0.3, 
                        risk.premium.up=1, risk.increment=.001)
      })
    
    # Find the optimal portfolio
    eff.optimal.point <- reactive({
      eff()[eff()$Risk.Premium==input$Risk.Premium,]
      })
    #output$text1 <- renderPrint({eff.optimal.point()})
    
    # Plot the efficient frontier
    eff.frontier.plot(eff,eff.optimal.point)
  }
)
    
