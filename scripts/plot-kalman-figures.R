# Display: accuracy against transition draws, and Lotka-Volterra differences
# Source: as specified in the request
# The plotted numbers are replicate means already stored for the manuscript.
# This script does not rerun the filters.
# Symbols:
#   e        mean absolute error of the log-parameter means     mean_abs_err
#   c        mean number of transition draws                    n_trans
#   m_j(a)   mean over replicates of the weighted mean          mean_log
#   s_j(a)   replicate standard deviation of that mean          sd_log
#   d_j(a)   m_j(a) - m_j(SMC2)                                 diff
#   se_j(a)  standard error of d_j(a)                           se

# Step 1. Read the stored summaries.
# The Ornstein-Uhlenbeck rows are the plain Metropolis-Hastings filter,
# delayed acceptance, the surrogate weight, and the two observation variances.
s2 <- read.csv(
  "Kalman extensions/results/summary-s2.csv",
  stringsAsFactors = FALSE
)
s4 <- read.csv(
  "Kalman extensions/results/summary-s4.csv",
  stringsAsFactors = FALSE
)
s6 <- read.csv(
  "Kalman extensions/results/summary-s6.csv",
  stringsAsFactors = FALSE
)
lv <- read.csv(
  "Kalman extensions/results/s7-lv-summary.csv",
  stringsAsFactors = FALSE
)

# Step 2. Ornstein-Uhlenbeck points.
# Panel (a): (c, e) for three schemes on the correctly specified series.
# Panel (b): (c, e) when the filter variance is five times the data variance.
ou_names <- c("mh", "da", "surrogate")
ou_labels <- c("Plain filter", "Delayed acceptance", "Surrogate weight")
ou_x <- c(
  s2$n_trans[s2$method == "mh"],
  s2$n_trans[s2$method == "da"],
  s4$n_trans[s4$method == "surrogate"]
)
ou_y <- c(
  s2$mean_abs_err[s2$method == "mh"],
  s2$mean_abs_err[s2$method == "da"],
  s4$mean_abs_err[s4$method == "surrogate"]
)
var_names <- c("plain_Rg_0.5", "rb_Rg_0.5")
var_labels <- c("Plain filter", "Rao-Blackwellised")
var_x <- c(
  s6$n_trans[s6$method == "plain_Rg_0.5"],
  s6$n_trans[s6$method == "rb_Rg_0.5"]
)
var_y <- c(
  s6$mean_abs_err[s6$method == "plain_Rg_0.5"],
  s6$mean_abs_err[s6$method == "rb_Rg_0.5"]
)

# Step 3. Lotka-Volterra differences from SMC2.
# d_j(a) = m_j(a) - m_j(SMC2)
# se_j(a) = sqrt( (s_j(a)^2 + s_j(SMC2)^2) / 4 )
# The divisor 4 is the number of algorithm replicates.
smc <- lv[lv$method == "smc2", ]
plain <- lv[lv$method == "nenkf", ]
rb <- lv[lv$method == "rb", ]
mean_cols <- c("mean_log_theta1", "mean_log_theta2", "mean_log_theta3")
sd_cols <- c("sd_log_theta1", "sd_log_theta2", "sd_log_theta3")
diff_plain <- as.numeric(plain[1, mean_cols] - smc[1, mean_cols])
diff_rb <- as.numeric(rb[1, mean_cols] - smc[1, mean_cols])
se_plain <- sqrt((as.numeric(plain[1, sd_cols])^2 + as.numeric(smc[1, sd_cols])^2) / 4)
se_rb <- sqrt((as.numeric(rb[1, sd_cols])^2 + as.numeric(smc[1, sd_cols])^2) / 4)

# The standard errors are printed so the manuscript can be checked against them.
# They are not a further analysis.
cat("LV standard errors, plain minus SMC2:\n")
print(se_plain)
cat("LV standard errors, Rao-Blackwellised minus SMC2:\n")
print(se_rb)

# Step 4. Accuracy against transition draws.
# Grey levels distinguish schemes that share a target from the surrogate weight.
pdf(
  file = "Kalman extensions/paper/figures/ou-accuracy-cost.pdf",
  width = 7.2,
  height = 3.6
)
par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.2, 0.8), cex = 0.9)
plot(
  ou_x, ou_y,
  pch = c(16, 15, 17),
  col = c("black", "grey35", "grey60"),
  xlim = c(0, 48000),
  ylim = c(0, 0.45),
  xlab = "Transition draws",
  ylab = "Mean absolute error",
  main = ""
)
mtext("(a) Surrogate weight", side = 3, line = 0.4, cex = 0.9)
# Labels sit above or below the point so the right-hand point stays inside the panel.
text(
  ou_x, ou_y,
  labels = ou_labels,
  pos = c(3, 1, 4),
  cex = 0.75,
  offset = 0.45
)
plot(
  var_x, var_y,
  pch = c(16, 1),
  col = c("black", "black"),
  xlim = c(18000, 42000),
  ylim = c(0, 0.55),
  xlab = "Transition draws",
  ylab = "Mean absolute error",
  main = ""
)
mtext("(b) Misspecified variance", side = 3, line = 0.4, cex = 0.9)
text(
  var_x, var_y,
  labels = var_labels,
  pos = c(1, 3),
  cex = 0.75,
  offset = 0.45
)
dev.off()

# Step 5. Lotka-Volterra differences.
# The horizontal line is equality with the SMC2 mean.
# The bars are se_j(a), not posterior standard deviations.
pdf(
  file = "Kalman extensions/paper/figures/lv-differences.pdf",
  width = 7.2,
  height = 4.0
)
par(mar = c(4.2, 4.6, 1.0, 0.8), cex = 0.95)
x <- c(1, 2, 3)
plot(
  NA,
  xlim = c(0.6, 3.4),
  ylim = c(-0.25, 0.25),
  xlab = "",
  ylab = "Difference from SMC2",
  xaxt = "n"
)
axis(1, at = x, labels = expression(log~theta[1], log~theta[2], log~theta[3]))
abline(h = 0, lty = 2, col = "grey50")
# Plain filter, filled circles, offset left.
x_plain <- x - 0.12
arrows(
  x_plain, diff_plain - se_plain,
  x_plain, diff_plain + se_plain,
  angle = 90, code = 3, length = 0.05
)
points(x_plain, diff_plain, pch = 16, cex = 1.1)
# Rao-Blackwellised filter, open circles, offset right.
x_rb <- x + 0.12
arrows(
  x_rb, diff_rb - se_rb,
  x_rb, diff_rb + se_rb,
  angle = 90, code = 3, length = 0.05, col = "grey30"
)
points(x_rb, diff_rb, pch = 1, cex = 1.1, col = "grey30")
legend(
  "topright",
  legend = c("Plain filter", "Rao-Blackwellised"),
  pch = c(16, 1),
  col = c("black", "grey30"),
  bty = "n"
)
dev.off()
