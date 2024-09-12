#' Simulated effects on incidence and prognosis
#'
#' A simulated dataset consisting of regression coefficients on incidence and prognosis, with their standard errors,
#' for 10,000 variables (eg SNPs).  500 variables have effects on incidence only, 500 on prognosis only, and 500 on both.
#' The effects on incidence and prognosis are independent.
#' The estimates are obtained from linear regression in a simulated dataset of 20,000 individuals.
#'
#' @format A data frame with 10,000 rows and 4 variables:
#' \describe{
#'   \item{xbeta}{Regression coefficient on incidence}
#'   \item{xse}{Standard error of xbeta}
#'   \item{ybeta}{Regression coefficient on prognosis}
#'   \item{yse}{Standard error of ybeta}
#' }
#'
#' @examples
#' Default analysis with CWLS
#' indexevent(testData$xbeta,testData$xse,testData$ybeta,testData$yse)
#' # [1] "Coefficient -0.416773273239147"
#' # [1] "Standard error 0.0196993218284169"
#' # [1] "95% CI -0.455383234542707 -0.378163311935586"
#'
#' # Hedges-Olkin adjustment for regression dilution
#' # Equivalent to an unweighted regression with CWLS
#' indexevent(testData$xbeta,testData$xse,testData$ybeta,testData$yse, method="Hedges-Olkin")
#' # [1] "Coefficient -0.441061156526639"
#' # [1] "Standard error 0.0211910391231297"
#' # [1] "95% CI -0.482594830002953 -0.399527483050326"
#'
#' # SIMEX adjustment with 100 simulations for each step
#' indexevent(testData$xbeta,testData$xse,testData$ybeta,testData$yse,method="SIMEX",B=100)
#' # [1] "Coefficient -0.446543628582032"
#' # [1] "Standard error 0.011576233488927"
#' # [1] "95% CI -0.470301533547 -0.424923532117153"
#'
#' # First few unadjusted effects on prognosis
#' testData$ybeta[1:5]
#' # [1]  0.032240  0.057070 -0.006959  0.080460  0.032820
#' # Adjusted effects
#' indexevent(testData$xbeta,testData$xse,testData$ybeta,testData$yse)$ybeta.adj[1:5]
#' # [1]  0.05109482  0.06088181 -0.01446092  0.08931226  0.01435694
"testData"
