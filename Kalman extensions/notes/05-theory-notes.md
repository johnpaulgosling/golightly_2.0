# Theory notes

Source of the restated algorithm: `Source papers/5417950VOR.pdf`, Algorithm 6 and Sections 4.1 to 4.3. Notation is the notation in `notes/01-paper-context.md`. These notes do not improve the algorithm while restating it. Omissions that the PDF does not settle are listed in "Reading choices" and are not presented as part of the paper.

## Reading choices

The printed Algorithm 6 places the effective-sample-size test inside the particle loop, in the two-column layout. The surrounding text in Section 4.1 says that a resample-move step runs when the effective sample size falls below \(\gamma M\), which is the SMC2 order the paper says it keeps. The restatement completes the weight update for every particle, then tests the effective sample size once.

The distance in Section 4.2 is "some metric". The PDF does not name it. The simulation design chooses one before any run. The theory below treats the metric as given.

The Gamma priors in Section 5 are written \(\mathrm{Gamma}(a, b)\) with no shape-rate or shape-scale statement. The design note chooses shape-rate before any run.

Dynamic ensemble size, Section 4.1, is part of the published filter. Extension E4 holds \(N\) fixed. The restated algorithm records the published update and the studies that follow switch it off when they claim a fixed ensemble size.

## 5.1 Restated nested filter

### Algorithm A. Ensemble Kalman step at time \(t\) for one parameter

Source: Algorithm 3 and equations (8), (9), (11), (12), (13), as paraphrased in `notes/01-paper-context.md`.

Input: \(\theta\), analysis ensemble \(x_{t-1}^{1:N}\) (or an initial draw from \(p_0^{(\theta)}\) when \(t = 0\)), observation \(y_t\), observation matrix \(H\), observation covariance \(R\).

1. Forecast. For \(j = 1, \ldots, N\), draw \(\tilde{x}_t^j \sim p_t^{(\theta)}(\cdot \mid x_{t-1}^j)\). At \(t = 0\) the draw is from \(p_0^{(\theta)}\) and there is no parent state.
2. Forecast moments, equation (9). \(\hat{\mu}_{t \mid t-1} = N^{-1} \sum_{j=1}^{N} \tilde{x}_t^j\) and \(\hat{\Sigma}_{t \mid t-1}\) is the corresponding sample covariance with divisor \(N-1\).
3. Likelihood contribution, equation (13). \(\hat{p}_{\mathrm{enkf},t}^{(\theta)}(y_t \mid y_{0:t-1}, \tilde{x}_t^{1:N}) = \mathcal{N}(y_t; H\hat{\mu}_{t \mid t-1},\, H\hat{\Sigma}_{t \mid t-1} H^\top + R)\).
4. Kalman gain, equations (11) and (12). \(\hat{K}_t = \hat{\Sigma}_{t \mid t-1} H^\top (H\hat{\Sigma}_{t \mid t-1} H^\top + R)^{-1}\).
5. Stochastic analysis update. For \(j = 1, \ldots, N\), draw \(\tilde{y}_t^j \sim \mathcal{N}(H\tilde{x}_t^j, R)\) and set \(x_t^j = \tilde{x}_t^j + \hat{K}_t (y_t - \tilde{y}_t^j)\).

Output: the contribution (13), the analysis ensemble \(x_t^{1:N}\), and the forecast ensemble, which is an argument of (13).

### Algorithm B. Nested ensemble Kalman filter, step \(t\)

Source: Algorithm 6, the acceptance probability (18), and the random-walk proposal in Section 4.1.

Input: weighted particles \(\{\theta^i, u_{t-1}^i\}_{i=1}^{M}\), analysis ensembles, and the likelihood values \(\hat{p}_{\mathrm{enkf},t-1}^{(\theta^i)}(y_{0:t-1})\).

1. For each \(i = 1, \ldots, M\), run Algorithm A at \(\theta^i\). Set \(\tilde{u}_t^i = u_{t-1}^i \, \hat{p}_{\mathrm{enkf},t}^{(\theta^i)}(y_t \mid y_{0:t-1})\) and multiply the stored likelihood by the same contribution.
2. Effective sample size (6). Normalise \(\tilde{u}_t^{1:M}\). The effective sample size is \(1 / \sum_{i=1}^{M} (u_t^i)^2\).
3. If the effective sample size is at least \(\gamma M\), set \(u_t^i = \tilde{u}_t^i\) after normalisation and stop.
4. Otherwise resample. Draw indices with replacement from the normalised weights and set each resampled weight to \(1/M\). Copy the ensemble and the stored likelihood of the selected parent.
5. For each resampled particle \(i\), let \(V_t^{(-i)}\) be the sample covariance of the resampled particles other than \(i\). Propose \(\theta^\star = \theta^i + \epsilon\) with \(\epsilon \sim \mathcal{N}(0, \zeta V_t^{(-i)})\). Run Algorithm A from time 0 through time \(t\) at \(\theta^\star\). Accept with probability \(1 \wedge \rho_{\mathrm{enkf}}\), where
   \[
   \rho_{\mathrm{enkf}}
     = \frac{\pi(\theta^\star)\, \hat{p}_{\mathrm{enkf},t}^{(\theta^\star)}(y_{0:t})}{\pi(\theta^i)\, \hat{p}_{\mathrm{enkf},t}^{(\theta^i)}(y_{0:t})}
       \times \frac{q(\theta^i \mid \theta^\star)}{q(\theta^\star \mid \theta^i)}.
   \]
   This is (18). For the random walk above, \(V_t^{(-i)}\) does not depend on the value of particle \(i\), so the Gaussian proposal is symmetric and the proposal ratio equals 1, provided a rejected or accepted proposal does not change \(V_t^{(-i)}\) inside that ratio. On acceptance, replace \(\theta^i\), the stored likelihood, and the analysis ensemble.

Output: the updated cloud. The \(\theta\)-marginal of the extended target in Section 4.1 is \(\hat{\pi}_{\mathrm{enkf},t}\).

The product of the contributions (13) is not unbiased for the true likelihood. Algorithm B does not target \(\pi_t(\theta \mid y_{0:t})\).

### Algorithm C. Delayed-acceptance move

Source: Section 4.2, ratios (19) and (20). This replaces step 5 of Algorithm B.

1. From the distinct resampled particles and their stored log ensemble Kalman likelihoods, and for a point \(\theta\), let \(\theta^{[1]}, \ldots, \theta^{[k]}\) be the \(k\) nearest neighbours under the chosen metric, with distances \(d_{[i]}\). The surrogate log-likelihood is the inverse-distance average in Section 4.2. If some \(d_{[i]} = 0\), the surrogate equals the stored log-likelihood at that neighbour.
2. Propose \(\theta^\star\) as in Algorithm B. Accept the screen with probability \(1 \wedge \rho_1\), where \(\rho_1\) is (19): the ratio (18) with both ensemble Kalman likelihoods replaced by the surrogate.
3. If the screen rejects, keep \(\theta^i\). If the screen accepts, run the ensemble Kalman filter from time 0 through time \(t\) at \(\theta^\star\) and accept with probability \(1 \wedge \rho_{2 \mid 1}\), where \(\rho_{2 \mid 1}\) is (20).

The product \(\rho_1 \rho_{2 \mid 1}\) equals \(\rho_{\mathrm{enkf}}\), by algebra of (19) and (20), whenever the same proposal density appears in both ratios. The kernel is reversible with respect to the extended ensemble Kalman target, by the argument the paper attributes to standard delayed-acceptance theory. Christen and Fox, Theorem 1, is the form of that argument read in phase 3: the parent kernel is irreducible for the ensemble Kalman target, the random-walk proposal is reversible, and a positive surrogate wherever the proposal is positive keeps that target invariant. The product of the acceptance probabilities is at most the plain acceptance probability.

### Algorithm D. Rao-Blackwellised weight, one time step

Source: Section 4.3, displays (21), (22) and (24), Algorithm 7.

1. Choose a linear Gaussian approximation \(g_t^{(\theta)}(y_t \mid x_t) = \mathcal{N}(y_t; \tilde{H} x_t, \tilde{R})\).
2. Run Algorithm A with \(H = \tilde{H}\) and \(R = \tilde{R}\). The Gaussian predictive likelihood of that run is \(\hat{g}_{\mathrm{enkf},t}^{(\theta)}\).
3. The unnormalised weight of analysis member \(j\) is (24),
   \[
   \tilde{w}_t^j
     = \hat{g}_{\mathrm{enkf},t}^{(\theta)}(y_t \mid y_{0:t-1}, \tilde{x}_t^{1:N})
       \times \frac{f_t^{(\theta)}(y_t \mid x_t^j)}{g_t^{(\theta)}(y_t \mid x_t^j)}.
   \]
4. The incremental weight of the parameter particle is the average of \(\tilde{w}_t^{1:N}\).

Putting that average into step 1 of Algorithm B, in place of (13), is the Rao-Blackwellised recursion. Its parameter target is \(\tilde{\pi}_{\mathrm{enkf},t}\). It is not \(\pi_t\).

## 5.2 E4. Surrogate weights

Modified algorithm. Replace the incremental weight in step 1 of Algorithm B by the nearest-neighbour prediction, at \(\theta^i\), of the ensemble Kalman likelihood contribution, using stored contributions from other particles at the previous time and at the current time only where those contributions have already been computed. A particle with no stored contribution is evaluated with Algorithm A and then stored. Particles that already have a stored neighbour set take the surrogate as their weight and do not run Algorithm A for the weight.

This definition is usable only because the stored values come from earlier ensemble Kalman evaluations, not from the particle's own uncomputed likelihood. The circular case in the fallback of the agenda does not arise.

Target. Write \(\ell_{\mathrm{knn},t}(\theta)\) for the surrogate log-likelihood of \(y_{0:t}\) at \(\theta\), built from the stored cloud. The parameter posterior intended by the weights is
\[
\pi_{\mathrm{knn},t}(\theta)
  \propto \pi(\theta)\, \exp\bigl(\ell_{\mathrm{knn},t}(\theta)\bigr).
\]
The stored cloud is random. Conditional on the stored cloud, the weights target \(\pi_{\mathrm{knn},t}\) in the same heuristic sense that Algorithm B targets \(\hat{\pi}_{\mathrm{enkf},t}\): the incremental weight is the contribution that defines the target, and there is no unbiasedness argument. Chopin, Jacob and Papaspiliopoulos, Proposition 1, does not apply. No convergence theorem is claimed.

Two errors. \(\hat{\pi}_{\mathrm{enkf},t}\) differs from \(\pi_t\) because (13) replaces the true predictive density. \(\pi_{\mathrm{knn},t}\) differs from \(\hat{\pi}_{\mathrm{enkf},t}\) because \(\ell_{\mathrm{knn},t}\) replaces the ensemble Kalman log-likelihood. A comparison of \(\pi_{\mathrm{knn},t}\) with \(\pi_t\) mixes the two.

Fixed ensemble size. \(N\) is held fixed. The screen in Algorithm C, if it is still used, also uses the surrogate. New ensemble Kalman evaluations stop for particles whose weight and whose rejected proposals are served by the surrogate. They do not stop for a proposal that passes the screen, and they do not stop if an analysis ensemble is required for a particle that has not been evaluated. The cost per time step therefore falls only for the unevaluated weight updates. It is not a constant independent of \(t\) if any particle is still propagated.

Diagnostic, before any output is seen. On a subset of particles, recompute the ensemble Kalman log-likelihood and record the absolute difference from the surrogate log-likelihood. No bound on that difference was found. The design note sets the discrepancy at which the surrogate target is called a poor approximation of \(\hat{\pi}_{\mathrm{enkf}}\).

Will appear in the paper. The target \(\pi_{\mathrm{knn}}\), the split of the two errors, and the diagnostic. A simulation must show the diagnostic and the number of forecasts. It must not describe \(\pi_{\mathrm{knn}}\) as \(\hat{\pi}_{\mathrm{enkf}}\) or as \(\pi_t\).

## 5.3 E1. The same neighbours are the same kernel

Modified algorithm. Replace the linear neighbour scan inside Algorithm C by a KD-tree on the stored points. The tree returns \(k\) neighbours. On acceptance, insert the new point and its ensemble Kalman log-likelihood.

Conditional on the stored likelihoods, the surrogate in Section 4.2 is a function of the neighbour set and the distances. If the tree and the linear scan return the same multiset of neighbours, the surrogate, \(\rho_1\) and \(\rho_{2 \mid 1}\) agree, and the delayed-acceptance kernel agrees. The only new statement is cost.

A different deterministic neighbour set changes the kernel. If the surrogate is positive wherever the proposal is positive, Christen and Fox, Theorem 1, still leaves the ensemble Kalman target invariant, because stage two evaluates that target. Approximate or random neighbours are not covered by the theorem as read, because the proof uses a fixed approximation inside the kernel. They are a warning.

Cost at the dimension that will be used. The studies use \(d_\theta \le 3\) and a few tens to a few hundred stored points, which is the small-parameter end of the regime in Section 6 of the 2026 paper, not the large-dimension regime in which a tree is motivated. Sherlock, Golightly and Henderson, Section 2, give \(O(d \log n)\) for a balanced tree and \(O(n)\) for a list, and they say a KD-tree is a poor structure in very low dimension. At the size of these studies the list is expected to be cheaper once the cost of maintaining the tree is counted. The simulation counts distance evaluations and records which search is cheaper. It does not claim a saving that the count does not show.

Will appear in the paper. The equality of kernels when the neighbour sets agree, the invariance warning for a different deterministic set, and the cost count. A simulation must show whether the neighbour sets agree and whether the tree uses fewer distance evaluations.

## 5.4 E2. A mixture of invariant kernels

Modified algorithm. Before proposing, choose one kernel from a finite list. Each kernel is either the plain move in step 5 of Algorithm B or Algorithm C with a fixed neighbour count. The choice may depend on \(t\) and on summaries of the cloud that do not depend on the proposed value, including the effective sample size and a running estimate of cost per accepted move. The chosen kernel is then applied as written.

Invariance. Each listed kernel preserves \(\hat{\pi}_{\mathrm{enkf},t}\) under the conditions in Algorithms B and C. A choice that is made before the proposal, and that does not depend on the proposed point, produces a mixture of those kernels. A mixture of kernels with the same invariant distribution preserves that distribution. The ensemble Kalman likelihood is not unbiased, so this sentence does not cite Chopin, Jacob and Papaspiliopoulos, Proposition 1, and it does not cite Botha et al. (arXiv:2307.11553). Those proofs need an unbiased particle likelihood, and the particle-Gibbs kernel needs a conditional particle filter, which Algorithm A does not provide.

A choice that depends on the proposed particle is not this mixture. It would have to be absorbed into the proposal kernel. That version is not used.

The pre-registered rule, from the agenda's criterion, is stated in the design note: plain Metropolis–Hastings when the length of the series so far is at most half the terminal length, and delayed acceptance with \(k = 3\) afterwards. The criterion used to justify that split, before seeing output, is cost per accepted move. Early in the run a full ensemble Kalman likelihood is a short filter, so the screen saves little. The rule is a function of \(t\) only, which the mixture argument covers.

Fearnhead and Taylor's expected squared jumping distance, and Botha et al.'s minimum squared jumping distance divided by the number of state particles, are the sources of the idea of a jumping-distance score. They are not copied. The score used here is the agenda's cost per accepted move, which Sherlock, Thiery and Golightly's introduction supports as a comparison of relative cost and stage-two acceptance, without using their high-dimensional diffusion limit.

Will appear in the paper. The mixture statement and the pre-registered time rule. A simulation must compare the rule with each fixed kernel on cost per accepted move. If the rule is worse than the better fixed kernel, the extension is qualified or removed in the findings note.

## 5.5 E3. A corrected finite-difference proposal

Modified algorithm. On the linear Gaussian Ornstein–Uhlenbeck model only, replace the random-walk proposal in Algorithm B by
\[
\theta^\star
  = \theta^i + \frac{\lambda^2}{2} \widehat{\nabla} \log \hat{p}_{\mathrm{enkf},t}^{(\theta^i)}(y_{0:t})
    + \lambda Z,
  \qquad Z \sim \mathcal{N}(0, I),
\]
where \(\widehat{\nabla}\) is a central finite difference of the ensemble Kalman log-likelihood and the prior gradient is omitted from the drift so that the finite difference is only of (13). The acceptance probability is \(1 \wedge \rho_{\mathrm{enkf}}\), and the proposal ratio uses the Gaussian density of this proposal in both directions. Evaluating the reverse density requires the finite-difference gradient at \(\theta^\star\) as well as at \(\theta^i\).

The finite difference is a derivative of (13), not of the true likelihood. Chen, Sanz-Alonso and Willett, Theorem 3.2, say that an automatically differentiated gradient of the ensemble Kalman log-likelihood converges to the true score in the linear Gaussian case. The finite difference is not that automatic derivative, and the rate is not claimed for it. The theorem is the reason the claim is restricted to the linear Gaussian example.

The proposal density is included in \(\rho_{\mathrm{enkf}}\). The target density in the ratio is the ensemble Kalman likelihood times the prior. An approximate gradient therefore does not change the invariant distribution, provided the usual Metropolis–Hastings conditions hold for this proposal. The Langevin proposal without an accept-reject step, used by Rosato et al., is not used. The Rosato score is not a derivative of (13). The linear-noise score of Lowe, Golightly and Sherlock is not a derivative of (13) either, and it is not used in this reduced claim.

Will appear in the paper. The corrected proposal on the linear Gaussian example, with the restriction stated. A simulation must compare effective sample size per ensemble forecast with the random-walk move, at a matched number of likelihood evaluations. If there is no gain, the findings note says so.

## 5.6 E6. The linear Gaussian identity

Plain target: \(\hat{\pi}_{\mathrm{enkf},t}\), Algorithm B. Rao-Blackwellised target: \(\tilde{\pi}_{\mathrm{enkf},t}\), Algorithm D.

Linear Gaussian identity. If \(f_t^{(\theta)} = g_t^{(\theta)}\), the ratio in (24) equals 1 for every analysis member. The average of the weights (24) equals the ensemble Kalman predictive likelihood (13). The incremental weights agree, so the parameter targets agree. Evaluating the ratio costs extra density evaluations and does not change the estimate. The identity uses linearity and Gaussianity of the observation model. It is not a general rule.

Conjecture, not used as a theorem. For \(f \ne g\), Golightly et al. (2026), Section 6, expect the Rao-Blackwellised filter to lie between the plain nested filter and SMC2 in accuracy and in cost. Phase 5 does not prove that ordering. A simulation may illustrate it. Papadakis et al., weight (44), still contains the transition density, so it is not evidence for or against the conjecture.

Worth its cost. The design note compares absolute error of posterior means of \(\log \theta_i\), relative to a gold-standard mean when one exists, per model integration. In the linear Gaussian cell the identity says the correction cannot improve the error, so it is not worth its cost.

Will appear in the paper. The identity, labelled as linear Gaussian. The nonlinear ordering appears only if the findings note supports the conjecture, and then only as a conjecture plus that run.

## 5.7 E5. A scaling account, not a theorem

Quote, from Section 6 of Golightly et al. (2026), printed p. 19: the nested filter is of greatest utility when the parameter dimension is less than 10 and the observation dimension is greater than 10. Those thresholds are an illustration.

Account.

1. Algorithm A at one time costs \(N\) transition draws and one Gaussian density of dimension \(d_y\). A likelihood from time 0 to time \(t\) repeats that step \(t+1\) times.
2. A rejuvenation of \(M\) particles at time \(t\) repeats the likelihood, so the leading cost is of order \(t M N\) transition draws when every proposal is evaluated.
3. Katzfuss, Stroud and Wikle, Proposition 2, in Example 5: if the forecast members are independent draws from the true forecast, the variance of the log ensemble Kalman likelihood is \(O(n/N)\) as \(n, N \to \infty\). Keeping that variance bounded asks for \(N\) of order the observation dimension in that example. A particle-filter likelihood does not have that linear scaling. The proposition assumes independent forecast draws. The ensemble in Algorithm A is interacting, so the proposition is an analogy, not a theorem about Algorithm B.

The region where the account says one would run the nested filter is small \(d_\theta\), so that the random-walk rejuvenation and the neighbour search stay cheap, and large \(d_y\), so that the linear ensemble scaling is the reason not to run a particle filter. The boundaries are measured in phase 6. They are not asserted to be the numbers 10 and 10.

Will appear in the paper. The account and the cells that were measured. No curve is drawn through a cell that was not run.

## Amendment, 15 October 2026

The pilot in `notes/06-simulation-findings.md` failed the pre-registered effective-sample-size comparison for the finite-difference proposal. The invariance argument in Section 5.5 is unchanged. The proposal is not carried forward as a method. See "Dropped".

## Dropped

- A theorem that a KD-tree changes the invariant distribution. Not claimed. Same neighbours give the same kernel. Different deterministic neighbours keep the target if stage two evaluates it.
- Approximate nearest neighbours as a justified screen. Not claimed.
- The Botha et al. switch between particle marginal Metropolis–Hastings and particle Gibbs. The ensemble Kalman filter does not supply a conditional particle path, and the unbiasedness assumption fails.
- Fearnhead and Taylor's convergence theorem for the distribution of tuning parameters, copied as a proof for ensemble Kalman weights. Not claimed. Only the pre-proposal mixture is claimed.
- Uncorrected Langevin dynamics. Not claimed. Rosato et al. use them. They are not shown to leave \(\hat{\pi}_{\mathrm{enkf}}\) invariant.
- The Rosato particle-filter gradient as a score of (13). Not claimed.
- The linear-noise gradient as a score of \(\hat{\pi}_{\mathrm{enkf}}\). Not claimed. It remains available for a later surrogate screen of the Lowe et al. type, which is outside this reduced E3.
- Chen et al.'s \(N^{-1/2}\) rate for a finite-difference gradient, and for a nonlinear transition. Not claimed.
- A bound on \(\pi_{\mathrm{knn}}\) against \(\hat{\pi}_{\mathrm{enkf}}\). Not found. The diagnostic replaces it.
- Convergence of the surrogate-weight algorithm in the sense of Chopin, Jacob and Papaspiliopoulos, Proposition 1. Not claimed.
- The thresholds \(d_\theta < 10\) and \(d_y > 10\) as a theorem. Not claimed.
- A general proof that the Rao-Blackwellised filter is worth its cost. Not claimed. The linear Gaussian identity says that, in that case, it is not.
- The finite-difference Langevin proposal as a method to be used. The acceptance ratio in Section 5.5 still leaves \(\hat{\pi}_{\mathrm{enkf}}\) invariant. The pilot's pre-registered comparison, effective sample size per transition draw, went against the proposal. It is not part of the recommended algorithm.

## Amendment, 15 October 2026. A bound on \(\pi_{\mathrm{knn}}\) against \(\hat{\pi}_{\mathrm{enkf}}\) was not obtained

This amendment does not change the definition of \(\pi_{\mathrm{knn}}\) in Section 5.2, and it does not replace the diagnostic. It records a further attempt to bound the distance between \(\pi_{\mathrm{knn}}\) and \(\hat{\pi}_{\mathrm{enkf}}\). The attempt does not close. No numbered theorem is stated.

The routes below use only the literature summary and the papers already filed. Each one stops before a distance for this algorithm is obtained.

1. Chopin, Jacob and Papaspiliopoulos, Proposition 1, identifies the parameter marginal with the exact posterior only when the product of incremental weights is unbiased for the true likelihood. The nearest-neighbour weight is not unbiased for the ensemble Kalman likelihood. The proposition gives no distance between the two approximate posteriors.

2. Sherlock, Golightly and Henderson, Section 5.1, write that targeting the surrogate invalidates draws from the expensive posterior. They do not bound the difference of the two posteriors.

3. Bon, Lee and Drovandi keep the expensive likelihood as the second-stage target of the mutation. The preprint read in phase 3 states no limit for an algorithm whose incremental weights are the surrogate.

4. Drovandi, Everitt, Golightly and Prangle, Section 3.3, and the Ghurye–Olkin estimator discussed there, concern finite-sample bias of a plug-in Gaussian density. That is not the nearest-neighbour error. Temfack and Wyse use the same estimator for an epidemic observation variance and likewise do not treat a nearest-neighbour weight.

5. A conditional total-variation calculation, derived in this amendment and not attributed to a stored paper. Let \(\ell_1\) and \(\ell_2\) be two fixed log-likelihoods, and let \(\pi_i(\theta) \propto \pi(\theta) \exp(\ell_i(\theta))\), with both normalising constants finite and positive. Suppose \(|\ell_1(\theta) - \ell_2(\theta)| \le \delta\) at every \(\theta\) in the support of the prior. Set \(r(\theta) = \exp(\ell_1(\theta) - \ell_2(\theta))\) and \(\mu = \mathrm{E}_{\pi_2}[r]\). Then \(e^{-\delta} \le r(\theta) \le e^{\delta}\), so \(e^{-\delta} \le \mu \le e^{\delta}\), and the density ratio \(\rho = \pi_1 / \pi_2 = r / \mu\) satisfies \(e^{-2\delta} \le \rho \le e^{2\delta}\). Hence \(|\rho - 1| \le e^{2\delta} - 1\). The total variation distance is half the expectation of \(|\rho - 1|\) under \(\pi_2\), and it is at most 1, so
   \[
   \|\pi_1 - \pi_2\|_{\mathrm{TV}}
     \le \min\bigl(1,\ (e^{2\delta} - 1) / 2\bigr).
   \]
   The hypothesis was not established for \(\ell_{\mathrm{knn}}\) and the ensemble Kalman log-likelihood. The pilot diagnostic is a median absolute difference of one increment on eight particles. It is not a uniform bound on the log-likelihood of the series, and it is not \(\delta\) in the display above. Substituting the diagnostic into the display would not be a proof. The calculation also treats both log-likelihoods as fixed functions. \(\pi_{\mathrm{knn}}\) is conditional on a stored cloud, while \(\hat{\pi}_{\mathrm{enkf}}\) is a marginal of an extended target that still contains the ensembles. A fresh ensemble Kalman evaluation is a new draw. The variance cells in `notes/06-simulation-findings.md`, from `results/s5-variance.csv`, are already large relative to a small \(\delta\): the sample variance of the log ensemble Kalman likelihood is 14.059854 at ensemble size 8 in one observation dimension. Katzfuss, Stroud and Wikle, Proposition 2, is an analogy for that variance in a different example. It is not a uniform bound, and it points the wrong way for one: the log-likelihood moves when the ensemble is redrawn.

6. If a single fixed log-likelihood were Lipschitz with constant \(L\), the inverse-distance average in Section 4.2 of Golightly et al. (2026) would have absolute error at most \(L\) times the harmonic mean of the distances to the \(k\) neighbours. The absolute error of the weighted average is at most \(k L / \sum_{i=1}^{k} d_{[i]}^{-1}\), because each neighbour error is at most \(L d_{[i]}\) and the weight \(d_{[i]}^{-1}\) cancels that factor. No stored paper supplies a finite Lipschitz constant for the ensemble Kalman log-likelihood on the support of the Gamma prior. That support is unbounded. The same Lipschitz argument does not apply across two independent ensemble draws. This route stops. No external interpolation paper was required by name in the notes, and none is cited here.

The diagnostic in Section 5.2 remains the comparison that the paper can report. E1 and E2 are unchanged as invariance and cost remarks. The amendment in `research-plan.md` of this date removes them from the claim. It does not make the remarks false.
