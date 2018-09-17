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
#' # Default analysis with Hedges-Olkin adjustment for regression dilution
#' # Does not calculate a standard error
#' indexevent(testData$xbeta,testData$xse,testData$ybeta,testData$yse)
#' # [1] "Coefficient -0.441061156526639"
#' # [1] "Standard error 0"
#' # [1] "95% CI -0.441061156526639 -0.441061156526639"
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
#' # [1]  0.05219361  0.06110395 -0.01489810  0.08982814  0.01328099
"testData"
