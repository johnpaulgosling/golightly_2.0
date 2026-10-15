# Simulation design

Written before the code in `R/` and before any run. Date: 15 October 2026. The question and the diagnostic are those in `notes/05-theory-notes.md`, Section 5.2. This note does not report output.

## What is not run

Study S2 is not designed and is not run. Part B is parked, so there is no replacement proposal to put in place of \(q\). A run of S2 would simulate a dropped claim.

No gold-standard posterior is computed. Whitaker et al. (2025), Section 4.1, use a pseudo-marginal Metropolis–Hastings run of \(10^6\) iterations as a gold standard for posterior summaries of \(\gamma\) and \(\rho\). S1 does not estimate that posterior. Wall clock time is stored as a secondary record and is not used to accept or reject the prediction.

Ebola and COVID-19 counts are not used. They are not stored.

## S1. Effective sample size of the linear guide

Question. On data generated from the Section 4.1 SIR mechanism, is the median effective sample size of the linear incidence guide smaller at observation spacing 5 than at the published spacing 1?

What would count as the prediction failing. The median defined below is not smaller at spacing 5 than at spacing 1, or it is smaller for a reason Section 5.2 did not name. The findings note then qualifies the claim. The spacings, \(N_{\mathrm{prop}}\) and the invalid-draw rule are not changed after the output is seen, except by a dated amendment at the end of this file.

### Data-generating mechanism

Section 4.1, one replicate at a time. The published figure is a single untabulated series. S1 repeats the mechanism. It does not claim to recover Figure 1.

- Initial state \((s_0, i_0) = (762, 5)\). Removed is not stored. There is no exposed class.
- \(\gamma = 0.5\), \(\tilde{\beta}_0 = -6\), \(\lambda = 100\), binomial reporting probability \(\rho = 0.9\).
- Contact-rate step, equation (2): \(\tilde{\beta} \leftarrow \tilde{\beta} + \lambda^{-1/2} \Delta W\) with \(\Delta W \sim \mathcal{N}(0, \Delta t)\). Drift is zero.
- Forward simulation is Algorithm 1 for SIR, with two Poisson increments. The infection hazard is \(e^{\tilde{\beta}} s i\). The removal hazard is \(\gamma i\). The time step is \(0.001\) on \([0, 10]\), so \(10^4\) steps.
- If any fine-grid step would make \(s\) or \(i\) negative, that replicate is discarded and drawn again. The cap is 100 attempts. The script stops if the cap is hit. The count of discarded attempts is stored.

Observations. Infections are summed on the fine grid over each window, then one binomial draw with probability \(\rho\) is taken. That is the Section 4.1 construction, coarsened as follows. The horizon is 10. The pre-registered spacings are \(\Delta_{\mathrm{obs}} \in \{1, 2, 5\}\).

| Spacing | Windows | Number of windows | Substeps at \(\Delta\tau = 0.1\) |
| --- | --- | --- | --- |
| 1 | \((0,1],\ldots,(9,10]\) | 10 | 10 |
| 2 | \((0,2],\ldots,(8,10]\) | 5 | 20 |
| 5 | \((0,5],(5,10]\) | 2 | 50 |

Spacing 1 is the published grid. Spacings 2 and 5 are coarser. They were chosen because they divide the horizon, and because 5 is the coarsest divisor that still leaves two windows. They were not chosen from a weight.

### What each draw conditions on

For every window, the prevalence at the left endpoint is the simulated prevalence at that time, and the log contact rate at the left endpoint of each substep of length \(0.1\) is the simulated value at that time. \(\gamma\) and \(\rho\) stay at the simulation values. The filter's particle would not have this prevalence or this contact path. Section 5.1 of the theory note states that restriction. The weight's transition is still the \(\Delta\tau = 0.1\) dSIR transition, not the fine-grid transition that generated the counts. That is the same split as Section 4.1: generate at step \(0.001\), propagate at step \(0.1\).

### Proposals

Two guides, on the same simulated path and the same observations. Their Poisson draws are independent. The linear guide is run first.

- Linear. The scalar form of \(h^{*}\) in the theory note, Section 5.1, binomial variance (14) at \(\hat{\mu}\).
- Myopic. The same function with \(h^{*}\) replaced by \(h\). This is a comparator. It is not a second target, and it is not part of the prediction.

\(N_{\mathrm{prop}} = 500\) draws in each window. This is not the particle count \(N\) of the published filter.

Invalid draw, both guides. The weight is 0, the path stops, and the draw is counted as invalid, if any of the following holds:

- the denominator \(\rho^{2} h_{\mathrm{inf}}(t_i - \tau) + \sigma^{2}\) is 0, or is not finite;
- a component of the hazard passed to the Poisson generator is negative or is not finite;
- the updated \(s\) or \(i\) would be negative.

No ridge is added when the binomial variance is 0. A negative infection component of \(h^{*}\) is not replaced by 0.

### Effective sample size

For each replicate, each spacing, each guide and each window, compute ESS on the \(N_{\mathrm{prop}}\) unnormalised weights, zeros included, by the formula in the theory note. If every weight is zero, record ESS as 0 and flag the window. Also compute ESS on the finite weights only. If there is no finite weight, that second value is missing.

The within-replicate summary is the median of the window ESS values. Each replicate then contributes one number per spacing and guide, whether it has 10 windows or two.

The study summary is the median of those 20 numbers. The prediction uses the linear guide only: that median at spacing 5 is smaller than that median at spacing 1.

Secondary columns, stored and not used as a second prediction: the same median of the valid-only ESS; the proportion of invalid draws in the replicate, averaged in the study summary by a median across replicates; the myopic study summary at the same three spacings.

### Replicates and seeds

Twenty replicates. Seeds are not part of the algorithm. Replicate \(r \in \{1,\ldots,20\}\) starts at seed \(20251015 + r\). If attempt \(a \in \{0, 1, \ldots\}\) is required because the fine path was invalid, the seed is \(20251015 + r + 100000 a\). After a valid path, the same stream draws the binomial observations in spacing order 1, 2, 5, then the linear proposals in that spacing order, then the myopic proposals in that spacing order.

### Output

Written by `scripts/study-sparse-bridge-s1.R`.

| File | Contents |
| --- | --- |
| `Sparse bridge/results/s1-window-ess.csv` | One row per replicate, spacing, guide and window |
| `Sparse bridge/results/s1-replicate-summary.csv` | One row per replicate, spacing and guide |
| `Sparse bridge/results/s1-study-summary.csv` | One row per spacing and guide, the medians above |
| `Sparse bridge/results/s1-run-meta.csv` | Seed rule, \(N_{\mathrm{prop}}\), discarded fine paths, wall clock |

The findings note may cite only these files. A figure is not required for the claim. The presentation plan may later plot the window ESS against spacing from `s1-window-ess.csv`.

### Pilot switch

The script accepts an argument, defaulting to the full design above. The pilot is pre-registered here and is not a substitute for the full run. It uses two replicates, \(N_{\mathrm{prop}} = 50\), the same spacings, the same seed rule, and writes `s1-pilot-` prefixed files. Those files are not cited by the findings note. The pilot exists so a later session can check that the script finishes. It was declared before either run.

## Amendment, 15 October 2026. Study S2

The sentence above that S2 is not designed is superseded by this amendment. S1 is unchanged. S2 was not run when this amendment was written.

The proposal is the residual incidence guide stated in `notes/05-theory-notes.md`, Section 5.3, as amended on this date. It replaces \(q\) only. The numerator of the Algorithm 2 weight stays the dSIR transition times the binomial probability.

Question. On the same Section 4.1 mechanism as S1, is the median effective sample size of the residual guide at spacing 5 larger than the stored linear-guide median at spacing 5?

The stored linear median is 2.05670742297318, from `s1-study-summary.csv`. It is not recomputed. The prediction uses that number as the bar. It was fixed before any residual effective sample size was stored.

What would count as the prediction failing. The residual median defined below is not larger than 2.05670742297318. The findings note then qualifies the claim. The spacings, \(N_{\mathrm{prop}}\), the numerical ODE step and the invalid-draw rule are not changed after the output is seen.

### What is held from S1

The data-generating mechanism, the three spacings, the substep \(\Delta\tau = 0.1\), the supplied prevalence and contact-rate path, \(N_{\mathrm{prop}} = 500\), the twenty replicates and the seed rule are those of S1. Replicate \(r\) is simulated from seed \(20251015 + r\), with the same retry rule. Binomial observations are drawn in spacing order 1, 2, 5, and then the residual proposals are drawn in that spacing order. The linear and myopic proposals of S1 are not redrawn, so this script does not continue their random stream. The paths and the observations match S1 because those draws occur before either script's proposals.

### Numerical step

The incidence ODE and the linear-noise variance are integrated by a classical Runge–Kutta step of length 0.1. That length is not a step in Golightly et al. (2023). It was fixed after comparing the end mean and variance, on the Section 4.1 initial state over an interval of length 5, with a step of 0.02. The relative differences were smaller than \(10^{-3}\). They are not retuned from the effective sample size.

A separate check, run before the proposals, integrates a pure death process with removal rate 0.5 from 10 infectives over an interval of length 5. The end removal count is compared with \(10(1 - e^{-2.5})\). The script stops if the absolute error exceeds \(10^{-4}\).

### Invalid draw

The S1 rule applies. In addition, the weight is 0 if the restarted integration stops because a prevalence on the ODE would be negative, if the determinant of the fundamental matrix at the next substep is smaller than \(10^{-12}\) in absolute value, or if either Poisson mean is negative or is not finite. A negative mean is not replaced by 0.

### Summary

The within-replicate summary and the study summary are defined as in S1, for the residual guide only. The prediction is the comparison of `median_ess` at spacing 5 with 2.05670742297318.

Secondary columns, stored and not used as a second prediction: the median of the valid-only ESS, the median proportion of invalid draws, and the same medians at spacings 1 and 2.

### Output

Written by `scripts/study-sparse-bridge-s2.R`.

| File | Contents |
| --- | --- |
| `Sparse bridge/results/s2-window-ess.csv` | One row per replicate, spacing and window |
| `Sparse bridge/results/s2-replicate-summary.csv` | One row per replicate and spacing |
| `Sparse bridge/results/s2-study-summary.csv` | One row per spacing, the medians above |
| `Sparse bridge/results/s2-run-meta.csv` | Seed rule, \(N_{\mathrm{prop}}\), ODE step, discarded fine paths, wall clock |

The pilot switch uses two replicates and \(N_{\mathrm{prop}} = 50\), and writes `s2-pilot-` prefixed files. Those files are not cited by the findings note.
