# Theory agenda

Questions for parts A and B. Answers are in `notes/05-theory-notes.md`. This note does not claim those answers.

The literature summary has already settled the following, so they are not left open here.

- The constant-hazard Gaussian step is Golightly and Wilkinson (2015), equation (9), restated as Golightly and Sherlock (2019), equation (5). Section 3.2 of the 2019 paper says that step is often unreasonable, and Section 6 says accuracy falls as the inter-observation time grows.
- Equation (19) of Golightly and Sherlock (2019) is a Markov jump process proposal with an evaluable weight (3), for a Gaussian observation of the state.
- Theorem 4.2 of Corstanje et al. (2023) conditions a Poisson process on an exact end-point. The likelihood ratio (16) contains \(h(0, x_0)\).

## Part A

Target. The incidence proposal is \(q\), the product of Poisson probabilities with rates \(h^{*}\Delta\tau\). The importance target of one propagate step, as printed in Algorithm 2, uses the dSEIR transition and the observation mass function in the numerator. Part A does not change that numerator.

Already in hand. Whitaker et al. (2025), equation (12) and the display after (18). Golightly and Wilkinson (2015), equation (9). Golightly and Sherlock (2019), Sections 3.2, 5.1 and 6, for the constant-hazard guide on a jump process, not on dSEIR incidence.

Gap. Are equation (12) and the linearity sentence on p. 25 of Whitaker et al. (2025) the same assumption as the constant-hazard step in Golightly and Wilkinson (2015), equation (9)? With which law does p. 25 say the trajectories are inconsistent? Does a poor \(h^{*}\) change the importance target, or only the weights?

Route. Read (12) against equation (9), and read the weight in Algorithm 2. Do not add a theorem. The death-model numbers in Golightly and Sherlock (2019), Table 1, stay in that paper's model.

Solved means: a stated reading, with the pages, of what "inconsistent" refers to, and a diagnostic defined before any run. A numerical threshold is not required for the claim to be solved. If the reading cannot separate equation (12) from the p. 25 sentence, say so and do not invent a distinction.

Fallback. If the weight's numerator does depend on \(h^{*}\) after all, the claim shrinks to a description of the proposal, with no statement about the target.

Diagnostic, fixed here, before any output. For a latent path from the Section 4.1 SIR mechanism, and for observation spacings fixed in the design note, compute the effective sample size of the incidence weights in one window, using the formula in Golightly and Sherlock (2019), Section 5.2,
\[
\mathrm{ESS}(\tilde w_{1:N}) = \frac{\bigl(\sum_{i=1}^{N} \tilde w_i\bigr)^2}{\sum_{i=1}^{N} \tilde w_i^2}.
\]
The contact-rate path is held at the simulated path, so the diagnostic is about \(h^{*}\) and not about the blind contact-rate draw. The prediction to be checked, and not tuned after the run, is that the median of this effective sample size, across replicate data sets, is smaller at the coarsest pre-registered spacing than at the published unit spacing. A myopic proposal, with \(h^{*}\) replaced by \(h\), is computed on the same draws of the random numbers only if the design note says so. It is a comparator, not a second target.

## Part B

Target. A replacement may change the draw from \(q\) and the value of \(q\) in the denominator of the Algorithm 2 weight. It may not change the dSEIR transition, the observation model, the blind contact-rate propagation, the sufficient statistic, or the conditional draws of \(\theta\) and \(\lambda\).

Already in hand. Equation (19) and the weight (3) in Golightly and Sherlock (2019). Theorem 4.2 and the ratio (16) in Corstanje et al. (2023). Neither expression is the product of dSEIR Poisson probabilities on the subgrid.

Gap. Can either guide be evaluated as \(q\) in Algorithm 2 without a mapping that is not written in the source?

Route. Write the path each guide samples and the density each guide evaluates, from the sections above. Accept the guide only if that density is the density of the same incidence increments that the dSEIR transition in the numerator describes.

Solved means: either a numbered list of changes to Algorithm 2, each mapped to a section, or a decision to park.

Fallback. Park part B. Do not insert equation (19) into the Poisson rate and call it the 2019 algorithm. Do not drop \(h(0, x_0)\) from (16).

## Scope decision

Part A: `attempt`. The pages named above are enough for a reading and for the diagnostic. No numerical threshold will be claimed.

Part B: `park`. Golightly and Sherlock (2019), equation (19), samples a Markov jump process under a Gaussian observation of the state, and the weight (3) is the jump-process likelihood ratio. Whitaker et al. (2025), Algorithm 2, needs the density of Poisson incidence increments on a fixed grid, under a binomial or negative binomial observation of those increments. Equation (19) does not provide that density. Corstanje et al. (2023), Theorem 4.2, conditions a Poisson process on an exact integer end-point, and the ratio (16) contains the intractable transition probability \(h(0, x_0)\). Neither guide can be evaluated inside the Algorithm 2 weight without a construction that the source does not contain. The plan requires that this case be parked.

Phase 5 answers part A only.
