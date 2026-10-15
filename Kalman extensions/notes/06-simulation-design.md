# Simulation design

Written before any extension code was run. The studies below are the ones phase 5 left in scope. Numbers in the findings note come from the pilot defined here. They are not the 2026 table.

## What is not claimed as a reproduction

Golightly et al. (2026), Section 5.1, ran the Ornstein–Uhlenbeck example with \(M = 1000\), 50 integer-time observations, initial ensemble size 10, \(\gamma = 0.4\), delayed acceptance with \(k = 3\), a dynamic ensemble size, and 100 replicate data sets. The gold standard there is a Metropolis–Hastings run of \(10^6\) iterations on the exact likelihood. Lorenz-96 was the high-dimensional example.

This session runs the pilot below. The full settings are recorded so a later run can use them. The manuscript must not present pilot numbers as those 2026 figures.

Omissions filled before any run, because the PDF does not settle them:

- Gamma\((a, b)\) is shape and rate.
- The neighbour metric is Euclidean distance on \(\log \theta\), after each coordinate has been divided by the standard deviation of that coordinate in the stored cloud. A coordinate with standard deviation 0 is left unscaled.
- Resampling is with replacement, one draw per particle, with probabilities equal to the normalised weights. That is the draw named in Algorithm 6.
- The random-walk covariance is the sample covariance, divisor \(n-1\), of the resampled particles other than the particle being moved. If that matrix is not positive definite, \(10^{-4}\) is added to each diagonal entry before multiplying by \(\zeta\). This is a numerical safeguard. It is not part of the 2026 algorithm.
- \(\zeta^2 = 2.56^2 / d_\theta\), the rule of thumb named in Section 4.1.
- Dynamic ensemble size is off. \(N\) is held fixed, which is the reading of "fixed ensemble size" in the context note.
- One Metropolis–Hastings or delayed-acceptance proposal per particle at each rejuvenation.

## Pilot

Shared by every study unless a row says otherwise.

- Scalar Ornstein–Uhlenbeck transition as in Section 5.1: mean \(x e^{-\theta_1 \Delta t} + \theta_2(1-e^{-\theta_1 \Delta t})\), variance \(\theta_3^2(1-e^{-2\theta_1 \Delta t})/(2\theta_1)\), with \(\Delta t = 1\).
- Truth \(\theta = (1, 2, 1)\), \(x_0 = 10\), \(H = 1\), \(R = 0.1\).
- \(T = 16\) observations, at times \(1, \ldots, 16\). No observation at time 0.
- Prior \(\theta_1 \sim \mathrm{Gamma}(2, 2)\), \(\theta_2 \sim \mathrm{Gamma}(5, 3)\), \(\theta_3 \sim \mathrm{Gamma}(2, 5)\), independent, shape-rate.
- \(M = 60\), \(N = 12\), \(\gamma = 0.4\), \(k = 3\).
- Four replicate data sets. The study script sets the seed. The seed is not part of the algorithm. Master seed 20261015. Replicate \(r \in \{1,2,3,4\}\) uses seed \(20261015 + r\) for the data. The gold-standard chain uses seed \(20261015 + r + 500\). Each filter uses seed \(20261015 + r + 1000 \times s\), where \(s\) is the study method index in the script. The offsets keep the data seed fixed if the length of another chain changes.
- Initial parameter particles: independent draws from the prior. The initial condition is known, so the time-0 ensemble is \(N\) copies of \(x_0\). The first forecast is the transition into the first observation. Time 0 has no likelihood contribution.

Gold standard, per replicate: random-walk Metropolis–Hastings on \(\log \theta\), targeting the exact Kalman likelihood times the prior. Proposal standard deviation 0.15 on each log-coordinate, independent. 3000 iterations after 1000 burn-in. One chain. The posterior mean of \(\log \theta_i\) from the post-burn-in sample is the reference. This chain is much shorter than \(10^6\). Its Monte Carlo error is a limit on every comparison with it.

Metrics, fixed here:

- Absolute error of the weighted posterior mean of \(\log \theta_i\), against the gold-standard mean. The weighted mean uses the terminal normalised weights.
- Effective sample size of the terminal weights, \(1/\sum_i (u^i)^2\).
- Number of transition draws (model integrations).
- Stage-one and stage-two acceptance counts, and the number of proposals.
- Cost per accepted move: transition draws used inside rejuvenation, divided by the number of accepted proposals. If no proposal is accepted, the study records the draws and writes the ratio as missing.
- Wall-clock time is not a primary metric.

## Studies

| Study | Extension | What is run | Failure |
| --- | --- | --- | --- |
| S1 | E1 | On each delayed-acceptance rejuvenation of S2's always-delayed run, compute the \(k\) neighbours by a linear scan and by an exact KD-tree. Record whether the neighbour index sets agree, and how many stored points each search evaluates a distance to. | Neighbour sets disagree, or the tree evaluates a distance to fewer points than the list and the findings still recommend the tree without that count. A tree that is not cheaper is the expected outcome at this \(d_\theta\) and is not a failed implementation. |
| S2 | E2 | Three filters on each replicate: plain Metropolis–Hastings at every rejuvenation; delayed acceptance with \(k = 3\) at every rejuvenation; the pre-registered switch, plain Metropolis–Hastings when \(t \le 8\) and delayed acceptance when \(t > 8\). | On the mean, over replicates, of cost per accepted move, the switch is worse than the better of the two fixed kernels. |
| S3 | E3 | Plain Metropolis–Hastings against the finite-difference proposal in the theory note, Section 5.5. Central difference, fraction \(h = 0.05\) of the current coordinate, reduced so that both perturbed parameters stay positive. Drift scale \(\lambda = 0.2\). The prior gradient is not in the drift. The Gaussian proposal density is in the acceptance ratio. | The finite-difference move does not increase terminal effective sample size per transition draw, relative to the random walk, on the mean over replicates. |
| S4 | E4 | Surrogate incremental weights. The first \(k\) particles in the current order are reference particles and are always evaluated with the ensemble Kalman filter. Every other particle takes the inverse-distance prediction of the reference particles' incremental log-likelihoods. The move, when triggered, screens with the surrogate built from the reference cloud's cumulative log-likelihoods, and stage two still evaluates the ensemble Kalman likelihood. At the terminal time, recompute the ensemble Kalman incremental log-likelihood for 8 non-reference particles and record the median absolute log difference. | The median absolute log difference exceeds 1, the threshold fixed here, on the mean over replicates. That threshold means the surrogate increment differs from the ensemble Kalman increment by more than a factor of \(e\). A cost that does not fall relative to S2's plain filter is a second failure. |
| S5 | E5 | Separate from the particle filter. At the true \(\theta\), 20 independent ensemble Kalman log-likelihoods, \(N \in \{8, 16\}\), for a scalar series and for five independent Ornstein–Uhlenbeck coordinates with the same \(\theta\) and independent \(\mathcal{N}(x_i, 0.1)\) observations. Report the sample variance of the log-likelihood and the number of transition draws per likelihood. One data set per observation dimension, seeds \(20261015 + 100 + d_y\). | Used only as a measurement. No failure threshold. The account is not confirmed or denied beyond the two observation dimensions and the two ensemble sizes. |
| S6 | E6 | Two filters. Identity cell: \(f = g = \mathcal{N}(y; x, 0.1)\). Record the maximum absolute difference between the log ensemble Kalman increment and the log Rao-Blackwellised increment, over particles and times. Discrepancy cell: \(g = \mathcal{N}(y; x, 0.5)\) while the data and the gold standard use \(R = 0.1\). Compare absolute error of posterior means for the plain filter, which uses \(g\), and the Rao-Blackwellised filter. | The identity cell fails if the maximum absolute log difference exceeds \(10^{-6}\). The discrepancy cell has no pass mark. It is an illustration. The linear Gaussian identity already says the correction is not worth its cost when \(f = g\). |

Comparators that are not run: vanilla SMC2, ensemble MCMC as a long batch chain, Temfack and Wyse's state-dependent observation variance, and Lorenz-96. They are omitted because the pilot is a linear Gaussian Ornstein–Uhlenbeck study. The gold standard is the exact Kalman likelihood, which is available here and is not available for Lorenz-96 inside this pilot.

## Figures and tables the manuscript may use

- One table of posterior-mean absolute errors, transition draws, and terminal effective sample size, for the plain move, delayed acceptance, the switch, the finite-difference move, the surrogate weight, and the Rao-Blackwellised discrepancy cell. Means over the four replicates.
- One table of neighbour agreement and distance counts (S1).
- One table of log-likelihood variances (S5).
- The identity difference (S6) as a single reported maximum.

No plot is required for the pilot. If a figure is drawn, it is the absolute error against transition draws for the methods in the first table.

## Amendment, 15 October 2026. Study S7, three targets on Lotka–Volterra

Written before the posterior run. S1 to S6 are unchanged and are not rerun. S7 is the comparison required by the scope amendment of the same date in `research-plan.md`. A short execution of the functions, used to see that a call returned and to scale the cost, is not a result and is not stored.

### What is compared

On one synthetic series from Section 5.2 of Golightly et al. (2026):

- plain nested filter, weight (13), target \(\hat{\pi}_{\mathrm{enkf}}\), with \(\tilde{R} = H \hat{\mu}_{t \mid t-1}\);
- Rao-Blackwellised filter, weight (24), target \(\tilde{\pi}_{\mathrm{enkf}}\), with the same \(\tilde{R}\) multiplied by 2, and with \(f\) the observation density (27);
- vanilla SMC2, target \(\pi_t\), bootstrap proposal, as Section 5.2 describes it: the propagate step is the Euler–Maruyama transition (26) and the state weight equals (27).

The move, when the effective sample size falls below \(\gamma M\), is one symmetric random-walk Metropolis–Hastings proposal. Delayed acceptance is not used. Dynamic ensemble size is off. Neither omission changes the nominal target of a Metropolis–Hastings kernel that evaluates the likelihood the weight uses. Both differ from Section 5.2, which used delayed acceptance with \(k = 3\) and the ensemble-size rule of Section 5.1.

### Settings that match Section 5.2

- Drift and diffusion matrix (25), Euler–Maruyama (26), observation (27) with \(H = (1, 0)\). Prey is observed. Predators are latent.
- Truth \(X_0 = (50, 50)^\top\), \(\theta = (0.5, 0.0025, 0.3)^\top\).
- Prior \(\theta_1 \sim \mathrm{Gamma}(2, 4)\), \(\theta_2 \sim \mathrm{Gamma}(20, 10^4)\), \(\theta_3 \sim \mathrm{Gamma}(2, 4)\), independent.
- Synthetic path step \(10^{-3}\), thinned by 2000, so the observation spacing is 2. Filter step \(\Delta t = 0.2\), hence 10 Euler steps between observations.
- \(\gamma = 0.4\).
- \(\zeta^2 = 2.56^2 / d_\theta\), the rule of thumb named in Section 4.1.
- The Rao-Blackwellised observation variance is twice the plain-filter choice.

### Omissions filled before the run

The PDF does not settle these. The values below are choices, not readings of a printed number.

- \(\mathrm{Gamma}(a, b)\) is shape and rate, the same choice as the Ornstein–Uhlenbeck pilot.
- The initial condition \(X_0\) is treated as known and is not an observation. The PDF sets \(X_0\) for the synthetic path and says that thinning gives 20 observations. It does not list the time grid. Twenty observations at spacing 2, excluding time 0, are the times \(2, 4, \ldots, 40\). S7 uses that grid, on \([0, 40]\).
- The PDF does not say whether the 50 replicate runs redraw the latent path. S7 uses one path and several runs of each algorithm.
- The PDF does not say what happens when an Euler–Maruyama coordinate is not positive. The diffusion matrix (25) is then not a covariance in the form used for a positive population. After every Euler draw, and after every ensemble Kalman analysis update, a coordinate below \(10^{-6}\) is replaced by \(10^{-6}\). Each such Euler draw is counted. If, in a replicate, the number of floored draws exceeds 1% of the Euler draws, that method's replicate is not interpreted as a pure use of (26).
- The random-walk covariance adds \(10^{-12}\) to each diagonal entry when an eigenvalue is at most \(10^{-10}\). The Cholesky factor used to draw the proposal starts its extra diagonal term at \(10^{-12}\). The Ornstein–Uhlenbeck pilot's \(10^{-4}\) would dominate the \(\theta_2\) margin. This jitter is a numerical safeguard, not part of Section 4.1.
- Resampling inside Algorithm 1 is the printed per-particle draw. The outer resample is with replacement, one draw per parameter particle.

### Settings that differ from Section 5.2

| Item | Section 5.2 | S7 |
| --- | --- | --- |
| Parameter particles \(M\) | 1000 | 60 |
| Ensemble or state particles | initial \(N = 20\), then the Section 5.1 growth rule; Table 2 terminates at 20, 40 and 88 | fixed \(N = 12\) for the plain filter and the Rao-Blackwellised filter; fixed \(N_x = 24\) state particles for SMC2 |
| Replicates | 50 | 4 algorithm replicates on one series |
| Delayed acceptance, \(k = 3\) | used for all three schemes | not used |
| Dynamic \(N\) | on | off |
| Gold standard | particle MCMC, \(10^6\) iterations, 100 state particles | not run |

SMC2 is the reference for \(\pi_t\) inside this study. It is not a substitute of the same quality as the particle MCMC gold standard. Its Monte Carlo error, and the bias from a fixed \(N_x = 24\), remain in every comparison with it.

### Seeds

The seed is not part of the algorithm. Master seed 20261015. The series uses seed \(20261015 + 7100\). Method index \(s = 1, 2, 3\) for the plain filter, the Rao-Blackwellised filter and SMC2. Replicate \(r \in \{1, 2, 3, 4\}\) uses seed \(20261015 + 8100 + 100 s + r\).

### Rule for the shift, fixed before the run

Let \(m(a, j)\) be the average, over the four replicates, of the terminal weighted mean of \(\log \theta_j\) under algorithm \(a\). The weighted mean uses the terminal normalised parameter weights. Let \(s(a, j)\) be the sample standard deviation of those four replicate means, with divisor \(n - 1\). The standard error of \(m(\mathrm{nenkf}, j) - m(\mathrm{smc2}, j)\) is
\[
\sqrt{\bigl(s(\mathrm{nenkf}, j)^2 + s(\mathrm{smc2}, j)^2\bigr) / 4}.
\]
Table 2 of Golightly et al. (2026) reports estimators of \(\mathrm{E}(\log \theta_i)\). The prose of Section 5.2 says that the plain filter shifts the posterior means of \(\theta_2\) and \(\theta_3\) downward. S7 follows the table and applies the rule to \(\log \theta_2\) and \(\log \theta_3\).

- The downward shift is resolved on coordinate \(j\) if \(m(\mathrm{nenkf}, j) - m(\mathrm{smc2}, j)\) is negative and its absolute value exceeds the standard error above.
- The shift is reported as appearing if it is resolved on both \(j = 2\) and \(j = 3\).
- It is reported as failing to appear if the plain-filter mean is greater than or equal to the SMC2 mean on both of those coordinates.
- Otherwise it is unresolved.
- The Rao-Blackwellised filter reduces the discrepancy on coordinate \(j\) if \(|m(\mathrm{rb}, j) - m(\mathrm{smc2}, j)| < |m(\mathrm{nenkf}, j) - m(\mathrm{smc2}, j)|\). Whether this holds on both \(j = 2\) and \(j = 3\) is reported as a description of these runs. It is not a confirmation of the ordering in Section 5.2, because the settings differ and there is no particle MCMC gold standard.
- Coordinate \(j = 1\) is reported with the same arithmetic and without a pass mark.

Also recorded, for each replicate: terminal effective sample size, number of Euler draws, number of floored Euler draws, number of proposals, number of acceptances. Wall-clock time is not a primary metric.

### Output files

`results/s7-lv-data.csv`, `results/s7-lv-replicates.csv`, `results/s7-lv-summary.csv`, `results/s7-lv-shift.csv`, `results/s7-lv-verdict.csv`, `results/s7-lv-session.csv`. The verdict file applies only the rule in this amendment.
