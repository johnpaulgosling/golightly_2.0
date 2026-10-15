# Algorithm: Rao-Blackwellised incremental weight
# Source: Source papers/5417950VOR.pdf, Section 4.3, equation (24).
#         notes/05-theory-notes.md, Algorithm D and Section 5.6.
# Symbols:
#   f          true observation density          R_f
#   g          linear Gaussian approximation     R_g
#   hat g      ensemble Kalman predictive        log_g
#   w_tilde    unnormalised member weight        equation (24)

# log of the average of the weights (24).
# log_g is the log ensemble Kalman predictive likelihood under g.
# x_analysis are the analysis members from Algorithm A run with g.
rb_log_increment <- function(y_t, x_analysis, log_g, R_f, R_g) {
  n <- length(x_analysis)
  log_ratio <- numeric(n)
  for (j in 1:n) {
    # log f(y | x^j) - log g(y | x^j), equation (24)
    log_ratio[j] <- dnorm(y_t, x_analysis[j], sqrt(R_f), log = TRUE) -
      dnorm(y_t, x_analysis[j], sqrt(R_g), log = TRUE)
  }
  # log of the average of the ratios. Stable form of log(mean(exp(log_ratio))).
  m <- max(log_ratio)
  log_mean_ratio <- m + log(sum(exp(log_ratio - m))) - log(n)
  # average of hat g * f/g
  log_g + log_mean_ratio
}
