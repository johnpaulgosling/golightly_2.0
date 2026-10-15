# Context: nested ensemble Kalman filter (Golightly et al., 2026)

Source: `Source papers/5417950VOR.pdf`, read in full. Printed pages below are the article pages ("Page X of 23"), not the PDF file index. Equation and algorithm numbers are those printed in the paper. This note paraphrases. The only passages kept close to the original wording are the future-work sentences in "Open problems", which task 1.2 needs.

## Model class and the inference target at time t

A state-space model is defined for a fixed parameter \(\theta = (\theta_1, \ldots, \theta_{d_\theta}) \in \Omega\) (Section 2.1, p. 3). The latent state \(X_t \in \mathcal{X} = \mathbb{R}^{d_x}\) has initial density \(p_0^{(\theta)}\) and transition densities \(p_t^{(\theta)}(x_t \mid x_{t-1})\) for \(t = 1, \ldots, T\). The observation \(Y_t \in \mathcal{Y} = \mathbb{R}^{d_y}\) has density \(f_t^{(\theta)}(y_t \mid x_t)\) for \(t = 0, \ldots, T\).

The exact marginal parameter posterior at the terminal time is
\[
\pi_T(\theta \mid y_{0:T}) \propto \pi(\theta)\, p_T^{(\theta)}(y_{0:T}),
\]
equation (1). The sequential target at time \(t\) is the joint filtering density (2),
\[
\pi_t(\theta, x_t \mid y_{0:t}) = \pi_t(\theta \mid y_{0:t})\, p_t^{(\theta)}(x_t \mid y_{0:t}).
\]
The parameter recursion that an idealised filter would use is (5): the previous parameter posterior is multiplied by the observed-data likelihood contribution \(p_t^{(\theta)}(y_t \mid y_{0:t-1})\). That contribution is the object the ensemble Kalman filter replaces.

## What is kept from SMC2, and what replaces the inner particle filter

Section 2.3 (pp. 4–5) recalls SMC2 (Algorithm 2). A cloud of \(M\) parameter particles is reweighted by a particle-filter estimate of the likelihood contribution, and, when the effective sample size (6) falls below \(\gamma M\), the particles are resampled and moved by a pseudo-marginal Metropolis–Hastings kernel whose target is \(\pi_t(\theta \mid y_{0:t})\). The acceptance probability is (7). The inner filter is Algorithm 1.

Section 4 (pp. 7–9) keeps that outer recursion and replaces Algorithm 1 by the ensemble Kalman filter (Algorithm 3). Parameter particles are weighted by the ensemble Kalman likelihood contribution, and the move is one iteration of ensemble MCMC (Section 3.2), whose acceptance probability is (15) in the batch case and (18) inside the filter. The resulting scheme is the nested ensemble Kalman filter (NEnKF), Algorithm 6.

The paper's reason for the replacement is in the introduction (p. 2) and at the start of Section 4 (pp. 7–8). A particle filter's likelihood estimator needs a number of state particles that grows exponentially with the observation dimension, whereas the variance of the log ensemble Kalman likelihood can be controlled by scaling the ensemble size linearly with that dimension. The second comparison is attributed to Katzfuss, Stroud and Wikle (2019); this note has not opened that paper.

## The ensemble Kalman likelihood

Section 3.1 (pp. 5–6) assumes the linear Gaussian observation model (8),
\[
f_t^{(\theta)}(y_t \mid x_t) = \mathcal{N}(y_t; Hx_t, R).
\]
Given an ensemble \(x_{t-1}^{1:N}\) from the previous analysis, each member is propagated with the state transition to form a forecast ensemble \(\tilde{x}_t^{1:N}\). The forecast density is replaced by a Gaussian whose mean and variance are the sample moments of that ensemble, equation (9). The Kalman update (11)–(12) is then closed. The paper also describes the stochastic form used in Algorithm 3: a pseudo-observation \(\tilde{y}_t^j \sim \mathcal{N}(H\tilde{x}_t^j, R)\) shifts the forecast member, \(x_t^j = \tilde{x}_t^j + \hat{K}_t(y_t - \tilde{y}_t^j)\).

The ensemble Kalman likelihood contribution is the Gaussian marginal of the forecast under (8), equation (13):
\[
\hat{p}_{\mathrm{enkf},t}^{(\theta)}(y_t \mid y_{0:t-1}, \tilde{x}_t^{1:N})
  = \mathcal{N}\bigl(y_t; H\hat{\mu}_{t\mid t-1},\, H\hat{\Sigma}_{t\mid t-1}H^\top + R\bigr).
\]
The likelihood of the series is the product of these contributions. It is a function of \(\theta\) and of the forecast ensembles drawn along the way.

What it estimates, and in what sense it is not the exact likelihood. Equation (13) is exact for the Gaussian forecast approximation (9), not for the true predictive density of the state-space model. The approximation enters because the forecast law is replaced by a Gaussian with ensemble moments. The draw of the ensemble makes (13) a random function of \(\theta\). Section 3.2 (p. 6) therefore writes an extended target (14) whose \(\theta\)-marginal is denoted \(\hat{\pi}_{\mathrm{enkf},T}(\theta \mid y_{0:T})\). Ensemble MCMC targets that marginal. The paper does not claim that (13) is unbiased for \(p_T^{(\theta)}(y_{0:T})\). The language of bias is used for the filtering distribution when the observation model is nonlinear or non-Gaussian (introduction, p. 2; Section 4.3, p. 10): using the ensemble Kalman filter directly can then give biased or inaccurate filtering estimates, because the observation density is itself replaced by a linear Gaussian approximation.

## Delayed-acceptance rejuvenation and the k nearest neighbours

Section 4.2 (pp. 9–10). If the resample-move step runs at time \(t\), its cost is \(O(tMN)\), because each proposal runs the ensemble Kalman filter from time 0 to time \(t\). The Metropolis–Hastings move in step 3 of Algorithm 6 is replaced by a delayed-acceptance move.

The surrogate is built from the \(M_r\) distinct resampled parameter particles and their log ensemble Kalman likelihoods. For a proposed \(\theta\), find the \(k\) nearest neighbours \(\theta^{[1]}, \ldots, \theta^{[k]}\) under a chosen distance, with distances \(d_{[i]}\). The surrogate log-likelihood is the inverse-distance weighted average
\[
\log \hat{p}_{\mathrm{knn},t}^{(\theta)}(y_{0:t})
  = \frac{\sum_{i=1}^{k} d_{[i]}^{-1} \log \hat{p}_{\mathrm{enkf},t}^{(\theta^{[i]})}(y_{0:t} \mid \tilde{x}_{0:t}^{[i],1:N})}{\sum_{i=1}^{k} d_{[i]}^{-1}}.
\]
The dependence on the neighbour set is suppressed in the paper's notation.

Stage one proposes \(\theta^\star \sim q(\theta^i, \cdot)\), evaluates the surrogate, and accepts the screen with probability \(\alpha_1 = 1 \wedge \rho_1\), where \(\rho_1\) is (19): the usual Metropolis–Hastings ratio with the ensemble Kalman likelihood replaced by the surrogate. If the screen accepts, stage two runs the ensemble Kalman filter at \(\theta^\star\) and accepts with probability \(\alpha_{2\mid 1} = 1 \wedge \rho_{2\mid 1}\), where \(\rho_{2\mid 1}\) is (20). The product of the two ratios equals the ensemble MCMC ratio (18), so the kernel remains reversible with respect to the extended ensemble Kalman target. The product of the two acceptance probabilities is at most the plain ensemble MCMC acceptance probability. In the applications the neighbour count is \(k = 3\) (Section 5).

The move kernel used in the paper is a random walk on the current particle, \(\theta^\star = \theta^i + \epsilon^i\) with \(\epsilon^i \sim \mathcal{N}(0, \zeta V_t)\) (Section 4.1, p. 8). For reversibility, \(V_t\) is the sample variance of the resampled particles other than particle \(i\). The scaling may be chosen by the practitioner; the paper points to \(\zeta^2 = 2.56^2 / d_\theta\) from the pseudo-marginal random-walk literature. The applications use one ensemble MCMC iteration per particle, except Lorenz-96, which uses five (Section 5.4, p. 19).

Section 4.1 also describes a dynamic increase in the ensemble size \(N\). After a move, if an estimate \(\hat{\sigma}_N^2\) of the variance of the log ensemble Kalman likelihood at a central parameter exceeds 1.5, set the new ensemble size to \(\hat{\sigma}_N^2 N\) and regenerate ensembles with an artificial backward kernel whose incremental weight is 1. The applications use the threshold 1.5 and the effective-sample-size fraction \(\gamma = 0.4\).

## Rao-Blackwellised correction

Section 4.3 (pp. 10–12) drops the assumption that \(f_t^{(\theta)}\) is linear and Gaussian. The observation density need only be evaluable. It is approximated by a linear Gaussian density \(g_t^{(\theta)}(y_t \mid x_t) = \mathcal{N}(y_t; \tilde{H} x_t, \tilde{R})\), for example by a Taylor expansion of a nonlinear mean, or by augmenting the state with the nonlinear observation function. For a Gaussian observation with state-dependent variance, Sections 5.2 and 5.3 set \(\tilde{R}\) from the forecast mean and, in the Rao-Blackwellised scheme, inflate it by 2.

Three options are distinguished.

1. Plain NEnKF. Run Algorithm 6 with the ensemble Kalman filter using \(g\) in place of \(f\). The target remains the ensemble Kalman posterior \(\hat{\pi}_{\mathrm{enkf},t}\). The extra error is the replacement of \(f\) by \(g\).
2. A particle filter that uses the ensemble Kalman filter only as a proposal, as in Papadakis et al. (2010). The weight is (23). It still contains the transition density \(p_t^{(\theta)}(x_t \mid x_{t-1})\). That density can be sampled on a fine grid between observations but cannot usually be evaluated, so (23) is unavailable in the setting the paper cares about.
3. Rao-Blackwellised particle filter, Algorithm 7. One run of Algorithm 3, with \(H = \tilde{H}\) and \(R = \tilde{R}\), proposes the whole analysis ensemble from the Gaussian approximation (22). The unnormalised weight of member \(j\) is (24),
   \[
   \tilde{w}_t(\tilde{x}_t^{1:N}, x_t^j)
     = \hat{g}_{\mathrm{enkf},t}^{(\theta)}(y_t \mid y_{0:t-1}, \tilde{x}_t^{1:N})
       \times \frac{f_t^{(\theta)}(y_t \mid x_t^j)}{g_t^{(\theta)}(y_t \mid x_t^j)}.
   \]
   The forecast density appears in both the target identity (21) and the proposal (22), so it cancels, and the transition density is never evaluated. The average of these weights estimates the denominator of (21), the observed-data likelihood under the Gaussian forecast and the true observation density. Putting that estimate into the SMC2 recursion (Algorithm 2) targets a parameter posterior that the paper denotes \(\tilde{\pi}_{\mathrm{enkf},t}(\theta \mid y_{0:t})\). The scheme is called RB-SMC2.

The correction therefore puts the true observation density back into the weight, through the ratio \(f/g\), and it removes the latent path between observation times from the weight by using the Gaussian forecast as the transition approximation. It does not restore the exact posterior \(\pi_t(\theta \mid y_{0:t})\). Section 4.3 states that the procedure sacrifices accuracy relative to targeting \(p_t^{(\theta)}(x_t \mid y_{0:t})\), and Section 6 (p. 19) summarises the intended ordering: RB-SMC2 is typically less accurate but cheaper than vanilla SMC2, and more expensive but more accurate than plain NEnKF.

## The four examples

Settings that the paper leaves unspecified are marked as omissions. In particular, the Gamma priors are written \(\mathrm{Gamma}(a, b)\) with no statement of shape-rate or shape-scale.

### 5.1 Ornstein–Uhlenbeck (pp. 12–13)

The latent process is a scalar Ornstein–Uhlenbeck diffusion with drift \(\theta_1(\theta_2 - X_t)\) and diffusion coefficient \(\theta_3\). The transition is the exact Gaussian solution. Fifty observations are taken at integer times from one path with \(x_0 = 10\) and \(\theta = (1, 2, 1)^\top\), then corrupted by (8) with \(H = 1\) and \(R = 0.1\). The initial condition and \(R\) are treated as known. The prior is independent, \(\theta_1 \sim \mathrm{Gamma}(2, 2)\), \(\theta_2 \sim \mathrm{Gamma}(5, 3)\), \(\theta_3 \sim \mathrm{Gamma}(2, 5)\).

Comparators are the augmented ensemble Kalman filter (Algorithm 4) and the particle ensemble Kalman filter (Algorithm 5), not SMC2. The gold standard is a long MCMC run (\(10^6\) iterations) on the exact likelihood (1). NEnKF uses \(M = 1000\), initial \(N = 10\), \(\gamma = 0.4\), and delayed acceptance with \(k = 3\). The delayed-acceptance version is about 10% faster than plain NEnKF, and the reported results use delayed acceptance. One hundred replicate runs are summarised in Table 1. At matched CPU time (about 43 to 50 seconds), NEnKF (\(N = 100\) at termination) has smaller bias and RMSE than the particle ensemble Kalman filter for the reported posterior summaries of \(\log \theta_i\), and the augmented filter overestimates those summaries, especially for \(\log \theta_3\).

### 5.2 Lotka–Volterra (pp. 13–16)

The latent process is the bivariate prey–predator diffusion (25), simulated by Euler–Maruyama (26). Twenty prey observations are kept, at spacing 2, on \([0, 40]\), with \(\Delta t = 0.2\) inside the filter and \(\Delta t = 10^{-3}\) for the synthetic path. Predators are not observed. The observation model (27) is Gaussian with mean \(Hx_t\) and variance \(Hx_t\), \(H = (1, 0)\), which is nonlinear. Truth is \(X_0 = (50, 50)^\top\) and \(\theta = (0.5, 0.0025, 0.3)^\top\). The prior is independent, \(\theta_1 \sim \mathrm{Gamma}(2, 4)\), \(\theta_2 \sim \mathrm{Gamma}(20, 10^4)\), \(\theta_3 \sim \mathrm{Gamma}(2, 4)\).

Three schemes, all with delayed acceptance and \(k = 3\), \(M = 1000\), initial \(N = 20\):

- NEnKF, target \(\hat{\pi}_{\mathrm{enkf},t}\), with \(\tilde{R} = H\hat{\mu}_{t\mid t-1}\).
- RB-SMC2, target \(\tilde{\pi}_{\mathrm{enkf},t}\), with the same \(\tilde{R}\) scaled by 2.
- Vanilla SMC2, target \(\pi_t\), with a bootstrap proposal.

The gold standard is particle MCMC, \(10^6\) iterations with 100 state particles, targeting the exact posterior. Fifty replicate runs. Table 2 gives terminal ensemble sizes 20, 40 and 88, and CPU times 129, 287 and 561 seconds. The text says NEnKF is about four times as fast as vanilla SMC2 and about twice as fast as RB-SMC2. It also says that NEnKF shifts the posterior means of \(\theta_2\) and \(\theta_3\) downward relative to the gold standard, because the observation variance is replaced by a function of the forecast mean, and that RB-SMC2 reduces that discrepancy at greater cost. Delayed acceptance reduced CPU time by about 30% relative to a standard Metropolis–Hastings kernel.

### 5.3 Two-node epidemic (pp. 16–17)

Real oak processionary moth removals in Bushy Park and Richmond Park, yearly from 2013 to 2024 (Figure 5). The latent state is
\[
X_t = (S_{1,t}, I_{1,t}, S_{2,t}, I_{2,t}, \log \beta_{1,t}, \log \beta_{2,t})^\top,
\]
with \(\theta = (\gamma, \alpha_{1,2}, \alpha_{2,1}, \sigma_\beta)^\top\) and a further observation-noise parameter \(\sigma\) appended, so five static components. Infestation rates are Brownian motions on the log scale. Removals are observed through (28), a Gaussian approximation with state-dependent variance. \(H\) picks out \(S_j + I_j\) at each node. The prior is \(\mathrm{Gamma}(2, 2)\) on every component except \(\sigma_\beta \sim \mathrm{Gamma}(2, 10)\). The initial state is fixed at \((4631, 240, 37413, 1400, -10, -10.5)^\top\). Euler–Maruyama uses \(\Delta t = 0.1\).

NEnKF and RB-SMC2 only, one run each, delayed acceptance with \(k = 3\), initial \(N = 20\). The body text (p. 17) says \(M = 20{,}000\). The caption of Figure 4 (p. 18) says \(M = 5 \times 10^4\). These two statements conflict. Later reproduction should follow the body text and record the caption as a discrepancy, unless the code repository resolves it. NEnKF finished with \(N = 85\) and RB-SMC2 with \(N = 300\), a CPU ratio of about 1 to 2.7. Delayed acceptance saved about 15% (NEnKF) and 25% (RB-SMC2). Vanilla SMC2 was not run; a variance calculation at the RB-SMC2 posterior mean suggested it would need about \(5{,}000\) state particles. There is no gold-standard MCMC for this example. Figure 4 is described as showing agreement between the two parameter posteriors, and Figure 5 as showing removal predictions consistent with the data and infestation rates that are plausibly constant.

### 5.4 Lorenz-96 (pp. 17–19)

The latent process is the stochastic Lorenz-96 system (29) in dimension \(d\), with drift component \(\theta_1(X_{i+1} - X_{i-2})X_{i-1} - \theta_2 X_i + \theta_3\) and diffusion matrix \(\theta_4^2 I\). Two synthetic series, \(D_1\) (\(d = 5\)) and \(D_2\) (\(d = 10\)), use \(x_0 = 0\) and \(\theta = (1, 1, 8, \sqrt{10})^\top\), Euler–Maruyama on \([0, 30]\) with \(\Delta t = 5 \times 10^{-3}\), thinned by 40, then observed in full with additive \(\mathcal{N}(0, 5^2 I)\) noise. That is 30 observation times at spacing 0.2. The observation model is linear and Gaussian, so the Rao-Blackwellised correction is not used. The prior is independent, \(\theta_1, \theta_2 \sim \mathrm{Gamma}(4, 4)\), \(\theta_3 \sim \mathrm{Gamma}(6, 2)\), \(\theta_4 \sim \mathrm{Gamma}(16, 2)\).

NEnKF and vanilla SMC2, both with delayed acceptance, \(k = 3\), and five move iterations per particle. For \(D_1\), \(M = 1000\), initial \(N = 20\), 50 replicates, gold standard particle MCMC with \(10^6\) iterations and 300 state particles (Table 3). Terminal sizes are \(N = 128\) (NEnKF, 14 minutes) and \(N = 450\) (SMC2, 56 minutes), described as a factor of about 3.5 in efficiency. For \(D_2\), a single run with \(M = 5{,}000\) and initial \(N = 50\): SMC2 used 4762 state particles and 2737 minutes, NEnKF used 249 ensemble members and 147 minutes, described as a factor of about 19. Particle MCMC replicates were not run for \(D_2\). Table 3 reports bias and RMSE for \(\log \theta_1, \log \theta_2, \log \theta_3\) only; \(\theta_4\) is not in that table.

## Claims about accuracy and cost, in the paper's words

Section 6 (p. 19) states that, across four applications of increasing observation dimension, the NEnKF is able to provide accurate and computationally efficient inferences for the static parameters. The same section says the algorithm is expected to be of greatest use when the number of observed dynamic components is large relative to the number of parameters, and gives the illustration \(d_\theta < 10\) and \(d_y > 10\). The plug-and-play claim is that only forward simulation of the state and evaluation of the observation density are required (p. 19). The cost ordering among NEnKF, RB-SMC2 and SMC2 is the one quoted in the Rao-Blackwellised section above. The numerical factors in Section 5 are those already listed: about 10%, 30%, 15% and 25% from delayed acceptance in the four places it is compared, and the CPU ratios in Tables 1 to 3 and in the \(D_2\) run.

## Reference code

Section 5 (p. 12) gives the repository `https://github.com/AndyGolightly/NestedEnKF`. This repository does not contain that code: there is no `R/` implementation and no copy of the upstream sources. The plan says to read that code in phase 6, as an aid to the paper, and not to treat it as a substitute.

## Open problems

The future-work paragraph is Section 6, printed page 20. Four sentences carry the extensions. They are paraphrased closely here, with the page.

1. In the applications, the number of distinct resampled particles \(M_r\) used to build the nearest-neighbour surrogate was typically small, no more than a few thousand, which justified an \(O(M_r)\) list lookup for the neighbours of each proposal. A variation of the KD-tree (Sherlock, Golightly and Henderson, 2017) needs \(O(d_\theta \log M_r)\) operations and is cheaper when \(d_\theta\) is moderate (p. 20). This is E1.
2. Efficiency might also be improved by choosing, when a resample-move step is triggered, among delayed-acceptance kernels with different \(k\) and a standard Metropolis–Hastings kernel. Early in the run the likelihood estimator is likely to be relatively cheap, which motivates the standard kernel. The paper points to IBIS (Fearnhead and Taylor, 2013) and to SMC2 (Botha et al., 2023a) for similar choices (p. 20). This is E2.
3. The resample-move step might be improved further by gradient-based proposals inside the Metropolis–Hastings step (Rosato et al., 2024) (p. 20). This is E3, in the form the paper states. The linear-noise gradient from Lowe, Golightly and Sherlock (2023) is not mentioned in Section 6.
4. Using the surrogate in both the weighting step and the resample-move step, for a fixed value of \(N\), could give a fixed-cost alternative to the NEnKF, at the expense of inferential accuracy (p. 20). This is E4.

E5 is not a future-work sentence. It is the regime claim in the same section, printed page 19: greatest utility where the number of observed components is large relative to the number of parameters, with the illustration \(d_\theta < 10\) and \(d_y > 10\). The scoping note's "fewer than about ten parameters and more than about ten observed components" points at this sentence. It is an illustration attached to a conclusion, not a theorem and not a request for a new algorithm.

### In the paper but not in the scoping note

Section 6's future-work sentences map onto E1 to E4, and the regime sentence is E5. No further extension is proposed in that section.

Section 4.1 (p. 9) says that the number of ensemble MCMC iterations inside the move could be adapted, that the paper does not pursue this, and that Botha et al. (2023b) discuss it for SMC2. That remark is not in Section 6 and not in the scoping note's list. It is not given a label here. Phase 4 may pick it up only as a tuning choice inside E2, not as a new extension.

### Scoping note only

- The linear-noise score, as a candidate gradient inside E3, is not in Section 6. The only gradient citation there is Rosato et al. (2024). Do not build the linear-noise proposal until task 4.2, and then only for models that have a linear noise approximation. Lorenz-96, as used in Section 5.4, is not presented as such a model.
- E6, a rule for when the Rao-Blackwellised correction is worth its cost, is not a future-work item in Section 6. The paper does compare the two targets empirically in Sections 5.2 and 5.3 and states the expected accuracy–cost ordering on p. 19. A decision rule is scoping-note only until task 4.2.

## Notation

Symbols below are the ones later notes should use. The paper prints distinct accents on the ensemble Kalman quantities. A hat in this note means the accent on the linear-Gaussian ensemble Kalman likelihood in (13) and on the plain target in Section 4.1. A tilde means the accent on the nonlinear-observation likelihood in the denominator of (21) and on the Rao-Blackwellised parameter target in Section 4.3. The PDF text layer does not name those accents; the assignment was checked against the displays on pp. 6 and 11.

| Symbol | Meaning | Later R name |
| --- | --- | --- |
| \(t = 0, \ldots, T\) | time index, observations included at 0 | `t`. R loops use index `t + 1` |
| \(X_t\), \(d_x\) | latent state and its dimension | `x`, `dx` |
| \(Y_t\), \(d_y\) | observation and its dimension | `y`, `dy` |
| \(\theta\), \(d_\theta\) | static parameter and its dimension | `theta`, `d_theta` |
| \(i = 1, \ldots, M\) | parameter-particle index | `i`, `M` |
| \(j = 1, \ldots, N\) | ensemble-member index | `j`, `N` |
| \(N\) | ensemble size (number of ensemble members) | `N` |
| \(M\) | number of parameter particles | `M` |
| \(k\) | neighbour count in the surrogate | `k` |
| \(M_r\) | number of distinct resampled parameter particles | `M_r` |
| \(\hat{p}_{\mathrm{enkf},t}^{(\theta)}\) | ensemble Kalman likelihood contribution (13), and the product of contributions up to \(t\) | `penkf_t`, `penkf` |
| \(\hat{p}_{\mathrm{knn},t}^{(\theta)}\) | inverse-distance nearest-neighbour approximation of the log ensemble Kalman likelihood (Section 4.2) | `pknn` |
| \(\hat{\pi}_{\mathrm{enkf},t}(\theta \mid y_{0:t})\) | plain target: \(\theta\)-marginal of the extended target in Section 4.1, that is the posterior under the ensemble Kalman likelihood | `pi_enkf` |
| \(\tilde{\pi}_{\mathrm{enkf},t}(\theta \mid y_{0:t})\) | Rao-Blackwellised target: posterior under the likelihood estimated by Algorithm 7, denominator of (21) | `pi_rb` |
| \(\rho_{\mathrm{enkf}}\) | ensemble MCMC ratio (18) | `rho_enkf` |
| \(\rho_1\), \(\rho_{2\mid 1}\) | stage-one and stage-two delayed-acceptance ratios (19) and (20). Their product equals \(\rho_{\mathrm{enkf}}\) | `rho_1`, `rho_2_given_1` |
| \(\gamma\) | effective-sample-size fraction; move if ESS \(< \gamma M\) | `gamma_ess` |
| \(q(\theta, \cdot)\) | parameter proposal kernel. In Section 4.1, a random walk with covariance \(\zeta V_t\) | `q` |

The phrase "fixed ensemble size" in E4. Section 6 (p. 20) says: use the surrogate in both the weighting and the resample-move steps "(for a fixed value of \(N\))" to obtain "a fixed cost alternative". In this paper \(N\) is the ensemble size, introduced in Section 3.1 and used as the length of \(x_t^{1:N}\) in Algorithms 3 and 6. The number of parameter particles is \(M\). Section 4.1 separately allows \(N\) to grow when \(\hat{\sigma}_N^2 > 1.5\). The reading frozen here is therefore: E4 holds the ensemble size \(N\) fixed, in particular it does not use that growth rule, and it replaces the ensemble Kalman likelihood by the nearest-neighbour surrogate in the incremental weight as well as in the screen. "Fixed cost" is the paper's description of that alternative. It does not mean a fixed number of parameter particles.

One further clash of notation, already noted above: the epidemic run is \(M = 20{,}000\) in the body of Section 5.3 and \(M = 5 \times 10^4\) in the caption of Figure 4. The body text is the value later notes should use. The caption is recorded and not followed.

The symbol \(\hat{K}_t\) is the estimated Kalman gain (12). It is not a Markov kernel. The move kernel is the ensemble MCMC kernel \(K_{\mathrm{enkf},t}\). One sentence in Section 4 (p. 8) writes \(\tilde{K}_t\) for that kernel; the acceptance display (18) and Algorithm 6 identify it as the ensemble MCMC kernel. Later notes use \(K_{\mathrm{enkf},t}\).
