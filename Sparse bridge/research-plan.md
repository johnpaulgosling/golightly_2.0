# Research plan: a guide for sparsely observed cumulative incidence

This file is the task list for work on the conditioned hazard in Whitaker, Golightly, Gillespie and Kypraios (2025). It tells a later agent what to read, what to produce, and when to stop. It is not a summary of the literature, and it is not a result. Cite the notes and the PDFs, not this plan.

Do the phases in order. Do not write code, derivations, or manuscript prose until the phase that asks for them. Update the status table when a deliverable exists.

## How to take up this plan

1. Read `AGENTS.md`, `STYLE.md`, and `.cursor/skills/r-coding/SKILL.md` before drafting prose or R.
2. Read this file from the status table to the end of the phase you are about to start.
3. Do one phase, or one task inside the current phase. Leave a handover note at the end of this file if you stop mid-task.
4. British English in every note, commit message, and manuscript draft. No em dashes. Run `scripts/check_british_spelling.sh` on text you add.
5. Do not invent citations, theorem numbers, algorithm numbers, equation numbers, or numerical results. If a source has not been opened, write `[NOT READ]`. If a PDF is not stored in the repository, write `[PDF NOT STORED]`. If a citation is needed and not yet verified, write `[CITATION NEEDED]`.
6. The 2025 filter and the proposed replacement guides are different objects. Do not describe an algorithm from Golightly and Sherlock (2019) or from Corstanje, van der Meulen and Schauer (2023) unless that PDF has been opened and the section has been read. A paraphrase in another paper, or in `Scoping research/scoping-note.md`, is not a substitute.
7. Code, when a later phase asks for it, is base R and follows the R coding skill. Do not add a package on your own initiative. Algorithm functions go in `R/`, with names that do not begin `nenkf`. Study scripts go in `scripts/`, and must not replace `scripts/study-s*` or `scripts/reproduce-nenkf-extensions.R`. Notes, the manuscript, and PDFs for this programme stay under `Sparse bridge/`.

## Status

| ID | Task | Status | Deliverable |
| --- | --- | --- | --- |
| 1.1 | Read the 2025 epidemic filter paper | done | `notes/01-paper-context.md` |
| 1.2 | Extract the open problem in the paper's own words | done | same file, section "Open problem" |
| 1.3 | Freeze notation | done | same file, section "Notation" |
| 2.1 | Summarise the literature already opened | done | `notes/02-literature-summary.md` |
| 2.2 | Comparison of guides, with unread cells left empty | done | same file, section "Comparison" |
| 3.1 | Obtain and file the missing named sources, or stop | done | three PDFs in `Literature/`; summary blocks in `notes/02-literature-summary.md` |
| 3.2 | Search for work the named sources do not cover | done | `notes/03-search-log.md` |
| 4.1 | Write the theory agenda | done | `notes/04-theory-agenda.md` |
| 4.2 | Decide what will be attempted | done | same file, section "Scope decision" |
| 5.1 | Restate the 2025 filter and the linear guide | done | `notes/05-theory-notes.md` |
| 5.2 | Settle when the linear guide is inconsistent | done | same file, section "5.2" |
| 5.3 | Settle the replacement proposal | parked | same file, section "5.3"; no modified algorithm |
| 5.4 | Record failures and drop what will not be claimed | done | same file, section "Dropped" |
| 6.1 | Design the simulation studies | done | `notes/06-simulation-design.md`; S2 omitted because 5.3 is parked |
| 6.2 | Implement the algorithms in base R | done | `R/models-dsir.R`, `R/dsir-linear-guide.R`. No `R/dsir-filter.R`: S1 does not run rejuvenation. No replacement file |
| 6.3 | Run the studies and store the output | done | `scripts/study-sparse-bridge-s1.R`, `results/s1-*.csv`. S2 not run |
| 6.4 | Write the numerical findings | done | `notes/06-simulation-findings.md` |
| 6b.1 | Choose or decline a real application | done | `notes/07-application-choice.md`; declined |
| 6b.2 | Carry out the chosen application | parked | skipped because 6b.1 declined |
| 7.1 | Plan the paper | done | `notes/08-presentation-plan.md`; manuscript not drafted |
| 8.1 | Write the LaTeX manuscript | not started | `paper/` |
| 9.1 | Write the reproduction script | not started | `scripts/reproduce-sparse-bridge.R` |

Status values are `not started`, `in progress`, `done`, and `parked`. A parked task needs one sentence in the handover section saying why. Do not mark a task done until its deliverable is in the repository and the acceptance lines for that task hold.

## Scope

The source of the question is the limitations section of Whitaker, Golightly, Gillespie and Kypraios (2025), *Bayesian Analysis*, DOI 10.1214/25-BA1547, file `Source papers/4992336VoR.pdf`, together with the future-work bullet in `Scoping research/scoping-note.md` under "From the epidemic paper". The scoping note is a paraphrase. The PDF is the source.

The paper's filter propagates latent incidence with a conditioned hazard. That hazard is a Gaussian approximation of remaining incidence and of the next observation, and the limitations section adds an assumption that the latent process is linear over an interval no longer than the observation interval. The paper says that when observations are sparse enough for that assumption to fail, the hazard is likely to propose trajectories inconsistent with the true conditioned process. It points to guided samplers for conditioned jump processes, in particular Golightly and Sherlock (2019) and Corstanje, van der Meulen and Schauer (2023).

### The question this plan fixes

When is the linear incidence guide in Section 3.4 of Whitaker et al. (2025) inconsistent, and what proposal replaces it for sparsely observed cumulative incidence, while the rest of that paper's filter stays in place?

Two parts, and they stay in this order:

| Label | Question | Role |
| --- | --- | --- |
| A | When is the guide printed after equation (18) inconsistent with the incidence process the filter is trying to condition on? | Diagnosis. No numerical threshold is claimed until a later note derives one or a simulation measures one |
| B | Which proposal replaces the draw from \(q\) in Algorithm 2, once the named guides have been read? | The only algorithmic change this programme is allowed to make |

Part A is allowed to use only Whitaker et al. (2025) until the other PDFs arrive. Part B is not allowed to name a replacement algorithm until task 3.1 has filed the PDF that states it.

### What this plan does not cover

- An adaptive Poisson step, the other limitation in Section 5.1 of the 2025 paper. Gillespie (2001), Cao, Gillespie and Petzold (2006) and Sandmann (2009) stay out of this folder except as names the 2025 paper already prints.
- Degeneracy of the sufficient statistic, and the comparison with SMC2, the third limitation in Section 5.1. That comparison is not this programme. Do not edit `Kalman extensions/`, `R/nenkf*`, `scripts/study-s*`, or `scripts/reproduce-nenkf-extensions.R`.
- A new epidemic model. The inferential model remains the time-discretised S(E)IR model of the 2025 paper.
- Reimplementation of Lowe, Golightly and Sherlock (2023) or of Jovanovski, Golightly and Picchini (2024). Those papers are context for how linear-Gaussian guides behave. They are not the filter being modified.
- Any hazard, bridge, or guiding formula whose own paper has not been opened.

### Default shape of the eventual paper

Aim at one journal article. The working default, to be confirmed or overturned in task 4.2 and again in task 7.1, is:

- Centre: part A, a precise account of when the Section 3.4 guide is inconsistent, and part B, one replacement proposal inside Algorithm 2.
- The rest of the 2025 filter (blind propagation of the contact-rate path, the importance weight, the sufficient statistic, and the conditional parameter update) is held fixed and is described only so far as the replacement needs.
- A real series only if task 6b.1 finds the counts stored in a form that can be reproduced. Otherwise the manuscript has a simulation section and no application section.

The venue is the *Journal of Computational and Graphical Statistics*. The voice is *we*. Write British English until a submission-ready version is requested (`STYLE.md` section 12.1). The length guidance in `STYLE.md` section 12 is about 8,000 words including appendices, references, tables and figures. Phase 7 must cut to that scale.

## Repository map

| Path | What it is |
| --- | --- |
| `Source papers/4992336VoR.pdf` | Whitaker et al. (2025), the filter this programme keeps |
| `Source papers/38253VoR.pdf` | Lowe, Golightly and Sherlock (2023). Context only. Sections opened are listed in the literature note |
| `Source papers/3033124AOV.pdf` | Jovanovski, Golightly and Picchini (2024). Context only. Sections opened are listed in the literature note |
| `Scoping research/scoping-note.md` | Where the question was identified. Not a substitute for a PDF |
| `Sparse bridge/Literature/` | Create this when a missing PDF is filed. Do not put those PDFs in `Kalman extensions/Literature/` |
| `Sparse bridge/notes/` | One markdown file per deliverable above |
| `Sparse bridge/paper/` | Create this in phase 8 |
| `Sparse bridge/results/` | Numerical output from phase 6. Store tables as plain text or CSV |
| `R/`, `scripts/` | Code, under the R coding skill, with the filenames in task 6.2 and task 9.1 |

## Phase 1. Read the 2025 paper

Purpose: a context note that later phases can cite, so they do not drift from what the paper says.

### Task 1.1. Read the paper

Read `Source papers/4992336VoR.pdf`. The section headings are: 1 Introduction; 2 Stochastic epidemic models (2.1 Time-varying contact rate, 2.2 Time-discretised model); 3 Sequential Bayesian inference (3.1 Observation model, 3.2 Inference task, 3.3 Particle filter approach, 3.4 Bridge construct); 4 Applications (4.1 Simulation study, 4.2 Ebola, 4.3 Covid-19 in New York); 5 Summary (5.1 Limitations).

Write `notes/01-paper-context.md` with:

- the model class and the filtering target;
- the observation models;
- the particle filter, including what is propagated, what the weight uses, and how static parameters are rejuvenated;
- the conditioned hazard in Section 3.4, as printed, with equation numbers that appear in the PDF;
- the three applications: what is observed, what is static, and which comparator is used;
- whether the weekly counts are printed as a table or only drawn in a figure, and whether a data file is already in the repository;
- the code repository named in the paper, and that this repository does not contain that code.

Acceptance: a reader of the note can restate the filter and the guide without opening the PDF, and every structural claim carries a section or page that was read. Do not copy long passages. Paraphrase, and quote the sentences needed in task 1.2.

### Task 1.2. Extract the open problem in the paper's own words

In the same file, add "Open problem". Quote the limitations paragraph that states the failure of the conditioned hazard, with the page. Then quote the other limitations paragraphs, with pages, and mark them outside this programme, as the scope section already does. If the scoping note says something that is not in Section 5.1, mark it "scoping note only" and do not build a method on it.

Acceptance: part A and part B each point at a page in Section 5.1, or are marked as scoping-note only.

### Task 1.3. Freeze notation

In the same file, add "Notation". Use the paper's symbols. At least: time index, state, cumulative incidence, hazard, net effect matrix, contact-rate SDE, discretisation step, observation, static parameter, particle index, sufficient statistic, the conditioned hazard, the bridge proposal \(q\), and the importance weight.

If the paper's notation conflicts with itself, record both and choose one. Later phases must use that choice.

Acceptance: later notes can use these symbols without redefining them.

## Phase 2. Summarise the literature already in the repository

Purpose: relevance to parts A and B, not a general review of bridges.

### Task 2.1. Write the summary

Create `notes/02-literature-summary.md`. Summarise only files that have been opened. For each opened file, record:

- the citation as printed on the work;
- the path;
- which sections were read, and a statement if the reading stopped early;
- the question the paper answers;
- what it says that bears on part A or part B, with the page;
- what it does not give us;
- a sentence on how it differs from the object in Whitaker et al. (2025), Section 3.4.

Do not fill a Golightly and Sherlock (2019) or Corstanje et al. (2023) block from memory, from the scoping note, or from a citation in another paper. A secondary account may be summarised only as a statement in the paper that was opened, and it must be labelled as secondary.

Acceptance: every claim about a guide cites a page that was read. Unread guides appear only in the `[PDF NOT STORED]` list.

### Task 2.2. Comparison table

In the same file, add "Comparison". Rows are the guides that task 2.1 and task 3.1 name. Columns: what is propagated, what the proposal conditions on, whether an importance weight corrects the proposal, and the citation. Fill a cell with `[NOT READ]` or `[PDF NOT STORED]` rather than a guess. This table is the one phase 7 will turn into the paper's related-work display.

## Phase 3. Obtain the missing guides, or stop

### Task 3.1. Named sources that are not in the repository

The 2025 paper names the following in connection with the conditioned hazard. Obtain a copy that can be stored. Prefer an author manuscript or an open copy. If a file cannot be stored, leave the `[PDF NOT STORED]` line and stop. Do not bypass a paywall. Do not reconstruct the algorithm.

- Golightly and Sherlock (2019), *Statistics and Computing* 29, 1149–1163. DOI as printed in Whitaker et al. (2025): 10.1007/s11222-019-09861-5. Required for part B. The limitations section names it as work on sampling conditioned jump processes that could be adapted to the dS(E)IR model.
- Corstanje, van der Meulen and Schauer (2023), *Stochastics* 95, 963–996. DOI as printed in Whitaker et al. (2025): 10.1080/17442508.2022.2150081. Required for part B, for the same sentence. The paper does not say which of the two references is the replacement. Both have to be read before one is chosen.
- Golightly and Wilkinson (2015), *Statistical Applications in Genetics and Molecular Biology* 14, 169–188. DOI as printed in Whitaker et al. (2025): 10.1515/sagmb-2014-0070. Whitaker et al. (2025) say that their bridge adapts this conditioned hazard. Until this PDF is stored, later phases may use only the derivation Whitaker et al. print in Section 3.4, and must not claim what was changed relative to the 2015 hazard.

Filename for a new PDF: `AuthorYear-short-title.pdf`, ASCII, hyphens, no spaces. Example: `Golightly2019-conditioned-markov-jump-processes.pdf`. Store it in `Sparse bridge/Literature/`. Append a summary block, from the PDF, to `notes/02-literature-summary.md`.

Also cited beside the bridge, and not a substitute for the three items above:

- Golightly and Kypraios (2018), named on pp. 2–3 of Whitaker et al. (2025) with "see also". `[PDF NOT STORED]`. Do not treat it as the replacement guide.
- The supplement Whitaker et al. (2025), DOI 10.1214/25-BA1547SUPP. `[PDF NOT STORED]`. The main text says it contains further synthetic experiments and linear-noise details, not the bridge derivation.

Acceptance: each of the three bullets is either a summary block with a path, or an explicit `[PDF NOT STORED]` line. If either of the two replacement guides is `[PDF NOT STORED]`, do not start phase 4.

### Task 3.2. Search beyond the named list

Start this only after both replacement guides have been read. Keep a log in `notes/03-search-log.md`: date, query, where you searched, what you opened, and whether you filed it. One gap: does a paper already replace the Section 3.4 hazard inside the 2025 filter, or already state a condition for when that hazard is inconsistent?

Stop when a further query repeats methods already summarised. Write a short "Saturation" section. An empty gap is a legitimate outcome. Do not download a paywalled PDF.

## Phase 4. Decide what mathematics is needed

Purpose: a list of questions, not their answers. Phase 5 answers them. Do not start this phase while task 3.1 is parked.

### Task 4.1. Theory agenda

Write `notes/04-theory-agenda.md`. Include:

- the target Algorithm 2 is meant to represent, as stated in the context note, and whether part B is allowed to change it;
- what phase 2 and phase 3 already prove or already implement;
- the gap for part A, as a question a derivation or a counter-example could close;
- the gap for part B, naming the result in a PDF that has been read which would be adapted, with the section;
- what "solved" means (a stated result with the assumptions, a stated algorithm with the weight written out, or a diagnostic because no bound is available);
- the fallback if the argument fails, which must be a smaller claim, not a silent approximation.

Use the questions below as the starting list. Strike, split, or add questions so that the list matches task 1.2 and the literature summary. Do not leave a question in the list if the literature summary shows it is already settled, and say where it was settled.

**Part A, take this first.**

- Equation (12) freezes the hazard at the current state over the whole remaining time to the next observation. The limitations section calls a further assumption linearity of the latent process. Are these the same assumption, or does the limitations section add something Section 3.4 does not contain? Answer from the pages, not from a new expansion.
- The paper says the guide is likely to propose inconsistent trajectories when cumulative incidence does not evolve linearly. Inconsistent with which law: the dS(E)IR transition, the law of the jump process, or the law of the path conditional on the next observation? Quote the page and do not widen it.
- Algorithm 2 weights by the dS(E)IR transition times the observation probability, divided by \(q\). Does a poor \(q\) change the filtering target, or only the finite-sample quality of the particle approximation? If the second, say so, and define inconsistency as a property of the proposal rather than of the target.
- What observable would show the failure before any replacement is tried? Candidates to define, not to tune after a run: effective sample size of the importance weights; a comparison of the proposed incidence with the incidence under the unconditioned dS(E)IR law on the same interval; a comparison against a filter that uses a finer observation grid. Choose the criterion in this note. Do not invent a numerical threshold.

**Part B.**

- For each stored guide, write the proposal it actually samples, the observation it conditions on, and the assumptions that would fail for cumulative incidence of a dS(E)IR model. Cite the section.
- Say which pieces of Algorithm 2 stay: the blind contact-rate propagation, the weight, the sufficient statistic, and the conditional draws of the rate parameters. A replacement that changes the observation model or the rejuvenation step is a different paper.
- The 2025 weight divides by \(q\). A replacement proposal has to be evaluated, not only sampled. If a guide can be sampled but its density is not available, it does not drop into Algorithm 2 as written. Record that as a reason to park it.
- Do not adopt a proposal that leaves the target only in the limit of a continuous-time scheme unless the agenda shows that the limit is the dS(E)IR model on the grid the filter uses.

### Task 4.2. Scope decision

At the end of the agenda, add "Scope decision". Mark part A as `attempt` or `attempt in reduced form`. Mark part B as `attempt`, `attempt in reduced form`, or `park`, with a reason that points at a section that was read. Parking part B is required if neither stored guide can be evaluated inside the Algorithm 2 weight. Do not park part B only because the guides are long.

Acceptance: phase 5 attempts exactly the parts marked `attempt` or `attempt in reduced form`.

## Phase 5. Solve the theoretical questions

Purpose: arguments that can be copied into the methods section. Work in `notes/05-theory-notes.md`.

### Task 5.1. Restate the current algorithm

Write the 2025 filter as a numbered algorithm, using the notation from task 1.3. Include the bridge proposal. Every line maps to a section of `Source papers/4992336VoR.pdf`. Do not improve the filter while restating it.

### Task 5.2. Part A

State the condition under which the guide is inconsistent, in the sense fixed in task 4.1. Give the argument and the assumptions. If the argument fails, give the step that breaks and shrink the claim. End with "Will appear in the paper" or "Will not appear", and what a simulation must show.

### Task 5.3. Part B

State the modified algorithm as a numbered list of changes to task 5.1. The default change is the draw from \(q\), and the density used in the weight, and nothing else. Give the argument that the filtering target is unchanged, or state the target the new proposal actually uses. If the density of the new proposal is unavailable, stop and return to the scope decision.

### Task 5.4. Drop what will not be claimed

Add "Dropped". List claims that were tried and will not be made, with the reason. Phase 6 must not simulate a dropped claim, and phase 8 must not present it as a method.

Acceptance for phase 5: every object that phase 6 will simulate has a stated target and a stated algorithm in this note. Conjectures are labelled as conjectures.

## Phase 6. Simulations

Purpose: a study that can show the linear guide failing, and a study that can show the replacement failing. Design them before writing code.

### Task 6.1. Design

Write `notes/06-simulation-design.md` before any R. Reuse the 2025 synthetic SIR setting wherever it can discriminate the guide, so that the comparator is the published filter on a published problem. The published synthetic grid has ten observation times at unit spacing (Section 4.1). Sparse observation has to be defined in this note, before the run, as a coarsening of a series generated on a finer grid. Do not choose the coarse grid after seeing the weights.

| Study | Question | What would count as failure |
| --- | --- | --- |
| S1 | Part A. The same synthetic SIR mechanism as Section 4.1, observed at the published spacing and at coarser spacings fixed in this note | The pre-registered diagnostic does not move as the observation spacing grows, or it moves for a reason the theory note did not name |
| S2 | Part B. The same series as S1, with the replacement proposal in place of \(q\) | The replacement does not improve the pre-registered diagnostic at matched cost, or it changes the posterior relative to a long run of the published filter on the fine grid |

Comparators, included only where they can be run from a paper that has been read:

- Algorithm 2 as restated in task 5.1, on the same data;
- a bootstrap filter that draws the unconditioned dS(E)IR transition, if the theory note uses it as the myopic baseline;
- a long pseudo-marginal run, only if the design copies the 2025 settings closely enough to call it the same gold standard. If a setting is omitted in the paper, record the omission and choose a value here, before running.

Metrics, chosen here and not after the plots: a posterior summary against the gold-standard run where one is affordable; effective sample size of the incidence weights; wall-clock time as a secondary figure. Say what the gold standard is. If none is affordable, say so. Do not invent a truth that was not computed.

Also specify replicate runs, seeds, the observation spacings, and which numbers will become a table or a figure.

Match the 2025 settings when claiming to reproduce that paper. The context note records the settings that were printed.

### Task 6.2. Implement

Read `.cursor/skills/r-coding/SKILL.md` and `assets/algorithm-template.R`. Re-express the algorithm in base R. Do not add packages.

Files:

- `R/dsir-filter.R` for the restated 2025 filter;
- `R/dsir-linear-guide.R` for the Section 3.4 proposal, if it is kept separate;
- `R/dsir-replacement-guide.R` for the proposal from task 5.3, and only for a proposal whose paper was read;
- `R/models-dsir.R` for the synthetic model, if a separate file is needed.

Header comments must cite the PDF and the section, algorithm, or equation that was used. Comments inside the function must carry the symbol and the step. A direct loop is the version to keep.

Acceptance: an algorithm file can be read against task 5.1 or task 5.3 without guessing what a line computes.

### Task 6.3. Run

Scripts in `scripts/`, one per study: `scripts/study-sparse-bridge-s1.R` and `scripts/study-sparse-bridge-s2.R`. Each script sets the seed, sources the function files from the repository root, and writes tables to `Sparse bridge/results/`. The script does not reimplement the algorithm.

Run the studies. If a run is too long for the session, record the command, the seed, and the portion completed, and leave the script able to run a smaller pre-registered pilot. Do not change the design after seeing results except by adding a dated amendment to the design note that says what changed and why.

### Task 6.4. Findings

Write `notes/06-simulation-findings.md`. For each study: the comparison that was set out, the result, and whether the claim keeps its place in the paper. Every number cites a file in `results/`. No number enters the manuscript unless it is in this note.

Acceptance: part A and part B are each supported, qualified, or removed, and a removed claim is added to "Dropped".

## Phase 6b. A real application, if one is apt

### Task 6b.1. Choose or decline

Write `notes/07-application-choice.md`. Consider only the two series in Whitaker et al. (2025), and stop at the first that is apt:

1. The Sierra Leone Ebola series in Section 4.2, if the weekly counts are stored in the repository or printed as a table in a PDF that has been opened, and if a surviving claim changes a conclusion the simulations did not already show.
2. The New York COVID-19 series in Section 4.3, under the same two conditions.
3. No series. Decline if the counts are not available, or if neither series adds a conclusion beyond phase 6. A decline is a successful outcome. Record it and skip task 6b.2.

The context note is the place to check first. At the time of writing this plan, the weekly counts are not printed as a table in Sections 4.2 and 4.3, and no incidence file is stored in the repository. The paper names `https://github.com/Sam-Whitaker/Sequential_Bayes_Epi` and the source papers of Fintzi et al. (2022) and Spannaus et al. (2022). Those are not in the repository. Do not invent the counts from the figures. Do not fetch them unless a later instruction says to. If they are still absent when this task starts, mark the data as not in the repository and decline.

Do not go looking for a third data set.

### Task 6b.2. Carry it out

Only if task 6b.1 selects a series. Add a short design to the same note: data source and what was stored, observation model, prior, which proposal is applied, comparator, and the sentence the application is meant to support. Then implement and run it under the same rules as phase 6. Store output in `results/`. Write the finding in the same note.

Acceptance: the finding either supports that sentence or the application is withdrawn.

## Phase 7. How to present the work

### Task 7.1. Presentation plan

Read `STYLE.md` sections 5 and 12. Write `notes/08-presentation-plan.md`.

Decide the contents from phases 5, 6 and 6b, not from this plan's default. For each of part A and part B, say "main text", "supplement", or "future work", with the finding that justifies the choice.

Fix:

- a working title, as a descriptive noun phrase in sentence case, of the kind in `STYLE.md` section 5.1;
- the target venue, the *Journal of Computational and Graphical Statistics*, unless a reason is recorded to write for *Bayesian Analysis* instead, as the 2025 paper did;
- the section list: introduction, related work drawn from the comparison table, the 2025 filter and the linear guide, the replacement, simulation studies, application only if task 6b.2 was done, discussion;
- the display list: one schematic of Algorithm 2 with the replaced proposal marked; one diagnostic-against-spacing display for S1; one comparison for S2 if part B stays in the main text;
- what is not claimed, copied from "Dropped";
- a word budget that respects the venue guidance in `STYLE.md` section 12.

Acceptance: a later agent can draft from this note without making a scientific choice.

## Phase 8. Write the paper

### Task 8.1. LaTeX manuscript

Create `Sparse bridge/paper/` with `main.tex`, one file per section, and `references.bib`. Use a simple article class. Do not fetch a journal class file until a submission version is requested.

Write in British English, in the voice and shape of `STYLE.md`. Use *we*. Convert to American spelling only if a later instruction asks for a submission-ready version (`STYLE.md` section 12.1).

The methods section is the cleaned argument from `notes/05-theory-notes.md`. If a proof and the note disagree, stop and fix the note first. Every number in the results comes from `notes/06-simulation-findings.md` or the application note, and those notes cite `results/`.

The bibliography contains only works that appear in the literature summary or the context note and that were read. Anything else is `[CITATION NEEDED]` in the text and a comment in the tex file. A work marked `[PDF NOT STORED]` may be cited only for the fact that Whitaker et al. (2025) name it, and the sentence must say that the work itself was not read.

Abstract: one paragraph, 140 to 200 words, no citations and no displayed equations, in the order set by `STYLE.md` section 5.2.

Run `scripts/check_british_spelling.sh` on `Sparse bridge/paper`. Build the PDF with a standard TeX installation. Fix the build. Read the PDF once for cross-references, undefined citations, and figures that are mentioned before they appear.

Acceptance: `main.pdf` builds, the displays match the presentation plan, and no numerical claim lacks a results file.

## Phase 9. Reproduction script

### Task 9.1. One script that regenerates the paper's numbers

Write `scripts/reproduce-sparse-bridge.R`. It sources the algorithm files, runs every study and the application that the manuscript reports, and writes the tables and figures those sections include. A comment at the top lists the manuscript displays and the script section that produces each one. Seeds are set in this script and are commented as not being part of the algorithm.

The script does not reimplement the algorithms. It calls the functions in `R/`.

Document, in a header comment, how to run it from the repository root and what it writes. If a full run is too long, provide a switch, defaulting to the full run, that repeats the pre-registered pilot from the design note. The manuscript numbers must come from the full run. Say so in the comment.

Acceptance: from a clean results directory, the script regenerates the numbers cited in the manuscript. Check this once and record the command in the script header.

## Handover

### 15 October 2026, continued after the three PDFs were filed

- Current task: 7.1 is done. Phases 8 and 9 have not been started. Task 5.3 and task 6b.2 are parked.
- Files touched in this continuation: the three PDFs under `Sparse bridge/Literature/`; `notes/01-paper-context.md` (dated amendments that the three PDFs are stored); `notes/02-literature-summary.md`; `notes/03-search-log.md`; `notes/04-theory-agenda.md`; `notes/05-theory-notes.md`; `notes/06-simulation-design.md`; `notes/06-simulation-findings.md`; `notes/07-application-choice.md`; `notes/08-presentation-plan.md`; `R/models-dsir.R`; `R/dsir-linear-guide.R`; `scripts/study-sparse-bridge-s1.R`; `results/s1-*.csv` and the pre-registered pilot files.
- What is already reliable: the literature blocks written from the three PDFs; the scope decision that parks part B; the part A reading in the theory note; the S1 numbers in `results/s1-study-summary.csv`, as restated in the findings note.
- What the next agent should not trust: a mapping from Golightly and Sherlock (2019), equation (19), or from Corstanje et al. (2023), equation (16), into the Algorithm 2 denominator. None was written, because the sources do not contain it. The pilot CSVs are not the study. The earlier handover below is out of date on task 3.1.
- Why 5.3 is parked: neither stored guide evaluates the density of Poisson incidence increments on the dSEIR grid. Details are in the theory note, Section 5.3.
- Why 6b.2 is parked: the weekly counts are not stored. `notes/07-application-choice.md`.
- Next action: do not draft `paper/` unless the presentation plan is followed as a diagnostic article with part B left as future work. Do not code a replacement guide without a new source that states the density Algorithm 2 divides by. Do not scrape Ebola or COVID-19 counts.

### 15 October 2026

- Current task: 3.1 is parked. Phases 4 to 9 have not been started.
- Files touched: `Sparse bridge/research-plan.md`, `Sparse bridge/notes/01-paper-context.md`, `Sparse bridge/notes/02-literature-summary.md`.
- What is already reliable: the context note's account of Whitaker et al. (2025), with pages, and the literature note's account of the sections of Lowe et al. (2023) and Jovanovski et al. (2024) that were opened. The `[PDF NOT STORED]` list is the stopping point.
- What the next agent should not trust: any step of Golightly and Sherlock (2019), Corstanje et al. (2023), or Golightly and Wilkinson (2015) that is not a sentence printed in Whitaker et al. (2025) or, for the 2019 hazard only, a sentence printed in the opened pages of Lowe et al. (2023). Lowe's Section 4.2.3 is a secondary account. It is not a licence to code that hazard. The scoping note is not a licence either.
- Why 3.1 is parked: the two replacement guides, and Golightly and Wilkinson (2015), are not in the repository. They were not downloaded.
- Next action: file those three PDFs under `Sparse bridge/Literature/`, append summary blocks written from the PDFs, and only then start task 4.1. Do not start task 3.2 before that.

## Working rules

- Finish and commit a phase's deliverable before starting the next phase's deliverable. A later phase may read an earlier note. It may not contradict it without amending it.
- One scientific choice per amendment. Date the amendment and say what it replaces.
- A failed proposal is recorded and the programme continues with what remains.
- Do not add an R package, a new data set, or a new guide without a task in this file that allows it.
- Do not cite this plan as a scientific source. It is a set of instructions.
