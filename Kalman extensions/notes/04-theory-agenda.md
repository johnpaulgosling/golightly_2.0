# Theory agenda

The questions below are the ones phase 5 answers. A question that the literature summary already settles is marked as settled, with the place it was settled. Notation is the notation in `notes/01-paper-context.md`.

## E4. Surrogate incremental weights

Target. If the incremental weight is the nearest-neighbour prediction of the ensemble Kalman likelihood, the parameter particles are not aimed at \(\hat{\pi}_{\mathrm{enkf}}\). They are aimed at the posterior under the product of those predictions. Call that posterior \(\pi_{\mathrm{knn}}\). Phase 5 has to define it.

Already settled. Using a surrogate as the target changes the target: Sherlock, Golightly and Henderson, Section 5.1. Chopin, Jacob and Papaspiliopoulos, Proposition 1, recovers the exact posterior only for an unbiased likelihood. Bon, Lee and Drovandi keep the expensive likelihood as the second-stage target and do not replace the incremental weight. Drovandi et al., Section 3.3, separate finite-sample bias of a Gaussian density from the Gaussian approximation. None of these is a bound on a nearest-neighbour weight.

Gap. If the incremental weight uses a nearest-neighbour prediction of the ensemble Kalman likelihood instead of that likelihood, what distribution do the parameter particles target?

Route. Write the surrogate contribution as a function of the current cloud of stored ensemble Kalman likelihoods, form the product, and name the posterior proportional to the prior times that product. The randomness of the stored values is part of the target, as the ensemble is part of \(\hat{\pi}_{\mathrm{enkf}}\).

Solved means. A stated target, plus a diagnostic, because no bound is available.

Fallback. If the product cannot be defined without a circular dependence on the particle's own uncomputed likelihood, report that and do not claim a surrogate-weight filter.

Separation of errors. The ensemble Kalman likelihood against the true likelihood is the error already present in \(\hat{\pi}_{\mathrm{enkf}}\). The nearest-neighbour prediction against the ensemble Kalman likelihood is a second error. They are not the same discrepancy.

Fixed ensemble size. Task 1.3 freezes this as the ensemble size \(N\), held fixed, with the nearest-neighbour surrogate replacing the ensemble Kalman likelihood in the incremental weight and in the screen. It does not mean a fixed number of parameter particles.

Cost. Once a particle's weight is the surrogate, that particle does not need a new ensemble forecast for the weight. State filtering for that particle still needs a forecast if the analysis ensemble is required. Phase 5 states which of those costs stops.

Bound. No result was found that the particles converge to \(\pi_{\mathrm{knn}}\), and no bound on the distance from \(\pi_{\mathrm{knn}}\) to \(\hat{\pi}_{\mathrm{enkf}}\) was found (`notes/03-search-log.md`, gap 3). The diagnostic, defined before any run, is: recompute the ensemble Kalman likelihood on a subset of particles and compare it with the surrogate weight. The comparison used in the design note is the absolute difference of the logarithms.

## E1. KD-tree neighbour search

Target. The delayed-acceptance kernel that screens with the nearest-neighbour surrogate and corrects with the ensemble Kalman likelihood. The intended invariant distribution is \(\hat{\pi}_{\mathrm{enkf}}\), provided stage two evaluates that likelihood.

Already settled. If stage two evaluates the intended target, and the approximation is positive whenever the proposal is positive, Christen and Fox, Theorem 1, gives invariance for one Markov chain. Sherlock, Golightly and Henderson, Theorem 1, is the adaptive batch-MCMC version under diminishing adaptation. The same neighbours, conditional on the stored likelihoods, give the same surrogate and therefore the same kernel.

Gap. If the KD-tree returns the same neighbours as a linear scan, is the delayed-acceptance kernel the same, conditional on the stored likelihood values?

Route. The surrogate in Golightly et al. (2026), Section 4.2, is a function of the neighbour set and the stored log-likelihoods. Equality of neighbour sets implies equality of the surrogate and of the two acceptance ratios.

Solved means. A cost statement, plus a warning. Not a new invariance theorem.

Fallback. If the tree is not cheaper at the dimension actually used, the claim that remains is the warning, and the implementation keeps the list.

Neighbour sets that differ. Ties and approximate neighbours are not covered by "the same kernel". A different but deterministic neighbour set still leaves \(\hat{\pi}_{\mathrm{enkf}}\) invariant if stage two evaluates the ensemble Kalman likelihood, because Theorem 1 of Christen and Fox does not require a particular approximation, only a positive one. The kernel itself changes. Approximate or random neighbours are a warning, not a theorem.

Cost in the E5 regime. Sherlock, Golightly and Henderson, Section 2, state \(O(d \log n)\) search and insert for a balanced tree, for moderate \(d\), and warn that axis-aligned splits degrade under correlation. They also say a KD-tree is the wrong structure for very low dimension. The regime named in Golightly et al. (2026), Section 6, is \(d_\theta < 10\), and the applications had \(M_r\) at most a few thousand. Phase 5 states the cost at that size rather than quoting the generic tree complexity as a reason to prefer the tree.

Update. When a proposal is accepted, the new parameter and its ensemble Kalman log-likelihood are stored. The tree inserts that point. The list appends it. Both stores are the input to the next surrogate.

## E2. Choice among kernels

Target. \(\hat{\pi}_{\mathrm{enkf}}\) if every candidate kernel preserves it, and if the choice does not depend on the proposed particle. If E4 is the outer weight, the target of the move is \(\pi_{\mathrm{knn}}\) instead, and the same distinction applies.

Already settled. Fearnhead and Taylor choose among kernels that are each \(\pi_t\)-invariant, and they treat the tuning as an auxiliary variable. The proposal may depend on the current cloud. Botha et al. (arXiv:2307.11553) switch between particle marginal Metropolis–Hastings and particle Gibbs. That switch needs a conditional particle filter and an unbiased likelihood. It does not apply here. Chopin, Jacob and Papaspiliopoulos, Section 3.2, likewise uses unbiasedness.

Gap. Which choices leave the current target invariant: a choice that depends only on time, a choice that depends on a cloud summary, a choice that depends on the current particle, a choice that depends on the proposed particle?

Route. A choice made before the proposal, among kernels that each satisfy detailed balance for the same target, is a mixture of those kernels and preserves the target. A choice that depends on the proposed particle has to sit inside the kernel, in the acceptance probability. Do not import the Botha et al. particle-Gibbs switch.

Criterion, defined before any simulation output. Cost per accepted move: the number of ensemble forecasts used by the move, divided by the number of proposals that are accepted. Early in the run the ensemble Kalman likelihood from time 0 to time \(t\) is cheap, so the rule prefers plain Metropolis–Hastings when \(t\) is small. The pre-registered rule is in the design note. Sherlock, Thiery and Golightly describe relative efficiency by the relative cost of the cheap approximation and by the stage-two acceptance rate. Those are the quantities the criterion uses. Their diffusion limit is not copied.

Solved means. A stated algorithm whose invariance has been checked under the pre-proposal restriction, and a statement of where a proposed-particle choice would break it.

Fallback. If the mixture argument fails, the claim shrinks to one fixed kernel, which is the 2026 algorithm.

## E3. Gradient proposals

Target. \(\hat{\pi}_{\mathrm{enkf}}\), if the Metropolis–Hastings ratio uses the ensemble Kalman likelihood and the proposal density.

Candidates, and the function each differentiates.

- A finite difference of the random ensemble Kalman log-likelihood differentiates (13), noisily, at the proposed and current ensembles.
- Chen, Sanz-Alonso and Willett differentiate the same map by automatic differentiation. Theorem 3.2 is the \(L^p\) convergence of that gradient to the true score, at rate \(N^{-1/2}\), for linear Gaussian transitions and a Gaussian initial law. Their Algorithm 4.1 has no accept-reject step.
- An ensemble sensitivity that is not a derivative of (13) is rejected. None was read as a substitute score.
- The linear-noise score of Lowe, Golightly and Sherlock, displays (17) and (19), is the gradient of \(\pi_{\mathrm{LNA}}\), not of \(\hat{\pi}_{\mathrm{enkf}}\). It exists for a stochastic kinetic model with an LNA. The Ornstein–Uhlenbeck example is linear Gaussian, so the exact score exists. Lotka–Volterra and the epidemic diffusion are in the class of that paper. Lorenz-96 is not presented there as a linear-noise model.
- The Rosato particle-filter gradient, Appendix A, displays (42) and (43), is not a derivative of (13).

Already settled. Rosato et al. use a Langevin proposal without an accept-reject step. That proposal is not adopted. Lowe et al. put a surrogate gradient in stage one and an unbiased particle likelihood in stage two. The 2026 second stage is the ensemble Kalman likelihood, so the analogy does not transfer unchanged. A Metropolis–Hastings correction that puts the proposal density in the ratio, and that evaluates the ensemble Kalman likelihood as the target density, leaves \(\hat{\pi}_{\mathrm{enkf}}\) invariant even when the gradient is approximate.

Gap. On the linear Gaussian example, does a corrected random-walk proposal that adds a finite-difference step along \(\nabla \log \hat{p}_{\mathrm{enkf}}\) still have an evaluable proposal density?

Route. Use a preconditioned Langevin proposal whose drift is a finite difference of (13), and include the Gaussian proposal density in the acceptance ratio. Restrict the claim to the linear Gaussian case, where Chen et al. say the gradient estimates the true score. Do not claim the rate in Theorem 3.2 for a finite difference, and do not claim it for a nonlinear transition.

Solved means. A stated algorithm with the acceptance ratio written out. Improvement in effective sample size per forecast is a simulation question, not a theorem.

Fallback. If the finite-difference proposal density cannot be evaluated, the gradient stays a diagnostic and the move remains a random walk.

## E6. When the Rao-Blackwellised correction is worth its cost

Targets, side by side, from `notes/01-paper-context.md`. The plain target \(\hat{\pi}_{\mathrm{enkf},t}\) is the parameter posterior under the product of ensemble Kalman contributions (13), using the linear Gaussian approximation \(g\) in place of \(f\) when \(f\) is not linear Gaussian. The Rao-Blackwellised target \(\tilde{\pi}_{\mathrm{enkf},t}\) is the parameter posterior under the product of the averages of the weights (24), which estimate the denominator of (21).

Worth its cost, defined before any run. Absolute error of the posterior means of \(\log \theta_i\), against a gold-standard posterior when one exists, divided by the number of model integrations. A correction is worth its cost only when that ratio is smaller than the same ratio for the plain filter.

Sharp comparison. In a linear Gaussian model, \(f = g\), so the ratio \(f/g\) in (24) equals 1 and does not depend on the particle. The Rao-Blackwellised weight then equals the ensemble Kalman predictive likelihood. The correction does not change the target, and it adds the cost of evaluating a ratio that is identically one. This identity is linear Gaussian only.

Conjecture. For a nonlinear observation, the ordering stated in Golightly et al. (2026), Section 6, is that the Rao-Blackwellised filter sits between the plain nested filter and SMC2 in accuracy and in cost. That ordering is not proved here. Papadakis et al. correct a state proposal with a weight that still contains the transition density. That is not this correction.

Solved means. The linear Gaussian identity, stated as such, and the nonlinear ordering labelled as a conjecture plus the simulation.

Fallback. If a nonlinear example cannot be run, the paper claims only the identity.

## E5. Regime

The illustrative scale in Golightly et al. (2026), Section 6, printed p. 19, is \(d_\theta < 10\) and \(d_y > 10\). It is not promoted to a theorem.

Scaling account that can be tested.

- One ensemble Kalman likelihood costs one forecast of \(N\) members at each observation time, then one \(d_y\)-dimensional Gaussian density.
- Rejuvenation at time \(t\) reruns that filter from time 0, so the cost is of order \(t M N\) model integrations when every particle is moved.
- Katzfuss, Stroud and Wikle, Proposition 2, in their Example 5, give \(\mathrm{var}(\log L^E) = O(n/N)\) when forecast members are independent draws from the true forecast. The 2026 paper cites the journal version of that review for the comparison with a particle filter. The proposition is not a theorem about the nested filter's posterior.

Solved means. A region in the \((d_\theta, d_y)\) plane where the account says the nested filter is the method one would run, with the boundaries left to the simulation. The output of phase 5 is the account. The output of phase 6 is the measurement.

Fallback. If the pilot grid is too small to see the boundary, the paper reports the account and the cells that were run, and does not draw a curve through unmeasured cells.

## Scope decision

- E1: attempt in reduced form. The agenda's answer is a cost comparison at small \(d_\theta\), plus the warning on approximate neighbours. A new invariant is not expected.
- E2: attempt in reduced form. Only a pre-proposal choice among a plain Metropolis–Hastings kernel and delayed-acceptance kernels that preserve \(\hat{\pi}_{\mathrm{enkf}}\). The particle-Gibbs switch is out of scope.
- E3: attempt in reduced form. A finite-difference gradient of (13), inside a corrected Metropolis–Hastings proposal, on the linear Gaussian example. Uncorrected Langevin, the Rosato score, and a general linear-noise transfer are out of scope.
- E4: attempt. The surrogate target can be defined. It is not parked.
- E5: attempt. The product is a measured region on a small grid, not a theorem about the thresholds 10 and 10.
- E6: attempt in reduced form. The linear Gaussian identity is in scope. The nonlinear ordering is a conjecture if a nonlinear cell is run, and is dropped if it is not.

The default paper shape stands. Resample-move extensions E1 to E3 stay at the centre. E4 stays beside them because the surrogate target can be stated. E5 stays as a scaling remark. E6 stays as the linear Gaussian identity. A real series is not part of this decision.
