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
