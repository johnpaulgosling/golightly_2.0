# Style guide for academic writing in the Golightly manner

This file tells agents how to write (and edit) text so that it reads like the work of Andrew Golightly and his coauthors in computational and Bayesian statistics. It was derived by reading five coauthored papers in full or in part (see section 1). Follow it for abstracts, introductions, methods, results, discussions, captions, cover letters, reviewer responses and any other prose written on behalf of the author.

Rules are marked **MUST** (enforced, either by the user or because the corpus is uniform on the point), **SHOULD** (strong tendency in the corpus), or **MAY** (acceptable variation).

## 1. Source corpus

| Key | Paper | Venue | Lead author | Spelling observed |
| --- | --- | --- | --- | --- |
| P1 | Towards data-conditional simulation for ABC inference in stochastic differential equations (2024) | Bayesian Analysis | Jovanovski | American (see section 2.3) |
| P2 | Accelerating inference for stochastic kinetic models (2023) | Computational Statistics and Data Analysis | Lowe | British |
| P3 | Sequential Bayesian inference for stochastic epidemic models of cumulative incidence (2025) | Bayesian Analysis | Whitaker | British |
| P4 | Nested ensemble Kalman filter for static parameter inference in nonlinear state-space models (2026) | Statistics and Computing | Golightly | British |
| P5 | Robust, partially alive particle Metropolis–Hastings via the Frankenfilter (2026) | Journal of Computational and Graphical Statistics | Sherlock | British |

The PDFs are in `Source papers/`. When a rule below cites a key, that is where the pattern was observed. The subject matter is stochastic modelling and simulation-based Bayesian inference (particle filters, MCMC, SMC, ABC, stochastic differential equations, Markov jump processes, epidemic and kinetic models). The style transfers to neighbouring statistical topics, but do not import this subject-specific vocabulary into unrelated text.

## 2. British English (enforced)

### 2.1 Rule

**MUST** use British English spelling, vocabulary and conventions in all prose, comments, captions, commit messages and documentation. This applies to text you draft or edit, including text that you paraphrase from American sources.

Run `scripts/check_british_spelling.sh [PATH...]` on anything you write. It prints suspected American spellings and exits non-zero if it finds any. It is a heuristic, not a proof, so also apply the rules below by eye.

### 2.2 Core rules

| Topic | Use (British) | Avoid (American) |
| --- | --- | --- |
| Verbs and nouns in -ise | summarise, normalise, initialise, discretise, marginalise, parameterise, generalise, optimise, parallelise, realisation, discretisation, factorisation | summarize, normalize, initialize, discretize, marginalize, parameterize, generalize, optimize, parallelize, realization, discretization, factorization |
| -yse | analyse, analysing | analyze, analyzing |
| -our | behaviour, favour, neighbour, colour | behavior, favor, neighbor, color |
| -re | centre | center |
| Doubled l | modelling, modelled, labelled, travelled, fulfil | modeling, modeled, labeled, traveled, fulfill |
| Noun and verb pairs | licence (noun), license (verb); practice (noun), practise (verb) | license for both; practice for both |
| Other | grey, judgement, acknowledgements, artefact, sceptical, defence, programme (a scheme) | gray, judgment, acknowledgments, artifact, skeptical, defense, program (a scheme) |
| Directional adverbs | towards, afterwards, backwards | toward, afterward |
| Conjunctions | whilst (contrastive, see 4.4) or while | n/a |
| Dates | 7 June 2022 | June 7, 2022 |

Corpus evidence: P2 to P5 use the -ise forms throughout (for example *discretised*, *summarised*, *realisations* appear dozens of times with no -ize equivalent, apart from references and boilerplate). P3 and P5 use *analyse*; P2 and P3 use *centre*; P4 uses *neighbour* nine times; P3 and P5 use *grey* in figure captions. Names do not block the rule: P4 writes *Rao-Blackwellised* and *Blackwellised*.

### 2.3 Details and exceptions

- **Use -ise, not Oxford -ize.** The corpus uses plain -ise (*organised*, *emphasised*, *recognised*), not the Oxford variant. Do not write -ize even though it is acceptable in some British house styles.
- **Not every -ize word is a suffix.** Keep *size*, *prize*, *seize*, *capsize* and similar.
- **Keep original spelling in these cases:** proper nouns and institution names (for example the Chalmers AI Research Centre), titles of cited works (for example a reference called *Rao-Blackwellization and modularization*), direct quotations, software, package and function names, code identifiers, URLs, DOIs, and licence boilerplate copied from a publisher.
- **P1 is the outlier.** P1 (Bayesian Analysis, Chalmers-led) uses *-ize*, *behavior*, *favor*, *dataset* and *acknowledgments*. It is not representative of the house style here. When borrowing a sentence or phrase from P1, convert it. Do not copy its spelling as evidence of the author's preference.
- **"Program" is fine** for computer code. Use *programme* only for a scheme, schedule or broadcast.
- **Mixed results in published PDFs** (for example *conceptualization* in the Springer contributions statement of P4) come from publisher templates. Do not treat them as the author's usage.
- **Percentages:** use the symbol with a numeral and no space (`95%`), as the corpus does. Where the words are needed, write *per cent*.
- **Spelling of names:** *Itô* keeps its circumflex (P1 to P4 use it). *Schlögl*, *Särkkä* and similar keep diacritics.

## 3. Voice, tense and register

- **Register (MUST):** formal, precise, impersonal-leaning academic prose. No contractions, no rhetorical questions, no exclamation marks, no colloquial intensifiers (*really*, *very*, *huge*), no emoji.
- **Person (SHOULD):** first person plural *we* for the authors' own choices and contributions: *we consider*, *we propose*, *we denote*, *we assume*, *we set*, *we obtain*, *we focus on*. Do not use *I* in multi-author work. P2 (Lowe, Golightly and Sherlock) uses the impersonal passive more often (*It is proposed to...*, *Herein, it is recognised that...*, *It is anticipated that...*), so passive constructions in the introduction and discussion are acceptable. MAY alternate between the two within a paper, but keep one dominant choice per section.
- **Tense (SHOULD):**
  - Present tense for describing the method, the paper structure and general truths: *Section 3 outlines our approach*, *the surrogate is used in three ways*.
  - Past tense for what was done in numerical experiments: *We ran NEnKF with M = 1000 particles*, *we simulated 50 points*, *we found*.
  - Present perfect to open summary or discussion paragraphs: *We have introduced...*, *In this paper, we have considered...*, *We have proposed to use...*.
- **Hedging (SHOULD):** claims about performance are calibrated: *is likely to*, *typically*, *can be*, *it is anticipated that*, *suggest that*, *appears*, *at the expense of*. Reserve strong claims for results that were demonstrated, and attach a quantity: *about three times faster (and in some cases even 10 times faster)*, *an order of magnitude increase in overall efficiency*.
- **Evaluation (SHOULD):** support praise of a method with a comparison against a stated benchmark. State limitations plainly and propose concrete future work (see 5.7).

## 4. Phrasing patterns

### 4.1 Signposting and connectives

Used often and in a consistent register. Prefer these to inventing new ones.

- Contrast: *However*, *Nevertheless*, *On the other hand*, *Unlike [approach]*, *rather than*, *whilst*.
- Consequence: *Hence*, *Therefore*, *Consequently*, *Thus*, *As a result*.
- Addition: *Moreover*, *Additionally*, *We also*, *In addition*.
- Emphasis: *Crucially*, *Notably*, *Note that...*, *It is worth noting that...*, *It is evident that...*, *It should be clear that...*.
- Sequencing: *Firstly*, *secondly*, *thirdly* (or *(i)*, *(ii)*, *(iii)* inline), *Finally*.
- Local framing: *Here,* at the start of a sentence to scope a definition; *In what follows,* to set a convention for the rest of the text; *In brief,*; *In particular,*; *For example,*.
- Cross-reference: *see e.g. X, 2018* and *(see also Y, 2019)* inside parentheses. Always write *e.g.* and *i.e.* with full stops and no comma after them in running text and citations (*see e.g. Wilkinson, 2018*; *that is, ...* is also used instead of *i.e.* at sentence level).

Aim for one connective per paragraph transition, not one per sentence.

### 4.2 Characteristic vocabulary

Reuse the author's established terms when the meaning fits. Do not use them as decoration.

| Term | Typical use |
| --- | --- |
| *intractable*, *tractable*, *tractability* | likelihoods, transition densities, surrogates, conditional posteriors |
| *myopic* | forward simulation or bootstrap proposals that ignore the next observation |
| *bridge*, *bridge construct*, *guided proposal* | conditioned or end-point-aware path simulation |
| *surrogate* | cheap approximation used for proposals, screening or delayed acceptance |
| *leverage* (verb) | *leveraging the tractability of...* |
| *rejuvenate*, *resample-move*, *propagate* | particle methods |
| *natural* | *the most natural description*, *the most natural MJP representation* |
| *practitioner* | the user who chooses tuning values: *a time step chosen by the practitioner* |
| *commonplace*, *it is common to* | introducing standard practice |
| *unified framework*, *plug-and-play* | summarising what a method offers |
| *ubiquitously*, *widely adopted* | describing literature uptake |
| *order of magnitude* | efficiency gains, extra particles |
| *inter alia* | trailing lists of references |
| *at the expense of*, *trades off X and Y* | accuracy versus cost |
| *exactly targets the posterior* | validity claims for pseudo-marginal and similar schemes |

### 4.3 Hedged, concrete result sentences

Pattern: *[Subject] gives [measured outcome] relative to [benchmark] (qualifier).*

- *Our approach achieves accurate inference and is about three times faster (and in some cases even 10 times faster) than standard (forward-only) ABC-SMC.*
- *We found, across four applications of increasing observation dimension, that the NEnKF is able to provide accurate and computationally efficient inferences regarding the static parameters.*
- *This gave a modest decrease in CPU time of around 10%; therefore all results are based on [variant].*

### 4.4 *While* and *whilst*

*Whilst* appears occasionally (P1, P2, P3 and P5), always in a contrastive or concessive sense (*Whilst sampling based inference schemes such as Markov chain Monte Carlo are routinely applied, ...*; *Whilst our choice works well in the simulation studies, it may not be optimal*). Use *while* for simultaneity (*while the chain is running*). Do not use *amongst* (the corpus uses *among*).

### 4.5 Words and phrases to avoid

- Marketing language (*revolutionary*, *state of the art* as a bare boast, *game-changing*), unless quoting a source.
- Empty emphasis (*very*, *really*, *extremely*, *obviously*). Use *clearly* or *evidently* only when the point is in fact immediate.
- *Utilise* when *use* works. Prefer *use* and *employ*.
- Filler openers (*In today's world*, *It goes without saying*).
- *Novel* as an unsupported adjective. The corpus does use it (*a novel bridge construct*), but attaches it to something specific and compares with prior work.
- Sentences that narrate the edit rather than state the point.

## 5. Structure of a paper

The five papers share one skeleton. Follow it unless the target venue dictates otherwise.

### 5.1 Title

A descriptive noun phrase in sentence case naming the problem class and, where useful, the method: *Accelerating inference for stochastic kinetic models*; *Sequential Bayesian inference for stochastic epidemic models of cumulative incidence*. A catchy coinage is acceptable when it is explained (*The Frankenfilter*, with a literary nod in the text). The *X for Y* and *Towards X* forms are common, and titles seldom need a colon.

### 5.2 Abstract

One paragraph, about 140 to 200 words, with no citations, no equations and no headings. Order:

1. Context sentence naming the model class and why it matters (*Stochastic kinetic models (SKMs) are increasingly used to account for...*).
2. The difficulty (*intractability of the observed-data likelihood*, computational cost).
3. What is proposed (*We develop...*, *It is proposed to...*, *we combine...*, *we replace...*).
4. Mechanism or key idea in one or two sentences (*Crucially, the resulting model allows a tractable conditional parameter posterior...*).
5. Quantified benefit or validation, and the applications (*We illustrate our approach using synthetic and real data applications.*).

Follow with a **Keywords** line: lower-case terms separated by commas (or middle dots if the venue's template requires them), with proper names and acronyms capitalised (*particle filter, S(E)IR model, Markov jump process, time discretisation, bridge construct*).

### 5.3 Introduction

Typically five to eight paragraphs:

1. Broad setting and applications, with grouped citations (*in areas such as epidemiology (O'Neill and Roberts, 1999; ...), population ecology (...) and systems biology (...)*).
2. The inferential obstacle: incomplete, discrete, noisy observations, hence an intractable likelihood.
3. Existing solutions, ending in a limitation (*However, the use of nested particle filters in this way can be computationally expensive.*).
4. The gap, often via the word *myopic* or a statement about computational cost.
5. **Contribution paragraph**: *In this work, we propose...*, *Our contribution is...*, *The contribution here is...*. Enumerate with *(i)*, *(ii)*, *(iii)* or *firstly/secondly/thirdly* when there are several parts. Contrast with the closest related work (*Unlike their approach, ...*; *Unlike related approaches which use X as Y, ...*).
6. Brief statement of the applications used to illustrate the method.
7. **Roadmap**, always the last paragraph, in this form: *The remainder of this paper is organised as follows. Section 2 describes ... Section 3 outlines ... Applications are considered in Section 4 and conclusions drawn in Section 5.* Use *organised* and *Section N* in full.

### 5.4 Background and model

Open each section with *Consider...*, *Let ... denote...*, or *We consider...*. Introduce notation inline and in order of use. Define each acronym once, in parentheses, on first use (*stochastic differential equation (SDE)*, *Markov jump process (MJP)*). Keep background to what the reader needs; defer to a review citation for the rest (*see Craigmile et al. (2022) for a recent review*).

### 5.5 Methodology

State the target, then the algorithm, then its validity. Present algorithms as numbered pseudo-code boxes and refer to them by number (*Algorithm 2*). Precede each algorithm with a prose description of its steps and the intuition. State results as numbered *Proposition*, *Theorem* or *Lemma* with a short motivating sentence before and a pointer to the proof in the main text or an appendix after (*Theorem 1 is proved in Appendix A.*). Mention tuning choices and give practical guidance (P5 devotes a whole section to tuning).

### 5.6 Applications (numerical experiments)

- Open with a roadmap paragraph listing the applications in order of increasing complexity or realism, usually synthetic first, then real data (*To illustrate X and benchmark against existing methods, we consider four applications of increasing complexity.*).
- Give implementation details once: language (*All algorithms were coded in R*), hardware (*a desktop computer with an Intel Core i7-10700 processor and a 2.90 GHz clock speed*), parallelisation, and a repository link for code. Say that data are simulated or cite their source.
- For each application: the model, the data or the simulation set-up, the priors, the algorithm settings (*We ran NEnKF with M = 1000 particles...*), the benchmark (*gold standard reference values from a long run of an MCMC scheme*), the metrics, then the findings and a one-sentence interpretation of why.
- Standard metrics and phrasings: effective sample size (ESS) and ESS per second (*mESS/s*), relative efficiency, bias and RMSE, wall clock time, CPU time, ground truth, replicate runs, *overall efficiency*.
- Summarise comparisons with numbers and a verdict (*It is evident that the combination of delayed acceptance and MALA gives the best performing scheme, with an order of magnitude increase in mESS/s against the benchmark.*).

### 5.7 Discussion or summary

One to three paragraphs, then optionally a **Limitations** subsection (P3 includes one). Pattern:

1. Restate the problem and the contribution in the present perfect (*We have introduced...*).
2. Summarise the main empirical findings with the same figures as in the results.
3. Say where the method is expected to help most and where it may not (*we anticipate that the NEnKF will be of most benefit to practitioners working with models in which...*).
4. Concrete extensions (*This work can be extended in a number of ways. For example, ...*; *further work is required to assess...*; *merits further attention*).

Do not introduce new results in the discussion.

### 5.8 Back matter

In this order where the venue allows: **Acknowledgements** (plural, British), **Funding** or *This research was conducted without external funding*, **Data availability** (*all data used in this paper were simulated randomly from the models, as specified in Section 4*; or a repository link), **Supplementary material** (a short paragraph listing what it contains), **Declarations** and author contributions where required, then **References**.

## 6. Mathematics and notation

- **Define before use.** *Let X_t denote...*, *We denote by ... the ...*, *where N(x | mu, Sigma) denotes the multivariate normal density evaluated at x*. State dimensions and domains.
- **Display equations** are numbered consecutively on the right as (1), (2), ... and referred to as *(1)* inside parentheses or *Equation (3)* at the start of a sentence (the corpus uses both; *Equation* is capitalised when named). Equations are part of the sentence: end with a comma or a full stop and continue with *where...* or *so that...* in lower case.
- **Suppress and simplify.** Prefer sentences such as *We suppress dependence on the parameter from the notation* or *with explicit dependence on the rate constant omitted for notational convenience*.
- **Proper names in notation.** Standard distribution and process names are capitalised (*Gaussian*, *Poisson*, *Brownian motion*, *Markov*, *Gamma(2, 2)*). *Monte Carlo* is always capitalised and never hyphenated.
- **Matrices and vectors:** follow the symbol conventions already established in the document. If none exist, use bold or plain symbols consistently, with the prime or superscript T for transpose.
- **Sets and ranges:** *for t = 0, 1, ..., T*, *i = 1, ..., r*. Use an en dash for numerical ranges in text (*pp. 1–31*, *rounds 3–5*).
- **Cross-references:** capitalise and write in full in running text: *Section 3*, *Algorithm 1*, *Figure 2*, *Table 1*, *Appendix A*, *Proposition 2*, *Theorem 1*. Do not abbreviate (*Sect.*, *Eq.*) in prose. Elsevier-style captions may begin *Fig.* when the template demands it, but write *Figure* in text.

## 7. Citations and references

- **Author–year throughout.** *Author (Year)* for a subject; *(Author, Year)* for a parenthetical; two authors joined by *and* (*Golightly and Wilkinson (2015)*); three or more as *Author et al.*.
- **Multiple citations** are separated by semicolons inside one pair of brackets (*(Andrieu and Roberts, 2009; Andrieu et al., 2010)*). Use *e.g.* to flag examples and *see also* for secondary pointers. Several papers by one set of authors in one bracket: *(2004, 2005)*.
- **Comma between name and year:** use it by default (*Kalman, 1960*), as in P1, P2 and P3. P4 follows Springer (*Kalman 1960*, no comma) and P5 follows Taylor & Francis. Follow the target journal's style if known; otherwise use the comma form.
- **Use citations to carry weight**, not to decorate: *Following Kurtz (1972) (see also Wilkinson (2018))*, *This approach was first described in Storvik (2002) (see also Fearnhead, 2002)*.
- **Review pointers** for background: *see Sisson et al. (2018)* or *for a survey see e.g. ...*.
- **Do not invent references.** Cite only works the user supplies or that you have checked. If a claim needs a citation you do not have, leave a clear placeholder such as `[CITATION NEEDED]` and tell the user.

## 8. Punctuation, typography and formatting

- **No em dashes (MUST).** The user prohibits them, and the corpus uses essentially none (one instance across all five papers). Do not use the em dash character as parenthetical punctuation or as a pause. Use commas, brackets, colons, semicolons or a rewritten sentence. Do not substitute a spaced hyphen or a double hyphen.
- **En dashes** only for numerical ranges and joined surnames: *pp. 1–31*, *Lotka–Volterra*, *Chan–Karaolyi–Longstaff–Sanders*. For *Metropolis–Hastings*, P5 uses an en dash and P2 to P4 use a hyphen; SHOULD use the en dash and be consistent within a document.
- **Hyphenation.** Hyphenate compound modifiers before a noun, leave the same words open when they follow the noun. Preferred forms:
  - *state-space model*; *pseudo-marginal* (always); *low-dimensional*, *high-dimensional*; *one-step*; *time-varying*; *resample-move step*; *plug-and-play*; *speed-up* (noun); *non-negative*; *log-likelihood* (or *log likelihood*, be consistent).
  - *observed-data likelihood* in P4, *observed data likelihood* in P2: use the hyphenated form as a modifier by default.
  - *delayed acceptance* as a noun (*a delayed acceptance scheme* is used in P2) but *delayed-acceptance kernel* when the hyphen helps parsing.
  - *data set* (two words, as in P3, P4 and P5), *time step*, *step size*, *wall clock time*, *ground truth*, *real data*.
- **Quotation marks.** SHOULD use single quotation marks for scare quotes and coinages, with punctuation outside unless it belongs to the quoted material (P2, P4 and P5: *'small'*, *'gold standard'*, *'bridges'*). Double quotation marks are used in P1 and P3; avoid them in new text unless a venue requires it.
- **Serial (Oxford) comma:** SHOULD omit. About four in five lists in the corpus have no comma before *and* or *or* (*susceptible, exposed, infected and removed*). Add one only where omission would be ambiguous.
- **Semicolons** join closely related clauses and separate items in a list with internal commas. They are used freely.
- **Parentheses** carry definitions of acronyms, brief asides and citation groups. Do not nest more than one level in prose.
- **Numbers.** Spell out one to nine in running text (*three examples*, *two applications*); use numerals for 10 and above and always with units or symbols (*10 cores*, *50 points*, *95% interval*). Large counts may be written as powers (*10^6 iterations*) or in full (*1000 draws*). Put a space between a number and its unit (*2.6 GHz*). Write percentages as `95%`.
- **Dates and times:** day month year (*7 June 2022*); durations as *6 minutes*.
- **Italics** for first use of a defined term and for emphasis, sparingly. Bold is reserved for section headings, theorem labels and table or figure titles as per the template.
- **Headings.** Numbered, sentence case (*State-space models and inference task*), no trailing punctuation.
- **Lists.** Use bullets only for genuinely list-like content (such as the two observation regimes in P5). In prose papers, enumerate inline with *(i)*, *(ii)*, *(iii)*.

## 9. Figures, tables and captions

- Captions are placed below figures and above or below tables per the template, and begin with the application or topic as a short noun phrase, a colon or full stop, then the specifics: *Figure 1: Synthetic data application. Left panel: observed new infections (black) and ...*; *Fig. 4. Aphid model. Marginal posterior plots for the two parameters.*
- Describe encodings explicitly (*solid grey*, *dashed grey*, *histograms*, *kernel density estimates overlaid*), the quantity shown (*filtering mean and 95% credible interval*), the data used (*computed for 1000 draws from...*), and how many replicates support it.
- Refer to every figure and table in the text, before it appears. Use *Figure N*, *Table N*, *left panel*, *right panel*.
- Tables report comparisons on common metrics (CPU time, ESS, ESS per second, relative efficiency, bias, RMSE) with a brief note on what the benchmark is.

## 10. Process for agents

1. **Check the register.** Decide whether the text is a formal paper, a response to reviewers or a short summary. Apply this guide fully to the first; keep the spelling, punctuation and phrasing rules for the others.
2. **Draft in British English from the start.** Do not convert later.
3. **Match the section pattern** in section 5 for the part you are writing.
4. **Keep claims tied to evidence** the user has supplied. Never fabricate results, numbers, benchmarks, citations, affiliations or funding.
5. **Run `scripts/check_british_spelling.sh`**, fix hits (other than the accepted exceptions in 2.3), and check your text for em dashes (the script also flags them) and remove any.
6. **Read once for flow.** Confirm: acronyms defined once; cross-references in full; *we* or the passive used consistently within each section; hedges where needed; no filler.

## 11. Worked example

American, informal draft:

> We propose a really new method that leverages a cheap approximation to speed up inference, and it's up to 10 times faster. We summarize the results in Table 1 and analyze why it works.

Rewritten in this style:

> We propose a method that leverages the tractability of a computationally cheap surrogate to accelerate inference. Our approach is about three times faster than the standard scheme and, in some cases, an order of magnitude faster. The results are summarised in Table 1, and we analyse the reasons for the gain in Section 4.

## 12. Known limits of this guide

- The corpus is small (five papers) and the venues differ (Bayesian Analysis, CSDA, Statistics and Computing, JCGS). Where venues disagree (citation punctuation, hyphenation of *Metropolis–Hastings*, quotation marks), the defaults above were chosen to follow the majority or the more standard British practice. Replace them if the target journal's author guidelines differ.
- Lead authorship varies, so the voice (*we* versus passive) is a blend. Golightly-led P4 leans on *we* and *our*; P2 leans on the passive.
- The guide covers prose style. It does not cover LaTeX conventions, macros or bibliography file formats.
