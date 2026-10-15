# Algorithm: SIR special case of dSEIR forward simulation (Algorithm 1)
# Source: Source papers/4992336VoR.pdf, Algorithm 1 (p. 6), equation (4),
#         equation (2) for the contact-rate step, Section 4.1 for the SIR
#         hazard and the observation (5).
#         SIR drops the exposed class: Section 2, with P' = (1, 0).
# Symbols:
#   s, i           prevalence                 s, i
#   beta_tilde     log contact rate           beta_tilde
#   Delta N_1      infection increment        dn_inf
#   Delta N_3      removal increment          dn_rem
#   gamma          removal rate               gamma
#   lambda         contact-rate precision     lambda
#   Delta t        fine time step             dt
#   rho            reporting probability      rho
#   y              binomial observation       y

# Step 0. SIR hazard at a known state.
# h = (exp(beta_tilde) * s * i, gamma * i)'
# The middle SEIR component is absent. Algorithm 1, step 1, with kappa removed.
dsir_hazard_sir <- function(s, i, beta_tilde, gamma) {
  h_inf <- exp(beta_tilde) * s * i
  h_rem <- gamma * i
  list(h_inf = h_inf, h_rem = h_rem)
}

# Algorithm 1 on [0, T] at step dt, SIR, equation (2) for beta_tilde.
# Returns the state at times 0, dt, ..., T and the infection increment on each step.
# A negative count sets invalid = TRUE and stops the path. The caller discards it.
dsir_simulate_sir <- function(s0, i0, beta_tilde0, gamma, lambda, dt, n_step) {
  s <- numeric(n_step + 1)
  i <- numeric(n_step + 1)
  beta_tilde <- numeric(n_step + 1)
  dn_inf <- numeric(n_step)
  s[1] <- s0
  i[1] <- i0
  beta_tilde[1] <- beta_tilde0
  invalid <- FALSE
  # Index j is 1, ..., n_step. Paper index on this step is j-1, time (j-1)*dt.
  for (j in seq_len(n_step)) {
    # Step 1. Hazard at the left endpoint of the step.
    h <- dsir_hazard_sir(s[j], i[j], beta_tilde[j], gamma)
    # Step 2. Poisson incidence increments, then the state update in (4).
    # Delta N_1 ~ Po(h_inf * dt), Delta N_rem ~ Po(h_rem * dt).
    rate_inf <- h$h_inf * dt
    rate_rem <- h$h_rem * dt
    step_dn_inf <- rpois(1, rate_inf)
    step_dn_rem <- rpois(1, rate_rem)
    s_new <- s[j] - step_dn_inf
    i_new <- i[j] + step_dn_inf - step_dn_rem
    if (s_new < 0 || i_new < 0) {
      invalid <- TRUE
      break
    }
    s[j + 1] <- s_new
    i[j + 1] <- i_new
    dn_inf[j] <- step_dn_inf
    # Step 3. Equation (2): beta_tilde <- beta_tilde + lambda^{-1/2} * Delta W,
    # Delta W ~ N(0, dt). Drift a is 0.
    delta_w <- rnorm(1, mean = 0, sd = sqrt(dt))
    beta_tilde[j + 1] <- beta_tilde[j] + (lambda^(-0.5)) * delta_w
  }
  list(
    s = s,
    i = i,
    beta_tilde = beta_tilde,
    dn_inf = dn_inf,
    invalid = invalid,
    dt = dt
  )
}

# One observation window on a simulated path.
# Infections are summed on the fine grid, then Y ~ Bin(n_true, rho), equation (5).
# beta_left holds log contact rate at the left endpoint of each filter substep.
# State index: position k = 1 is time 0. Time t = (k-1)*dt.
dsir_window_from_path <- function(path, t_left, t_right, delta_tau, rho) {
  dt <- path$dt
  left_k <- as.integer(round(t_left / dt))
  right_k <- as.integer(round(t_right / dt))
  # State at t_left is the prevalence the next window starts from.
  s0 <- path$s[left_k + 1]
  i0 <- path$i[left_k + 1]
  # Fine increments on (t_left, t_right] are steps left_k+1, ..., right_k.
  n_true <- sum(path$dn_inf[(left_k + 1):right_k])
  y <- rbinom(1, size = n_true, prob = rho)
  m <- as.integer(round((t_right - t_left) / delta_tau))
  beta_left <- numeric(m)
  fine_per_sub <- as.integer(round(delta_tau / dt))
  for (j in seq_len(m)) {
    # Paper substep index is j-1. Left time is t_left + (j-1)*delta_tau.
    tau_k <- left_k + (j - 1) * fine_per_sub
    beta_left[j] <- path$beta_tilde[tau_k + 1]
  }
  list(
    s0 = s0,
    i0 = i0,
    beta_left = beta_left,
    y = y,
    n_true = n_true,
    t_left = t_left,
    t_right = t_right
  )
}
