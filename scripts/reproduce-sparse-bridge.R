# Reproduction script for the sparse-incidence diagnostic paper.
# Manuscript: Sparse bridge/paper/main.tex
# Displays produced here:
#   Table 1  (tab:s1)  section write_linear_table
#                     from Sparse bridge/results/s1-study-summary.csv
#                     written to Sparse bridge/paper/tables/s1-study-summary.tex
#                     included by Sparse bridge/paper/05-simulation.tex
#   Figure 1 (fig:ess) section write_ess_figure
#                     from the same study summary
#                     written to Sparse bridge/paper/figures/ess-against-spacing.pdf
#                     included by Sparse bridge/paper/05-simulation.tex
# The manuscript reports no application, so no application is run.
#
# Run from the repository root:
#   Rscript scripts/reproduce-sparse-bridge.R
#   Rscript scripts/reproduce-sparse-bridge.R pilot
# The default is the full study in scripts/study-sparse-bridge-s1.R.
# The pilot switch repeats the pre-registered pilot and does not replace
# the manuscript table or figure. Manuscript numbers come from the full run
# recorded in Sparse bridge/notes/06-simulation-findings.md.
#
# This script does not reimplement the guide. The full and pilot runs are
# the existing study script, which sources R/models-dsir.R and
# R/dsir-linear-guide.R. Seeds are set in that study script and are not
# part of the algorithm.
#
# Check, 15 October 2026, from the repository root:
#   Rscript scripts/reproduce-sparse-bridge.R
# The regenerated study summary matched the findings note on every quoted
# cell. The elapsed time in s1-run-meta.csv changed, so the stored full-run
# CSVs were restored and the manuscript numbers were not replaced. The table
# and the figure were written from that stored summary.

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

# Cells quoted in notes/06-simulation-findings.md. A regenerated run must
# match these character values. They are the manuscript contract, not a
# new estimate.
findings_linear <- list(
  c(spacing = "1", median_ess = "149.660679297905",
    median_ess_valid = "149.660679297905", median_prop_invalid = "0.0329"),
  c(spacing = "2", median_ess = "8.09166818813341",
    median_ess_valid = "8.09166818813341", median_prop_invalid = "0.009"),
  c(spacing = "5", median_ess = "2.05670742297318",
    median_ess_valid = "2.05670742297318", median_prop_invalid = "0")
)
findings_myopic_ess <- c("1" = "139.525563697813",
                         "2" = "142.824313796391",
                         "5" = "195.181391518181")

summary_path <- "Sparse bridge/results/s1-study-summary.csv"
full_outputs <- c(
  summary_path,
  "Sparse bridge/results/s1-window-ess.csv",
  "Sparse bridge/results/s1-replicate-summary.csv",
  "Sparse bridge/results/s1-run-meta.csv"
)

read_summary_text <- function(path) {
  # Keep the printed digits. Do not reformat through as.numeric.
  lines <- readLines(path)
  rows <- strsplit(lines[-1], ",", fixed = TRUE)
  out <- list()
  for (i in seq_along(rows)) {
    parts <- gsub("\"", "", rows[[i]])
    out[[i]] <- c(
      spacing = parts[1],
      guide = parts[2],
      median_ess = parts[3],
      median_ess_valid = parts[4],
      median_prop_invalid = parts[5]
    )
  }
  out
}

summary_matches_findings <- function(path) {
  rows <- read_summary_text(path)
  ok <- TRUE
  for (expected in findings_linear) {
    found <- FALSE
    for (row in rows) {
      if (row["guide"] == "linear" && row["spacing"] == expected["spacing"]) {
        found <- TRUE
        if (row["median_ess"] != expected["median_ess"] ||
            row["median_ess_valid"] != expected["median_ess_valid"] ||
            row["median_prop_invalid"] != expected["median_prop_invalid"]) {
          ok <- FALSE
        }
      }
    }
    if (!found) {
      ok <- FALSE
    }
  }
  for (spacing in names(findings_myopic_ess)) {
    found <- FALSE
    for (row in rows) {
      if (row["guide"] == "myopic" && row["spacing"] == spacing) {
        found <- TRUE
        if (row["median_ess"] != findings_myopic_ess[[spacing]]) {
          ok <- FALSE
        }
      }
    }
    if (!found) {
      ok <- FALSE
    }
  }
  ok
}

backup_dir <- tempfile("s1-backup-")
dir.create(backup_dir)
for (path in full_outputs) {
  if (file.exists(path)) {
    file.copy(path, file.path(backup_dir, basename(path)))
  }
}

# The study script sets the seed. That seed is not part of the algorithm.
status <- system2("Rscript", c("scripts/study-sparse-bridge-s1.R", mode))
if (status != 0) {
  stop("The study script failed.")
}

if (mode == "full") {
  if (!summary_matches_findings(summary_path)) {
    for (path in full_outputs) {
      backed <- file.path(backup_dir, basename(path))
      if (file.exists(backed)) {
        file.copy(backed, path, overwrite = TRUE)
      }
    }
    stop("Regenerated summary does not match the findings note. Stored files restored.")
  }
  # Keep the stored bytes when a rewrite is numerically the same.
  for (path in full_outputs) {
    backed <- file.path(backup_dir, basename(path))
    if (file.exists(backed)) {
      same <- identical(readLines(backed), readLines(path))
      if (!same) {
        file.copy(backed, path, overwrite = TRUE)
      }
    }
  }
}

write_linear_table <- function(path, dest) {
  rows <- read_summary_text(path)
  dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
  lines <- c(
    "\\begin{table}[t]",
    "\\centering",
    "\\caption{Linear incidence guide. Median effective sample size across 20 replicates. Finite-weight medians use the draws with a finite log weight. The myopic comparator is not in this table.}",
    "\\label{tab:s1}",
    "{\\small\\setlength{\\tabcolsep}{3pt}%",
    "\\begin{tabular}{rrrr}",
    "\\hline",
    "Spacing & ESS & ESS, finite weights & Invalid proportion \\\\",
    "\\hline"
  )
  for (expected in findings_linear) {
    # Write the findings digits, after checking the file still holds them.
    matched <- NULL
    for (row in rows) {
      if (row["guide"] == "linear" && row["spacing"] == expected["spacing"]) {
        matched <- row
      }
    }
    if (is.null(matched)) {
      stop("Linear row missing from the study summary.")
    }
    if (matched["median_ess"] != expected["median_ess"]) {
      stop("Study summary drifted from the findings note.")
    }
    lines <- c(lines, paste0(
      expected["spacing"], " & ",
      expected["median_ess"], " & ",
      expected["median_ess_valid"], " & ",
      expected["median_prop_invalid"], " \\\\"
    ))
  }
  lines <- c(lines, "\\hline", "\\end{tabular}}", "\\end{table}", "")
  writeLines(lines, dest)
}

write_ess_figure <- function(path, dest, residual_path = NULL) {
  rows <- read_summary_text(path)
  spacing_linear <- numeric(3)
  ess_linear <- numeric(3)
  spacing_myopic <- numeric(3)
  ess_myopic <- numeric(3)
  i_linear <- 0
  i_myopic <- 0
  for (row in rows) {
    if (row["guide"] == "linear") {
      i_linear <- i_linear + 1
      spacing_linear[i_linear] <- as.numeric(row["spacing"])
      ess_linear[i_linear] <- as.numeric(row["median_ess"])
    }
    if (row["guide"] == "myopic") {
      i_myopic <- i_myopic + 1
      spacing_myopic[i_myopic] <- as.numeric(row["spacing"])
      ess_myopic[i_myopic] <- as.numeric(row["median_ess"])
    }
  }
  spacing_residual <- numeric(0)
  ess_residual <- numeric(0)
  if (!is.null(residual_path) && file.exists(residual_path)) {
    residual_rows <- read_summary_text(residual_path)
    spacing_residual <- numeric(length(residual_rows))
    ess_residual <- numeric(length(residual_rows))
    for (i in seq_along(residual_rows)) {
      spacing_residual[i] <- as.numeric(residual_rows[[i]]["spacing"])
      ess_residual[i] <- as.numeric(residual_rows[[i]]["median_ess"])
    }
  }
  dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
  pdf(dest, width = 6.2, height = 4.4)
  # Figure 1. Study medians only. No new summary is computed.
  y_max <- max(c(ess_linear, ess_myopic, ess_residual))
  plot(spacing_linear, ess_linear,
       type = "n",
       xlab = "Observation spacing",
       ylab = "Median effective sample size",
       xlim = c(1, 5),
       ylim = c(0, y_max * 1.05),
       xaxt = "n")
  axis(1, at = c(1, 2, 5))
  lines(spacing_linear, ess_linear, lty = 1)
  points(spacing_linear, ess_linear, pch = 16)
  lines(spacing_myopic, ess_myopic, lty = 2)
  points(spacing_myopic, ess_myopic, pch = 1)
  if (length(ess_residual) > 0) {
    lines(spacing_residual, ess_residual, lty = 1)
    points(spacing_residual, ess_residual, pch = 17)
  }
  legend("topright",
         legend = c("Linear guide", "Myopic comparator", "Residual guide"),
         pch = c(16, 1, 17), lty = c(1, 2, 1), bty = "n")
  dev.off()
}

if (!summary_matches_findings(summary_path)) {
  stop("Stored study summary does not match the findings note.")
}
write_linear_table(summary_path, "Sparse bridge/paper/tables/s1-study-summary.tex")
residual_path <- "Sparse bridge/results/s2-study-summary.csv"
write_ess_figure(summary_path, "Sparse bridge/paper/figures/ess-against-spacing.pdf",
                 residual_path)
cat("Wrote Table 1 and Figure 1 from the stored full-run summaries.\n")
