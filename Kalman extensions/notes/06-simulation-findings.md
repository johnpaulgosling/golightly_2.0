# Simulation findings

The design is `notes/06-simulation-design.md`. Every number below is a mean over the four pilot replicates unless a replicate is named, and it is copied from a file in `Kalman extensions/results/`. The pilot is not the 2026 experiment: \(M = 60\), \(T = 16\), \(N = 12\) fixed, and the gold-standard chain has 3000 iterations after 1000 burn-in.

## S1. Neighbour search

Comparison: exact KD-tree against a linear scan, inside delayed acceptance.

Result, from `results/s1-neighbours.csv` and `results/summary-s1.csv`. The neighbour index sets agreed on every check. The mean number of checks was 491, the mean number of agreements was 491, and the mean agreement rate was 1. The mean number of distance evaluations was 29460 for the list and 13422.5 for the tree.

The tree therefore touched fewer stored points at \(d_\theta = 3\) and \(M = 60\). The implementation rebuilds the tree on every query, so this count is not a wall-clock comparison. Neighbour sets did not disagree, and the kernel is unchanged when they agree.

Place in the paper: kept, as a cost count and the equality of the kernels. Not as a claim that the tree is faster once the cost of building it is included.

## S2. Choice of kernel

Comparison: plain Metropolis–Hastings, delayed acceptance with \(k = 3\), and the switch at \(t = 8\). The pre-registered criterion is the mean cost per accepted move.

Result, from `results/summary-s2.csv`.

| Method | Mean absolute error | Transition draws | Cost per accepted move | Terminal ESS |
| --- | --- | --- | --- | --- |
| Metropolis–Hastings | 0.1719693 | 33855 | 310.4406 | 39.58499 |
| Delayed acceptance | 0.1262270 | 23970 | 221.5755 | 43.33147 |
| Switch | 0.1324337 | 23457 | 214.7086 | 36.70344 |

The switch has the lowest mean cost per accepted move. It is not worse than the better fixed kernel. Mean stage-one counts were 245.50 screens and 144.25 screen acceptances for delayed acceptance, and 74.25 screens and 38.00 screen acceptances for the switch.

Place in the paper: kept. The switch is a small improvement on delayed acceptance on this criterion, on this pilot.

## S3. Finite-difference proposal

Comparison: terminal effective sample size per transition draw, against the random walk.

Result, from `results/summary-s3.csv`. The random walk had mean effective sample size 39.58499 and mean transition draws 33855, so 0.0012263996 per draw. The finite-difference proposal had mean effective sample size 38.38152 and mean transition draws 268602, so 0.0001482658 per draw. The proposal does not increase effective sample size per draw. The mean absolute error was smaller (0.0741601 against 0.1719693). The mean transition draws were 268602 against 33855.

Place in the paper: removed as a method. The invariance argument stays in the theory note. The simulation section reports the negative comparison and does not recommend the proposal. Added to "Dropped" in `notes/05-theory-notes.md`.

## S4. Surrogate weights

Comparison: the median absolute difference between the surrogate increment and a fresh ensemble Kalman increment, threshold 1, and whether the number of transition draws falls relative to plain Metropolis–Hastings.

Result, from `results/s4-surrogate.csv` and `results/summary-s4.csv`. The mean of the median absolute log differences was 0.2772671, which does not exceed 1. The mean number of transition draws was 5217, against 33855 for plain Metropolis–Hastings in `results/summary-s2.csv`. The cost falls. The mean absolute error was 0.2932941, which is larger than the plain filter's 0.1719693 and the delayed-acceptance filter's 0.1262270.

Place in the paper: kept, with that qualification. The particles are aimed at the surrogate posterior. On this pilot the increment diagnostic stayed inside the pre-registered threshold, the cost fell, and the error in the posterior means was larger.

## S5. Scaling cells

Result, from `results/s5-variance.csv`. Sample variance of the log ensemble Kalman likelihood at the true parameter, 20 replicates.

| Observation dimension | Ensemble size | Variance | Mean transition draws |
| --- | --- | --- | --- |
| 1 | 8 | 14.059854 | 128 |
| 1 | 16 | 2.879392 | 256 |
| 5 | 8 | 24.934850 | 640 |
| 5 | 16 | 10.661297 | 1280 |

The ratio of the variance at ensemble size 8 to the variance at ensemble size 16 is \(14.059854 / 2.879392\) in one dimension and \(24.934850 / 10.661297\) in five dimensions. The ratio of the five-coordinate variance to the one-coordinate variance is \(24.934850 / 14.059854\) at ensemble size 8 and \(10.661297 / 2.879392\) at ensemble size 16. None of these four ratios is 5, which would be the ratio of the observation dimensions. Proposition 2 of Katzfuss, Stroud and Wikle is an analogy here, because the ensemble is interacting and the likelihood is a product over time. No curve is drawn. The illustrative thresholds 10 and 10 were not measured.

Place in the paper: kept as these four cells and the account. Not as a confirmation of the thresholds.

## S6. Rao-Blackwellised correction

Identity. From `results/s6-identity.csv`, the maximum absolute difference between the log ensemble Kalman increment and the log Rao-Blackwellised increment was 0 on each of the four replicates. The linear Gaussian identity holds in the run. The correction does not change the weight when \(f = g\).

Discrepancy cell, \(R = 0.1\) for the data and the gold standard, and \(R_g = 0.5\) inside the filter. From `results/summary-s6.csv`.

| Method | Mean absolute error | Transition draws | Error per draw |
| --- | --- | --- | --- |
| Plain filter with \(R_g = 0.5\) | 0.3694299 | 22776 | 1.622014e-05 |
| Rao-Blackwellised filter with \(R_g = 0.5\) | 0.1689277 | 36069 | 4.683460e-06 |
| Rao-Blackwellised filter with \(R_g = 0.1\) | 0.1210414 | 31248 | 3.873572e-06 |

Error per draw is the ratio of the two means. In the discrepancy cell the Rao-Blackwellised filter has the smaller ratio, so on the pre-registered criterion it is worth its cost relative to the plain filter that uses the same \(g\). Both Gaussian observation variances are linear. This is not the nonlinear observation model in Section 5.2 of Golightly et al. (2026). The ordering against SMC2 was not run.

Place in the paper: the identity is kept. The discrepancy cell is kept as an illustration, labelled as Gaussian \(f \ne g\), not as a general rule.

## What remains in the paper

Kept: the neighbour equality and the distance count; the time switch; the surrogate target, with the larger posterior error stated; the four scaling cells; the linear Gaussian identity and the Gaussian discrepancy illustration.

Removed as a method: the finite-difference proposal.
