#' Profile likelihood confidence interval for SIMEX
#'
#' Obtains a maximum likelihood estimate of the slope in a simple linear regression model
#' with measurement error in the predictor, using the SIMEX method.
#'
#' \code{simex.estimates} is a matrix with three columns.
#' Column 1 contains the values of lambda under which measurement error is simulated.
#' Column 2 contains the estimated slopes for each value of lambda.
#' Column 3 contains the sampling variances of the estimated slopes.
#'
#' The likelihood is a profile likelihood for the true regression slope, with the profile taken over a nuisance
#' parameter representing the ratio of the sampling variance to the variance of the true predictors.
#' The profiling step requires a value for the \code{variance.ratio}.
#'
#' @param simex.estimates Matrix containing data simulated by SIMEX.
#' @param variance.ratio Ratio of the variance of the predictor to the variance of the outcome.
#'
#' @return A vector with three elements, the estimated slope and its lower and upper 95\% confidence limits.
#'
#' @export
simexprofileCI = function(simex.estimates, variance.ratio) {

  profileFit = optimise(simexprofilellhd, c(-100,100), simex.estimates, variance.ratio)

  obj = function(p) (2*(simexprofilellhd(p, simex.estimates, variance.ratio) - profileFit$obj) - qchisq(.95,1))^2

  lowerCI = optimise(obj,c(-100,profileFit$min))$min
  upperCI = optimise(obj,c(profileFit$min,100))$min

  c(profileFit$min, lowerCI, upperCI)
}
