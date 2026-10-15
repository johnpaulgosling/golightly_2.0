# Algorithm: finite-difference Langevin proposal, Metropolis-Hastings corrected
# Source: notes/05-theory-notes.md, Section 5.5.
#         The target ratio is equation (18) of Source papers/5417950VOR.pdf.
#         The finite difference is of the ensemble Kalman log-likelihood (13),
#         replayed with common random numbers so that it is one realisation.
# Symbols:
#   theta        current parameter                 theta
#   lambda       drift scale                       lambda
#   h_frac       relative finite-difference step   h_frac
#   Z            standard normal                   z

# Central difference of log hat p_enkf along each coordinate.
# replay(theta) must return the log-likelihood of one fixed noise bank.
fd_grad_log_enkf <- function(theta, replay, h_frac) {
  d <- length(theta)
  g <- numeric(d)
  for (j in 1:d) {
    # h = h_frac * theta_j, reduced so both neighbours stay positive
    h <- h_frac * theta[j]
    if (theta[j] - h <= 0) {
      h <- theta[j] / 2
    }
    theta_plus <- theta
    theta_minus <- theta
    theta_plus[j] <- theta[j] + h
    theta_minus[j] <- theta[j] - h
    # (log p(theta + h e_j) - log p(theta - h e_j)) / (2h)
    log_plus <- replay(theta_plus)
    log_minus <- replay(theta_minus)
    g[j] <- (log_plus - log_minus) / (2 * h)
  }
  g
}

# Gaussian log-density of a Langevin proposal with identity covariance
# scaled by lambda^2. Mean is theta + (lambda^2 / 2) * gradient.
log_langevin_density <- function(destination, origin, grad, lambda) {
  # mean of q(. | origin)
  mean_q <- origin + (lambda^2 / 2) * grad
  # log N(destination; mean_q, lambda^2 I)
  sum(dnorm(destination, mean_q, lambda, log = TRUE))
}
