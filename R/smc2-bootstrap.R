# Algorithm: vanilla SMC2 with a bootstrap particle filter
# Source: Source papers/5417950VOR.pdf, Algorithm 1, Algorithm 2,
#         the acceptance probability (7), and Section 5.2.
#         Section 5.2 replaces the propagate step by the Euler-Maruyama
#         transition (26) and sets the weight equal to the observation
#         density (27). That is the bootstrap proposal: q = p.
#         Calls log_sum_exp, proposal_covariance and draw_random_walk in
#         R/nenkf.R, ou_log_prior in R/models-ou.R, and the transition in
#         R/models-lv.R.
# Symbols:
#   theta^i          parameter particle i              theta[i, ]
#   x_t^{i,j}        state particle                    x[i, j, ]
#   w_t^{i,j}        normalised state weight           w_state[i, j]
#   u_t^i            parameter weight                  log_w[i]
#   N                number of state particles         N
#   M                number of parameter particles     M
#   p_hat_t          likelihood increment              log_inc

# Algorithm 1 at one observation time, bootstrap form used in Section 5.2.
# x_prev is N x 2. w_prev is a normalised probability vector of length N.
lv_bootstrap_step <- function(x_prev, w_prev, theta, y_t, dt_step, n_steps,
                              floor_eps, counter) {
  n <- nrow(x_prev)
  x_new <- matrix(NA_real_, nrow = n, ncol = 2)
  log_w <- numeric(n)
  for (j in seq_len(n)) {
    # Step 1 of Algorithm 1. Resample an ancestor index.
    a <- sample.int(n, size = 1, prob = w_prev)
    # Step 2. Propagate. Section 5.2: Euler-Maruyama (26), and q = p.
    x_new[j, ] <- lv_bridge(
      x_prev[a, ], theta, dt_step, n_steps, floor_eps, counter
    )
    # Step 3. Weight. Section 5.2: the weight equals f(y | x^j), equation (27).
    # The transition ratio is 1 because the proposal is the transition.
    log_w[j] <- lv_log_f(y_t, x_new[j, ])
  }
  # Output of Algorithm 1: likelihood estimate (1/N) sum w_tilde.
  # Stable form of log(mean(exp(log_w))).
  m <- max(log_w)
  if (!is.finite(m)) {
    return(list(x = x_new, w = rep(1 / n, n), log_inc = -Inf))
  }
  log_inc <- m + log(sum(exp(log_w - m))) - log(n)
  log_z <- m + log(sum(exp(log_w - m)))
  w <- exp(log_w - log_z)
  list(x = x_new, w = w, log_inc = log_inc)
}

# Product of bootstrap increments from the first observation through y.
lv_bootstrap_path <- function(theta, y, x0, N, dt_step, n_steps, floor_eps,
                              counter) {
  x <- matrix(x0, nrow = N, ncol = 2, byrow = TRUE)
  w <- rep(1 / N, N)
  if (any(!is.finite(theta)) || any(theta <= 0)) {
    return(list(log_lik = -Inf, x = x, w = w))
  }
  log_lik <- 0
  for (t in seq_along(y)) {
    step <- lv_bootstrap_step(
      x, w, theta, y[t], dt_step, n_steps, floor_eps, counter
    )
    x <- step$x
    w <- step$w
    log_lik <- log_lik + step$log_inc
  }
  list(log_lik = log_lik, x = x, w = w)
}

# Algorithm 2 outer recursion. The move is one pseudo-marginal
# Metropolis-Hastings proposal with acceptance probability (7).
# Delayed acceptance is not used. The design amendment records that.
lv_smc2 <- function(y, M, N, gamma, zeta2, x0, dt_step, n_steps,
                    shapes, rates, floor_eps, jitter) {
  n_obs <- length(y)
  d <- length(shapes)
  counter <- new.env(parent = emptyenv())
  counter$n_trans <- 0
  counter$n_floor <- 0
  counter$n_prop <- 0
  counter$n_acc <- 0

  theta <- matrix(NA_real_, nrow = M, ncol = d)
  x <- array(NA_real_, dim = c(M, N, 2))
  w_state <- matrix(1 / N, nrow = M, ncol = N)
  log_lik <- numeric(M)
  log_w <- numeric(M)
  for (i in seq_len(M)) {
    for (j in seq_len(d)) {
      # Initial draw from the prior. Section 5.2, shape-rate reading.
      theta[i, j] <- rgamma(1, shape = shapes[j], rate = rates[j])
    }
    for (j in seq_len(N)) {
      x[i, j, ] <- x0
    }
    log_lik[i] <- 0
    log_w[i] <- 0
  }

  for (t in seq_len(n_obs)) {
    y_so_far <- y[seq_len(t)]
    for (i in seq_len(M)) {
      # Reweight by the bootstrap estimate of p(y_t | y_{0:t-1}), equation (5).
      x_prev <- x[i, , , drop = TRUE]
      if (N == 1) {
        x_prev <- matrix(x_prev, nrow = 1, ncol = 2)
      }
      step <- lv_bootstrap_step(
        x_prev, w_state[i, ], theta[i, ], y[t], dt_step, n_steps,
        floor_eps, counter
      )
      for (j in seq_len(N)) {
        x[i, j, ] <- step$x[j, ]
      }
      w_state[i, ] <- step$w
      log_w[i] <- log_w[i] + step$log_inc
      log_lik[i] <- log_lik[i] + step$log_inc
    }
    if (!any(is.finite(log_w))) {
      break
    }
    # Effective sample size (6).
    log_z <- log_sum_exp(log_w)
    w <- exp(log_w - log_z)
    ess <- 1 / sum(w^2)
    if (ess < gamma * M) {
      idx <- sample.int(M, size = M, replace = TRUE, prob = w)
      theta <- theta[idx, , drop = FALSE]
      x <- x[idx, , , drop = FALSE]
      w_state <- w_state[idx, , drop = FALSE]
      log_lik <- log_lik[idx]
      log_w <- rep(-log(M), M)
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
        # Fresh particle filter at theta*. Numerator of (7).
        proposed <- lv_bootstrap_path(
          theta_star, y_so_far, x0, N, dt_step, n_steps, floor_eps, counter
        )
        # equation (7). Symmetric random walk: the proposal ratio is 1.
        log_rho <- (log_prior_star - log_prior_i) +
          (proposed$log_lik - log_lik[i])
        if (is.finite(log_rho) && log(runif(1)) < min(0, log_rho)) {
          theta[i, ] <- theta_star
          log_lik[i] <- proposed$log_lik
          for (j in seq_len(N)) {
            x[i, j, ] <- proposed$x[j, ]
          }
          w_state[i, ] <- proposed$w
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
