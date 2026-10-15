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

The result does not supply a numerical threshold, and it does not measure a pathwise distance to the true conditioned process. Part B remains dropped. Nothing from the "Dropped" list in the theory note is reinstated.
