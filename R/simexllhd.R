#' Log-likelihood for SIMEX data
#'
#' Calculates the log-likelihood in a simple linear regression model
#' with measurement error in the predictor, using the SIMEX method.
#'
#' \code{simex.estimates} is a matrix with three columns.
#' Column 1 contains the values of lambda under which measurement error is simulated.
#' Column 2 contains the estimated slopes for each value of lambda.
#' Column 3 contains the sampling variances of the estimated slopes.
#'
#' The likelihood is a function of two parameters, the true slope of the simple linear regression and a
#' parameter representing the ratio of the sampling variance to the variance of the true predictors.
#' As this parameter must be positive, it is estimated on the log scale.
#'
#' @param pvar Ratio of the sampling variance to the variance of the true predictors, on the log scale.
#' @param pmean Slope of the simple linear regression.
#' @param simex.estimates Matrix containing data simulated by SIMEX.
#'
#' @return Log-likelihood evaluated at \code{pvar} and \code{pmean} for the data in \code{simex.estimates}.


simexllhd = function(pvar, pmean, simex.estimates) {

  betaLambdaMean = pmean/(1+(simex.estimates[,1]+1)*exp(pvar))
  betaLambdaVar = simex.estimates[,3]

  llhd = -sum(dnorm(simex.estimates[,2],mean=betaLambdaMean,sd=sqrt(betaLambdaVar),log=T))
  llhd

}
