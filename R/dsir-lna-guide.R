# Algorithm: residual incidence guide on one substep
# Source: Sparse bridge/Literature/Golightly2023-incidence-lna.pdf,
#         Section 2.2, equations (4), (6), (8) and (9), and the restart after (19).
#         Sparse bridge/Literature/Whitaker2017-improved-bridge-constructs.pdf,
#         Section 3.1.2, the conditional residual mean rho-hat after (24).
#         Source papers/4992336VoR.pdf, equation (14), for the binomial variance,
#         and p. 12 for q as a product of Poisson PMFs.
# Symbols:
#   eta        incidence ODE path              eta1, eta2
#   V          LNA variance of the residual    v11, v12, v22
#   G          fundamental matrix              g11, g12, g21, g22
#   h*         hazard in terms of eta          h1, h2
#   F          Jacobian of h*                  f11, f12, f21, f22
#   rho-hat    conditional residual mean       rho_inf, rho_rem
# The numerical step ode_step is not an equation in those papers.
# It is the study's step for integrating (4), (8) and (9).

# Right-hand side of (4), (8) and (9), restarted so eta(0) = 0 and G(0) = I
# at prevalence (s, i). beta is the contact rate, exp(beta_tilde), held fixed.
dsir_incidence_lna_deriv <- function(eta1, eta2, v11, v12, v22,
                                    g11, g12, g21, g22,
                                    s, i, beta, gamma) {
  # Prevalence implied by incidence measured from the restart. Equation (1).
  s_ode <- s - eta1
  i_ode <- i + eta1 - eta2
  if (!is.finite(s_ode) || !is.finite(i_ode) || s_ode < 0 || i_ode < 0) {
    return(list(ok = FALSE))
  }
  # Equation (4): d eta / dt = h*(eta).
  h1 <- beta * s_ode * i_ode
  h2 <- gamma * i_ode
  if (!is.finite(h1) || !is.finite(h2) || h1 < 0 || h2 < 0) {
    return(list(ok = FALSE))
  }
  # Jacobian F printed after (6), with (s0, i0) = (s, i) at the restart.
  f11 <- beta * (s - i - 2 * eta1 + eta2)
  f12 <- beta * (eta1 - s)
  f21 <- gamma
  f22 <- -gamma
  # Equation (9): dV/dt = V F' + diag(h*) + F V.
  vf11 <- v11 * f11 + v12 * f12
  vf12 <- v11 * f21 + v12 * f22
  vf22 <- v12 * f21 + v22 * f22
  fv11 <- f11 * v11 + f12 * v12
  fv12 <- f11 * v12 + f12 * v22
  fv22 <- f21 * v12 + f22 * v22
  # Equation (8): dG/dt = F G.
  list(
    ok = TRUE,
    d_eta1 = h1,
    d_eta2 = h2,
    d_v11 = vf11 + h1 + fv11,
    d_v12 = vf12 + fv12,
    d_v22 = vf22 + h2 + fv22,
    d_g11 = f11 * g11 + f12 * g21,
    d_g12 = f11 * g12 + f12 * g22,
    d_g21 = f21 * g11 + f22 * g21,
    d_g22 = f21 * g12 + f22 * g22
  )
}

# One classical Runge-Kutta step. h_step is the numerical step, not a hazard.
dsir_incidence_lna_rk4 <- function(state, s, i, beta, gamma, h_step) {
  add_k <- function(state, k, scale) {
    if (!isTRUE(k$ok)) {
      return(list(ok = FALSE))
    }
    list(
      ok = TRUE,
      eta1 = state$eta1 + scale * k$d_eta1,
      eta2 = state$eta2 + scale * k$d_eta2,
      v11 = state$v11 + scale * k$d_v11,
      v12 = state$v12 + scale * k$d_v12,
      v22 = state$v22 + scale * k$d_v22,
      g11 = state$g11 + scale * k$d_g11,
      g12 = state$g12 + scale * k$d_g12,
      g21 = state$g21 + scale * k$d_g21,
      g22 = state$g22 + scale * k$d_g22
    )
  }
  deriv <- function(state) {
    dsir_incidence_lna_deriv(
      state$eta1, state$eta2, state$v11, state$v12, state$v22,
      state$g11, state$g12, state$g21, state$g22,
      s, i, beta, gamma
    )
  }
  k1 <- deriv(state)
  s2 <- add_k(state, k1, 0.5 * h_step)
  if (!isTRUE(s2$ok)) {
    return(list(ok = FALSE))
  }
  k2 <- deriv(s2)
  s3 <- add_k(state, k2, 0.5 * h_step)
  if (!isTRUE(s3$ok)) {
    return(list(ok = FALSE))
  }
  k3 <- deriv(s3)
  s4 <- add_k(state, k3, h_step)
  if (!isTRUE(s4$ok)) {
    return(list(ok = FALSE))
  }
  k4 <- deriv(s4)
  if (!isTRUE(k1$ok) || !isTRUE(k2$ok) || !isTRUE(k3$ok) || !isTRUE(k4$ok)) {
    return(list(ok = FALSE))
  }
  list(
    ok = TRUE,
    eta1 = state$eta1 + (h_step / 6) * (k1$d_eta1 + 2 * k2$d_eta1 + 2 * k3$d_eta1 + k4$d_eta1),
    eta2 = state$eta2 + (h_step / 6) * (k1$d_eta2 + 2 * k2$d_eta2 + 2 * k3$d_eta2 + k4$d_eta2),
    v11 = state$v11 + (h_step / 6) * (k1$d_v11 + 2 * k2$d_v11 + 2 * k3$d_v11 + k4$d_v11),
    v12 = state$v12 + (h_step / 6) * (k1$d_v12 + 2 * k2$d_v12 + 2 * k3$d_v12 + k4$d_v12),
    v22 = state$v22 + (h_step / 6) * (k1$d_v22 + 2 * k2$d_v22 + 2 * k3$d_v22 + k4$d_v22),
    g11 = state$g11 + (h_step / 6) * (k1$d_g11 + 2 * k2$d_g11 + 2 * k3$d_g11 + k4$d_g11),
    g12 = state$g12 + (h_step / 6) * (k1$d_g12 + 2 * k2$d_g12 + 2 * k3$d_g12 + k4$d_g12),
    g21 = state$g21 + (h_step / 6) * (k1$d_g21 + 2 * k2$d_g21 + 2 * k3$d_g21 + k4$d_g21),
    g22 = state$g22 + (h_step / 6) * (k1$d_g22 + 2 * k2$d_g22 + 2 * k3$d_g22 + k4$d_g22)
  )
}

# Integrate from 0 to t_end. Record the state at t_chord and at t_end.
dsir_incidence_lna_integrate <- function(s, i, beta, gamma, t_chord, t_end, ode_step) {
  state <- list(
    eta1 = 0, eta2 = 0, v11 = 0, v12 = 0, v22 = 0,
    g11 = 1, g12 = 0, g21 = 0, g22 = 1
  )
  t <- 0
  chord <- NULL
  reached_chord <- FALSE
  guard <- 0
  while (t < t_end - 1e-12) {
    guard <- guard + 1
    if (guard > 100000) {
      return(list(ok = FALSE))
    }
    h_step <- ode_step
    if (t + h_step > t_end) {
      h_step <- t_end - t
    }
    if (!reached_chord && t + h_step > t_chord) {
      h_step <- t_chord - t
    }
    state <- dsir_incidence_lna_rk4(state, s, i, beta, gamma, h_step)
    if (!isTRUE(state$ok)) {
      return(list(ok = FALSE))
    }
    t <- t + h_step
    if (!reached_chord && abs(t - t_chord) <= 1e-8) {
      chord <- state
      reached_chord <- TRUE
    }
  }
  if (!reached_chord) {
    return(list(ok = FALSE))
  }
  list(ok = TRUE, chord = chord, end = state)
}

# Poisson means for the next substep.
# The mean is the increment of eta + rho-hat over Delta tau.
# rho-hat(0) = 0 at a restart. q is the Poisson PMF at these means.
dsir_residual_poisson_means <- function(s, i, beta_tilde, gamma, n_past,
                                       remaining, delta_tau, y, rho, ode_step) {
  beta <- exp(beta_tilde)
  integrated <- dsir_incidence_lna_integrate(
    s, i, beta, gamma, delta_tau, remaining, ode_step
  )
  if (!isTRUE(integrated$ok)) {
    return(list(ok = FALSE))
  }
  chord <- integrated$chord
  end <- integrated$end
  # Binomial variance (14), with the frozen product replaced by the LNA mean.
  # Golightly et al. (2023), equation (22), is the same variance for P' = (1, 0).
  mu_hat <- rho * (n_past + end$eta1)
  sigma2 <- (1 - rho) * mu_hat
  denom <- (rho^2) * end$v11 + sigma2
  if (!is.finite(denom) || denom == 0 || !is.finite(mu_hat)) {
    return(list(ok = FALSE))
  }
  # Cov(R_t, R_T) = V_t (G_T G_t^{-1})'. Section 3.1.2 of Whitaker et al. (2017)
  # writes the same block as P_t psi_t P_T'.
  det_g <- chord$g11 * chord$g22 - chord$g12 * chord$g21
  if (!is.finite(det_g) || abs(det_g) < 1e-12) {
    return(list(ok = FALSE))
  }
  # inv(G_t), then G_T inv(G_t).
  inv11 <- chord$g22 / det_g
  inv12 <- -chord$g12 / det_g
  inv21 <- -chord$g21 / det_g
  inv22 <- chord$g11 / det_g
  a11 <- end$g11 * inv11 + end$g12 * inv21
  a12 <- end$g11 * inv12 + end$g12 * inv22
  a21 <- end$g21 * inv11 + end$g22 * inv21
  a22 <- end$g21 * inv12 + end$g22 * inv22
  # Columns of V_t %*% t(A). The first column covaries with residual infection at T.
  c_inf_inf <- chord$v11 * a11 + chord$v12 * a21
  gap <- y - mu_hat
  # rho-hat on the infection residual. Y loads on infection by rho, as in the
  # scalar SIR form of the 2025 display, where the removal hazard is not shifted.
  # The removal mean is the ODE chord over the next substep.
  rho_inf <- c_inf_inf * rho * gap / denom
  mean_inf <- chord$eta1 + rho_inf
  mean_rem <- chord$eta2
  if (!is.finite(mean_inf) || !is.finite(mean_rem) || mean_inf < 0 || mean_rem < 0) {
    return(list(ok = FALSE))
  }
  list(ok = TRUE, mean_inf = mean_inf, mean_rem = mean_rem)
}
