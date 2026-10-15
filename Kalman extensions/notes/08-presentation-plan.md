# Presentation plan

Read against `STYLE.md` sections 5 and 12. The contents follow the findings note, not the default cut in the research plan.

## Decisions

- Working title: Extensions of a nested ensemble Kalman filter.
- Venue: *Journal of Computational and Graphical Statistics*. No reason arose to move to *Statistics and Computing*. British spelling until a submission version is requested.
- Voice: we.
- No application section. `notes/07-application-choice.md` declines a real series.
- Word budget: at or under 8000 words, including the reference list. The draft should stay well under that, because the numerical section is one pilot.

## Where each extension goes

- E1, neighbour equality and the distance count: main text. The neighbour sets agreed, and the tree evaluated fewer distances on the recorded count.
- E2, the time switch: main text. It had the lowest mean cost per accepted move.
- E3, finite-difference proposal: not a method. One paragraph in the simulation section reports the negative comparison. The discussion lists it as dropped.
- E4, surrogate weights: main text, including the larger posterior error.
- E5, scaling: main text as four cells and the account. Not a figure with a fitted boundary.
- E6, linear Gaussian identity, and the Gaussian discrepancy illustration: main text.

## Section list

1. Introduction.
2. Related work, drawn from the comparison table in `notes/02-literature-summary.md`.
3. Methods: the restated filter, delayed acceptance, the kernel switch, surrogate weights, the Rao-Blackwellised identity.
4. Simulation studies.
5. Discussion: what the pilot supports, and what remains open. No application.

## Displays

- One accuracy-against-cost scatter of mean absolute error against mean transition draws, for the methods that remain and for the finite-difference proposal as a comparison point. File `paper/figures/cost-error.pdf`, drawn from `results/summary-s2.csv`, `results/summary-s3.csv` and `results/summary-s4.csv`.
- Table of kernel costs (S2).
- Table of neighbour counts (S1).
- Table of log-likelihood variances (S5).
- Table of the Rao-Blackwellised comparison (S6).
- No schematic beyond the numbered algorithms in the methods section. A diagram would repeat Algorithm B.

## What is not claimed

Copied from the Dropped list in `notes/05-theory-notes.md`, including the amendment of 15 October 2026. In particular: no particle-Gibbs switch, no uncorrected Langevin proposal, no bound on the surrogate posterior, no theorem at the thresholds 10 and 10, and no recommendation of the finite-difference proposal. The pilot is not a reproduction of the 2026 tables.

## Abstract

One paragraph, 140 to 200 words, no citations and no displayed equations, in the order in `STYLE.md` section 5.2. Keywords after it, three to six, alphabetical, not repeating the title wording.

## Amendment, 15 October 2026. The manuscript is recentred

This amendment replaces the decisions under "Where each extension goes" and the section list. The pilot findings for S1 to S6 stay available. They do not lead the paper.

- Working title: Likelihood targets of a nested ensemble Kalman filter.
- Venue and voice are unchanged. British spelling. No application section.
- E1 and E2: not contributions. One sentence may say that the pilot already compared a tree with a list and a time switch with two fixed kernels. No table of those counts in the main text, and no further analysis.
- E3: remains dropped. One sentence in the discussion, pointing at the findings note, is enough. It is not a results table.
- E4: main text, as the second of the two errors. The target is \(\pi_{\mathrm{knn}}\). The bound was not obtained. The paper says so and reports the existing diagnostic, the mean of the median absolute log difference. No new surrogate run.
- E5: not a contribution of the recentred paper. The four variance cells stay in the findings note. The discussion may say that they were measured and that they do not confirm a threshold. They are not a main display.
- E6: the linear Gaussian identity is a lemma. The Ornstein–Uhlenbeck identity run is the check. The Gaussian discrepancy cell, \(R_g = 0.5\), is not the nonlinear comparison and is not presented as one. A sentence may record that it was a Gaussian illustration.
- S7: main text. One table of the plain filter, the Rao-Blackwellised filter and SMC2 on the Lotka–Volterra series. The prose states the pre-registered verdict from the findings note and does not add a comparison that the design did not name.

Section list:

1. Introduction, with the contribution being the separation of the two errors and the comparison of \(\hat{\pi}_{\mathrm{enkf}}\), \(\tilde{\pi}_{\mathrm{enkf}}\) and \(\pi_t\) on the nonlinear observation model.
2. Related work, kept only so far as it separates those targets from SMC2, from ensemble MCMC, and from a surrogate that is used as a screen rather than as a weight.
3. Methods: the two errors, the three targets, the identity lemma, and the statement that the total-variation route did not close.
4. Simulation: the identity check, the surrogate diagnostic, and S7.
5. Discussion: what S7 showed, the missing bound, and the extensions that are not claimed.

The word budget remains at or under 8000 words. The numerical section is the identity, the diagnostic and one Lotka–Volterra table.

## Amendment, 15 October 2026. Standalone manuscript

This amendment replaces the instruction that the draft should stay short, and the instruction that there is no schematic. The manuscript is a standalone paper. It does not cite notes, result files, seeds stored in the repository, or runs that are not part of the claim.

- Figure of the four parameter targets, with the two errors marked.
- Figure of one Lotka–Volterra observation update, with the plain increment, the Rao-Blackwellised increment and bootstrap SMC2.
- Figure of mean absolute error against transition draws for the Ornstein–Uhlenbeck checks.
- Figure of the Lotka–Volterra differences from SMC2, with the standard-error bars.
- The linear Gaussian discrepancy cell and the surrogate-weight error are reported as experiments of the paper, with the settings written out. They are not pointers to a results file.
