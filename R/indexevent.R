#' Adjust association statistics for index event bias
#'
#' Given effect sizes and standard errors for predictors of an index trait and a subsequent trait,
#' this function adjusts the statistics for the subsequent trait for selection bias through the index trait.
#'
#' Effect sizes are on a linear scale, so could be the coefficients from linear regression, or log odds ratios, or log hazard ratios.
#' Effects on the subsequent trait are regressed on the effects on the index trait.
#' By default, the regression is weighted by the inverse variances of the subsequent trait effects.
#' The regression is adjusted for sampling variation in the index trait effects,
#' and the residuals then used to obtain adjusted effect sizes and standard errors for the subsequent trait.
#'
#' The regression should be performed on a subset of predictors that are independent.
#' In the context of a genome-wide association study, these would be LD-pruned SNPs.
#' In terms of the input parameters, the regression command is \code{lm(ybeta[prune]~xbeta[prune],weights=1/yse[prune]^2)}.
#'
#' The effects in \code{xbeta} and \code{ybeta} should be aligned for the same variables
#' and the same direction prior to running \code{indexevent}.
#'
#' The default value of \code{B} is 10 to get a quick result, but higher values are recommended, eg 1000.

#' @param xbeta Vector of effects on the index trait
#' @param xse Vector of standard errors of \code{xbeta}
#' @param ybeta Vector of effects on the subsequent trait
#' @param yse Vector of standard errors of \code{ybeta}
#' @param weighted If true (default), regression of \code{ybeta} on \code{xbeta} is weighted by the inverse of \code{yse^2}.
#' @param prune Vector containing the indices of an approximately independent subset of the predictors in \code{xbeta} and \code{ybeta}.
#' If unspecified, all predictors will be used.
#' @param method Method to adjust for regression dilution (weak instruments) in the regression of \code{ybeta[prune]} on \code{xbeta[prune]}.
#' "CWLS" (default) applies Corrected Weighted Least Squares from Cai et al (2022).
#' "Hedges-Olkin" applies the correction from Dudbridge et al (2019), equivalent to CWLS for unweighted regression.
#' "Simex" applies a more time-consuming correction which may be more accurate than CWLS.
#' @param B Number of simulations performed in each stage of the Simex adjustment.
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
#' Cai S, Hartley A, Mahmoud O, Tilling K, Dudbridge F (2022) Adjusting for collider bias in genetic association studies using instrumental variable methods. Genetic Epidemiol 46:303-316
#'
#' Dudbridge F, Allen RJ, Sheehan NA, Schmidt AF, Lee JC, Jenkins RG, Wain LV, Hingorani AD, Patel RS (2019) Adjustment for index event bias in genome-wide association studies of subsequent events.  Nat Commun 10:1561
#'
#' @export
indexevent = function (xbeta,
                       xse,
                       ybeta,
                       yse,
                       weighted=T,
                       prune=NULL,
                       method=c("CWLS","Hedges-Olkin","Simex"),
                       tol=1e-6,
                       B=10,
                       lambda=seq(0.25,5,0.25),
                       seed=2018) {

  if (is.null(prune)) prune = 1:length(xbeta)

  # regression of ybeta on xbeta
  xbetaprune=xbeta[prune]
  xseprune=xse[prune]
  ybetaprune=ybeta[prune]
  yseprune=yse[prune]
  if (weighted) weight = 1/yseprune^2
  else weight = rep(1,length(prune))

  fit = lm(ybetaprune~xbetaprune,weights=weight)
  b.raw = as.numeric(fit$coef[2])
  b.se = sqrt(as.numeric(vcov(fit)[2,2]))

# Corrected weighted least squares
  if (startsWith("cwls",tolower(method[1]))) {
    sumWeight = sum(weight)
    cwls.numer = sumWeight * sum(weight*xbetaprune*ybetaprune) - sum(weight*xbetaprune)*sum(weight*ybetaprune)
    cwls.denom = sumWeight * sum(weight*xbetaprune^2) - sum(weight*xbetaprune)^2 - sumWeight*sum(weight*xseprune^2)
    b = cwls.numer / cwls.denom
    b.ci = c(b-qnorm(0.975)*b.se*b/b.raw, b+qnorm(0.975)*b.se*b/b.raw)
    simex.estimates = NULL
  }

  # Hedges-Olkin adjustment
  if (startsWith("hedges-olkin",tolower(method[1]))) {
    hedgesOlkin = var(xbetaprune) / (var(xbetaprune) - mean(xseprune^2))
    b = b.raw * hedgesOlkin
    #b.ci = rep(b,2)
    b.ci = c(b-qnorm(0.975)*b.se*hedgesOlkin, b+qnorm(0.975)*b.se*hedgesOlkin)
    simex.estimates = NULL
  }

  # SIMEX adjustment
  if (startsWith("simex",tolower(method[1]))) {
    set.seed(seed)
    simex.estimates = fit$coef[2]
    simex.variance.sandwich = (sum(weight*xbetaprune)^2*sum(weight*fit$res^2) - 2*sum(weight)*sum(weight*xbetaprune)*sum(weight*xbetaprune*fit$res^2) +
                                            sum(weight)^2*sum(weight*xbetaprune^2*fit$res^2)) /
      (sum(weight)*sum(weight*xbetaprune^2)-sum(weight*xbetaprune)^2)^2
    progress = txtProgressBar(max=B*length(lambda),width=10,style=3)
    for(l in 1:length(lambda)) {
      simexcoef=rep(0,B)
      for(iter in 1:B) {
        simexdata = rnorm(length(xbetaprune), mean=xbetaprune, sd=xseprune*sqrt(lambda[l]))
        simexfit = lm(ybetaprune~simexdata,weights=weight)
        simexcoef[iter] = simexfit$coef[2]
        setTxtProgressBar(progress,(l-1)*B+iter)
      }
      simex.estimates = c(simex.estimates, mean(simexcoef))
      svar=(sum(weight*simexdata)^2*sum(weight*simexfit$res^2) - 2*sum(weight)*sum(weight*simexdata)*sum(weight*simexdata*simexfit$res^2) +
              sum(weight)^2*sum(weight*simexdata^2*simexfit$res^2)) /
        (sum(weight)*sum(weight*simexdata^2)-sum(weight*simexdata)^2)^2
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
