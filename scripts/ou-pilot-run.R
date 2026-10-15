# Pilot runner for the Ornstein-Uhlenbeck studies.
# Settings: Kalman extensions/notes/06-simulation-design.md.
# Seeds are not part of the algorithm.
# Source this file from the repository root, or run a study script.

pilot_root <- function() {
  if (file.exists("R/nenkf.R")) {
    return(normalizePath("."))
  }
  if (file.exists("../R/nenkf.R")) {
    return(normalizePath(".."))
  }
  stop("Run from the repository root.")
}

pilot_source <- function() {
  root <- pilot_root()
  source(file.path(root, "R/models-ou.R"))
  source(file.path(root, "R/nenkf-knn-tree.R"))
  source(file.path(root, "R/nenkf-adaptive-kernel.R"))
  source(file.path(root, "R/nenkf-gradient-move.R"))
  source(file.path(root, "R/nenkf-surrogate-weight.R"))
  source(file.path(root, "R/nenkf-rb.R"))
  source(file.path(root, "R/nenkf.R"))
  root
}

# Design-note constants. Not tuned after results.
pilot_cfg <- function() {
  list(
    M = 60,
    N = 12,
    T = 16,
    gamma = 0.4,
    k = 3,
    x0 = 10,
    dt = 1,
    R = 0.1,
    theta_true = c(1, 2, 1),
    shapes = c(2, 5, 2),
    rates = c(2, 3, 5),
    zeta2 = 2.56^2 / 3,
    t_switch = 8,
    lambda = 0.2,
    h_frac = 0.05,
    n_rep = 4,
    master = 20261015,
    gold_iter = 3000,
    gold_burn = 1000,
    gold_sd = 0.15,
    results = file.path("Kalman extensions", "results")
  )
}

pilot_data <- function(cfg, r) {
  set.seed(cfg$master + r)
  ou_simulate(cfg$theta_true, cfg$x0, cfg$T, cfg$dt, cfg$R)
}

pilot_gold <- function(cfg, y, r) {
  set.seed(cfg$master + r + 500)
  ou_gold_mean_log(
    y, cfg$x0, cfg$dt, cfg$R, cfg$shapes, cfg$rates,
    cfg$gold_iter, cfg$gold_burn, cfg$gold_sd
  )
}

# s is the method index used only to offset the seed.
pilot_filter <- function(cfg, y, r, s, move, R_f, R_g) {
  set.seed(cfg$master + r + 1000 * s)
  nenkf_ou(
    y = y, M = cfg$M, N = cfg$N, gamma = cfg$gamma, k = cfg$k,
    zeta2 = cfg$zeta2, move = move, x0 = cfg$x0, dt = cfg$dt,
    R_f = R_f, R_g = R_g, shapes = cfg$shapes, rates = cfg$rates,
    t_switch = cfg$t_switch, lambda = cfg$lambda, h_frac = cfg$h_frac
  )
}

pilot_row <- function(r, method, fit, gold) {
  err <- abs(fit$mean_log_theta - gold)
  data.frame(
    replicate = r,
    method = method,
    mean_log_1 = fit$mean_log_theta[1],
    mean_log_2 = fit$mean_log_theta[2],
    mean_log_3 = fit$mean_log_theta[3],
    gold_1 = gold[1],
    gold_2 = gold[2],
    gold_3 = gold[3],
    abs_err_1 = err[1],
    abs_err_2 = err[2],
    abs_err_3 = err[3],
    mean_abs_err = mean(err),
    ess = fit$ess,
    n_trans = fit$n_trans,
    n_prop = fit$n_prop,
    n_acc = fit$n_acc,
    n_screen = fit$n_screen,
    n_screen_acc = fit$n_screen_acc,
    cost_per_accept = fit$cost_per_accept,
    ess_per_trans = fit$ess / fit$n_trans,
    knn_checks = fit$knn_checks,
    knn_agree = fit$knn_agree,
    list_dists = fit$list_dists,
    tree_dists = fit$tree_dists,
    max_abs_log_diff = fit$max_abs_log_diff,
    diag_median = fit$diag_median,
    stringsAsFactors = FALSE
  )
}

pilot_write <- function(cfg, df, name) {
  dir.create(cfg$results, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(cfg$results, name)
  write.csv(df, path, row.names = FALSE)
  path
}

# S2 runs the three kernels. S1's neighbour counts are the delayed-acceptance rows.
run_s1_s2 <- function() {
  root <- pilot_source()
  setwd(root)
  cfg <- pilot_cfg()
  rows <- list()
  n <- 0
  for (r in 1:cfg$n_rep) {
    y <- pilot_data(cfg, r)
    gold <- pilot_gold(cfg, y, r)
    methods <- c("mh", "da", "switch")
    for (j in seq_along(methods)) {
      n <- n + 1
      fit <- pilot_filter(cfg, y, r, s = j, move = methods[j], R_f = cfg$R, R_g = cfg$R)
      rows[[n]] <- pilot_row(r, methods[j], fit, gold)
    }
  }
  df <- do.call(rbind, rows)
  pilot_write(cfg, df, "s2-kernels.csv")
  s1 <- df[df$method == "da", c(
    "replicate", "knn_checks", "knn_agree", "list_dists", "tree_dists"
  )]
  s1$agree_rate <- ifelse(s1$knn_checks > 0, s1$knn_agree / s1$knn_checks, NA)
  pilot_write(cfg, s1, "s1-neighbours.csv")
  df
}

run_s3 <- function() {
  root <- pilot_source()
  setwd(root)
  cfg <- pilot_cfg()
  rows <- list()
  n <- 0
  for (r in 1:cfg$n_rep) {
    y <- pilot_data(cfg, r)
    gold <- pilot_gold(cfg, y, r)
    # s = 4 is the finite-difference move. The random-walk comparator is s = 1,
    # the same seed offset as the plain filter in S2.
    for (spec in list(c("mh", 1), c("gradient", 4))) {
      n <- n + 1
      fit <- pilot_filter(cfg, y, r, s = as.integer(spec[2]), move = spec[1],
                          R_f = cfg$R, R_g = cfg$R)
      rows[[n]] <- pilot_row(r, spec[1], fit, gold)
    }
  }
  df <- do.call(rbind, rows)
  pilot_write(cfg, df, "s3-gradient.csv")
  df
}

run_s4 <- function() {
  root <- pilot_source()
  setwd(root)
  cfg <- pilot_cfg()
  rows <- list()
  n <- 0
  for (r in 1:cfg$n_rep) {
    y <- pilot_data(cfg, r)
    gold <- pilot_gold(cfg, y, r)
    n <- n + 1
    fit <- pilot_filter(cfg, y, r, s = 5, move = "surrogate", R_f = cfg$R, R_g = cfg$R)
    rows[[n]] <- pilot_row(r, "surrogate", fit, gold)
  }
  df <- do.call(rbind, rows)
  pilot_write(cfg, df, "s4-surrogate.csv")
  df
}

run_s5 <- function() {
  root <- pilot_source()
  setwd(root)
  cfg <- pilot_cfg()
  rows <- list()
  n <- 0
  for (dy in c(1, 5)) {
    set.seed(cfg$master + 100 + dy)
    if (dy == 1) {
      y <- ou_simulate(cfg$theta_true, cfg$x0, cfg$T, cfg$dt, cfg$R)
    } else {
      y <- ou_simulate_vector(cfg$theta_true, cfg$x0, cfg$T, cfg$dt, cfg$R, dy)
    }
    for (N in c(8, 16)) {
      logs <- numeric(20)
      draws <- numeric(20)
      for (b in 1:20) {
        counter <- new.env(parent = emptyenv())
        counter$n_trans <- 0
        logs[b] <- enkf_loglik_once(cfg$theta_true, y, cfg$x0, N, cfg$dt, cfg$R, counter)
        draws[b] <- counter$n_trans
      }
      n <- n + 1
      rows[[n]] <- data.frame(
        d_y = dy,
        N = N,
        var_loglik = stats::var(logs),
        mean_draws = mean(draws),
        stringsAsFactors = FALSE
      )
    }
  }
  df <- do.call(rbind, rows)
  pilot_write(cfg, df, "s5-variance.csv")
  df
}

run_s6 <- function() {
  root <- pilot_source()
  setwd(root)
  cfg <- pilot_cfg()
  rows <- list()
  n <- 0
  ident <- numeric(cfg$n_rep)
  for (r in 1:cfg$n_rep) {
    y <- pilot_data(cfg, r)
    gold <- pilot_gold(cfg, y, r)
    n <- n + 1
    id_fit <- pilot_filter(cfg, y, r, s = 6, move = "rb", R_f = cfg$R, R_g = cfg$R)
    ident[r] <- id_fit$max_abs_log_diff
    rows[[n]] <- pilot_row(r, "rb_identity", id_fit, gold)
    n <- n + 1
    plain <- pilot_filter(cfg, y, r, s = 7, move = "mh", R_f = cfg$R, R_g = 0.5)
    rows[[n]] <- pilot_row(r, "plain_Rg_0.5", plain, gold)
    n <- n + 1
    rb <- pilot_filter(cfg, y, r, s = 8, move = "rb", R_f = cfg$R, R_g = 0.5)
    rows[[n]] <- pilot_row(r, "rb_Rg_0.5", rb, gold)
  }
  df <- do.call(rbind, rows)
  pilot_write(cfg, df, "s6-rb.csv")
  write.csv(
    data.frame(replicate = 1:cfg$n_rep, max_abs_log_diff = ident),
    file.path(cfg$results, "s6-identity.csv"),
    row.names = FALSE
  )
  df
}

write_summaries <- function() {
  cfg <- pilot_cfg()
  s1 <- read.csv(file.path(cfg$results, "s1-neighbours.csv"))
  s2 <- read.csv(file.path(cfg$results, "s2-kernels.csv"))
  s3 <- read.csv(file.path(cfg$results, "s3-gradient.csv"))
  s4 <- read.csv(file.path(cfg$results, "s4-surrogate.csv"))
  s6 <- read.csv(file.path(cfg$results, "s6-rb.csv"))
  mean_by <- function(df, cols) {
    aggregate(df[cols], by = list(method = df$method), FUN = mean)
  }
  write.csv(
    data.frame(
      mean_checks = mean(s1$knn_checks),
      mean_agree = mean(s1$knn_agree),
      mean_list = mean(s1$list_dists),
      mean_tree = mean(s1$tree_dists),
      mean_agree_rate = mean(s1$agree_rate)
    ),
    file.path(cfg$results, "summary-s1.csv"),
    row.names = FALSE
  )
  write.csv(
    mean_by(s2, c(
      "mean_abs_err", "ess", "n_trans", "n_acc", "n_prop",
      "n_screen", "n_screen_acc", "cost_per_accept", "ess_per_trans"
    )),
    file.path(cfg$results, "summary-s2.csv"),
    row.names = FALSE
  )
  write.csv(
    mean_by(s3, c("mean_abs_err", "ess", "n_trans", "ess_per_trans", "n_acc")),
    file.path(cfg$results, "summary-s3.csv"),
    row.names = FALSE
  )
  write.csv(
    mean_by(s4, c("mean_abs_err", "ess", "n_trans", "diag_median", "ess_per_trans")),
    file.path(cfg$results, "summary-s4.csv"),
    row.names = FALSE
  )
  d <- mean_by(s6, c("mean_abs_err", "ess", "n_trans"))
  # Ratio of the mean error to the mean number of transition draws.
  d$err_per_trans <- d$mean_abs_err / d$n_trans
  write.csv(d, file.path(cfg$results, "summary-s6.csv"), row.names = FALSE)
}

run_all_pilot <- function() {
  run_s1_s2()
  run_s3()
  run_s4()
  run_s5()
  run_s6()
  write_summaries()
}
