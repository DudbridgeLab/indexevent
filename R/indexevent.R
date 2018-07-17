#' Adjust association statistics for index event bias
#'
#' Given effect sizes and standard errors for predictors of an index trait and a subsequent trait,
#' this function adjusts the statistics for the subsequent trait for selection bias through the index trait.
#'
#' Effect sizes are on a linear scale, so could be the coefficients from linear regression, or log odds ratios, or log hazard ratios.
#' Effects on the subsequent trait are regressed on the effects on the index trait.
#' The regression is adjusted for sampling variation in the index trait effects,
#' and the residuals then used to obtain adjusted effect sizes and standard errors for the subsequent trait.
#' The regression should be performed on a subset of predictors that are independent.
#' In the context of a genome-wide association study, these would be LD-pruned SNPs.
#'
#' @param xbeta Vector of effects on the index trait
#' @param xse Vector of standard errors of \code{xbeta}
#' @param ybeta Vector of effects on the subsequent trait
#' @param yse Vector of standard errors of \code{ybeta}
#' @param prune Vector containing the indices of an approximately independent subset of the predictors in \code{xbeta} and \code{ybeta}.
#' If unspecified, all predictors will be used.
#' @param method Method to adjust for regression dilution in the regression of \code{ybeta[prune]} on \code{xbeta[prune]}.
#' "Hedges-Olkin" applies a quick but approximate correction.
#' "Simex" applies a more time-consuming, but accurate correction with proper allowance for its uncertainty.
#' @param B Number of simulations performed in each stage of the Simex adjustment
#' @param lambda Vector of lambdas for which the Simex simulations are performed.
#' @param seed Random number seed for the Simex adjustment
#'
#' @import stats
#'
#' @return An object of class "indexevent" which contains:
#'   \itemize{
#'     \item{\code{ybeta.adj} Adjusted effects on the subsequent trait}
#'     \item{\code{yse.adj} Adjusted standard errors of \code{ybeta.adj}}
#'     \item{\code{ychisq.adj} Chi-square statistics for \code{(ybeta.adj/yse.adj)^2}}
#'     \item{\code{yp.adj} P-values for \code{ychisq.adj} on 1df}
#'     \item{\code{b} Coefficient of the regression of \code{ybeta[prune]} on \code{xbeta[prune]}, after correction for regression dilution}
#'     \item{\code{b.se} Standard error of \code{b}}
#'     \item{\code{b.ci} Lower and upper confidence limits for \code{b}}
#'     \item{\code{b.raw} Regression coefficient without correction for regression dilution}
#'     \item{\code{simex.estimates} Regression coefficients under simulated measurement error}
#'   }
#'
#' @author Frank Dudbridge
#'
#' @references
#' Dudbridge F et al, Adjustment for index event bias in genome-wide association studies of subsequent events.  Submitted.
#'
#' @export
indexevent = function (xbeta,
                       xse,
                       ybeta,
                       yse,
                       prune,
                       method=c("Hedges-Olkin","Simex"),
                       B=1000,
                       lambda=seq(0.25,5,0.25),
                       seed=2018) {

  #if (is.null(prune)) prune = 1:length(xbeta)

  # regression of ybeta on xbeta
  xbetaprune=xbeta[prune]
  xseprune=xse[prune]
  ybetaprune=ybeta[prune]
  yseprune=yse[prune]

  fit = lm(ybetaprune~xbetaprune)
  b.raw = fit$coef[2]

  # Hedges-Olkin adjustment
  if (startsWith("hedges-olkin",tolower(method[1]))) {
    hedgesOlkin = var(xbetaprune) / (var(xbetaprune) - mean(xseprune^2))
    b = b.raw * hedgesOlkin
    b.ci = rep(b,2)
    simex.estimates = NULL
  }

  # SIMEX adjustment
  if (startsWith("simex",tolower(method[1]))) {
    set.seed(seed)
    simex.estimates = fit$coef[2]
    simex.variance.sandwich = (sum(xbetaprune)^2*sum(fit$res^2) - 2*length(xbetaprune)*sum(xbetaprune)*sum(xbetaprune*fit$res^2) +
                                            length(xbetaprune)^2*sum(xbetaprune^2*fit$res^2)) /
      (length(xbetaprune)*sum(xbetaprune^2)-sum(xbetaprune)^2)^2
    progress = txtProgressBar(max=B*length(lambda),width=10,style=3)
    for(l in 1:length(lambda)) {
      simexcoef=rep(0,B)
      for(iter in 1:B) {
        simexdata = rnorm(length(xbetaprune), mean=xbetaprune, sd=xseprune*sqrt(lambda[l]))
        simexfit = lm(ybetaprune~simexdata)
        simexcoef[iter] = simexfit$coef[2]
        setTxtProgressBar(progress,(l-1)*B+iter)
      }
      simex.estimates = c(simex.estimates, mean(simexcoef))
      svar=(sum(simexdata)^2*sum(simexfit$res^2) - 2*length(simexdata)*sum(simexdata)*sum(simexdata*simexfit$res^2) +
              length(simexdata)^2*sum(simexdata^2*simexfit$res^2)) /
        (length(simexdata)*sum(simexdata^2)-sum(simexdata)^2)^2
      simex.variance.sandwich=c(simex.variance.sandwich,svar/B)
    }
    simex.estimates = cbind(c(0,lambda), simex.estimates, simex.variance.sandwich)
    colnames(simex.estimates) = c("Lambda", "Coefficient", "Variance")
    rownames(simex.estimates) = NULL
    simex.mle = simexprofileCI(simex.estimates, var(xbetaprune)/var(ybetaprune))
    b = simex.mle[1]
    b.ci = simex.mle[2:3]
  }

  # SE of regression coefficient b
  b.se = (b.ci[2] - b.ci[1]) / (2*qnorm(0.975))

  # Adjusted association statistics
  ybeta.adj = ybeta - b*xbeta
  yse.adj = sqrt(yse^2 + b^2*xse^2 + b.se^2*xbeta^2 + b.se^2*xse^2)
  ychisq.adj = (ybeta.adj/yse.adj)^2
  yp.adj = pchisq(ychisq.adj,1,lower=F)

  results = list(ybeta.adj = ybeta.adj,
                 yse.adj = yse.adj,
                 ychisq.adj = ychisq.adj,
                 yp.adj = yp.adj,
                 b = b,
                 b.se = b.se,
                 b.ci = b.ci,
                 b.raw = b.raw,
                 simex.estimates = simex.estimates)
  class(results) = ("indexevent")

  results
}
