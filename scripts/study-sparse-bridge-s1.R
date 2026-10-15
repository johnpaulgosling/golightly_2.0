# Study S1. Effective sample size of the linear incidence guide.
# Design: Sparse bridge/notes/06-simulation-design.md (15 October 2026).
# Run from the repository root:
#   Rscript scripts/study-sparse-bridge-s1.R
#   Rscript scripts/study-sparse-bridge-s1.R pilot
# The default is the full design. The pilot is the pre-registered smaller run.
# Seeds are set here and are not part of the algorithm.
# This script calls the functions in R/. It does not reimplement them.

args <- commandArgs(trailingOnly = TRUE)
mode <- "full"
if (length(args) >= 1) {
  mode <- args[1]
}
if (!(mode %in% c("full", "pilot"))) {
  stop("Argument must be 'full' or 'pilot'.")
}

if (!file.exists("R/models-dsir.R")) {
  stop("Run this script from the repository root.")
}
source("R/models-dsir.R")
source("R/dsir-linear-guide.R")

# Section 4.1 settings, as fixed in the design note.
s0 <- 762
i0 <- 5
beta_tilde0 <- -6
gamma <- 0.5
lambda <- 100
rho <- 0.9
dt <- 0.001
n_step <- 10000
delta_tau <- 0.1
horizon <- 10
spacings <- c(1, 2, 5)
guides <- c("linear", "myopic")
seed_base <- 20251015
max_attempts <- 100

if (mode == "full") {
  n_rep <- 20
  n_prop <- 500
  prefix <- "s1-"
} else {
  n_rep <- 2
  n_prop <- 50
  prefix <- "s1-pilot-"
}

dir.create("Sparse bridge/results", showWarnings = FALSE, recursive = TRUE)

# Formula check, independent of the random stream.
# The expressions are the scalar form in the theory note, Section 5.1.
h_inf_check <- exp(-6) * 100 * 10
h_rem_check <- 0.5 * 10
mu_hat_check <- 0.9 * (0 + h_inf_check * 1)
sigma2_check <- (1 - 0.9) * mu_hat_check
denom_check <- (0.9^2) * h_inf_check * 1 + sigma2_check
h_star_inf_check <- h_inf_check + 0.9 * h_inf_check * (5 - mu_hat_check) / denom_check
h_star_rem_check <- h_rem_check
check <- dsir_conditioned_hazard_sir(h_inf_check, h_rem_check, 0, 1, 5, 0.9)
if (abs(check$h_star_inf - h_star_inf_check) > 1e-10 ||
    abs(check$h_star_rem - h_star_rem_check) > 1e-10) {
  stop("Conditioned hazard does not match the scalar form in the theory note.")
}

started <- proc.time()
window_rows <- list()
replicate_rows <- list()
n_discarded <- 0
row_id <- 0

for (r in seq_len(n_rep)) {
  path <- NULL
  for (attempt in 0:(max_attempts - 1)) {
    # Seed rule from the design note. Not part of the algorithm.
    set.seed(seed_base + r + 100000 * attempt)
    path <- dsir_simulate_sir(s0, i0, beta_tilde0, gamma, lambda, dt, n_step)
    if (!path$invalid) {
      n_discarded <- n_discarded + attempt
      break
    }
    path <- NULL
  }
  if (is.null(path)) {
    stop("Fine-grid path was invalid on every attempt.")
  }

  # Binomial observations in spacing order, then linear, then myopic.
  windows <- list()
  for (spacing in spacings) {
    n_window <- as.integer(horizon / spacing)
    windows[[as.character(spacing)]] <- list()
    for (w in seq_len(n_window)) {
      t_left <- (w - 1) * spacing
      t_right <- w * spacing
      windows[[as.character(spacing)]][[w]] <- dsir_window_from_path(
        path, t_left, t_right, delta_tau, rho
      )
    }
  }

  for (guide in guides) {
    for (spacing in spacings) {
      n_window <- length(windows[[as.character(spacing)]])
      ess_values <- numeric(n_window)
      ess_valid_values <- numeric(n_window)
      invalid_counts <- numeric(n_window)
      for (w in seq_len(n_window)) {
        window <- windows[[as.character(spacing)]][[w]]
        fit <- dsir_window_weights(
          s0 = window$s0,
          i0 = window$i0,
          beta_left = window$beta_left,
          gamma = gamma,
          rho = rho,
          y = window$y,
          delta_tau = delta_tau,
          n_prop = n_prop,
          guide = guide
        )
        ess <- dsir_ess_from_log_weights(fit$log_w)
        ess_valid <- dsir_ess_valid_only(fit$log_w)
        ess_values[w] <- ess
        ess_valid_values[w] <- ess_valid
        invalid_counts[w] <- fit$n_invalid
        row_id <- row_id + 1
        window_rows[[row_id]] <- data.frame(
          replicate = r,
          spacing = spacing,
          guide = guide,
          window_index = w,
          t_left = window$t_left,
          t_right = window$t_right,
          ess = ess,
          ess_valid = ess_valid,
          n_invalid = fit$n_invalid,
          n_prop = n_prop,
          y = window$y,
          n_true = window$n_true,
          stringsAsFactors = FALSE
        )
      }
      prop_invalid <- sum(invalid_counts) / (n_window * n_prop)
      replicate_rows[[length(replicate_rows) + 1]] <- data.frame(
        replicate = r,
        spacing = spacing,
        guide = guide,
        median_ess = median(ess_values),
        median_ess_valid = median(ess_valid_values, na.rm = TRUE),
        prop_invalid = prop_invalid,
        stringsAsFactors = FALSE
      )
    }
  }
}

window_table <- do.call(rbind, window_rows)
replicate_table <- do.call(rbind, replicate_rows)

study_rows <- list()
study_id <- 0
for (guide in guides) {
  for (spacing in spacings) {
    block <- replicate_table[replicate_table$guide == guide &
      replicate_table$spacing == spacing, ]
    study_id <- study_id + 1
    study_rows[[study_id]] <- data.frame(
      spacing = spacing,
      guide = guide,
      median_ess = median(block$median_ess),
      median_ess_valid = median(block$median_ess_valid, na.rm = TRUE),
      median_prop_invalid = median(block$prop_invalid),
      stringsAsFactors = FALSE
    )
  }
}
study_table <- do.call(rbind, study_rows)

elapsed <- proc.time() - started
meta <- data.frame(
  mode = mode,
  n_replicates = n_rep,
  n_prop = n_prop,
  seed_base = seed_base,
  n_discarded_paths = n_discarded,
  elapsed_seconds = as.numeric(elapsed["elapsed"]),
  formula_check = "pass",
  stringsAsFactors = FALSE
)

write.csv(window_table,
  file = paste0("Sparse bridge/results/", prefix, "window-ess.csv"),
  row.names = FALSE)
write.csv(replicate_table,
  file = paste0("Sparse bridge/results/", prefix, "replicate-summary.csv"),
  row.names = FALSE)
write.csv(study_table,
  file = paste0("Sparse bridge/results/", prefix, "study-summary.csv"),
  row.names = FALSE)
write.csv(meta,
  file = paste0("Sparse bridge/results/", prefix, "run-meta.csv"),
  row.names = FALSE)

print(study_table)
print(meta)
