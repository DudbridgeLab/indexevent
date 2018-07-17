#' Profile log-likelihood for SIMEX data
#'
#' Calculates the profile log-likelihood of the slope in a simple linear regression model
#' with measurement error in the predictor, using the SIMEX method.
#'
#' \code{simex.estimates} is a matrix with three columns.
#' Column 1 contains the values of lambda under which measurement error is simulated.
#' Column 2 contains the estimated slopes for each value of lambda.
#' Column 3 contains the sampling variances of the estimated slopes.
#'
#' The likelihood is a profile likelihood for the true regression slope, with the profile taken over a nuisance
#' parameter representing the ratio of the sampling variance to the variance of the true predictors.
#' The lower bound for this nuisance parameter depends on \code{p} and \code{variance.ratio}.
#'
#' @param p Slope of the simple linear regression.
#' @param simex.estimates Matrix containing data simulated by SIMEX.
#' @param variance.ratio Ratio of the variance of the predictor to the variance of the outcome.
#'
#' @return Profile log-likelihood evaluated at \code{p} for the data in \code{simex.estimates}.

simexprofilellhd = function(p, simex.estimates, variance.ratio) {

  # lower bound on the nuisance parameter
  lowerbound=(p^2*variance.ratio-1)/(simex.estimates[,1]+1)
  if (min(lowerbound)>0) lowerbound=max(log(lowerbound/(simex.estimates[,1]+1)))

  optimise(simexllhd, c(lowerbound,10), p, simex.estimates)$objective

}
