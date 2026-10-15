# Context: sequential inference for cumulative incidence (Whitaker et al. 2025)

Source: `Source papers/4992336VoR.pdf`, read in full. Printed pages below are the article pages (pp. 1–30), which match the PDF page index. Equation and algorithm numbers are those printed in the paper. The conditioned hazard after (18) is not given an equation number in the PDF; this note calls it the display following (18).

This note paraphrases. The passages kept close to the original wording are the limitations sentences in "Open problem".

## Model class and the filtering target

Section 2 (pp. 3–4) takes a closed population of size \(N_{\mathrm{pop}}\) and an SEIR classification. The pseudo-reactions are contact \(S+I \to E+I\) at rate \(\beta\), infection \(E \to I\) at rate \(\kappa\), and removal \(I \to R\) at rate \(\gamma\). The parameter is \(\theta = (\beta, \kappa, \gamma)'\). Setting \(\kappa = 0\) and replacing \(E\) by \(I\) gives SIR, in which \(\beta\) is the infection rate.

The prevalence is \(X_t = (S_t, E_t, I_t)'\), with \(R_t = N_{\mathrm{pop}} - S_t - E_t - I_t\). The cumulative incidence \(N_t = (n^{\mathrm{se}}_t, n^{\mathrm{ei}}_t, n^{\mathrm{ir}}_t)'\) counts contact, infection and removal events. The hazard, with dependence on \(\theta\) suppressed, is
\[
h(x_t) = (\beta s_t i_t,\, \kappa e_t,\, \gamma i_t)'.
\]
The net effect matrix \(A\) has rows \((-1, 1, 0)\), \((0, -1, 1)\) and \((0, 0, -1)\). Prevalence and incidence are linked by \(X_t = x_0 + \sum_i A_i' N_{i,t}\) (p. 4).

Section 2.1 (p. 5) lets the contact rate vary. With \(\tilde{\beta}_t = \log \beta_t\),
\[
d\tilde{\beta}_t = a(\tilde{\beta}_t, \lambda)\, dt + b(\tilde{\beta}_t, \lambda)\, dW_t,
\]
equation (1). The conflict between the sentence that sets \(b = \lambda\) and equation (2) is recorded under "Notation". Sections 4.1 and 4.3 use the precision form.

Section 2.2 (pp. 5–6) replaces the jump process by a time-discretised model. Over a step \(\Delta t\) short enough that \(\tilde{\beta}\) and \(X\) may be treated as constant, the incidence increments are independent Poisson random variables,
\[
\Delta N_{1,t} \sim \mathrm{Po}\bigl(e^{\tilde{\beta}_t} s_t i_t \Delta t\bigr),\quad
\Delta N_{2,t} \sim \mathrm{Po}(\kappa e_t \Delta t),\quad
\Delta N_{3,t} \sim \mathrm{Po}(\gamma i_t \Delta t).
\]
The dSEIR recursion is equation (4): \(X\) jumps by \(A'\Delta N_t\), and \(\tilde{\beta}\) takes an Euler–Maruyama step. Algorithm 1 (p. 6) is forward simulation of that recursion. The practitioner chooses the step.

## Observation model

Section 3.1 (pp. 6–7). Data \(y = (y_{t_1}, \ldots, y_{t_L})'\) are partial observations of incidence over windows \((t_{i-1}, t_i]\). Two models are used. The binomial model (5) is \(Y_{t_i} \mid \Delta N_{t_i} \sim \mathrm{Bin}(P'\Delta N_{t_i}, \rho)\). The negative binomial model (6) has mean \(\rho P'\Delta N_{t_i}\) and variance \(\mu_i + \mu_i^2/\nu\). In the SEIR applications \(P' = (0, 1, 0)\), so the data are noisy counts of new infections. In the SIR applications \(P' = (1, 0)\). The observation parameter is \(\phi\), and the mass function is \(\pi(y_{t_i} \mid \Delta n_{t_i}, \phi)\). Section 4.3 lets the reporting rate vary; that is recorded with the COVID-19 application below.

## Inference task and the particle filter

Section 3.2 (pp. 7–8). The static parameter is \(\psi = (\theta', \lambda', \phi')'\). Each observation window is split into \(m\) substeps of length \(\Delta \tau = \Delta t / m\), because the hazard cannot be treated as constant on the observation scale. The joint posterior (7) is the prior times the Gaussian density of the contact-rate path, times a product of Poisson probabilities for the incidence increments, times the observation mass functions.

Section 3.3 (pp. 8–10). The sequential target the paper writes at time \(t_{i+1}\) is the proportionality (8): the previous filtering distribution, times the contact-rate transition, times the incidence transition, times the new observation mass function. The stored filtering objects are \(\psi\), \(\tilde{\beta}_{t_i}\) and \(\Delta n_{t_i}\), together with a sufficient statistic defined below. The paper's target sentence (p. 8) is the sequence of filtering distributions \(\pi(\psi, \tilde{\beta}_{t_i}, \Delta n_{t_i} \mid y_{[1,i]})\).

A bootstrap filter would draw the contact rate and the incidence from their transitions and weight by the observation. The paper gives two reasons not to stop there (p. 8). Resampling static parameters collapses them, and forward simulation of incidence ignores the next count.

For the first problem, independent gamma priors on \(\kappa\), \(\gamma\) and, when (2) is used, on the precision \(\lambda\), give the gamma conditional posteriors (9), (10) and (11). The paper summarises \(\pi(\theta, \lambda \mid \Delta n_{(0,i]}, \tilde{\beta}_{[0,i]})\) by the sufficient statistic \(T_i\), the three shape and three rate hyperparameters in (9)–(11), initialised at the prior hyperparameters (p. 9). A binomial reporting rate with a beta prior has a beta conditional posterior on the same page. That beta update is not included in the definition of \(T_i\) just quoted. For the negative binomial, \(\phi = (\rho, \nu)'\) does not have a tractable conditional posterior. Algorithm 2 then jitters \(\phi\) with the Liu and West (2001) kernel printed on pp. 9–10. This note has not opened Liu and West (2001). The discount range printed in the paper is \(\delta\) typically 0.95 to 0.99. Equations (9)–(11) are written for the SEIR hazard and one contact-rate precision. Section 4.3 does not reprint a statistic for the second precision \(\lambda_{\rho}\).

The contact-rate path on the next window is drawn from its transition, which the paper calls propagating \(\tilde{\beta}\) blindly (p. 10). The incidence path is drawn from a proposal \(q\) that depends on the next observation. That proposal is Section 3.4.

Algorithm 2 (pp. 10–11) is stated for observation model (6). For each observation time and each particle: jitter \(\phi\); draw the contact-rate path from its transition; draw the incidence path from \(q\); resample with the importance weight below; update \(T_i\); draw \(\theta\) and \(\lambda\) from (9)–(11). The paper does not print a second algorithm box for the binomial model. The synthetic application uses that model, and the beta conditional posterior is printed, but this note does not invent the missing box.

The weight in step 2 of Algorithm 2 is
\[
w_{i+1}^{(k)} \propto
\frac{\pi\bigl(\Delta n_{(i,i+1]}^{(k)} \mid \tilde{\beta}_{[i,i+1)}^{(k)}, \theta^{(k)}\bigr)\,
\pi\bigl(y_{t_{i+1}} \mid \Delta n_{t_{i+1}}^{(k)}, \phi_{t_{i+1}}^{(k)}\bigr)}
{q\bigl(\Delta n_{(i,i+1]}^{(k)} \mid \tilde{\beta}_{[i,i+1)}^{(k)}, \phi_{t_{i+1}}^{(k)}, \theta^{(k)}, y_{t_{i+1}}\bigr)}.
\]
The numerator uses the dSEIR transition and the observation model. The denominator is the bridge proposal. This note does not add a theorem about the limiting target of the weighted particles. The printed weight is an importance ratio.

## The conditioned hazard

Section 3.4 (pp. 10–12). The aim is an instantaneous rate conditioned on the next observation. The paper says the derivation builds a Gaussian approximation to the joint distribution of the remaining incidence and the next observation, and that the conditioned hazard is then taken to be proportional to the expected incidence given the observation (p. 11). The last paragraph of the derivation says, more specifically, that one conditions on \(Y_{t_i} = y_{t_i}\), takes the expectation, and divides by the remaining time \(t_i - \tau_{i,j}\) (p. 12).

Fix a time \(\tau_{i,j}\) inside \((t_{i-1}, t_i]\), with the state and the incidence so far treated as known. The remaining increment \(\Delta N_{(\tau_{i,j}, t_i]}\) is Poisson with rate \(h(x_{\tau_{i,j}})(t_i - \tau_{i,j})\) under dSEIR. The Gaussian approximation (12) is
\[
\Delta N_{(\tau_{i,j}, t_i]} \;\overset{\mathrm{approx}}{\sim}\;
\mathcal{N}\bigl(h(x_{\tau_{i,j}})(t_i - \tau_{i,j}),\, H(x_{\tau_{i,j}})(t_i - \tau_{i,j})\bigr),
\]
where \(H(x) = \mathrm{diag}\{h(x)\}\). The mean in (12) is the current hazard times the remaining time. Section 3.4 does not use the word linear. The limitations section does; see "Open problem".

The observation is given its own Gaussian approximation (13), with mean \(\mu = \rho P'(\Delta n_{(t_{i-1}, \tau_{i,j}]} + \Delta N_{(\tau_{i,j}, t_i]})\). The binomial variance is (14), \((1-\rho)\mu\). The negative binomial variance is (15), \(\mu + \mu^2/\nu\). Both depend on the remaining incidence. To obtain a joint Gaussian law, the paper replaces \(\mu\) inside (14) and (15) by \(\hat{\mu}\), which uses the mean of (12) in place of the random remaining incidence. Marginalising the remaining incidence gives (16). The covariance is (17), \(\rho P' H(x_{\tau_{i,j}})(t_i - \tau_{i,j})\). The joint normal approximation is (18).

The display following (18), transcribed as printed, is
\begin{align*}
h^{*}(x_{\tau_{i,j}} \mid y_{t_i})
&= h(x_{\tau_{i,j}})
+ \rho P' H(x_{\tau_{i,j}})
\bigl\{\rho^{2} P' H(x_{\tau_{i,j}}) P (t_i - \tau_{i,j})
+ \sigma^{2}(\Delta n_{(t_{i-1}, \tau_{i,j}]})\bigr\}^{-1} \\
&\qquad \times \bigl\{y_{t_i} - \hat{\mu}(\Delta n_{(t_{i-1}, \tau_{i,j}]})\bigr\}.
\end{align*}
Dependence on \(\theta\), \(\phi\), the contact rate and the incidence so far is suppressed in the paper's notation (p. 11). This note does not reorder \(P\) and \(P'\), and it does not rederive the display.

End-point conditioned trajectories on \((t_{i-1}, t_i]\) are obtained by running Algorithm 1 with \(h\) replaced by \(h^{*}\) and with time step \(\Delta \tau\). The proposal density \(q\) is the product of Poisson probabilities with rates \(h^{*}(x_{\tau_{i,j}} \mid y_{t_i})\,\Delta \tau\), for \(j = 0, \ldots, m-1\) (p. 12).

The introduction (pp. 2–3) says this construct adapts the bridge of Golightly and Wilkinson (2015); see also Golightly and Kypraios (2018). The summary (p. 24) repeats the attribution to Golightly and Wilkinson (2015). Neither PDF is stored. This note uses only what Section 3.4 prints.

## Applications, as described

Section 4 (p. 12). Three applications. In all three the dS(E)IR step is \(\Delta \tau = 0.1\), in weeks for the two real series. Code is in R, on a PC with a 2.6 GHz clock, across 20 cores. The paper gives the address `https://github.com/Sam-Whitaker/Sequential_Bayes_Epi`. That code is not in this repository.

### Synthetic SIR

Section 4.1 (pp. 12–16). One synthetic series: noisy new infections on \((t-1, t]\) for \(t = 1, \ldots, 10\). The series was generated from Algorithm 1 with step 0.001 on \([0, 10]\), then summed to unit windows. Initial state \((s_0, i_0)' = (762, 5)'\), \(\gamma = 0.5\), \(d\tilde{\beta}_t = \lambda^{-1/2} dW_t\) with \(\tilde{\beta}_0 = -6\) and \(\lambda = 100\), binomial reporting with \(\rho = 0.9\). Figure 1 plots the series. The counts are not printed as a table.

Priors: \(\log \beta_0 \sim \mathcal{N}(-6.5, 0.5^2)\), \(\gamma \sim \mathrm{Gamma}(11, 20)\), \(\lambda \sim \mathrm{Gamma}(15, 0.14)\), \(\rho \sim \mathrm{Beta}(90, 15)\). The filter uses \(N = 10^k\) particles for \(k = 1, \ldots, 6\). A parallel run with \(N = 10^6\) takes about 16 minutes (p. 13). The gold standard is a pseudo-marginal Metropolis–Hastings run of \(10^6\) iterations under the dSIR model, with a bootstrap particle filter for the likelihood (p. 14). The paper reports that bias and RMSE of the posterior mean and standard deviation of \(\gamma\) and \(\rho\) improve with \(N\), with relatively little improvement beyond \(N = 50\mathrm{K}\) (p. 14). The summary (p. 25) says these quantities stabilise for \(N \ge 10^5\). Both sentences are in the paper. This note does not replace them by a single threshold.

Figure 5 shows the filtering means and 95% intervals against the ground truth. The paper says the precision \(\lambda\) is barely informed by the data. Figure 6 shows prevalence. No numerical posterior summaries are printed in the text, so none are copied here.

### Ebola in Sierra Leone

Section 4.2 (pp. 17–20). A subset of the data in Fintzi et al. (2022): 53 weekly incidence observations from Sierra Leone, May 2014 to May 2015. Figure 7 plots them. The weekly counts are not printed as a table, and no incidence file is stored in this repository. Fintzi et al. (2022) has not been opened.

The observation model is the negative binomial (6). Immigration is not included. The contact rate is constant. Priors, stated as consistent with Fintzi et al. (2022): \(\beta \sim \mathrm{Gamma}(2, 50000)\), \(\kappa \sim \mathrm{Gamma}(5, 4.6)\), \(\gamma \sim \mathrm{Gamma}(10, 10)\), \(\mathrm{logit}(\rho) \sim \mathcal{N}(0.85, 0.75^2)\), \(\nu \sim \mathrm{Gamma}(5, 0.2)\). The initial state is fixed at \(x_0 = (44326, 15, 10)'\). At least \(N = 4 \times 10^6\) particles were used. One parallel run took about 321 minutes (p. 17).

The comparator is a linear noise approximation as the transmission model, with the same negative binomial observations, fitted by the marginal Metropolis–Hastings scheme of Golightly et al. (2023). This note has not opened that paper or the supplement, which the main text says contains the linear-noise details (p. 20). The MCMC run was 100k iterations after a pilot of 10k, at a wall-clock cost about equal to the particle filter run. The paper compares five one-step-ahead forecasts in Figure 10. Under dSEIR it says the observations lie close to the median of each forecast and between the quartiles (p. 18). Under the linear noise approximation it says the approximation tends to overestimate the observations (p. 20). The overdispersion parameter is the parameter on which the two fits disagree most, in the direction of larger values under the linear noise approximation (p. 20).

### COVID-19 in New York

Section 4.3 (pp. 20–24). Twenty-five weekly incidence observations from New York, March 2020 to mid-August 2020, from Spannaus et al. (2022). Figure 11 plots them. The counts are not printed as a table and are not stored here. Spannaus et al. (2022) has not been opened.

The transmission model is SIR with two scaled Brownian motions, equation (19): one for \(\log \beta_t\) with precision \(\lambda_{\beta}\), and one for \(\mathrm{logit}\,\rho_t\) with precision \(\lambda_{\rho}\). The observation model is (20), a negative binomial with time-varying reporting rate. Priors, following Spannaus et al. (2022): \(\log \beta_0 = 0\) fixed, \(\gamma \sim \mathrm{Gamma}(11.088, 2.192)\), \(\lambda_{\beta} \sim \mathrm{Gamma}(4, 1)\), \(\lambda_{\rho} \sim \mathrm{Gamma}(4, 1)\), \(\rho_0 \sim \mathrm{Beta}(3, 2)\), and \(1/\sqrt{\nu} \sim \mathrm{Uniform}(0, 0.5)\). At least \(N = 4 \times 10^6\) particles were used. One parallel run took about 49 minutes (p. 21).

The comparator is the Kermack–McKendrick ODE system (21) with the same stochastic infection rate and the same observation model, fitted by particle marginal Metropolis–Hastings for \(10^5\) iterations with 100 state particles, in about 41 hours (p. 23). The paper reports agreement of forecast medians with the data for both fits, and larger forecast uncertainty under the ODE model, which it attributes to larger values of \(1/\sqrt{\nu}\) compensating for deterministic dynamics (pp. 23–24).

The summary (p. 25) says a new observation is assimilated in around 6 minutes for dSEIR and 2 minutes for dSIR. Those are the paper's figures. This note does not recompute them from the total run times.

Nothing in Sections 4.2 or 4.3 says that these weekly series are sparse enough for the linearity assumption to fail. The failure mode is stated only in Section 5.1.

## What the paper claims about the filter

The summary (pp. 24–25) claims: a parallel implementation; for the synthetic series, an order-of-magnitude speed-up over a serial run once \(N \ge 10^4\), and posterior accuracy against long pseudo-marginal runs that stabilises for \(N \ge 10^5\); for Ebola, forecasts that follow the end of the epidemic more closely than the linear noise approximation at a matched computational budget; for COVID-19, point forecasts in agreement with the ODE comparison and tighter forecast uncertainty. The claims are tied to the figures named above. This note does not add numerical values that the text does not print.

## Open problem

Section 5.1 (pp. 25–26) states three limitations. Only the second is the question of this programme.

### In scope: the conditioned hazard under sparse observation

Page 25, quoted:

> The particle filter used in this paper propagates particles conditional on the next observation by replacing the Poisson rate with a hazard function derived via a Gaussian approximation of the cumulative incidence between the current time and next observation, conditional on the observation itself. A further assumption in deriving the resulting conditioned hazard is linearity of the latent process over a time interval of length at most given by the observation interval. In scenarios in which the epidemic is sparsely observed in time, to the extent that cumulative incidence does not evolve in a linear fashion, the conditioned hazard is likely to result in trajectories that are inconsistent with the true conditioned process. Recent work on sampling conditioned jump processes (in a chemical kinetics setting) is relevant here (see e.g. Golightly and Sherlock, 2019; Corstanje et al., 2023) and could be adapted to dS(E)IR model.

Part A of the research question is the failure named in the second and third sentences. Part B is the adaptation named in the last sentence. The paper says "likely", and it says "the true conditioned process". It does not give a numerical spacing at which the failure begins, and it does not say that the importance weight in Algorithm 2 then targets the wrong distribution. Those are questions for a later phase, not claims of this note.

The same paragraph points at Golightly and Sherlock (2019) and Corstanje et al. (2023). Both are `[PDF NOT STORED]`. The scoping note's bullet under "From the epidemic paper" matches this paragraph. It is not scoping-note only.

### In the paper, outside this programme

Page 25, the step-size limitation, quoted in part. The dS(E)IR model needs a step that balances accuracy relative to the jump process against cost. The paper uses a fixed step and says an optimal choice is likely to depend on the phase of the epidemic. It names Gillespie (2001) for conditions on the Poisson approximation, and Cao et al. (2006) and Sandmann (2009) for adaptive tau-leaping. This programme does not rebuild the step.

Pages 25–26, the degeneracy limitation. The conditional parameter update depends on a low-dimensional statistic \(T_i\). The paper says the number of distinct ancestral values feeding \(T_i\) falls exponentially in time, cites Section 4 of Chopin et al. (2010), and says the applications here stay short enough, and use enough particles, to avoid the worst of it. It leaves open longer series and a comparison with resample-move schemes such as SMC2 (Chopin et al. 2013). This programme does not take up that comparison.

### Scoping note only

The join in the scoping note, that every linear-Gaussian guide in the five papers fails for long intervals or strongly nonlinear dynamics, is not a sentence in Section 5.1. The 2025 paper states the failure for its own hazard. What the 2023 and 2024 papers say is in the literature note, and only for the pages that were opened.

## Notation

Later notes use the symbols below. They are the paper's, except for the one choice marked as such.

| Symbol | Meaning |
| --- | --- |
| \(N_{\mathrm{pop}}\) | Fixed population size |
| \(X_t = (S_t, E_t, I_t)'\) | Prevalence. SIR drops \(E\) |
| \(N_t = (n^{\mathrm{se}}_t, n^{\mathrm{ei}}_t, n^{\mathrm{ir}}_t)'\) | Cumulative incidence of contact, infection and removal |
| \(\theta = (\beta, \kappa, \gamma)'\) | Contact, infection and removal rates. In SIR, \(\beta\) is the infection rate and there is no \(\kappa\) |
| \(h(x_t)\) | Unconditioned hazard \((\beta s_t i_t, \kappa e_t, \gamma i_t)'\) |
| \(A\) | Net effect matrix, as in Section 2 |
| \(\tilde{\beta}_t = \log \beta_t\) | Log contact rate |
| \(\lambda\) | Precision of the scaled Brownian motion for \(\tilde{\beta}\), in the choice below |
| \(\psi = (\theta', \lambda', \phi')'\) | Static parameter. Components change with the application, as in Sections 4.1 to 4.3 |
| \(t_i\), \(i = 1, \ldots, L\) | Observation times. Windows are \((t_{i-1}, t_i]\) |
| \(\tau_{i,j}\), \(\Delta \tau = \Delta t / m\) | Subgrid inside an observation window |
| \(y_{t_i}\) | Scalar incidence observation. \(P\) selects the incidence component |
| \(\phi\) | Observation parameter: \(\rho\), or \((\rho, \nu)'\) |
| \(k = 1, \ldots, N\) | Particle index. \(N\) is the number of particles |
| \(T_i\) | Sufficient statistic for \((\theta, \lambda)\) in (9)–(11): three shapes and three rates. The binomial beta update for \(\rho\) is separate |
| \(h^{*}\) | Conditioned hazard, the display following (18) |
| \(q\) | Product of Poisson probabilities with rates \(h^{*} \Delta \tau\) |
| \(w_{i+1}^{(k)}\) | Importance weight in Algorithm 2, step 2 |

Choice for the contact-rate SDE. Page 5 says that \(a(\tilde{\beta}_t, \lambda) = 0\) and \(b(\tilde{\beta}_t, \lambda) = \lambda\) give a generalised Brownian motion, and then prints equation (2),
\[
\tilde{\beta}_{t+\Delta t} = \tilde{\beta}_t + \lambda^{-1/2} \Delta W_t, \qquad \Delta W_t \sim \mathcal{N}(0, \Delta t),
\]
with \(\lambda\) called a precision parameter. Section 4.1 uses \(d\tilde{\beta}_t = \lambda^{-1/2} dW_t\). Equation (19) uses the same precision form for \(\log \beta_t\) and for \(\mathrm{logit}\,\rho_t\). Later notes use equation (2) and (19). They do not use the assignment \(b = \lambda\). The sentence and the displays disagree; the displays and the applications agree with each other.

The word "linear" is reserved for the assumption named on p. 25. Equation (12) is the Gaussian approximation with the hazard frozen at \(\tau_{i,j}\). Whether that freeze is exactly the linearity assumption is a question for the theory agenda, not a definition imposed here.

## Data and code that are not in the repository

- Weekly Ebola counts and weekly COVID-19 counts: described and plotted, not tabulated, and not stored as a data file.
- `https://github.com/Sam-Whitaker/Sequential_Bayes_Epi`: named on p. 12, not copied here.
- Supplement, DOI 10.1214/25-BA1547SUPP: named on p. 26. The main text says it contains further synthetic experiments and the linear-noise derivation for the Ebola comparison. `[PDF NOT STORED]`.
- Golightly and Wilkinson (2015), Golightly and Kypraios (2018), Golightly and Sherlock (2019), Corstanje et al. (2023): cited. `[PDF NOT STORED]`. Bibliographic details as printed in the reference list are in the literature note.
