# Requires R/models-dsir.R to be sourced first (dsir_hazard_sir).
# Algorithm: one-window linear incidence guide and its importance weight
# Source: Source papers/4992336VoR.pdf, Section 3.4, display after (18),
#         equations (12), (14) and (16), Algorithm 1 step 2 with h replaced
#         by h*, Algorithm 2 step 2.
#         Scalar form and the zero-weight rule: Sparse bridge/notes/05-theory-notes.md,
#         Section 5.1. That note records why the column and the printed row agree
#         for this SIR model.
#         ESS: Golightly and Sherlock (2019), Section 5.2, as named in the theory note.
#         PDF: Sparse bridge/Literature/Golightly2019-conditioned-markov-jump.pdf.
# Symbols:
#   h              unconditioned hazard       h_inf, h_rem
#   h*             conditioned hazard         h_star_inf, h_star_rem
#   mu_hat         mean used in the variance  mu_hat
#   sigma^2        binomial variance (14)     sigma2
#   y              observation in the window  y
#   q              Poisson proposal product   log_q
#   w              unnormalised weight        log_w
#   ESS            effective sample size      ess

# One evaluation of the scalar SIR form of the display after (18).
# h*_inf = h_inf + rho * h_inf * (y - mu_hat) / denom
# h*_rem = h_rem
# mu_hat = rho * (n_past + h_inf * remaining)
# denom = rho^2 * h_inf * remaining + sigma^2
# sigma^2 = (1 - rho) * mu_hat     binomial (14), with mu replaced by mu_hat
dsir_conditioned_hazard_sir <- function(h_inf, h_rem, n_past, remaining, y, rho) {
  mu_hat <- rho * (n_past + h_inf * remaining)
  sigma2 <- (1 - rho) * mu_hat
  denom <- (rho^2) * h_inf * remaining + sigma2
  if (!is.finite(denom) || denom == 0) {
    h_star_inf <- NA_real_
    h_star_rem <- NA_real_
  } else {
    h_star_inf <- h_inf + rho * h_inf * (y - mu_hat) / denom
    h_star_rem <- h_rem
  }
  list(
    h_star_inf = h_star_inf,
    h_star_rem = h_star_rem,
    mu_hat = mu_hat,
    sigma2 = sigma2,
    denom = denom
  )
}

# ESS(w) = (sum w_i)^2 / (sum w_i^2), zeros included.
# Stable form: m = max log w over finite weights, u_i = exp(log w_i - m),
# and a non-finite log weight (the zero weight) contributes u_i = 0.
# ESS = (sum u)^2 / (sum u^2). The shift m cancels in this ratio.
# If every weight is zero the formula is undefined; return 0, as the theory note states.
dsir_ess_from_log_weights <- function(log_w) {
  finite <- is.finite(log_w)
  if (!any(finite)) {
    return(0)
  }
  m <- max(log_w[finite])
  u <- rep(0, length(log_w))
  u[finite] <- exp(log_w[finite] - m)
  sum_u <- sum(u)
  sum_u2 <- sum(u * u)
  (sum_u * sum_u) / sum_u2
}

# ESS on the finite weights only. Missing if there is none.
dsir_ess_valid_only <- function(log_w) {
  finite <- is.finite(log_w)
  if (!any(finite)) {
    return(NA_real_)
  }
  dsir_ess_from_log_weights(log_w[finite])
}

# N_prop incidence paths on one window.
# guide = "linear" uses h*. guide = "myopic" uses h. The weight is Algorithm 2, step 2.
# beta_left[j] is log contact rate at substep j-1, supplied by the caller.
# The function does not draw the contact rate and does not set a seed.
dsir_window_weights <- function(s0, i0, beta_left, gamma, rho, y,
                               delta_tau, n_prop, guide) {
  m <- length(beta_left)
  log_w <- rep(-Inf, n_prop)
  n_invalid <- 0
  for (draw in seq_len(n_prop)) {
    s <- s0
    i <- i0
    n_past <- 0
    log_pi <- 0
    log_q <- 0
    invalid <- FALSE
    # Paper index j = 0, ..., m-1. R index on beta_left is j+1.
    for (j in 0:(m - 1)) {
      remaining <- (m - j) * delta_tau
      # Unconditioned hazard at the left endpoint. Algorithm 1, step 1.
      h <- dsir_hazard_sir(s, i, beta_left[j + 1], gamma)
      # Conditioned hazard, display after (18), scalar SIR form.
      # Skipped for the myopic guide, which proposes at h.
      if (guide == "linear") {
        h_star <- dsir_conditioned_hazard_sir(
          h$h_inf, h$h_rem, n_past, remaining, y, rho
        )
        rate_inf <- h_star$h_star_inf * delta_tau
        rate_rem <- h_star$h_star_rem * delta_tau
      } else {
        rate_inf <- h$h_inf * delta_tau
        rate_rem <- h$h_rem * delta_tau
      }
      pi_rate_inf <- h$h_inf * delta_tau
      pi_rate_rem <- h$h_rem * delta_tau
      if (!is.finite(rate_inf) || !is.finite(rate_rem) ||
          rate_inf < 0 || rate_rem < 0 ||
          !is.finite(pi_rate_inf) || !is.finite(pi_rate_rem) ||
          pi_rate_inf < 0 || pi_rate_rem < 0) {
        invalid <- TRUE
        break
      }
      # Algorithm 1, step 2, at the guide's rates. Step Delta tau.
      dn_inf <- rpois(1, rate_inf)
      dn_rem <- rpois(1, rate_rem)
      if (!is.finite(dn_inf) || !is.finite(dn_rem)) {
        invalid <- TRUE
        break
      }
      # log q: product of Poisson PMFs at the rates that were sampled.
      # log pi: the same increments at the unconditioned rates.
      # Myopic guide: the two rates agree, so log q = log pi and the ratio is 1.
      log_pi <- log_pi + dpois(dn_inf, pi_rate_inf, log = TRUE) +
        dpois(dn_rem, pi_rate_rem, log = TRUE)
      if (guide == "myopic") {
        log_q <- log_pi
      } else {
        log_q <- log_q + dpois(dn_inf, rate_inf, log = TRUE) +
          dpois(dn_rem, rate_rem, log = TRUE)
      }
      s_new <- s - dn_inf
      i_new <- i + dn_inf - dn_rem
      if (s_new < 0 || i_new < 0) {
        invalid <- TRUE
        break
      }
      s <- s_new
      i <- i_new
      n_past <- n_past + dn_inf
    }
    if (invalid) {
      n_invalid <- n_invalid + 1
      log_w[draw] <- -Inf
    } else {
      # Algorithm 2, step 2, one window.
      # log w = log pi(path) + log Bin(y | n_past, rho) - log q
      log_obs <- dbinom(y, size = n_past, prob = rho, log = TRUE)
      log_w[draw] <- log_pi + log_obs - log_q
    }
  }
  list(log_w = log_w, n_invalid = n_invalid)
}
