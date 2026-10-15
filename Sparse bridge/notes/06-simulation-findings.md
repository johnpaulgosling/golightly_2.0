# Simulation findings

Study S1 only. S2 was not run. Part B is parked in `notes/04-theory-agenda.md` and dropped in `notes/05-theory-notes.md`. Every number below is taken from a file in `Sparse bridge/results/`. The pilot files are not cited.

## S1. What was compared

The design in `notes/06-simulation-design.md` fixes the comparison. Data are repeated draws from the Section 4.1 SIR mechanism, observed at spacings 1, 2 and 5. The linear guide is the scalar form of the display after (18). The myopic guide proposes at the unconditioned hazard. Both are given the simulated prevalence at the left endpoint of the window and the simulated contact-rate path. Twenty replicates, 500 draws per window, seed base 20251015. No fine-grid path was discarded (`s1-run-meta.csv` records `n_discarded_paths` 0). The run took 46.879 seconds (`s1-run-meta.csv`, `elapsed_seconds`). That time is a record of this run, not a comparison with Whitaker et al. (2025).

The prediction was that the median, across replicates, of the within-replicate median window ESS of the linear guide would be smaller at spacing 5 than at spacing 1.

## S1. Result

From `s1-study-summary.csv`, linear guide, column `median_ess`:

| Spacing | Median ESS | Median ESS on finite weights | Median proportion invalid |
| --- | --- | --- | --- |
| 1 | 149.660679297905 | 149.660679297905 | 0.0329 |
| 2 | 8.09166818813341 | 8.09166818813341 | 0.009 |
| 5 | 2.05670742297318 | 2.05670742297318 | 0 |

The value at spacing 5 is smaller than the value at spacing 1. The prediction holds. The same file gives the myopic comparator, which was not part of the prediction: 139.525563697813 at spacing 1, 142.824313796391 at spacing 2, and 195.181391518181 at spacing 5. The myopic median does not fall as the spacing grows.

At every linear row of `s1-study-summary.csv`, `median_ess` equals `median_ess_valid`. The fall from spacing 1 to spacing 5 is present in the finite weights. It is not produced by the zero-weight rule. The invalid proportion is largest at spacing 1 and is 0 at spacing 5 in that file.

No gold-standard posterior was computed. The diagnostic does not say whether a filtering distribution of \(\gamma\) or \(\rho\) would change.

## What the claim keeps

The claim that stays is the diagnostic in `notes/05-theory-notes.md`, Section 5.2. On this design, the linear guide's effective sample size is smaller at the coarsest pre-registered spacing than at the published unit spacing, while the draws are still aimed at the printed Algorithm 2 ratio. Two qualifications belong with that sentence.

The guide was given the simulated state and the simulated contact path. A particle in Algorithm 2 does not have either. The result is about \(h^{*}\) given those paths.

At spacing 1 the linear median ESS is 149.660679297905 out of 500 draws. The guide is already uneven on the published grid. The prediction was the comparison across spacings, not a claim that the published grid is unaffected.

The result does not supply a numerical threshold, and it does not measure a pathwise distance to the true conditioned process. The linear-guide rows are not replaced by the residual guide below.

## S2. What was compared

The amendment in `notes/06-simulation-design.md` fixes the comparison. The mechanism, the spacings, the twenty replicates and the seed rule are those of S1. Binomial observations are drawn before the residual proposals. The linear proposals are not redrawn. The prediction was that the median, across replicates, of the within-replicate median window ESS of the residual guide at spacing 5 would be larger than 2.05670742297318, the stored linear median at that spacing.

The numerical step for equations (4), (8) and (9) of Golightly et al. (2023) was 0.1. The pure-death check passed (`s2-run-meta.csv`, `death_check`). No fine-grid path was discarded. The run took 1502.073 seconds (`elapsed_seconds`).

With two windows, the within-replicate median is the average of the two window values. That is the median R returns for an even count of two, and it is the same functional as the linear spacing-5 summary.

## S2. Result

From `s2-study-summary.csv`, residual guide, column `median_ess`:

| Spacing | Median ESS | Median ESS on finite weights | Median proportion invalid |
| --- | --- | --- | --- |
| 1 | 281.708848707666 | 281.708848707666 | 0.0287 |
| 2 | 236.47088660943 | 236.47088660943 | 0.0096 |
| 5 | 169.453475371897 | 173.333046076685 | 5e-04 |

The value at spacing 5 is larger than 2.05670742297318. The prediction holds. The residual median declines from spacing 1 to spacing 5. It does not fall to the linear-guide value.

At spacing 5, `median_ess` and `median_ess_valid` differ. The file records 169.453475371897 and 173.333046076685. The difference is small beside the gap from the linear median. The median invalid proportion at spacing 5 is the stored value 5e-04.

That median proportion does not describe every replicate. In `s2-window-ess.csv`, at spacing 5, five of the twenty first windows have `n_invalid` equal to 500, so every residual draw in that window has weight zero. The second window in each of those replicates has `n_invalid` 0. The median ESS of the twenty first windows is 5.87283517539277. The median ESS of the twenty second windows is 331.985239567309. These two medians are descriptions of the stored window file. They were not the pre-registered summary. The linear guide, in `s1-window-ess.csv`, has median ESS 1.36201529794476 on the first window at spacing 5 and 1.61726241454208 on the second, and no window has ESS 0.

The pre-registered residual number at spacing 5 therefore mixes a weak first window with a much stronger second window. The comparison with 2.05670742297318 still uses the functional named before the run.

No gold-standard posterior was computed. The Ebola and COVID-19 series remain unused.
