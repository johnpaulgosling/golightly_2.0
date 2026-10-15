# Theory notes

Answers to `notes/04-theory-agenda.md`. Part A is attempted. Part B stays parked. No new theorem is stated. Equation numbers are those printed in the PDFs that were opened.

## 5.1 Restatement of the 2025 filter

Source: `Source papers/4992336VoR.pdf`, Algorithm 2 (pp. 10–11), Section 3.4 (pp. 11–12), and Algorithm 1 (p. 6) for the transition that the weight uses. The synthetic SIR mechanism is Section 4.1. Notation is the table in `notes/01-paper-context.md`, including the choice of equation (2) for the contact-rate step.

Algorithm 2 is printed for the negative binomial observation (6). Section 4.1 uses the binomial observation (5). The paper does not print a second algorithm box. The restatement below keeps the printed steps. Where a line is specific to (6), that is said. The diagnostic that phase 6 runs is a restriction of steps 1c and 2, written after the restatement, and it uses (5) because that is the Section 4.1 model.

### Algorithm 2, as printed

Input: data \(y = (y_{t_1}, \ldots, y_{t_L})'\), particle count \(N\), initial draws \(\psi^{(1:N)} \sim \pi(\psi)\), \(x_{t_0}^{(1:N)} \sim \pi(x_{t_0})\), \(\tilde{\beta}_{t_0}^{(1:N)} \sim \pi(\tilde{\beta}_{t_0})\), and sufficient statistics \(T_0^{(1:N)}\).

For \(i = 0, \ldots, L-1\) and \(k = 1, \ldots, N\):

1. Propagate.
   1. Draw \(\phi_{t_{i+1}}^{(k)} \sim \mathcal{N}(m_i, s^2 V_i)\) and set \(\phi^{(k)}\) to that draw. This is the Liu and West kernel on pp. 9–10, printed for the negative binomial parameter. This note has not opened Liu and West (2001). The binomial reporting rate is not updated by this kernel. Its conditional posterior is the beta update on p. 9, which is outside \(T_i\).
   2. Draw the contact-rate path \(\tilde{\beta}_{(i,i+1]}^{(k)}\) from its transition given \(\tilde{\beta}_{t_i}^{(k)}\) and \(\lambda^{(k)}\). The paper calls this a blind propagation (p. 10). The transition used here is equation (2).
   3. Draw the incidence path \(\Delta n_{(i,i+1]}^{(k)}\) from \(q(\cdot \mid \tilde{\beta}_{[i,i+1)}^{(k)}, \phi_{t_{i+1}}^{(k)}, \theta^{(k)}, y_{t_{i+1}})\).

2. Resample \(\psi^{(1:N)}\), \(\tilde{\beta}_{t_{i+1}}^{(1:N)}\) and \(\Delta n_{t_{i+1}}^{(1:N)}\) with weights
\[
w_{i+1}^{(k)} \propto
\frac{\pi\bigl(\Delta n_{(i,i+1]}^{(k)} \mid \tilde{\beta}_{[i,i+1)}^{(k)}, \theta^{(k)}\bigr)\,
\pi\bigl(y_{t_{i+1}} \mid \Delta n_{t_{i+1}}^{(k)}, \phi_{t_{i+1}}^{(k)}\bigr)}
{q\bigl(\Delta n_{(i,i+1]}^{(k)} \mid \tilde{\beta}_{[i,i+1)}^{(k)}, \phi_{t_{i+1}}^{(k)}, \theta^{(k)}, y_{t_{i+1}}\bigr)}.
\]
The numerator is the dS(E)IR transition and the observation mass function. For model (5) that mass function is the binomial PMF. For model (6) it is the negative binomial PMF. The denominator is \(q\). The factor \(\pi(\Delta n \mid \tilde{\beta}, \theta)\) does not contain \(h^{*}\).

3. Update \(T_{i+1}^{(k)}\) from \(T_i^{(k)}\), the incidence path and the contact-rate path. For the gamma conditionals, \(T_i\) is the shapes and rates in (9)–(11).

4. Draw \(\theta^{(k)}\) and \(\lambda^{(k)}\) from (9)–(11).

Output: a particle representation of \(\pi(\psi, \tilde{\beta}_{t_i}, \Delta n_{t_i} \mid y_{[1,i]})\), \(i = 1, \ldots, L\), as printed under Algorithm 2. This note does not add a convergence theorem.

### The proposal \(q\)

Section 3.4. At a subgrid time \(\tau_{i,j}\) inside \((t_{i-1}, t_i]\), with state and incidence so far treated as known, equation (12) approximates the remaining incidence by a Gaussian whose mean and variance are the current hazard times the remaining time \(t_i - \tau_{i,j}\). The observation is approximated by (13), with variance (14) for the binomial model and (15) for the negative binomial. The mean \(\mu\) inside that variance is replaced by \(\hat{\mu}\), which inserts the mean of (12). The joint approximation is (18).

The display after (18), as printed, is
\begin{align*}
h^{*}(x_{\tau_{i,j}} \mid y_{t_i})
&= h(x_{\tau_{i,j}})
+ \rho P' H(x_{\tau_{i,j}})
\bigl\{\rho^{2} P' H(x_{\tau_{i,j}}) P (t_i - \tau_{i,j})
+ \sigma^{2}\bigr\}^{-1}
\bigl\{y_{t_i} - \hat{\mu}\bigr\}.
\end{align*}
The paper suppresses the arguments of \(\sigma^{2}\) and \(\hat{\mu}\) in that display (p. 12).

Orientation. The printed correction multiplies by \(\rho P' H\), which is a row when the observation is scalar. The top-right block of (18) is \(\rho H P (t_i - \tau_{i,j})\), a column, and that is the block the conditional mean of the remaining incidence uses. For a diagonal \(H\) the row \(\rho P' H\) and the column \(\rho H P\) have the same entries. On the Section 4.1 SIR model, \(P' = (1, 0)\) and \(H = \mathrm{diag}(h_{\mathrm{inf}}, h_{\mathrm{rem}})\), so both orientations add the correction to the infection component only:
\[
h^{*}_{\mathrm{inf}}
= h_{\mathrm{inf}}
+ \rho h_{\mathrm{inf}}
\frac{y_{t_i} - \hat{\mu}}{\rho^{2} h_{\mathrm{inf}}(t_i - \tau_{i,j}) + \sigma^{2}},
\qquad
h^{*}_{\mathrm{rem}} = h_{\mathrm{rem}},
\]
with \(\hat{\mu} = \rho\bigl(n^{\mathrm{past}}_{\mathrm{inf}} + h_{\mathrm{inf}}(t_i - \tau_{i,j})\bigr)\) and, for the binomial variance (14) evaluated at \(\hat{\mu}\), \(\sigma^{2} = (1-\rho)\hat{\mu}\). The code uses this scalar form. It matches the entries of the printed display, and it matches Golightly and Wilkinson (2015), equation (9), in the case \(S = I\), where the correction is the column \(H P\). This is a choice of orientation where the printed row and the column in (18) agree. It is not a new guide.

Trajectories on \((t_{i-1}, t_i]\) are Algorithm 1 with \(h\) replaced by \(h^{*}\) and with step \(\Delta\tau\). The density \(q\) is the product, over components and over \(j = 0, \ldots, m-1\), of Poisson probabilities with rates \(h^{*}(x_{\tau_{i,j}} \mid y_{t_i})\,\Delta\tau\) (p. 12).

### What study S1 computes

S1 does not run steps 1a, 1b, 3 or 4. The agenda fixes the contact-rate path at the simulated path, so the diagnostic is about \(h^{*}\) rather than about the blind draw. The same reason fixes the prevalence at the start of the window at the simulated prevalence, and it fixes \(\gamma\) and \(\rho\) at the Section 4.1 simulation values. That is more information than a particle carries. The findings have to say so.

For one window, one guide and \(N_{\mathrm{prop}}\) draws, with the contact-rate path supplied:

1. At each substep, compute \(h\) from the current state and the supplied \(\tilde{\beta}\), then \(h^{*}\) from the scalar form above. The myopic comparator, if the design note includes it, replaces \(h^{*}\) by \(h\) and leaves every other line unchanged.
2. Draw the two SIR incidence increments from Poisson distributions with those rates times \(\Delta\tau\). This is Algorithm 1, step 2, with the hazard the guide is using. Update \(S\) and \(I\) by those increments. Do not update \(\tilde{\beta}\) inside the window.
3. The unnormalised weight of a completed draw is the Algorithm 2 ratio for that window: the product of unconditioned Poisson probabilities, times the binomial PMF of \(y\) given the proposed infection count, divided by \(q\).

A draw is invalid, and its weight is zero, when the correction is undefined, when a component of the hazard passed to the Poisson draw is negative, or when the updated \(S\) or \(I\) would be negative. Whitaker et al. (2025) do not print a truncation. Golightly and Sherlock (2019), Section 3.2, truncate equation (5) to keep it positive. That truncation is not copied onto the 2025 display. A zero weight is the diagnostic's record that \(q\) was not a Poisson density for that draw. The design note states this before any run.

The effective sample size of one window is the formula in Golightly and Sherlock (2019), Section 5.2,
\[
\mathrm{ESS}(\tilde w_{1:N_{\mathrm{prop}}})
= \frac{\bigl(\sum_{i} \tilde w_i\bigr)^2}{\sum_{i} \tilde w_i^2},
\]
applied to these unnormalised weights, including the zeros. If every weight in the window is zero, the formula is undefined and the recorded value is 0, as a table convention, not as a value of the formula.

## 5.2 Part A

### Reading

Equation (12) freezes the hazard at \(\tau_{i,j}\) over the whole remaining time to the next observation. The mean is that frozen hazard times the remaining time. Golightly and Wilkinson (2015), Section 3.1, equation (9), use the same step for remaining reaction counts: a Gaussian with mean and variance equal to the current hazard times \(\Delta s\). Golightly and Sherlock (2019), Section 3.2, restate that hazard as equation (5) and say that normality of the remaining reaction counts, and a hazard constant on an interval of length \(\Delta t\), are often unreasonable. Section 6 of the same paper says that treating the time until the next observation as one discretisation makes the bridges less accurate as the inter-observation time increases.

Whitaker et al. (2025), p. 25, call linearity of the latent process, over an interval no longer than the observation interval, a further assumption in the derivation of the conditioned hazard. Section 3.4 does not use the word linear, and it does not print a second condition beyond (12) and the display after (18). This note does not separate equation (12) from that sentence. The constant-hazard Gaussian step is the assumption the limitations paragraph is pointing at.

The same paragraph says the conditioned hazard is likely to result in trajectories inconsistent with the true conditioned process, when cumulative incidence does not evolve linearly. The law named on the page is the true conditioned process. The sentence is about the trajectories the hazard proposes. It does not say that the dS(E)IR transition in the numerator is the wrong model, and it does not say that the Algorithm 2 weight then targets a different distribution.

The numerator of the weight in step 2 does not depend on \(h^{*}\). A poor \(h^{*}\) changes \(q\) and therefore the weights. On the printed ratio, the importance target of one propagate step stays the dS(E)IR transition times the observation mass function. That is a reading of the printed weight. It is not a proof that the particle filter converges.

### What inconsistent means here

Inconsistent, in the sense fixed by the agenda, is a property of the proposal \(q\): the constant-hazard guide is the proposal the limitations paragraph expects to disagree with the process conditioned on the next observation, once the observation spacing is long enough that cumulative incidence is not linear. No numerical spacing is stated in any paper opened for this programme. Golightly and Sherlock (2019), Section 5.1, report that the linear form fails to describe exponential decay, and that effective sample size falls as \(T\) grows, for a death process. Those numbers are not dSEIR results and are not copied here.

The observable is the effective sample size defined in Section 5.1 of this note. The prediction, fixed before the run, is the one in the agenda: the median of that effective sample size across replicate data sets is smaller at the coarsest pre-registered spacing than at the published unit spacing. The design note defines the median. A myopic comparator is not a second target.

Will appear in the paper as this diagnostic, not as a threshold and not as a theorem. A simulation must report that comparison. If the median does not fall, the claim is qualified in the findings note. The claim does not say that the filtering distribution changes.

## 5.3 Part B

Amendment, 15 October 2026. The scope decision that parked part B used the three guides then stored. The files added after that decision are summarised in `notes/02-literature-summary.md`. This section states one replacement. It does not claim that any one of those papers already prints the replacement inside Algorithm 2.

### What is still not a density for \(q\)

Golightly and Sherlock (2019), equation (19), samples a Markov jump process, and the weight (3) is the jump-process likelihood ratio under a Gaussian observation of the state. Corstanje et al. (2023), Theorem 4.2, and Corstanje (2024), Corollary 4.3.6 and Theorem 4.4.2, give path-space likelihood ratios for a guided jump process conditioned on an exact end-point or an exact linear image of the state. Those ratios are not products of Poisson probabilities for dSIR increments on a grid of width \(\Delta\tau\). Whitaker et al. (2017), equations (15) and (25), are Gaussian densities for a diffusion skeleton. None of those expressions is placed in the Algorithm 2 denominator.

Golightly and Kypraios (2018), equation (6), is the constant-hazard correction already adapted by Whitaker et al. (2025). It is not a second proposal.

### The residual incidence guide

The draw stays a pair of Poisson increments, and \(q\) stays the product of those Poisson probabilities, as on p. 12 of Whitaker et al. (2025). The numerator of the Algorithm 2 weight is unchanged. The change is the Poisson mean.

At a substep with current prevalence \((s, i)\), log contact rate \(\tilde{\beta}\), infections already proposed in the window \(n^{\mathrm{past}}\), remaining time \(t_i - \tau\), step \(\Delta\tau\) and observation \(y\):

1. Restart the incidence linear-noise approximation at \((s, i)\). The incidence coordinate \(\eta\) starts at 0, the fundamental matrix \(G\) starts at the identity, and the residual variance \(V\) starts at 0. The contact rate \(\exp(\tilde{\beta})\) is held fixed on this restart. Integrate equations (4), (8) and (9) of Golightly, Wadkin, Whitaker, Baggaley, Parker and Kypraios (2023) from 0 to \(\Delta\tau\) and from 0 to \(t_i - \tau\). The Jacobian is the matrix printed after their equation (6), with the restart prevalence in place of \((s_0, i_0)\). The restart is the one they describe after their equation (19), which they attribute to Fearnhead, Giagos and Sherlock (2014). Section 4.2 of that 2014 paper is where the restart is stated: the ODE is re-initialised at the start of each interval.

2. The mean of the binomial observation uses the linear-noise mean of remaining infections, \(\eta_1(t_i - \tau)\), in place of the frozen product \(h_{\mathrm{inf}}(t_i - \tau)\). The variance stays equation (14) of Whitaker et al. (2025), \(\sigma^{2} = (1 - \rho)\hat{\mu}\), with \(\hat{\mu} = \rho\bigl(n^{\mathrm{past}} + \eta_1(t_i - \tau)\bigr)\). For \(P' = (1, 0)\) this is the binomial variance in equation (22) of Golightly et al. (2023).

3. Let \(R\) be the residual incidence, with mean 0 and variance \(V\) under the restart. The covariance of the residual at time \(\Delta\tau\) with the residual at the end of the remaining interval is \(V_{\Delta\tau}(G_{t_i-\tau} G_{\Delta\tau}^{-1})'\). Whitaker, Golightly, Boys and Sherlock (2017), Section 3.1.2, write the same block as \(P_t \psi_t P_T'\) after their display (24). The observation loads on the infection component by \(\rho\). The conditional mean of the infection residual at \(\Delta\tau\) is that infection covariance times \(\rho(y - \hat{\mu})\) divided by \(\rho^{2} V_{11}(t_i - \tau) + \sigma^{2}\). The removal component is not shifted. That matches the scalar SIR form in Section 5.1, where the correction is added to the infection hazard only.

4. The Poisson mean for infections over the next step is the ODE increment \(\eta_1(\Delta\tau)\) plus that conditional residual mean. The Poisson mean for removals is the ODE increment \(\eta_2(\Delta\tau)\). Both are means of counts, not rates multiplied again by \(\Delta\tau\). Draw the increments from those Poisson distributions. The factor \(q\) in the weight is the product of the two Poisson probabilities, and of the same factors at later substeps.

A draw is invalid, and its weight is zero, when the integration stops because a prevalence along the ODE would be negative, when the determinant of \(G_{\Delta\tau}\) is smaller than \(10^{-12}\) in absolute value, when either Poisson mean is negative or is not finite, or when the updated \(s\) or \(i\) would be negative. A negative mean is not replaced by zero. The 2019 truncation of equation (5) is not copied here.

The numerical step used to integrate (4), (8) and (9) is 0.1. It is fixed in the S2 amendment of the design note. It is not a step in Golightly et al. (2023).

### What this claims

On the printed weight, the importance target of one propagate step stays the dSIR transition times the binomial probability. The residual guide changes \(q\). It is the proposal whose evaluated density is the density of the same incidence increments that the numerator describes. No convergence theorem is added.

The prediction for this proposal is the one in the S2 amendment of the design note. It is not a claim that the filtering distribution of \(\gamma\) or \(\rho\) changes.

## 5.4 Dropped

Phase 6 does not simulate these, and a manuscript does not present them as methods.

- A replacement of \(q\) by Golightly and Sherlock (2019), equation (19), or by the guided process in Corstanje et al. (2023), Theorem 4.2. Those densities are not the density Algorithm 2 divides by. The residual incidence guide in Section 5.3 is a different proposal, and it is not on this list.
- Dropping \(h(0, x_0)\) from the ratio (16). Theorem 4.2 keeps that factor.
- Truncating a negative \(h^{*}\) to zero and calling the result the 2025 guide. The 2019 paper truncates equation (5). The 2025 display does not.
- A numerical spacing at which the 2025 guide fails. No opened paper states one for dSEIR incidence.
- A claim that a poor \(h^{*}\) changes the filtering target. The reading in Section 5.2 says the opposite about the printed weight, and it is not a convergence theorem.
- The death-model effective sample sizes in Golightly and Sherlock (2019), Table 1, as evidence about the Section 4.1 SIR model.
- A gold-standard posterior for S1. The diagnostic does not target \(\pi(\psi \mid y)\). The pseudo-marginal run in Section 4.1 of Whitaker et al. (2025) is a different comparison.
