# Algorithm: nested ensemble Kalman filter for the Lotka-Volterra observation
# Source: Source papers/5417950VOR.pdf, Algorithm 3, Algorithm 6,
#         equations (9), (13) and (18), Section 4.1, Section 4.3 equation (24),
#         Section 5.2 equations (25)-(27).
#         Calls log_sum_exp, proposal_covariance and draw_random_walk in R/nenkf.R.
#         Calls ou_log_prior in R/models-ou.R for the shape-rate prior chosen
#         in the simulation design. Calls the transition in R/models-lv.R.
# Symbols:
#   theta^i     parameter particle i                 theta[i, ]
#   x_t^{i,j}   analysis ensemble member             x[i, j, ]
#   u_t^i       weight                               log_w[i]
#   N           ensemble size                        N
#   M           number of parameter particles        M
#   R_tilde     observation variance inside g        R_tilde
#   R_scale     1 for plain NEnKF, 2 for RB-SMC2     R_scale

# One ensemble Kalman step at an observation time.
# Algorithm A in notes/05-theory-notes.md, with R replaced by R_tilde
# as in Section 5.2. x_prev has one row per ensemble member.
lv_enkf_step <- function(x_prev, theta, y_t, dt_step, n_steps, floor_eps,
                         R_scale, counter) {
  n <- nrow(x_prev)
  x_tilde <- matrix(NA_real_, nrow = n, ncol = 2)
  for (j in seq_len(n)) {
    # Step 1. Forecast. Section 5.2: n_steps Euler-Maruyama draws (26).
    x_tilde[j, ] <- lv_bridge(
      x_prev[j, ], theta, dt_step, n_steps, floor_eps, counter
    )
  }
  failed <- list(
    x = x_prev, log_g = -Inf, R_tilde = NA_real_, mu = c(NA_real_, NA_real_)
  )
  if (any(!is.finite(x_tilde))) {
    return(failed)
  }
  # Step 2. Forecast moments, equation (9), divisor N - 1. H = (1, 0).
  mu <- numeric(2)
  mu[1] <- sum(x_tilde[, 1]) / n
  mu[2] <- sum(x_tilde[, 2]) / n
  xc1 <- x_tilde[, 1] - mu[1]
  xc2 <- x_tilde[, 2] - mu[2]
  sigma <- matrix(0, nrow = 2, ncol = 2)
  sigma[1, 1] <- sum(xc1 * xc1) / (n - 1)
  sigma[1, 2] <- sum(xc1 * xc2) / (n - 1)
  sigma[2, 1] <- sigma[1, 2]
  sigma[2, 2] <- sum(xc2 * xc2) / (n - 1)
  # Section 5.2. Plain filter: R_tilde = H mu. RB-SMC2 scales that by 2.
  R_tilde <- R_scale * mu[1]
  if (!is.finite(R_tilde) || R_tilde <= 0 || !is.finite(sigma[1, 1])) {
    return(failed)
  }
  # Step 3. Likelihood contribution (13): N(y; H mu, H Sigma H' + R_tilde).
  s_yy <- sigma[1, 1] + R_tilde
  if (!is.finite(s_yy) || s_yy <= 0) {
    return(failed)
  }
  log_g <- dnorm(y_t, mean = mu[1], sd = sqrt(s_yy), log = TRUE)
  # Step 4. Gain (12). K is 2 x 1 because H' is the first unit vector.
  K <- sigma[, 1] / s_yy
  x_new <- matrix(NA_real_, nrow = n, ncol = 2)
  for (j in seq_len(n)) {
    # Step 5. Stochastic analysis update, Algorithm 3.
    # y_pseudo ~ N(H x_tilde^j, R_tilde)
    y_pseudo <- x_tilde[j, 1] + sqrt(R_tilde) * rnorm(1)
    x_new[j, ] <- x_tilde[j, ] + K * (y_t - y_pseudo)
    # Floor after the update so the next forecast stays defined.
    # Not Algorithm 3. Design note, 15 October 2026.
    x_new[j, ] <- lv_floor_state(x_new[j, ], floor_eps)
  }
  list(x = x_new, log_g = log_g, R_tilde = R_tilde, mu = mu)
}

# Log of the average of the weights (24).
# log_g is the ensemble Kalman predictive log-likelihood under g.
# f is equation (27). g is N(y; H x^j, R_tilde), Section 5.2.
lv_rb_log_increment <- function(y_t, x_analysis, log_g, R_tilde) {
  n <- nrow(x_analysis)
  log_ratio <- numeric(n)
  for (j in seq_len(n)) {
    # log f(y | x^j) - log g(y | x^j), equation (24)
    log_ratio[j] <- lv_log_f(y_t, x_analysis[j, ]) -
      lv_log_g(y_t, x_analysis[j, ], R_tilde)
  }
  m <- max(log_ratio)
  if (!is.finite(m)) {
    return(-Inf)
  }
  # Stable form of log(mean(exp(log_ratio))).
  log_mean_ratio <- m + log(sum(exp(log_ratio - m))) - log(n)
  # log of the average of hat g * f / g
  log_g + log_mean_ratio
}

# Ensemble Kalman, or Rao-Blackwellised, log-likelihood from the first
# observation through the last entry of y.
# weight is "enkf" for (13) or "rb" for (24).
lv_filter_path <- function(theta, y, x0, N, dt_step, n_steps, floor_eps,
                           R_scale, weight, counter) {
  x <- matrix(x0, nrow = N, ncol = 2, byrow = TRUE)
  if (any(!is.finite(theta)) || any(theta <= 0)) {
    return(list(log_lik = -Inf, x = x))
  }
  log_lik <- 0
  for (t in seq_along(y)) {
    step <- lv_enkf_step(
      x, theta, y[t], dt_step, n_steps, floor_eps, R_scale, counter
    )
    x <- step$x
    if (weight == "rb") {
      # Algorithm D. Weight (24) in place of (13).
      log_inc <- lv_rb_log_increment(y[t], step$x, step$log_g, step$R_tilde)
    } else {
      log_inc <- step$log_g
    }
    log_lik <- log_lik + log_inc
  }
  list(log_lik = log_lik, x = x)
}

# Nested filter, Algorithm B, one Metropolis-Hastings proposal per particle.
# No delayed acceptance and no growth of N. Those omissions are in the
# 15 October 2026 design amendment, not in Algorithm 6.
# shapes and rates are the shape-rate Gamma prior of Section 5.2.
lv_nested_filter <- function(y, M, N, gamma, zeta2, weight, x0, dt_step, n_steps,
                             shapes, rates, floor_eps, R_scale, jitter) {
  n_obs <- length(y)
  d <- length(shapes)
  counter <- new.env(parent = emptyenv())
  counter$n_trans <- 0
  counter$n_floor <- 0
  counter$n_prop <- 0
  counter$n_acc <- 0

  theta <- matrix(NA_real_, nrow = M, ncol = d)
  x <- array(NA_real_, dim = c(M, N, 2))
  log_lik <- numeric(M)
  log_w <- numeric(M)
  for (i in seq_len(M)) {
    # Initial draw from the prior. Section 5.2, shape-rate reading.
    for (j in seq_len(d)) {
      theta[i, j] <- rgamma(1, shape = shapes[j], rate = rates[j])
    }
    for (j in seq_len(N)) {
      # Known initial condition, N copies of x_0.
      x[i, j, ] <- x0
    }
    log_lik[i] <- 0
    log_w[i] <- 0
  }

  for (t in seq_len(n_obs)) {
    y_so_far <- y[seq_len(t)]
    for (i in seq_len(M)) {
      # Step 1 of Algorithm B. One ensemble Kalman step at theta^i.
      x_prev <- x[i, , , drop = TRUE]
      if (N == 1) {
        x_prev <- matrix(x_prev, nrow = 1, ncol = 2)
      }
      step <- lv_enkf_step(
        x_prev, theta[i, ], y[t], dt_step, n_steps, floor_eps, R_scale, counter
      )
      for (j in seq_len(N)) {
        x[i, j, ] <- step$x[j, ]
      }
      if (weight == "rb") {
        log_inc <- lv_rb_log_increment(y[t], step$x, step$log_g, step$R_tilde)
      } else {
        log_inc <- step$log_g
      }
      log_w[i] <- log_w[i] + log_inc
      log_lik[i] <- log_lik[i] + log_inc
    }
    # Step 2. Effective sample size (6).
    if (!any(is.finite(log_w))) {
      break
    }
    log_z <- log_sum_exp(log_w)
    w <- exp(log_w - log_z)
    ess <- 1 / sum(w^2)
    if (ess < gamma * M) {
      # Step 4. Resample with replacement. Weights become 1/M.
      idx <- sample.int(M, size = M, replace = TRUE, prob = w)
      theta <- theta[idx, , drop = FALSE]
      x <- x[idx, , , drop = FALSE]
      log_lik <- log_lik[idx]
      log_w <- rep(-log(M), M)
      # Step 5. One random-walk proposal. Acceptance ratio (18).
      for (i in seq_len(M)) {
        counter$n_prop <- counter$n_prop + 1
        theta_i <- theta[i, ]
        log_prior_i <- ou_log_prior(theta_i, shapes, rates)
        cov_i <- proposal_covariance(theta, i, zeta2, jitter = jitter)
        theta_star <- draw_random_walk(theta_i, cov_i, jitter0 = jitter)
        log_prior_star <- ou_log_prior(theta_star, shapes, rates)
        if (!is.finite(log_prior_star)) {
          next
        }
        proposed <- lv_filter_path(
          theta_star, y_so_far, x0, N, dt_step, n_steps, floor_eps,
          R_scale, weight, counter
        )
        # equation (18). Symmetric random walk: proposal ratio 1.
        log_rho <- (log_prior_star - log_prior_i) +
          (proposed$log_lik - log_lik[i])
        if (is.finite(log_rho) && log(runif(1)) < min(0, log_rho)) {
          theta[i, ] <- theta_star
          log_lik[i] <- proposed$log_lik
          for (j in seq_len(N)) {
            x[i, j, ] <- proposed$x[j, ]
          }
          counter$n_acc <- counter$n_acc + 1
        }
      }
    }
  }

  list(
    theta = theta,
    log_w = log_w,
    n_trans = counter$n_trans,
    n_floor = counter$n_floor,
    n_prop = counter$n_prop,
    n_acc = counter$n_acc
  )
}
