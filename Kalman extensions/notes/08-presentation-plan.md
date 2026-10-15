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
