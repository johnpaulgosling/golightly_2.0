# Algorithm: scalar Ornstein-Uhlenbeck transition and exact Kalman likelihood
# Source: Source papers/5417950VOR.pdf, Section 5.1.
#         The transition density is the Gaussian solution printed there.
#         The observation model is equation (8) with H = 1 and R = 0.1.
# Symbols:
#   theta     parameter (theta_1, theta_2, theta_3)     theta
#   x         state                                     x
#   y         observation                               y
#   Delta t   time step, 1 in Section 5.1               dt
#   R         observation variance                      R

# Limit of the printed transition as theta_1 -> 0.
# The printed variance has a factor 1/(2 theta_1). The same Gaussian
# transition has mean x and variance theta_3^2 * Delta t in that limit.
ou_mean_var <- function(x, theta, dt) {
  # theta_1, theta_2, theta_3
  a <- theta[1]
  b <- theta[2]
  s <- theta[3]
  if (a <= 0 || s <= 0) {
    return(list(mean = NA_real_, var = NA_real_))
  }
  if (a < 1e-8) {
    # printed mean -> x, printed variance -> s^2 * dt
    m <- x
    v <- s^2 * dt
  } else {
    # Section 5.1: N(x exp(-theta_1 dt) + theta_2 (1 - exp(-theta_1 dt)),
    #              theta_3^2 (1 - exp(-2 theta_1 dt)) / (2 theta_1))
    e1 <- exp(-a * dt)
    m <- x * e1 + b * (1 - e1)
    v <- s^2 * (1 - exp(-2 * a * dt)) / (2 * a)
  }
  list(mean = m, var = v)
}

# Draw one transition. Counts as one model integration.
ou_draw <- function(x, theta, dt) {
  mv <- ou_mean_var(x, theta, dt)
  # x_new ~ p(x_{t+dt} | x, theta), Section 5.1
  rnorm(1, mv$mean, sqrt(mv$var))
}

# Exact observed-data log-likelihood. Kalman filter for the linear
# Gaussian transition and equation (8). Used only as the gold-standard
# target in the design note, not inside the ensemble filter.
ou_exact_log_lik <- function(theta, y, x0, dt, R) {
  if (any(theta <= 0)) {
    return(-Inf)
  }
  # filter mean and variance at time 0: x_0 known
  m <- x0
  v <- 0
  log_p <- 0
  for (t in seq_along(y)) {
    mv <- ou_mean_var(m, theta, dt)
    # forecast mean and variance
    m_pred <- mv$mean
    # law of total variance: transition variance plus propagated filter variance
    e1 <- exp(-theta[1] * dt)
    v_pred <- e1^2 * v + mv$var
    # equation (8): y ~ N(H m, H v H' + R) with H = 1
    s_y <- v_pred + R
    log_p <- log_p + dnorm(y[t], m_pred, sqrt(s_y), log = TRUE)
    # Kalman update
    K <- v_pred / s_y
    m <- m_pred + K * (y[t] - m_pred)
    v <- (1 - K) * v_pred
  }
  log_p
}

# Independent Gamma(shape, rate) prior. Shape-rate is the choice in
# notes/06-simulation-design.md. The PDF writes Gamma(a, b) without
# saying which parameterisation.
ou_log_prior <- function(theta, shapes, rates) {
  if (any(theta <= 0)) {
    return(-Inf)
  }
  # log pi(theta) = sum_i log Gamma(theta_i; a_i, b_i)
  sum(dgamma(theta, shape = shapes, rate = rates, log = TRUE))
}

# One replicate series. Seed is set by the caller, not here.
ou_simulate <- function(theta, x0, T, dt, R) {
  x <- x0
  y <- numeric(T)
  for (t in 1:T) {
    # latent skeleton at integer times, Section 5.1
    x <- ou_draw(x, theta, dt)
    # equation (8)
    y[t] <- rnorm(1, x, sqrt(R))
  }
  y
}

# Gold-standard posterior means of log theta.
# Random walk on log theta, symmetric, so the proposal ratio is 1.
# The target density of z = log theta includes the Jacobian sum(z).
# This is the short chain in notes/06-simulation-design.md, not Algorithm 6.
ou_gold_mean_log <- function(y, x0, dt, R, shapes, rates, n_iter, n_burn, prop_sd) {
  d <- length(shapes)
  z <- log(shapes / rates)
  log_target <- function(z_now) {
    th <- exp(z_now)
    # log pi(theta) + log p(y | theta) + sum(log theta)
    ou_log_prior(th, shapes, rates) +
      ou_exact_log_lik(th, y, x0, dt, R) +
      sum(z_now)
  }
  log_t <- log_target(z)
  draws <- matrix(NA_real_, nrow = n_iter, ncol = d)
  for (iter in 1:n_iter) {
    z_prop <- z + rnorm(d, 0, prop_sd)
    log_prop <- log_target(z_prop)
    # Metropolis-Hastings ratio on z
    if (log(runif(1)) < (log_prop - log_t)) {
      z <- z_prop
      log_t <- log_prop
    }
    draws[iter, ] <- z
  }
  kept <- draws[seq.int(n_burn + 1, n_iter), , drop = FALSE]
  colMeans(kept)
}

# Five independent coordinates, same theta, independent observation noise.
# Used only by study S5. Each coordinate follows Section 5.1.
ou_simulate_vector <- function(theta, x0, T, dt, R, d) {
  y <- matrix(NA_real_, nrow = T, ncol = d)
  for (j in 1:d) {
    y[, j] <- ou_simulate(theta, x0, T, dt, R)
  }
  y
}
