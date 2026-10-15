# Study S7. Three targets on the Lotka-Volterra observation model.
# Settings: the 15 October 2026 amendment in
# Kalman extensions/notes/06-simulation-design.md.
# The seed is not part of the algorithm.
# Run from the repository root:
#   Rscript scripts/study-s7-lv-targets.R

s7_root <- function() {
  if (file.exists("R/nenkf-lv.R")) {
    return(normalizePath("."))
  }
  if (file.exists("../R/nenkf-lv.R")) {
    return(normalizePath(".."))
  }
  stop("Run from the repository root.")
}

s7_source <- function() {
  root <- s7_root()
  source(file.path(root, "R/models-ou.R"))
  source(file.path(root, "R/models-lv.R"))
  source(file.path(root, "R/nenkf.R"))
  source(file.path(root, "R/nenkf-lv.R"))
  source(file.path(root, "R/smc2-bootstrap.R"))
  root
}

# Constants from the design amendment. Not tuned after the posterior run.
s7_cfg <- function() {
  list(
    M = 60,
    N_enkf = 12,
    N_smc2 = 24,
    n_rep = 4,
    gamma = 0.4,
    x0 = c(50, 50),
    theta_true = c(0.5, 0.0025, 0.3),
    shapes = c(2, 20, 2),
    rates = c(4, 10000, 4),
    t_end = 40,
    dt_fine = 1e-3,
    thin = 2000,
    dt_step = 0.2,
    n_steps = 10,
    floor_eps = 1e-6,
    jitter = 1e-12,
    zeta2 = (2.56^2) / 3,
    master = 20261015,
    data_seed = 20261015 + 7100,
    floor_frac_limit = 0.01,
    results = file.path("Kalman extensions", "results")
  )
}

# Terminal weighted mean of log theta. Design amendment, not Algorithm 6.
# log_sum_exp is the stable normaliser from R/nenkf.R.
s7_weighted_mean_log <- function(theta, log_w) {
  d <- ncol(theta)
  out <- rep(NA_real_, d)
  if (!any(is.finite(log_w))) {
    return(out)
  }
  log_z <- log_sum_exp(log_w)
  w <- exp(log_w - log_z)
  log_theta <- log(theta)
  for (j in seq_len(d)) {
    out[j] <- sum(w * log_theta[, j])
  }
  out
}

s7_ess <- function(log_w) {
  if (!any(is.finite(log_w))) {
    return(NA_real_)
  }
  log_z <- log_sum_exp(log_w)
  w <- exp(log_w - log_z)
  1 / sum(w^2)
}

s7_cpu <- function() {
  cpu <- NA_character_
  if (file.exists("/proc/cpuinfo")) {
    lines <- readLines("/proc/cpuinfo")
    hit <- lines[grepl("^model name", lines)]
    if (length(hit) > 0) {
      cpu <- trimws(strsplit(hit[1], ":", fixed = TRUE)[[1]][2])
    }
  }
  cpu
}

s7_run <- function() {
  root <- s7_source()
  setwd(root)
  cfg <- s7_cfg()
  dir.create(cfg$results, recursive = TRUE, showWarnings = FALSE)

  # Seed for the synthetic series only. Not part of the algorithm.
  set.seed(cfg$data_seed)
  y <- lv_simulate_prey(
    cfg$theta_true, cfg$x0, cfg$t_end, cfg$dt_fine, cfg$thin, cfg$floor_eps
  )
  times <- seq(from = 2, by = 2, length.out = length(y))
  write.csv(
    data.frame(time = times, y = y),
    file.path(cfg$results, "s7-lv-data.csv"),
    row.names = FALSE
  )

  methods <- c("nenkf", "rb", "smc2")
  rows <- vector("list", cfg$n_rep * length(methods))
  k <- 0
  for (s in seq_along(methods)) {
    method <- methods[s]
    for (r in seq_len(cfg$n_rep)) {
      # Separate seed for each algorithm replicate. Not part of the algorithm.
      seed <- cfg$master + 8100 + 100 * s + r
      set.seed(seed)
      if (method == "smc2") {
        fit <- lv_smc2(
          y, cfg$M, cfg$N_smc2, cfg$gamma, cfg$zeta2, cfg$x0,
          cfg$dt_step, cfg$n_steps, cfg$shapes, cfg$rates,
          cfg$floor_eps, cfg$jitter
        )
      } else {
        R_scale <- if (method == "rb") 2 else 1
        weight <- if (method == "rb") "rb" else "enkf"
        fit <- lv_nested_filter(
          y, cfg$M, cfg$N_enkf, cfg$gamma, cfg$zeta2, weight, cfg$x0,
          cfg$dt_step, cfg$n_steps, cfg$shapes, cfg$rates,
          cfg$floor_eps, R_scale, cfg$jitter
        )
      }
      mean_log <- s7_weighted_mean_log(fit$theta, fit$log_w)
      floor_frac <- if (fit$n_trans > 0) fit$n_floor / fit$n_trans else NA_real_
      k <- k + 1
      rows[[k]] <- data.frame(
        method = method,
        replicate = r,
        seed = seed,
        mean_log_theta1 = mean_log[1],
        mean_log_theta2 = mean_log[2],
        mean_log_theta3 = mean_log[3],
        ess = s7_ess(fit$log_w),
        n_trans = fit$n_trans,
        n_floor = fit$n_floor,
        floor_frac = floor_frac,
        n_prop = fit$n_prop,
        n_acc = fit$n_acc,
        stringsAsFactors = FALSE
      )
      write.csv(
        do.call(rbind, rows[seq_len(k)]),
        file.path(cfg$results, "s7-lv-replicates.csv"),
        row.names = FALSE
      )
      cat(
        "S7", method, "replicate", r, "trans", fit$n_trans,
        "acc", fit$n_acc, "\n"
      )
    }
  }
  rep_df <- do.call(rbind, rows)

  sum_rows <- vector("list", length(methods))
  for (s in seq_along(methods)) {
    method <- methods[s]
    sub <- rep_df[rep_df$method == method, , drop = FALSE]
    sum_rows[[s]] <- data.frame(
      method = method,
      mean_log_theta1 = mean(sub$mean_log_theta1),
      mean_log_theta2 = mean(sub$mean_log_theta2),
      mean_log_theta3 = mean(sub$mean_log_theta3),
      # Sample standard deviation, divisor n_rep - 1.
      sd_log_theta1 = stats::sd(sub$mean_log_theta1),
      sd_log_theta2 = stats::sd(sub$mean_log_theta2),
      sd_log_theta3 = stats::sd(sub$mean_log_theta3),
      mean_ess = mean(sub$ess),
      mean_n_trans = mean(sub$n_trans),
      mean_floor_frac = mean(sub$floor_frac),
      max_floor_frac = max(sub$floor_frac),
      mean_n_prop = mean(sub$n_prop),
      mean_n_acc = mean(sub$n_acc),
      stringsAsFactors = FALSE
    )
  }
  sum_df <- do.call(rbind, sum_rows)
  write.csv(sum_df, file.path(cfg$results, "s7-lv-summary.csv"), row.names = FALSE)

  # Pre-registered shift rule. Standard error of a difference of means.
  m_n <- sum_df[sum_df$method == "nenkf", , drop = FALSE]
  m_r <- sum_df[sum_df$method == "rb", , drop = FALSE]
  m_s <- sum_df[sum_df$method == "smc2", , drop = FALSE]
  n_rep <- cfg$n_rep
  shift_rows <- vector("list", 3)
  n_resolved <- 0
  n_nonneg <- 0
  n_rb_closer <- 0
  for (j in 1:3) {
    mean_col <- paste0("mean_log_theta", j)
    sd_col <- paste0("sd_log_theta", j)
    d_n <- m_n[[mean_col]] - m_s[[mean_col]]
    d_r <- m_r[[mean_col]] - m_s[[mean_col]]
    se_n <- sqrt((m_n[[sd_col]]^2 + m_s[[sd_col]]^2) / n_rep)
    resolved <- is.finite(d_n) && is.finite(se_n) && (d_n < -se_n)
    nonneg <- is.finite(d_n) && (d_n >= 0)
    rb_closer <- is.finite(d_r) && is.finite(d_n) && (abs(d_r) < abs(d_n))
    if (j %in% c(2, 3) && resolved) {
      n_resolved <- n_resolved + 1
    }
    if (j %in% c(2, 3) && nonneg) {
      n_nonneg <- n_nonneg + 1
    }
    if (j %in% c(2, 3) && rb_closer) {
      n_rb_closer <- n_rb_closer + 1
    }
    shift_rows[[j]] <- data.frame(
      coord = j,
      mean_nenkf = m_n[[mean_col]],
      mean_rb = m_r[[mean_col]],
      mean_smc2 = m_s[[mean_col]],
      sd_nenkf = m_n[[sd_col]],
      sd_rb = m_r[[sd_col]],
      sd_smc2 = m_s[[sd_col]],
      diff_nenkf = d_n,
      diff_rb = d_r,
      se_diff_nenkf = se_n,
      shift_resolved = resolved,
      shift_nonnegative = nonneg,
      rb_closer = rb_closer,
      stringsAsFactors = FALSE
    )
  }
  shift_df <- do.call(rbind, shift_rows)
  write.csv(shift_df, file.path(cfg$results, "s7-lv-shift.csv"), row.names = FALSE)

  if (n_resolved == 2) {
    verdict <- "appearing"
  } else if (n_nonneg == 2) {
    verdict <- "failing"
  } else {
    verdict <- "unresolved"
  }
  verdict_df <- data.frame(
    shift_verdict = verdict,
    rb_reduces_both = (n_rb_closer == 2),
    n_resolved = n_resolved,
    n_nonnegative = n_nonneg,
    n_rb_closer = n_rb_closer,
    floor_limit = cfg$floor_frac_limit,
    nenkf_floor_exceeds = m_n$max_floor_frac > cfg$floor_frac_limit,
    rb_floor_exceeds = m_r$max_floor_frac > cfg$floor_frac_limit,
    smc2_floor_exceeds = m_s$max_floor_frac > cfg$floor_frac_limit,
    stringsAsFactors = FALSE
  )
  write.csv(verdict_df, file.path(cfg$results, "s7-lv-verdict.csv"), row.names = FALSE)

  session_df <- data.frame(
    r_version = R.version.string,
    cpu = s7_cpu(),
    data_seed = cfg$data_seed,
    M = cfg$M,
    N_enkf = cfg$N_enkf,
    N_smc2 = cfg$N_smc2,
    n_rep = cfg$n_rep,
    n_obs = length(y),
    stringsAsFactors = FALSE
  )
  write.csv(session_df, file.path(cfg$results, "s7-lv-session.csv"), row.names = FALSE)
  invisible(list(replicates = rep_df, summary = sum_df, shift = shift_df, verdict = verdict_df))
}

if (sys.nframe() == 0) {
  s7_run()
}
