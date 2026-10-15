# Algorithm: Lotka-Volterra diffusion and its nonlinear Gaussian observation
# Source: Source papers/5417950VOR.pdf, Section 5.2, equations (25), (26) and (27).
#         The floor on non-positive coordinates is not in those equations.
#         It is the choice in the 15 October 2026 amendment to
#         Kalman extensions/notes/06-simulation-design.md.
# Symbols:
#   X_t        latent prey and predator state     x (length 2)
#   theta      (theta_1, theta_2, theta_3)        theta
#   a          drift in (25)                      a
#   b          diffusion matrix in (25)           b
#   Delta t    Euler step                         dt
#   y          prey observation                   y
#   H          (1, 0)                             implied by using x[1]

# Replace a non-positive coordinate by floor_eps.
# Not equation (26). Design note, 15 October 2026.
lv_floor_state <- function(x, floor_eps) {
  x_out <- x
  if (x_out[1] < floor_eps) {
    x_out[1] <- floor_eps
  }
  if (x_out[2] < floor_eps) {
    x_out[2] <- floor_eps
  }
  x_out
}

# Drift a(X, theta) in equation (25), Section 5.2.
lv_drift <- function(x, theta) {
  x1 <- x[1]
  x2 <- x[2]
  theta1 <- theta[1]
  theta2 <- theta[2]
  theta3 <- theta[3]
  # a = (theta_1 X_1 - theta_2 X_1 X_2, theta_2 X_1 X_2 - theta_3 X_2)
  c(theta1 * x1 - theta2 * x1 * x2, theta2 * x1 * x2 - theta3 * x2)
}

# Diffusion matrix b(X, theta) in equation (25), Section 5.2.
lv_diffusion <- function(x, theta) {
  x1 <- x[1]
  x2 <- x[2]
  theta1 <- theta[1]
  theta2 <- theta[2]
  theta3 <- theta[3]
  b12 <- -theta2 * x1 * x2
  b <- matrix(0, nrow = 2, ncol = 2)
  # b_11 = theta_1 X_1 + theta_2 X_1 X_2
  b[1, 1] <- theta1 * x1 + theta2 * x1 * x2
  b[1, 2] <- b12
  b[2, 1] <- b12
  # b_22 = theta_2 X_1 X_2 + theta_3 X_2
  b[2, 2] <- theta2 * x1 * x2 + theta3 * x2
  b
}

# One Euler-Maruyama draw, equation (26).
# x_new ~ N(x + a dt, b dt).
# counter$n_trans counts model integrations. counter$n_floor counts draws
# whose Gaussian coordinate was not strictly positive before the floor.
lv_euler_step <- function(x, theta, dt, floor_eps, counter = NULL) {
  # The rate functions in (25) are written for positive states.
  x_use <- lv_floor_state(x, floor_eps)
  a <- lv_drift(x_use, theta)
  b <- lv_diffusion(x_use, theta)
  # Covariance of the Gaussian increment in (26) is b * Delta t.
  cov_step <- b * dt
  z <- rnorm(2)
  chol_try <- try(chol(cov_step), silent = TRUE)
  if (inherits(chol_try, "try-error")) {
    # Numerical safeguard, not equation (26). Design note.
    diag(cov_step) <- diag(cov_step) + floor_eps
    chol_try <- chol(cov_step)
  }
  # Lower triangular factor times Z ~ N(0, I_2).
  raw <- x_use + a * dt + as.numeric(t(chol_try) %*% z)
  if (!is.null(counter)) {
    counter$n_trans <- counter$n_trans + 1
    if (raw[1] <= 0 || raw[2] <= 0) {
      counter$n_floor <- counter$n_floor + 1
    }
  }
  lv_floor_state(raw, floor_eps)
}

# Propagate one state across one observation interval.
# Section 5.2: recursive application of (26). The paper uses Delta t = 0.2
# between observations spaced 2 time units apart, hence n_steps = 10
# when those two settings are the ones passed in.
lv_bridge <- function(x, theta, dt_step, n_steps, floor_eps, counter = NULL) {
  if (any(!is.finite(theta)) || any(theta <= 0)) {
    return(c(NA_real_, NA_real_))
  }
  for (s in seq_len(n_steps)) {
    x <- lv_euler_step(x, theta, dt_step, floor_eps, counter)
  }
  x
}

# Log observation density (27): N(y; H x, H x) with H = (1, 0).
# The variance equals the prey component. This is f in Section 4.3.
lv_log_f <- function(y, x) {
  prey <- x[1]
  if (!is.finite(prey) || prey <= 0) {
    return(-Inf)
  }
  # log f(y | x) = log N(y; prey, prey)
  dnorm(y, mean = prey, sd = sqrt(prey), log = TRUE)
}

# Log linear Gaussian approximation g(y | x) = N(y; H x, R_tilde).
# Section 5.2. R_tilde is a scalar from the forecast mean, not H x.
lv_log_g <- function(y, x, R_tilde) {
  prey <- x[1]
  if (!is.finite(prey) || !is.finite(R_tilde) || R_tilde <= 0) {
    return(-Inf)
  }
  dnorm(y, mean = prey, sd = sqrt(R_tilde), log = TRUE)
}

# Synthetic prey series. Section 5.2 generates the latent path with
# Delta t = 10^{-3} and thins by 2000, which spaces observations by 2.
# Predator values are discarded. Prey values are corrupted by (27).
# The caller sets the seed. The seed is not part of the algorithm.
# t_end, dt_fine and thin are arguments so a reduced interval can be used
# without changing (26) or (27).
lv_simulate_prey <- function(theta, x0, t_end, dt_fine, thin, floor_eps) {
  n_steps <- as.integer(round(t_end / dt_fine))
  n_obs <- as.integer(n_steps / thin)
  y <- numeric(n_obs)
  x <- x0
  obs <- 0
  for (s in seq_len(n_steps)) {
    # equation (26) on the fine grid. No filter counter: this is the data.
    x <- lv_euler_step(x, theta, dt_fine, floor_eps, counter = NULL)
    if (s %% thin == 0) {
      obs <- obs + 1
      # equation (27), prey only
      prey <- x[1]
      y[obs] <- rnorm(1, mean = prey, sd = sqrt(prey))
    }
  }
  y
}
