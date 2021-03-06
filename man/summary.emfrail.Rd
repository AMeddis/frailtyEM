% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.emfrail.R
\name{summary.emfrail}
\alias{summary.emfrail}
\title{Summary for \code{emfrail} objects}
\usage{
\method{summary}{emfrail}(object, lik_ci = TRUE, print_opts = list(coef =
  TRUE, dist = TRUE, fit = TRUE, frailty = TRUE, adj_se = TRUE, verbose_frailty
  = TRUE), ...)
}
\arguments{
\item{object}{An object of class \code{emfrail}}

\item{lik_ci}{Logical. Should the confidence intervals for the frailty parameter be calculated based on the likelihood? If not, they are calculated with the delta method.}

\item{print_opts}{A list with options for printing the summary object. These include \code{coef}, \code{dist}, \code{fit}, \code{frailty}, \code{adj_se}, \code{verbose_frailty}.}

\item{...}{Ignored}
}
\value{
An object of class \code{emfrail_summary},
with some more human-readable results from an \code{emfrail} object.
}
\description{
Summary for \code{emfrail} objects
}
\details{
Regardless of
the fitted model, the following fields will be present in this object: \code{est_dist} (an object of class \code{emfrail_distribution}) with the estimated
distribution, \code{loglik} (a named vector with the log-likelihoods of the no-frailty model, the frailty model,
the likelihood ratio test statistic and the p-value of the one-sided likelihood ratio test), \code{theta} (a named vector with
the estimated value of the parameter \eqn{\theta}, the standard error, and the limits of a 95% cofindence interval) and \code{frail}, which
is a data frame with the following columns: \code{id} (cluster identifier), \code{z} (empirical Bayes frailty estimates), and optional
\code{lower_q} and \code{upper_q} as the 2.5% and 97.5% quantiles of the posterior distribution of the frailties (only for gamma distribution).

For the the PVF or gamma distributions, the field \code{fr_var} contains a transformation of \code{theta} to correspond to the
frailty variance.
The fields \code{pvf_pars} and \code{stable_pars} are for quantities that are calculated only when the distribution is PVF or stable.
If the model contains covariates, the field \code{coefmat} contains the corresponding estimates. The p-values are based on
the adjusted standard errors, if they have been calculated successfully (i.e. if they appear when prining the summary object).
Otherwise, they are based on the regular standard errors.
}
\examples{
data("bladder")
mod_gamma <- emfrail(Surv(start, stop, status) ~ treatment + cluster(id), bladder1)
summary(mod_gamma)
summary(mod_gamma, print_opts = list(frailty_verbose = FALSE))

# plot the Empirical Bayes estimates of the frailty
# easy way:
plot(mod_gamma, type = "hist")

# a fancy graph:
sum_mod <- summary(mod_gamma)
library(dplyr)
library(ggplot2)

# Create a plot just with the points
pl1 <- sum_mod$frail \%>\%
  arrange(z) \%>\%
  mutate(x = 1:n()) \%>\%
  ggplot(aes(x = x, y = z)) +
  geom_point()

# If the quantiles of the posterior distribution are
# known, then error bars can be added:
if(!is.null(sum_mod$frail$lower_q))
  pl1 <- pl1 + geom_errorbar(aes(ymin = lower_q, ymax = upper_q), alpha = 0.5)

pl1

# The plot can be made interactive!
# ggplot2 gives a warning about the "id" aesthetic, just ignore it
pl2 <- sum_mod$frail \%>\%
  arrange(z) \%>\%
  mutate(x = 1:n()) \%>\%
  ggplot(aes(x = x, y = z)) +
  geom_point(aes(id = id))

if(!is.null(sum_mod$z$lower_q))
  pl2 <- pl2 + geom_errorbar(aes(ymin = lower_q, ymax = upper_q, id = id), alpha = 0.5)

library(plotly)
ggplotly(pl2)

# Proportional hazards test
off_z <- log(sum_mod$frail$z)[match(bladder1$id, sum_mod$frail$id)]

zph1 <- cox.zph(coxph(Surv(start, stop, status) ~ treatment + cluster(id), data = bladder1))

# no sign of non-proportionality
zph2 <- cox.zph(coxph(Surv(start, stop, status) ~ treatment + offset(off_z), data = bladder1))

zph2
# the p-values are even larger; the frailty "corrects" for proportionality.
}
\seealso{
\code{\link{predict.emfrail}, \link{plot.emfrail}}
}
