---
title: "Implementing the Mean-Variance Algorithm in R"
author: "Mrinal Mishra"
highlighter: highlight.js
job: Indian School of Business
knit: slidify::knit2slides
mode: selfcontained
hitheme: hemisu-light
subtitle: Automated Portfolio Optimizer
framework: io2012
url:
  assets: C:/Users/Rashh/Documents/R/win-library/3.2/slidifyLibraries/assets
widgets: mathjax
---

## Creating the efficient frontier

* Select a list of assets (ETFs) traded on the National Stock Exchange (India)
* Enter the individual's risk aversion to obtain his optimal optimal given the risk return tradeoff
* Invoke the ``` quadprog ``` package to carry out quadratic optimization
* The mathematical form optimized is:

$$ \min -d^Tb + {\lambda \over2} b^TDb $$ 
$$ where A^Tb>=b_0 $$

* Here $d$ and $D$ denote the expected return and variance-covariance matrix respectively. $b$ is the vector of optimal weights obtained.

<script type="text/x-mathjax-config">
   MathJax.Hub.Config({  "HTML-CSS": { minScaleAdjust: 125, availableFonts: [] }  });
</script>

--- 

## Data Sources and User Input   

* Daily returns data is pulled for the following ETFs from Yahoo Finance:

```
## [1] "GOLDBEES.NS"   "HNGSNGBEES.BO" "KOTAKNIFTY.BO" "LICNMFET.NS"  
## [5] "LIQUIDBEES.BO" "M100.BO"       "N100.NS"       "RELCONS.NS"   
## [9] "RELDIVOPP.NS"
```
* The ETFs are:

     High Risk  | Low Risk
  ------------- | -------------
  Goldman Sachs Gold ETF  | R-Shares Dividend ETF
  Kotak Nifty ETF         | LIC Nomura G-Sec Long Term ETF
  R-Shares Consumption ETF| Motilal Midcap ETF
  Motilal NASDAQ 100 ETF  | Goldman Sachs Liquid ETF
  Goldman Sachs Hang Seng ETF |  


----

## Tailoring output for risk preferences

* The user risk premium coefficient is captured using the ``` Risk.Premium ``` variable 
* We subsequently match the value of the risk premium $\lambda$ with the corresponding point on the efficient frontier
* The following function in server.R plots the efficient frontier 

```r
eff.frontier(returns = returns$R, short = "no", max.allocation = 0.3, risk.premium.up = 1, 
    risk.increment = 0.001)
```

---

## Efficient Frontier 

* Expected returns and standard deviation for a user with ``` Risk.Premium=0.25``` is depicted in the graph below

![alt text](C:/Users/Rashh/Documents/Presentation/Efficient Frontier.png)
---
