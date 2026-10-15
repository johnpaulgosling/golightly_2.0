# Reproduce the pilot numbers cited in Kalman extensions/paper/.
#
# From the repository root:
#   Rscript scripts/reproduce-nenkf-extensions.R
#
# The manuscript reports the pre-registered pilot in
# Kalman extensions/notes/06-simulation-design.md
# (M = 60, T = 16, N = 12, four replicates).
# Those are the numbers in Kalman extensions/results/.
# They are not the 2026 experiment (M = 1000, 50 observations,
# 100 replicates). The full settings were not run.
#
# Seeds are set in scripts/ou-pilot-run.R. They are not part of
# the algorithm.
#
# Displays and the code that writes them:
#   Table of kernels          summary-s2.csv     run_s1_s2
#   Neighbour counts          summary-s1.csv     run_s1_s2
#   Cost against error        paper/figures/cost-error.pdf
#   Variance table            s5-variance.csv    run_s5
#   Rao-Blackwellised table   summary-s6.csv     run_s6
#   Identity differences      s6-identity.csv    run_s6
#
# A full 2026-scale run is not switched on here. Passing
# --full stops with a message rather than launching that run.

args <- commandArgs(trailingOnly = TRUE)
if ("--full" %in% args) {
  stop(
    "The 2026-scale settings are recorded in notes/06-simulation-design.md and were not run. ",
    "The manuscript uses the pilot. Omit --full."
  )
}

source("scripts/ou-pilot-run.R")
run_all_pilot()

# Figure. Drawn from the summary tables, not from a second analysis.
root <- pilot_root()
setwd(root)
cfg <- pilot_cfg()
s2 <- read.csv(file.path(cfg$results, "summary-s2.csv"))
s3 <- read.csv(file.path(cfg$results, "summary-s3.csv"))
s4 <- read.csv(file.path(cfg$results, "summary-s4.csv"))
lab <- c(
  "Metropolis-Hastings", "Delayed acceptance", "Switch",
  "Finite difference", "Surrogate weight"
)
x <- c(
  s2$n_trans[s2$method == "mh"],
  s2$n_trans[s2$method == "da"],
  s2$n_trans[s2$method == "switch"],
  s3$n_trans[s3$method == "gradient"],
  s4$n_trans[s4$method == "surrogate"]
)
y <- c(
  s2$mean_abs_err[s2$method == "mh"],
  s2$mean_abs_err[s2$method == "da"],
  s2$mean_abs_err[s2$method == "switch"],
  s3$mean_abs_err[s3$method == "gradient"],
  s4$mean_abs_err[s4$method == "surrogate"]
)
fig_dir <- file.path("Kalman extensions", "paper", "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
pdf(file.path(fig_dir, "cost-error.pdf"), width = 6.2, height = 4.4)
plot(
  x, y, log = "x", pch = 19,
  xlab = "Mean number of transition draws",
  ylab = "Mean absolute error of posterior means",
  xlim = c(min(x) * 0.7, max(x) * 1.35),
  ylim = c(0, max(y) * 1.15)
)
text(x, y, lab, pos = 4, cex = 0.75)
dev.off()
