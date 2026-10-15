# Presentation plan

Read against `STYLE.md` sections 5 and 12. The manuscript is not drafted in this session. Phase 8 has not been started. A later draft follows this note and does not reopen the scientific choices below.

## What goes where

Part A, the diagnostic in `notes/05-theory-notes.md` and the comparison in `notes/06-simulation-findings.md`, is main text. The finding that justifies that place is the pre-registered drop in median effective sample size from spacing 1 to spacing 5, with the two qualifications in the findings note.

Part B is future work. No replacement of \(q\) was stated. The discussion says why equation (19) of Golightly and Sherlock (2019) and Theorem 4.2 of Corstanje et al. (2023) were not put into Algorithm 2, in the words of the theory note, Section 5.3. It does not present either construction as a method of this paper.

There is no application section. Task 6b.1 declined both series.

## Title, venue, voice

Working title: A diagnostic for the linear incidence guide under sparse observation.

Venue: *Journal of Computational and Graphical Statistics*. No reason is recorded to write for *Bayesian Analysis* instead.

Voice: we. British spelling until a submission-ready version is requested (`STYLE.md` section 12.1).

## Section list

1. Introduction. The 2025 filter, the sentence on p. 25, and the contribution: a reading of what that sentence refers to, and a diagnostic. Part B is named as open.
2. Related work. The comparison table in `notes/02-literature-summary.md`. Cells that are `[PDF NOT STORED]` stay out of the table, or carry the fact that Whitaker et al. (2025) name the work and that it was not read.
3. The 2025 filter and the linear guide. The restatement in the theory note, Section 5.1, including the scalar SIR form and the statement that the printed weight's numerator does not contain \(h^{*}\).
4. Diagnostic. The effective sample size, the constant-hazard reading, and what is not claimed.
5. Simulation. Study S1 only, with numbers taken from the findings note.
6. Discussion. Qualifications, the parked replacement, and the declined application.

## Displays

- One schematic of Algorithm 2. The proposal \(q\) is marked as the object of the diagnostic. It is not marked as replaced.
- One display of effective sample size against spacing for the linear guide, from `Sparse bridge/results/s1-window-ess.csv` or the study summary, with the myopic comparator if the caption says it is not the prediction.
- No S2 display.

## What is not claimed

Copied from the theory note, Section 5.4, together with the findings qualifications.

- No replacement of \(q\) by Golightly and Sherlock (2019), equation (19), or by Corstanje et al. (2023), Theorem 4.2.
- No deletion of \(h(0, x_0)\) from the ratio (16).
- No truncation of a negative \(h^{*}\) presented as the 2025 guide.
- No numerical spacing at which the guide fails, beyond the three spacings that were pre-registered and the comparison that was stored.
- No claim that a poor \(h^{*}\) changes the filtering target.
- No use of the death-model table in Golightly and Sherlock (2019) as a dSEIR result.
- No gold-standard posterior, and no Ebola or COVID-19 analysis.

## Word budget

The venue guidance in `STYLE.md` section 12 is about 8,000 words, including appendices, references, tables and figures. The draft stays under that. A diagnostic article without a replacement and without an application should be shorter. The abstract, when written, is one paragraph of 140 to 200 words, with no citations and no displayed equations, in the order of `STYLE.md` section 5.2.

## What the drafter still needs

The findings note for every number. The theory note for the algorithm. The literature note for citations. Works marked `[PDF NOT STORED]` are cited only as names in Whitaker et al. (2025), with the sentence saying they were not read. This session does not write `Sparse bridge/paper/`.
