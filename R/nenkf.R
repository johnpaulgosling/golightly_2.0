# Algorithm: nested ensemble Kalman filter for the scalar Ornstein-Uhlenbeck model
# Source: Source papers/5417950VOR.pdf, Algorithm 3, Algorithm 6,
#         equations (8), (9), (13), (18), Section 4.1 and Section 4.2.
#         Extensions call the functions in R/nenkf-knn-tree.R,
#         R/nenkf-adaptive-kernel.R, R/nenkf-gradient-move.R,
#         R/nenkf-surrogate-weight.R and R/nenkf-rb.R, which cite
#         notes/05-theory-notes.md.
# Symbols:
#   theta^i     parameter particle i              theta[i, ]
#   x_t^{i,j}   analysis ensemble member          x[i, j]
#   u_t^i       normalised weight                 w[i]
#   N           ensemble size                     N
#   M           number of parameter particles     M
#   gamma       ESS fraction                      gamma

# One ensemble Kalman step with stored standard normal draws.
# Algorithm A in notes/05-theory-notes.md.
# forecast_z and pseudo_z are length-N standard normals.
enkf_step_replay <- function(x_prev, theta, y_t, dt, R, forecast_z, pseudo_z, counter) {
  n <- length(x_prev)
  x_tilde <- numeric(n)
  for (j in 1:n) {
    mv <- ou_mean_var(x_prev[j], theta, dt)
    # Step 1. Forecast draw, Section 5.1 transition, common random number forecast_z[j]
    x_tilde[j] <- mv$mean + sqrt(mv$var) * forecast_z[j]
    counter$n_trans <- counter$n_trans + 1
  }
  # Step 2. Forecast moments, equation (9), divisor N - 1
  mu <- sum(x_tilde) / n
  s2 <- sum((x_tilde - mu)^2) / (n - 1)
  if (!is.finite(s2) || s2 < 0) {
    s2 <- 0
  }
  # Step 3. Likelihood contribution, equation (13), H = 1
  pred_var <- s2 + R
  log_inc <- dnorm(y_t, mu, sqrt(pred_var), log = TRUE)
  # Step 4. Gain
  K <- s2 / pred_var
  x_new <- numeric(n)
  for (j in 1:n) {
    # Step 5. Stochastic analysis update
    y_pseudo <- x_tilde[j] + sqrt(R) * pseudo_z[j]
    x_new[j] <- x_tilde[j] + K * (y_t - y_pseudo)
  }
  list(x = x_new, log_inc = log_inc)
}

# Fresh noise for one time step, then the step.
enkf_step_fresh <- function(x_prev, theta, y_t, dt, R, counter) {
  n <- length(x_prev)
  forecast_z <- rnorm(n)
  pseudo_z <- rnorm(n)
  step <- enkf_step_replay(x_prev, theta, y_t, dt, R, forecast_z, pseudo_z, counter)
  step$noise <- list(forecast = forecast_z, pseudo = pseudo_z)
  step
}

# Replay a whole path with a stored noise bank. Returns the log-likelihood
# and the terminal analysis ensemble.
enkf_path_replay <- function(theta, y, x0, noise, dt, R, counter) {
  if (any(!is.finite(theta)) || any(theta <= 0)) {
    return(list(log_lik = -Inf, x = rep(x0, length(noise[[1]]$forecast))))
  }
  n <- length(noise[[1]]$forecast)
  x <- rep(x0, n)
  log_lik <- 0
  for (t in seq_along(y)) {
    step <- enkf_step_replay(
      x, theta, y[t], dt, R,
      noise[[t]]$forecast, noise[[t]]$pseudo, counter
    )
    x <- step$x
    log_lik <- log_lik + step$log_inc
  }
  list(log_lik = log_lik, x = x)
}

# Draw a new noise bank and evaluate the path. Used by a Metropolis-Hastings proposal.
# If rb is TRUE, the returned log-likelihood is the sum of the weights (24)
# rather than the sum of the ensemble Kalman contributions (13).
enkf_path_fresh <- function(theta, y, x0, N, dt, R_g, counter, rb = FALSE, R_f = NULL) {
  if (any(!is.finite(theta)) || any(theta <= 0)) {
    return(list(log_lik = -Inf, x = rep(x0, N), noise = list()))
  }
  x <- rep(x0, N)
  log_lik <- 0
  noise <- vector("list", length(y))
  for (t in seq_along(y)) {
    step <- enkf_step_fresh(x, theta, y[t], dt, R_g, counter)
    x <- step$x
    if (rb) {
      # Algorithm D at this time step
      log_inc <- rb_log_increment(y[t], step$x, step$log_inc, R_f, R_g)
    } else {
      log_inc <- step$log_inc
    }
    log_lik <- log_lik + log_inc
    noise[[t]] <- step$noise
  }
  list(log_lik = log_lik, x = x, noise = noise)
}

# Sample covariance of the rows of `others`, scaled by zeta2.
# Divisor n - 1. Diagonal jitter if the matrix is not positive definite.
# notes/06-simulation-design.md.
proposal_covariance <- function(theta_mat, i, zeta2) {
  others <- theta_mat[-i, , drop = FALSE]
  d <- ncol(theta_mat)
  if (nrow(others) < 2) {
    v <- diag(d)
  } else if (d == 1) {
    v <- matrix(stats::var(others[, 1]), 1, 1)
  } else {
    v <- stats::var(others)
  }
  v <- as.matrix(v)
  ev <- eigen(v, symmetric = TRUE, only.values = TRUE)$values
  if (any(!is.finite(ev)) || any(ev <= 1e-10)) {
    diag(v) <- diag(v) + 1e-4
  }
  # zeta^2 * V_t^{(-i)}, Section 4.1
  zeta2 * v
}

draw_random_walk <- function(theta, cov_mat) {
  d <- length(theta)
  z <- rnorm(d)
  # epsilon ~ N(0, zeta V), Section 4.1
  # chol needs a positive definite matrix. The design's diagonal jitter
  # is repeated until that holds.
  jitter <- 0
  repeat {
    trial <- cov_mat
    diag(trial) <- diag(trial) + jitter
    chol_try <- try(chol(trial), silent = TRUE)
    if (!inherits(chol_try, "try-error")) {
      eps <- t(chol_try) %*% z
      return(theta + as.numeric(eps))
    }
    jitter <- if (jitter == 0) 1e-4 else jitter * 10
  }
}

# Log-sum-exp normaliser. Stable form of log(sum(exp(log_w))).
log_sum_exp <- function(log_w) {
  m <- max(log_w)
  m + log(sum(exp(log_w - m)))
}

# Neighbour search used by delayed acceptance, with the S1 comparison.
# points are already standardised log-parameters. stored_log aligns with rows.
da_surrogate <- function(query, points, stored_log, k, counter, compare) {
  lin <- knn_linear(query, points, k)
  surr <- knn_surrogate_log(lin$dist, stored_log[lin$index])
  if (compare) {
    tree <- knn_tree(query, points, k)
    counter$list_dists <- counter$list_dists + lin$n_dist
    counter$tree_dists <- counter$tree_dists + tree$n_dist
    counter$knn_checks <- counter$knn_checks + 1
    same <- identical(sort(lin$index), sort(tree$index))
    if (same) {
      counter$knn_agree <- counter$knn_agree + 1
    }
  }
  surr
}

# One rejuvenation sweep on the cloud at the observations y[1:t_now].
rejuvenate <- function(state, y, t_now, x0, dt, R_g, R_f, shapes, rates, zeta2,
                       k, move, t_switch, lambda, h_frac, counter) {
  M <- nrow(state$theta)
  N <- ncol(state$x)
  d <- ncol(state$theta)
  kernel <- move
  if (move == "switch") {
    # E2. Choice before any proposal, function of t only.
    kernel <- choose_move_kernel(t_now, t_switch)
  }
  if (move == "gradient") {
    kernel <- "gradient"
  }
  if (move == "surrogate") {
    kernel <- "da"
  }
  if (move == "rb") {
    kernel <- "mh"
  }

  # Reference cloud for a surrogate screen: distinct rows are not required.
  # Delayed acceptance uses every resampled particle, Section 4.2.
  # E4 uses only the first k particles, which were evaluated with the filter.
  if (move == "surrogate") {
    ref <- seq_len(k)
  } else {
    ref <- seq_len(M)
  }
  log_theta_ref <- log(state$theta[ref, , drop = FALSE])
  scaled_ref <- knn_standardise(log_theta_ref)
  compare <- (kernel == "da" && move != "surrogate")

  n_before <- counter$n_trans
  for (i in 1:M) {
    counter$n_prop <- counter$n_prop + 1
    theta_i <- state$theta[i, ]
    log_prior_i <- ou_log_prior(theta_i, shapes, rates)
    cov_i <- proposal_covariance(state$theta, i, zeta2)

    if (kernel == "gradient") {
      # Refresh the ensemble at the current theta so the finite difference
      # and the denominator use one common noise bank.
      refreshed <- enkf_path_fresh(theta_i, y, x0, N, dt, R_g, counter)
      state$log_lik[i] <- refreshed$log_lik
      state$x[i, ] <- refreshed$x
      state$noise[[i]] <- refreshed$noise
      replay_i <- function(th) {
        enkf_path_replay(th, y, x0, refreshed$noise, dt, R_g, counter)$log_lik
      }
      # gradient of this realisation of equation (13); prior gradient omitted
      grad_i <- fd_grad_log_enkf(theta_i, replay_i, h_frac)
      z <- rnorm(d)
      # theta* = theta + (lambda^2 / 2) * grad + lambda * Z
      theta_star <- theta_i + (lambda^2 / 2) * grad_i + lambda * z
    } else {
      theta_star <- draw_random_walk(theta_i, cov_i)
    }

    log_prior_star <- ou_log_prior(theta_star, shapes, rates)
    if (!is.finite(log_prior_star)) {
      next
    }

    accepted <- FALSE
    proposed <- NULL

    if (kernel == "mh" || kernel == "gradient") {
      proposed <- enkf_path_fresh(
        theta_star, y, x0, N, dt, R_g, counter,
        rb = (move == "rb"), R_f = R_f
      )
      log_rho <- (log_prior_star - log_prior_i) +
        (proposed$log_lik - state$log_lik[i])
      if (kernel == "gradient") {
        replay_star <- function(th) {
          enkf_path_replay(th, y, x0, proposed$noise, dt, R_g, counter)$log_lik
        }
        grad_star <- fd_grad_log_enkf(theta_star, replay_star, h_frac)
        # log q(theta | theta*) - log q(theta* | theta), both Langevin
        log_rho <- log_rho +
          log_langevin_density(theta_i, theta_star, grad_star, lambda) -
          log_langevin_density(theta_star, theta_i, grad_i, lambda)
      }
      # equation (18). Random walk: proposal ratio is 1.
      if (log(runif(1)) < min(0, log_rho)) {
        accepted <- TRUE
      }
    } else {
      # Delayed acceptance. Algorithm C.
      query <- log(theta_star) / scaled_ref$scale
      surr_star <- da_surrogate(
        query, scaled_ref$scaled, state$log_lik[ref], k, counter, compare
      )
      query_i <- log(theta_i) / scaled_ref$scale
      surr_i <- da_surrogate(
        query_i, scaled_ref$scaled, state$log_lik[ref], k, counter, compare
      )
      # equation (19). Symmetric random walk, so no proposal ratio.
      log_rho1 <- (log_prior_star - log_prior_i) + (surr_star - surr_i)
      counter$n_screen <- counter$n_screen + 1
      if (log(runif(1)) < min(0, log_rho1)) {
        counter$n_screen_acc <- counter$n_screen_acc + 1
        proposed <- enkf_path_fresh(theta_star, y, x0, N, dt, R_g, counter)
        # equation (20)
        log_rho2 <- (proposed$log_lik - state$log_lik[i]) + (surr_i - surr_star)
        if (log(runif(1)) < min(0, log_rho2)) {
          accepted <- TRUE
        }
      }
    }

    if (accepted && !is.null(proposed)) {
      state$theta[i, ] <- theta_star
      state$log_lik[i] <- proposed$log_lik
      state$x[i, ] <- proposed$x
      state$noise[[i]] <- proposed$noise
      counter$n_acc <- counter$n_acc + 1
    }
  }
  counter$n_rejuv_trans <- counter$n_rejuv_trans + (counter$n_trans - n_before)
  state
}

# Nested filter. move is one of mh, da, switch, gradient, surrogate, rb.
# R_g is the observation variance inside the ensemble Kalman filter.
# R_f is the observation variance in the Rao-Blackwellised ratio.
# For every move except rb, R_g is the filter variance and the weight is (13).
nenkf_ou <- function(y, M, N, gamma, k, zeta2, move, x0, dt, R_f, R_g,
                     shapes, rates, t_switch, lambda, h_frac) {
  T <- length(y)
  d <- length(shapes)
  counter <- new.env(parent = emptyenv())
  counter$n_trans <- 0
  counter$n_prop <- 0
  counter$n_acc <- 0
  counter$n_screen <- 0
  counter$n_screen_acc <- 0
  counter$n_rejuv_trans <- 0
  counter$list_dists <- 0
  counter$tree_dists <- 0
  counter$knn_checks <- 0
  counter$knn_agree <- 0
  counter$max_abs_log_diff <- 0

  theta <- matrix(NA_real_, M, d)
  x <- matrix(NA_real_, M, N)
  log_lik <- numeric(M)
  log_w <- numeric(M)
  noise <- vector("list", M)
  for (i in 1:M) {
    # initial draw from the prior
    for (j in 1:d) {
      theta[i, j] <- rgamma(1, shape = shapes[j], rate = rates[j])
    }
    # known initial condition, N copies
    x[i, ] <- x0
    log_lik[i] <- 0
    log_w[i] <- 0
    noise[[i]] <- list()
  }
  state <- list(theta = theta, x = x, log_lik = log_lik, log_w = log_w, noise = noise)

  diag_abs <- numeric(0)

  for (t in 1:T) {
    log_inc <- numeric(M)
    evaluated <- rep(FALSE, M)
    if (move == "surrogate") {
      ref <- seq_len(min(k, M))
    } else {
      ref <- seq_len(M)
    }
    for (i in ref) {
      step <- enkf_step_fresh(state$x[i, ], state$theta[i, ], y[t], dt, R_g, counter)
      state$x[i, ] <- step$x
      state$noise[[i]][[t]] <- step$noise
      log_g <- step$log_inc
      if (move == "rb") {
        # Algorithm D. Weight (24) in place of (13).
        log_inc[i] <- rb_log_increment(y[t], step$x, log_g, R_f, R_g)
        diff <- abs(log_inc[i] - log_g)
        if (diff > counter$max_abs_log_diff) {
          counter$max_abs_log_diff <- diff
        }
      } else {
        log_inc[i] <- log_g
      }
      evaluated[i] <- TRUE
    }
    if (move == "surrogate") {
      for (i in seq_len(M)) {
        if (!evaluated[i]) {
          # E4. Surrogate of the increment from the reference evaluations.
          log_inc[i] <- surrogate_loglik(
            log(state$theta[i, ]),
            log(state$theta[ref, , drop = FALSE]),
            log_inc[ref]
          )
        }
      }
      # Diagnostic store: which non-reference increments were surrogates.
      # Recomputed after the loop over t, at the terminal time only.
      if (t == T) {
        n_diag <- min(8, M - length(ref))
        if (n_diag > 0) {
          diag_id <- ref[length(ref)] + seq_len(n_diag)
          # A side counter so the diagnostic's forecasts are not part of the
          # method's integration count.
          side <- new.env(parent = emptyenv())
          side$n_trans <- 0
          for (i in diag_id) {
            # One fresh ensemble Kalman increment at this theta, equation (13).
            if (t == 1) {
              x_parent <- rep(x0, N)
            } else {
              path <- enkf_path_fresh(
                state$theta[i, ], y[seq_len(t - 1)], x0, N, dt, R_g, side
              )
              x_parent <- path$x
            }
            fresh <- enkf_step_fresh(
              x_parent, state$theta[i, ], y[t], dt, R_g, side
            )
            diag_abs <- c(diag_abs, abs(fresh$log_inc - log_inc[i]))
          }
        }
      }
    }
    for (i in 1:M) {
      # Step 1 of Algorithm B. Multiply the weight and the stored likelihood.
      state$log_w[i] <- state$log_w[i] + log_inc[i]
      state$log_lik[i] <- state$log_lik[i] + log_inc[i]
    }
    # Step 2. Effective sample size (6), from normalised weights.
    log_z <- log_sum_exp(state$log_w)
    w <- exp(state$log_w - log_z)
    ess <- 1 / sum(w^2)
    if (ess < gamma * M) {
      # Step 4. Resample with replacement. Weights become 1/M.
      idx <- sample.int(M, size = M, replace = TRUE, prob = w)
      state$theta <- state$theta[idx, , drop = FALSE]
      state$x <- state$x[idx, , drop = FALSE]
      state$log_lik <- state$log_lik[idx]
      state$noise <- state$noise[idx]
      state$log_w <- rep(-log(M), M)
      if (move == "surrogate") {
        # The screen needs k cumulative ensemble Kalman likelihoods.
        # Resampling can place a surrogate-weighted particle in a reference
        # slot, so those k particles are re-evaluated before the move.
        for (i in seq_len(k)) {
          rebuilt <- enkf_path_fresh(
            state$theta[i, ], y[seq_len(t)], x0, N, dt, R_g, counter
          )
          state$log_lik[i] <- rebuilt$log_lik
          state$x[i, ] <- rebuilt$x
          state$noise[[i]] <- rebuilt$noise
        }
      }
      # Step 5. Move.
      state <- rejuvenate(
        state, y[seq_len(t)], t, x0, dt, R_g, R_f, shapes, rates, zeta2,
        k, move, t_switch, lambda, h_frac, counter
      )
    }
  }

  log_z <- log_sum_exp(state$log_w)
  w <- exp(state$log_w - log_z)
  ess <- 1 / sum(w^2)
  log_theta <- log(state$theta)
  mean_log <- numeric(d)
  for (j in 1:d) {
    # weighted posterior mean of log theta_j
    mean_log[j] <- sum(w * log_theta[, j])
  }
  cost_per <- if (counter$n_acc > 0) {
    counter$n_rejuv_trans / counter$n_acc
  } else {
    NA_real_
  }
  list(
    mean_log_theta = mean_log,
    ess = ess,
    n_trans = counter$n_trans,
    n_prop = counter$n_prop,
    n_acc = counter$n_acc,
    n_screen = counter$n_screen,
    n_screen_acc = counter$n_screen_acc,
    n_rejuv_trans = counter$n_rejuv_trans,
    cost_per_accept = cost_per,
    knn_checks = counter$knn_checks,
    knn_agree = counter$knn_agree,
    list_dists = counter$list_dists,
    tree_dists = counter$tree_dists,
    max_abs_log_diff = counter$max_abs_log_diff,
    diag_median = if (length(diag_abs) == 0) NA_real_ else median(diag_abs)
  )
}

# One ensemble Kalman log-likelihood at a fixed theta, for study S5.
# d independent scalar coordinates, summed. Each uses equation (13).
enkf_loglik_once <- function(theta, y, x0, N, dt, R, counter) {
  if (is.null(dim(y))) {
    return(enkf_path_fresh(theta, y, x0, N, dt, R, counter)$log_lik)
  }
  total <- 0
  for (j in seq_len(ncol(y))) {
    total <- total + enkf_path_fresh(theta, y[, j], x0, N, dt, R, counter)$log_lik
  }
  total
}
