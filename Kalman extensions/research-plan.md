# Research plan: extensions of the nested ensemble Kalman filter

This file is the task list for work that follows the nested ensemble Kalman filter paper. It tells a later agent what to read, what to produce, and when to stop. It is not a summary of the literature, and it is not a result. Nothing below has been checked against the papers beyond the scoping note and the titles of the PDFs already in this folder.

Do the phases in order. Do not write code, derivations, or manuscript prose until the phase that asks for them. Update the status table when a deliverable exists.

## How to take up this plan

1. Read `AGENTS.md`, `STYLE.md`, and `.cursor/skills/r-coding/SKILL.md` before drafting prose or R.
2. Read this file from the status table to the end of the phase you are about to start.
3. Do one phase, or one task inside the current phase. Leave a handover note at the end of this file if you stop mid-task.
4. British English in every note, commit message, and manuscript draft. No em dashes. Run `scripts/check_british_spelling.sh` on text you add.
5. Do not invent citations, theorem numbers, algorithm numbers, or numerical results. If a source has not been opened, write `[NOT READ]`. If a citation is needed and not yet verified, write `[CITATION NEEDED]`.
6. The phrase "ensemble" is used in two ways in this literature (the EnKF state ensemble, and the outer cloud of parameter particles). Do not collapse them. The first reading task is to fix the notation from the paper itself.
7. Code, when a later phase asks for it, is base R and follows the R coding skill. Algorithm functions go in `R/`. Study scripts go in `scripts/`. Notes, the manuscript, and PDFs stay under `Kalman extensions/`.

## Status

| ID | Task | Status | Deliverable |
| --- | --- | --- | --- |
| 1.1 | Read the nested ensemble Kalman filter paper | done | `notes/01-paper-context.md` |
| 1.2 | Extract the open problems in the paper's own words | done | same file, section "Open problems" |
| 1.3 | Freeze notation | done | same file, section "Notation" |
| 2.1 | Summarise the eight PDFs already in `Literature/` | not started | `notes/02-literature-summary.md` |
| 2.2 | Build the comparison table of neighbouring methods | not started | same file, section "Comparison" |
| 3.1 | Obtain and file the missing named sources | not started | new PDFs in `Literature/`, rows in the summary |
| 3.2 | Search for work the named sources do not cover | not started | `notes/03-search-log.md` and new summary rows |
| 3.3 | Stop the search | not started | search log, section "Saturation" |
| 4.1 | Write the theory agenda | not started | `notes/04-theory-agenda.md` |
| 4.2 | Decide what will be attempted | not started | same file, section "Scope decision" |
| 5.1 | Restate the current algorithm | not started | `notes/05-theory-notes.md` |
| 5.2 | Settle E4, surrogate weights | not started | same file |
| 5.3 | Settle E1, nearest-neighbour lookup | not started | same file |
| 5.4 | Settle E2, choice of kernel | not started | same file |
| 5.5 | Settle E3, gradient proposals | not started | same file |
| 5.6 | Settle E6, Rao-Blackwellised correction | not started | same file |
| 5.7 | Settle E5, operating regime | not started | same file |
| 5.8 | Record failures and drop what will not be claimed | not started | same file, section "Dropped" |
| 6.1 | Design the simulation studies | not started | `notes/06-simulation-design.md` |
| 6.2 | Implement the algorithms in base R | not started | `R/*.R` |
| 6.3 | Run the studies and store the output | not started | `scripts/*.R`, `results/` |
| 6.4 | Write the numerical findings | not started | `notes/06-simulation-findings.md` |
| 6b.1 | Choose or decline a real application | not started | `notes/07-application-choice.md` |
| 6b.2 | Carry out the chosen application | not started | only if 6b.1 selects one |
| 7.1 | Plan the paper | not started | `notes/08-presentation-plan.md` |
| 8.1 | Write the LaTeX manuscript | not started | `paper/` |
| 9.1 | Write the reproduction script | not started | `scripts/reproduce-nenkf-extensions.R` |

Status values are `not started`, `in progress`, `done`, and `parked`. A parked task needs one sentence in the handover section saying why. Do not mark a task done until its deliverable is in the repository and the acceptance lines for that task hold.

## Scope

The source of the questions is `Scoping research/scoping-note.md`, in the subsection "From the nested ensemble Kalman filter paper (Golightly et al., 2026)", together with the two joins in "Directions that join the five papers" that are about this method: when the Rao-Blackwellised correction is worth its cost, and whether the linear-noise gradient can be carried into the resample-move step. The epidemic series from Whitaker, Golightly, Gillespie and Kypraios (2025) are a candidate application, not a separate method.

The paper is Golightly, Heaps, Sherlock, Wadkin and Wilkinson (2026), *Statistics and Computing* 36, 149. The file is `Source papers/5417950VOR.pdf`. A reference implementation is recorded in the scoping note at `https://github.com/AndyGolightly/NestedEnKF`. Read that code in phase 6, when implementing. Do not treat it as a substitute for the paper.

### Extensions

Keep these labels in every later note.

| Label | Idea, as the scoping note records it | Role in the programme |
| --- | --- | --- |
| E1 | Replace the linear nearest-neighbour lookup in the delayed-acceptance screen with a KD-tree once the parameter dimension is moderate. Sherlock, Golightly and Henderson (2017). | Mutation, cost only if the neighbour set is unchanged |
| E2 | Choose, inside a run, among delayed-acceptance kernels with different neighbour counts and a plain Metropolis-Hastings kernel. Early on, the likelihood estimator is cheap, so screening buys less. Fearnhead and Taylor (2013); Botha, Kohn, South and Drovandi (2023) and their companion preprint on switching kernels. | Mutation, adaptive |
| E3 | Put a gradient-based proposal inside the resample-move step. Rosato et al. (2024). A related join is to carry the linear-noise gradient from Lowe, Golightly and Sherlock (2023) into that step. | Mutation, proposal |
| E4 | Use the nearest-neighbour surrogate for weighting as well as for mutation, at a fixed ensemble size. Fixed cost, a less accurate posterior. | Changes the weight, and so the target |
| E5 | Treat the method as suited to few static parameters relative to the number of observed series. The scoping note's illustrative scale is fewer than about ten parameters and more than about ten observed components. | Regime, not a new algorithm |
| E6 | A rule for when the Rao-Blackwellised correction is worth its cost. The plain filter targets the posterior under the ensemble Kalman likelihood; the corrected filter puts an importance weight back. | Comparison of two targets already in the 2026 paper |

E1 to E5 are the paper's own open points. E6 is included because it decides which of those two 2026 filters an extension should modify. The linear-noise gradient is a candidate score inside E3, not a sixth algorithm. It is available only for models that have a linear noise approximation. Lorenz-96, as used in the 2026 applications, is not such a model until someone shows that it is.

### What this plan does not cover

Future work from the kinetic-model paper, the ABC paper, the epidemic paper, and the Frankenfilter paper stays out of this folder, except for the linear-noise gradient and the epidemic series named above. Do not open a second programme on Hamiltonian Monte Carlo, summary networks, adaptive tau-leaping, or alive-filter central limit theorems while working through this file.

### Default shape of the eventual paper

Aim at one journal article, not five notes. The working default, to be confirmed or overturned in task 4.2 and again in task 7.1, is:

- Centre: the resample-move step (E1, E2, E3), which is what the 2026 discussion asks for.
- Alongside: E4, if the target it defines can be stated cleanly, as a cheaper and less accurate alternative.
- Short: E5, as a scaling remark tied to a simulation grid, not as a theorem about the number ten.
- Include E6, and a real series, only if the earlier tasks show that they change the conclusion a reader would draw.

The *Journal of Computational and Graphical Statistics* length guidance in `STYLE.md` section 12 is about 8,000 words including appendices, references, tables and figures. Phase 7 must cut to that scale. Parked extensions go in the discussion as future work, with the reason.

## Repository map

| Path | What it is |
| --- | --- |
| `Source papers/5417950VOR.pdf` | The 2026 nested ensemble Kalman filter paper |
| `Source papers/38253VoR.pdf` | Lowe, Golightly and Sherlock (2023), for the linear-noise gradient |
| `Source papers/4992336VoR.pdf` | Whitaker et al. (2025), for a possible real series |
| `Scoping research/scoping-note.md` | Where these extensions were identified |
| `Kalman extensions/Literature/` | PDFs already collected. The folder name uses a capital L |
| `Kalman extensions/notes/` | Create this when phase 1 starts. One markdown file per deliverable above |
| `Kalman extensions/paper/` | Create this in phase 8 |
| `Kalman extensions/results/` | Numerical output from phase 6. Store tables as plain text or CSV. Do not commit large binary dumps without a reason |
| `R/`, `scripts/` | Code, under the R coding skill |

## Phase 1. Read the original paper

Purpose: a context note that later phases can cite, so they do not re-read the PDF for every small point and do not drift from what the paper says.

### Task 1.1. Read the paper

Read `Source papers/5417950VOR.pdf` in full. The section headings to account for are: 1 Introduction; 2 Background (state-space models, particle filter, SMC2); 3 Inference using the ensemble Kalman filter (EnKF, ensemble MCMC, state augmentation, particle ensemble Kalman filter); 4 Nested ensemble Kalman filter (algorithm, delayed-acceptance resample-move, nonlinear observation model); 5 Applications (Ornstein-Uhlenbeck, Lotka-Volterra, two-node epidemic, Lorenz-96); 6 Discussion.

Write `notes/01-paper-context.md` with:

- the model class and the inference target at time t;
- how the outer SMC2-style recursion is kept and what replaces the inner particle filter;
- the ensemble Kalman likelihood: what it estimates, and in what sense it is biased;
- the delayed-acceptance rejuvenation step and the role of the k nearest neighbours;
- the Rao-Blackwellised correction for nonlinear or non-Gaussian observations, and how it differs from using the ensemble Kalman filter as a proposal only;
- the four examples: what is observed, what is static, and which comparator (plain nested filter, Rao-Blackwellised SMC2, vanilla SMC2) is run;
- what the paper claims, in its words, about accuracy and cost;
- the reference code repository, and whether this repository already contains any of that code (it does not, at the time of writing this plan).

Acceptance: a reader of the note can restate the algorithm without opening the PDF, and every structural claim carries a section or page that you have read. Do not copy long passages. Paraphrase, and quote only the sentences you will need in task 1.2.

### Task 1.2. Extract the open problems in the paper's own words

In the same file, add "Open problems". Quote or closely paraphrase each future-work sentence in section 6, with the page. Then map each sentence onto E1 to E5. If the paper says something the scoping note omitted, add a row to a subsection "In the paper but not in the scoping note" and treat it as in scope. If the scoping note says something you cannot find in section 6, mark it "scoping note only" and do not build a method on it until task 4.2.

Acceptance: E1 to E5 each point at a page in section 6, or are marked as scoping-note only.

### Task 1.3. Freeze notation

In the same file, add "Notation". Use the paper's symbols where they are readable. At least: time index, state, observation, static parameter, parameter-particle index, ensemble-member index, ensemble size, number of parameter particles, neighbour count, the ensemble Kalman likelihood, the nearest-neighbour approximation of that likelihood, the two targets (plain and Rao-Blackwellised), and the delayed-acceptance ratio.

Resolve the phrase "fixed ensemble size" in E4. Say whether section 6 means the EnKF ensemble size, the number of parameter particles, or something else, and quote the sentence. Later phases must use your reading.

Acceptance: later notes can use these symbols without redefining them. If the paper's notation conflicts with itself, record both and choose one.

## Phase 2. Summarise the literature already in the folder

Purpose: relevance to E1 to E6, not a general review of data assimilation.

### What is already filed

Summarise these, and do not search for replacements before you have done so.

| File | Identity, from the PDF first page |
| --- | --- |
| `Literature/1101.1528v3.pdf` | Chopin, Jacob and Papaspiliopoulos. SMC2: an efficient algorithm for sequential analysis of state-space models. arXiv:1101.1528. The outer recursion the 2026 method keeps |
| `Literature/1509.00172v2.pdf` | Sherlock, Golightly and Henderson. Adaptive, delayed-acceptance MCMC for targets with expensive likelihoods. arXiv:1509.00172. The KD-tree construction cited for E1. The published version is Sherlock, Golightly and Henderson (2017), *Journal of Computational and Graphical Statistics* |
| `Literature/2201.11354v2.pdf` | Botha, Kohn, South and Drovandi. Automatically adapting the number of state particles in SMC2. arXiv:2201.11354. Cited for E2. This preprint adapts the particle count. The kernel-switching companion is a different preprint and is not in the folder yet |
| `Literature/2407.17296v1.pdf` | Rosato, Murphy, Varsi, Horridge and Maskell. Enhanced SMC2: leveraging gradient information from differentiable particle filters within Langevin proposals. arXiv:2407.17296. Cited for E3 |
| `Literature/2512.05650v4.pdf` | Temfack and Wyse. Efficient sequential Bayesian inference for state-space epidemic models using ensemble data assimilation. arXiv:2512.05650. Independent nested scheme for epidemics. Must be positioned against the 2026 method, not ignored |
| `Literature/Tellus A - 2010 - PAPADAKIS - Data assimilation with the weighted ensemble  Kalman filter.pdf` | Papadakis, Mémin, Cuzol and Gengembre (2010), *Tellus A* 62, 673-697. Ensemble Kalman proposal inside a particle filter. The contrast drawn in the scoping note is that the 2026 Rao-Blackwellised filter also approximates the transition density and can use a finer state grid than the observation grid. Check that contrast against both papers |
| `Literature/Understanding the Ensemble Kalman Filter.pdf` | Katzfuss, Stroud and Wikle (2016), *The American Statistician* 70, 350-357. Short introduction. Their 2019 review is not this file |
| `Literature/ensemble.pdf` | Drovandi, Everitt, Golightly and Prangle (2022), *Bayesian Analysis* 17, 223-260. Ensemble MCMC: the ensemble Kalman likelihood inside pseudo-marginal MCMC rather than inside SMC2. A main comparator |

### Task 2.1. Write the summary

Create `notes/02-literature-summary.md`. For each file, use this template and no other:

- citation, as printed on the work you read;
- path;
- question the paper answers;
- assumptions that would fail for a nested ensemble Kalman filter (unbiased likelihood, linear Gaussian observation, particle filter still present, batch MCMC rather than sequential, and so on);
- relevance to E1, E2, E3, E4, E5 and E6, one short paragraph each, or "not relevant" with a reason;
- algorithms, estimators, or theorems a later derivation might reuse, each with a section you have read;
- what the paper does not give us;
- a sentence on how it differs from Golightly et al. (2026).

Read the whole paper when it is a primary source for an extension (the SMC2 paper, Sherlock et al. on delayed acceptance, Rosato et al., Botha et al., Temfack and Wyse, Drovandi et al.). For Katzfuss et al. (2016) and Papadakis et al. (2010), read enough to complete the template honestly, and say if you stopped early.

Acceptance: every extension E1 to E6 has at least one paragraph that says which of these eight papers constrains it. No paragraph claims a theorem you did not see.

### Task 2.2. Comparison table

In the same file, add "Comparison". Rows are methods: SMC2, ensemble MCMC, state augmentation with artificial evolution, the weighted ensemble Kalman filter, the particle ensemble Kalman filter, the 2026 nested filter, the 2026 Rao-Blackwellised version, and Temfack and Wyse's ensemble SMC2. Columns: what is propagated, what the weight uses, whether the static-parameter target is exact, whether the scheme is sequential, and the citation. Fill a cell with `[NOT READ]` rather than a guess. This table is the one phase 7 will turn into the paper's related-work display. Get it right here.

## Phase 3. Find further literature

Purpose: close gaps left by phase 2. Add files to `Literature/`. Extend `notes/02-literature-summary.md`. Do not start a second summary.

### Task 3.1. Named sources that are not in the folder

The scoping note names the following in connection with this method. Obtain a copy you are entitled to store. Prefer an arXiv preprint or an author manuscript. If a file cannot be stored, record the citation and "[PDF NOT STORED]" and read it by whatever legitimate means you have. Do not bypass a paywall.

- Katzfuss, Stroud and Wikle (2019), or the 2020 journal version, on ensemble Kalman methods for high-dimensional hierarchical dynamic space-time models. The scoping note says this is the review the 2026 paper uses for high-dimensional performance and for state augmentation. Needed for E5 and for the comparison table.
- Fearnhead and Taylor (2013), *Bayesian Analysis*, on adaptive sequential Monte Carlo. Needed for E2.
- Botha, Kohn, South and Drovandi, the companion preprint on switching between a particle marginal Metropolis-Hastings kernel and a particle Gibbs kernel in SMC2 (arXiv:2307.11553 in the scoping note). Needed for E2. Confirm the identifier before citing it.
- Christen and Fox (2005) on Markov chain Monte Carlo using an approximation, and Sherlock, Thiery and Golightly (2021), *Annals of Statistics*, on the efficiency of delayed-acceptance random walk Metropolis. Needed before any claim about when screening helps.
- Liu and West (2001) on artificial evolution of static parameters. Needed as the contrast with nesting, one entry in the comparison table.
- Evensen (1994) and, if a copy can be used, Evensen (2009) or Evensen, Vossepoel and van Leeuwen (2022). Background for the filter. Cite them. Do not summarise a book you have not used. A chapter you have read can be summarised.

Lowe, Golightly and Sherlock (2023) and Whitaker et al. (2025) are already in `Source papers/`. Summarise only the sections that bear on E3 and on the candidate application. Point at the source-paper path. Do not duplicate the PDF into `Literature/`.

Filename for a new PDF: `AuthorYear-short-title.pdf`, ASCII, hyphens, no spaces. Example: `Katzfuss2019-ensemble-kalman-methods.pdf`.

For each new file, append a block to the phase 2 summary using the same template.

Acceptance: each bullet above is either a summary block with a path, or an explicit "[PDF NOT STORED]" line with what you were able to read.

### Task 3.2. Search beyond the named list

Keep a log in `notes/03-search-log.md`: date, query, where you searched, what you opened, and whether you filed it. Search with intent, one gap at a time:

1. Nearest-neighbour and KD-tree approximations to expensive likelihoods after Sherlock, Golightly and Henderson (2017), including local likelihood approximations used inside delayed acceptance. Gap: does anyone already put that screen inside SMC2 or inside an ensemble Kalman likelihood?
2. Gradients of an ensemble Kalman likelihood, ensemble sensitivity analysis, and differentiable ensemble Kalman filters. Gap: E3 needs a score of the target the nested filter actually uses. Rosato et al. differentiate a particle filter. Look for a gradient that exists after the inner filter has been replaced.
3. Weighting by a surrogate likelihood inside SMC or SMC2, and results on the resulting bias. Gap: E4 changes the target. Look for a theorem that says what that approximate-weight algorithm converges to, and for any result that bounds the distance to the ensemble Kalman posterior.
4. Cost and accuracy as the parameter dimension and the observation dimension vary, for ensemble MCMC and for nested or ensemble SMC2. Gap: E5. Look for reported ranges, not for a slogan.
5. Work that cites Golightly et al. (2026) or Temfack and Wyse (2025). Gap: avoid repeating an extension that has already been published.

Add a paper only if it changes the theory agenda for at least one of E1 to E6. In the summary block, the first line after the citation should say which extension it changes.

### Task 3.3. Stop

Stop the search when a further query returns only papers that repeat a method already summarised. Write a short "Saturation" section: queries run, papers added, gaps that remain empty. An empty gap is a legitimate outcome. It means phase 4 has to derive the missing piece or drop the claim.

Do not search indefinitely. If saturation is not reached after the five numbered gaps have each been searched and the new papers have been summarised, stop anyway and list what you would have searched next.

## Phase 4. Decide what mathematics is needed

Purpose: a list of questions, not their answers. Phase 5 answers them.

### Task 4.1. Theory agenda

Write `notes/04-theory-agenda.md`. For each of E1 to E6, include:

- the target the extension is meant to leave invariant, or the target it deliberately replaces;
- what phase 2 and phase 3 already prove or already implement;
- the gap, as a question a proof or a counter-example could close;
- the route you expect to try, naming the result you would adapt;
- what "solved" means (a stated theorem, a stated algorithm with invariance checked, or a diagnostic because no bound is available);
- the fallback if the argument fails, which must be a smaller claim, not a silent approximation.

Use the questions below as the starting list. Strike, split, or add questions so that the list matches task 1.2 and the literature summary. Do not leave a question in the list if the literature summary shows it is already settled, and say where it was settled.

**E4, take this first, because it changes the target the other extensions mutate.**

- If the incremental weight uses a nearest-neighbour prediction of the ensemble Kalman likelihood instead of that likelihood, what distribution do the parameter particles target?
- How should the two errors be separated: ensemble Kalman likelihood against the true likelihood, and nearest-neighbour prediction against the ensemble Kalman likelihood?
- What does "fixed ensemble size" mean, given task 1.3? What is the cost per time step once new ensemble Kalman evaluations stop?
- Is there a result that the particles converge to the surrogate target, and is there any bound on the distance between that target and the ensemble Kalman posterior? If not, define a diagnostic that recomputes the ensemble Kalman likelihood on a subset of particles.

**E1.**

- If the KD-tree returns the same neighbours as a linear scan, is the delayed-acceptance kernel the same, conditional on the stored likelihood values? If yes, the only new statement is cost.
- When do the neighbour sets differ (ties, approximate nearest neighbours, a stale tree)? Does a different neighbour set still leave the intended target invariant, or only the exact neighbour set?
- What is the cost in the regime of E5, where the parameter dimension is small? KD-trees are known to degrade as dimension grows. State the cost for the dimension you will actually use, after reading Sherlock, Golightly and Henderson, rather than quoting a generic tree complexity.
- How is the tree updated when a proposed parameter is accepted and a new likelihood value is stored?

**E2.**

- Which choices of kernel leave the current target invariant: a choice that depends only on time, a choice that depends on a cloud summary such as the effective sample size, a choice that depends on the current particle, a choice that depends on the proposed particle?
- The 2026 likelihood is not the unbiased particle likelihood that SMC2 theory uses. Check whether an invariance argument you take from Fearnhead and Taylor, or from Botha et al., still applies when the weight is an ensemble Kalman likelihood or the E4 surrogate. Do not transfer a proof about an unbiased estimator without re-reading its assumptions.
- Turn the remark that screening buys less early in the run into a rule with a stated criterion. Cost per accepted move is one candidate. Define the criterion before looking at simulation output.

**E3.**

- List candidate gradients, and for each one write the function it is a derivative of. Candidates to consider, and to reject if they are not derivatives of the target: a finite difference of the ensemble Kalman log-likelihood; an ensemble sensitivity; the linear-noise score where a linear noise approximation exists; the Rosato particle-filter gradient.
- A Metropolis-Hastings correction needs the gradient of the log target that the kernel is supposed to preserve. A surrogate gradient can sit in a first stage, as in the 2023 kinetic-model paper, but only if the second stage still evaluates the target. Check that analogy. The 2023 second stage is an unbiased particle likelihood. The 2026 second stage is not.
- Rosato et al. discuss a Langevin proposal without an accept-reject step. Do not adopt that proposal unless you can show it leaves the target invariant. The default is a corrected Metropolis-Hastings proposal.
- Say for which of the four 2026 examples a linear-noise gradient exists. Restrict E3 to those examples if it does not exist more generally, or find a gradient that does.

**E6.**

- Write the plain target and the Rao-Blackwellised target side by side, from the sections named in the context note.
- Define "worth its cost" as a comparison of error in a posterior functional against the number of model integrations, or another criterion you can estimate. Say what the criterion is before any run.
- Try a sharp comparison in a linear Gaussian state-space model, where both filters can be related to the Kalman filter. Label that result as linear Gaussian if that is all it is. A general rule that you cannot prove becomes a conjecture plus the simulation in phase 6.

**E5.**

- Quote the illustrative scale from section 6 and do not promote it to a theorem.
- Write a scaling account you could test: cost of one ensemble Kalman likelihood as the observation dimension and the ensemble size grow; cost of rejuvenation as the parameter dimension grows; how the likelihood-estimator noise grows with the observation dimension. Katzfuss et al. (2019), once read, is the source the 2026 paper points to. Use it.
- The output of E5 is a region in the (parameter dimension, observation dimension) plane where you expect the nested filter to be the method you would run, and the reason. The boundaries are to be measured in phase 6, not asserted here.

### Task 4.2. Scope decision

At the end of the agenda, add "Scope decision". For each extension, mark it `attempt`, `attempt in reduced form`, or `park`, with a reason that points at the agenda. The default in "Default shape of the eventual paper" stands unless the agenda gives a reason to change it. Parking E4 is reasonable if the surrogate target cannot be defined. Parking E3 is reasonable if no usable gradient exists. Do not park an extension only because it looks hard.

Acceptance: phase 5 attempts exactly the extensions marked `attempt` or `attempt in reduced form`.

## Phase 5. Solve the theoretical questions

Purpose: arguments that can be copied into the methods section. Work in `notes/05-theory-notes.md`. One section per extension, in the order E4, E1, E2, E3, E6, E5, skipping anything parked in task 4.2. E4 comes first so that E1 to E3 can say which target they preserve.

### Task 5.1. Restate the current algorithm

Write the 2026 nested filter as a numbered algorithm, using the notation from task 1.3. Include the plain filter and, if E6 is in scope, the Rao-Blackwellised filter. Every line maps to a section of the PDF. This is the object the extensions modify. Do not improve it while restating it.

### Tasks 5.2 to 5.7. One extension each

For each extension still in scope:

- state the modified algorithm as a numbered list of changes to task 5.1;
- state the target;
- give the argument (invariance, cost, or bias decomposition), with assumptions;
- if the argument fails, give the counter-example or the step that breaks, and shrink the claim;
- end with "Will appear in the paper" or "Will not appear", and what a simulation must show.

E2's invariance argument and E3's choice of gradient are the parts most likely to fail by being copied from a paper whose assumptions do not hold. Spend the effort there. E1 is likely to be a cost result plus a warning about approximate neighbours. Do not write a long theory section for a result that is only "the kernel is unchanged".

### Task 5.8. Drop what will not be claimed

Add "Dropped". List claims you tried and will not make, with the reason. Phase 6 must not simulate a dropped claim, and phase 8 must not present it as a method.

Acceptance for phase 5: every extension that phase 6 will simulate has a stated target and a stated algorithm in this note. Conjectures are labelled as conjectures.

## Phase 6. Simulations

Purpose: studies that can show an extension failing. Design them before writing code.

### Task 6.1. Design

Write `notes/06-simulation-design.md` before any R that implements an extension. For each extension that survived task 5.8, specify one study. Reuse the 2026 examples wherever they can discriminate the extension, so that the comparator is the published method on a published problem.

| Study | Extension | Example to prefer | What would count as failure |
| --- | --- | --- | --- |
| S1 | E1 | The example in which rejuvenation is a large share of the cost. Read section 5 before choosing | Neighbour sets disagree and the chain targets the wrong distribution, or the tree is not cheaper at the dimension used |
| S2 | E2 | A series long enough that early and late rejuvenation differ | The switching rule is no better, on the pre-registered criterion, than the best fixed kernel |
| S3 | E3 | An example where the chosen gradient exists | The gradient proposal does not improve effective sample size per unit cost against random-walk rejuvenation, at matched cost |
| S4 | E4 | The same example as S1 or S2, so the bias of the cheaper weight is visible | The diagnostic in the theory note shows a discrepancy large enough that the fixed-cost target is not a useful approximation, or the cost is not in fact fixed |
| S5 | E5 and E6 | A grid. Ornstein-Uhlenbeck or a linear Gaussian model for the cheap cells; Lorenz-96 for a high observation dimension | The region where you would choose the method does not match the account in the theory note |

Comparators, to be included only where they can be run:

- the 2026 nested filter, as restated in task 5.1, on the same data;
- vanilla SMC2, where the observation dimension makes it feasible (the paper's own comparison on the smaller examples);
- ensemble MCMC (Drovandi et al., 2022), as a batch method with the same likelihood;
- Temfack and Wyse's ensemble SMC2, if the study is an epidemic model and you have implemented their observation-variance modification from the preprint you read.

Metrics, chosen in the design note and not after seeing the plots: a posterior summary against a gold-standard run where one is affordable; coverage of the intervals the method actually returns; effective sample size; acceptance rate at each stage of delayed acceptance; number of model integrations or ensemble forecasts; wall-clock time as a secondary figure, since it depends on the machine. Say what the gold standard is. If none is affordable, say so, and compare methods with each other plus the E4 diagnostic. Do not invent a truth you did not compute.

Also specify: number of replicate data sets or replicate runs, seeds, the factor grid for S5 (parameter dimension and observation dimension, placed so that the scoping note's illustrative scale sits inside the grid rather than at its edge), and which numbers will become a table or a figure.

Match the 2026 simulation settings when you claim to reproduce that paper. If you cannot, because the paper omits a setting, record the omission and choose a value in the design note before running.

### Task 6.2. Implement

Read `.cursor/skills/r-coding/SKILL.md` and `assets/algorithm-template.R`. Read the NestedEnKF repository only as an aid to the paper. Re-express the algorithm in base R. Do not add packages. Do not translate the GitHub code line by line if it pulls in packages or hides the algorithm.

Files:

- `R/nenkf.R` for the restated 2026 algorithm;
- one file per extension that changes the algorithm, for example `R/nenkf-knn-tree.R`, `R/nenkf-adaptive-kernel.R`, `R/nenkf-gradient-move.R`, `R/nenkf-surrogate-weight.R`;
- shared simulation models in `R/models-ou.R` and similarly, only for models you need.

Header comments must cite `Source papers/5417950VOR.pdf` and the section, algorithm, or equation you used. Comments inside the function must carry the symbol and the step. A direct loop is the version to keep.

Acceptance: an algorithm file can be read against task 5.1 or the modified algorithm in phase 5 without guessing what a line computes.

### Task 6.3. Run

Scripts in `scripts/`, one per study, named `study-s1-knn-tree.R` and so on. Each script sets the seed, sources the function files from the repository root, and writes tables to `Kalman extensions/results/`. The script does not reimplement the algorithm.

Run the studies. If a run is too long for the session, record the command, the seed, and the portion completed, and leave the script able to resume or to run a smaller pre-registered pilot. Do not change the design after seeing results except by adding a dated amendment to the design note that says what changed and why.

### Task 6.4. Findings

Write `notes/06-simulation-findings.md`. For each study: the comparison you set out to make, the result, and whether the extension keeps its place in the paper. Every number cites a file in `results/`. No number enters the manuscript unless it is in this note.

Acceptance: each surviving extension is either supported, qualified, or removed, and a removed extension is added to the "Dropped" list.

## Phase 6b. A real application, if one is apt

### Task 6b.1. Choose or decline

Write `notes/07-application-choice.md`. Consider, in this order, and stop at the first that is apt:

1. The oak processionary moth series already used in section 5 of the 2026 paper, if a surviving extension changes the cost or the posterior in a way the simulations did not already show. Prefer this when the point is computational.
2. The Ebola and COVID-19 incidence series in Whitaker et al. (2025), if the point is to compare the nested filter with that paper's filter on a series the 2025 paper left open. The scoping note names this comparison. Read the data description in that paper before promising it. Check that the observation model and the static parameters sit in the regime E5 describes.
3. No new data set. Decline if the first two do not add a conclusion beyond phase 6. A decline is a successful outcome of this task. Record it, and skip task 6b.2. The manuscript then has no application section.

Do not go looking for a third data set.

### Task 6b.2. Carry it out

Only if task 6b.1 selects a series. Add a short design to the same note: data source and licence, observation model, prior, which extension is applied, comparator, and the sentence the application is meant to support. Then implement and run it under the same rules as phase 6. Store output in `results/`. Write the finding in the same note.

Acceptance: the finding either supports that sentence or you withdraw the application.

## Phase 7. How to present the work

### Task 7.1. Presentation plan

Read `STYLE.md` sections 5 and 12. Write `notes/08-presentation-plan.md`.

Decide the contents from phases 5, 6 and 6b, not from this plan's default. The default is only the starting cut. For each extension, say "main text", "supplement", or "future work", with the finding that justifies the choice.

Fix:

- a working title, as a descriptive noun phrase in sentence case, of the kind in `STYLE.md` section 5.1;
- the target venue, which is the *Journal of Computational and Graphical Statistics* unless you record a reason to write for *Statistics and Computing* instead, as the 2026 paper did;
- the section list: introduction, related work drawn from the comparison table, methods and derivations, simulation studies, application only if task 6b.2 was done, discussion of what the results mean and what remains open;
- the display list: one schematic of the nested filter with the new pieces marked; one accuracy-against-cost display per study that stays in the main text; one regime plot if E5 stays; tables for the metrics in the design note;
- what is not claimed, copied from the "Dropped" sections;
- a word budget that respects the venue guidance in `STYLE.md` section 12.

Acceptance: a later agent can draft from this note without making a scientific choice.

## Phase 8. Write the paper

### Task 8.1. LaTeX manuscript

Create `Kalman extensions/paper/` with `main.tex`, one file per section, and `references.bib`. Use a simple article class. Do not fetch a journal class file until a submission version is requested.

Write in British English, in the voice and shape of `STYLE.md`. Convert to American spelling only if a later instruction asks for a submission-ready version (`STYLE.md` section 12.1).

The methods section is the cleaned argument from `notes/05-theory-notes.md`, not a second derivation. If a proof and the note disagree, stop and fix the note first. Every number in the results comes from `notes/06-simulation-findings.md` or the application note, and those notes cite `results/`.

The bibliography contains only works that appear in the literature summary or the context note and that you have read. Anything else is `[CITATION NEEDED]` in the text and a comment in the tex file.

Abstract: one paragraph, 140 to 200 words, no citations and no displayed equations, in the order set by `STYLE.md` section 5.2.

Run `scripts/check_british_spelling.sh` on `Kalman extensions/paper`. Build the PDF with a standard TeX installation. Fix the build. Read the PDF once for cross-references, undefined citations, and figures that are mentioned before they appear.

Acceptance: `main.pdf` builds, the displays match the presentation plan, and no numerical claim lacks a results file.

## Phase 9. Reproduction script

### Task 9.1. One script that regenerates the paper's numbers

Write `scripts/reproduce-nenkf-extensions.R`. It sources the algorithm files, runs every study and the application that the manuscript reports, and writes the tables and figures those sections include. A comment at the top lists the manuscript displays and the script section that produces each one. Seeds are set in this script and are commented as not being part of the algorithm.

The script does not reimplement the algorithms. It calls the functions in `R/`.

Document, in a header comment, how to run it from the repository root and what it writes. If a full run is too long, provide a switch, defaulting to the full run, that repeats the pre-registered pilot from the design note. The manuscript numbers must come from the full run. Say so in the comment.

Acceptance: from a clean results directory, the script regenerates the numbers cited in the manuscript. Check this once and record the command in the script header.

## Handover

When you stop before a task is done, append a dated subsection here.

- Current task:
- Files touched:
- What is already reliable:
- What the next agent should not trust:
- Next action:

## Working rules

- Finish and commit a phase's deliverable before starting the next phase's deliverable. A later phase may read an earlier note. It may not contradict it without amending it.
- One scientific choice per amendment. Date the amendment and say what it replaces.
- A failed extension is recorded and the programme continues with what remains.
- Do not add an R package, a new data set, or a new extension without a task in this file that allows it.
- Do not cite this plan as a scientific source. It is a set of instructions.
