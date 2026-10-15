# Literature bearing on the sparse incidence guide

This note covers files that were opened for this programme, and it lists the named guides that are not stored. It is not a review of every PDF in the repository. The Kalman-filter papers under `Kalman extensions/Literature/` were not opened. Their filenames were checked: none is Golightly and Sherlock (2019), Corstanje, van der Meulen and Schauer (2023), or Golightly and Wilkinson (2015).

Part A and part B are the labels in `Sparse bridge/research-plan.md`. Part A asks when the guide in Whitaker et al. (2025), Section 3.4, is inconsistent. Part B asks what proposal replaces it. Part B is not answered here.

## Whitaker, Golightly, Gillespie and Kypraios (2025)

- Citation, as printed: Whitaker, S. A., Golightly, A., Gillespie, C. S. and Kypraios, T. Sequential Bayesian inference for stochastic epidemic models of cumulative incidence. *Bayesian Analysis* (2025), pp. 1–30. DOI 10.1214/25-BA1547.
- Path: `Source papers/4992336VoR.pdf`.
- Reading: the whole paper. The working account is `notes/01-paper-context.md`.
- Question the paper answers: sequential Bayesian inference for a time-discretised S(E)IR model of cumulative incidence, with a tractable conditional parameter update and a conditioned hazard for the latent incidence.
- Part A: Section 5.1, p. 25, states the failure. The quotation is in the context note. The guide is a Gaussian approximation of remaining incidence, plus linearity of the latent process on an interval no longer than the observation interval. When cumulative incidence is not linear between sparse observations, the hazard is likely to propose trajectories inconsistent with the true conditioned process.
- Part B: the same paragraph names Golightly and Sherlock (2019) and Corstanje et al. (2023) as relevant work on sampling conditioned jump processes, which could be adapted to the dS(E)IR model. It does not state either algorithm. The introduction (pp. 2–3) and the summary (p. 24) say the printed guide adapts Golightly and Wilkinson (2015). That paper is not stored, so this note does not say what was adapted beyond the derivation in Section 3.4.
- What the paper does not give: a threshold on the observation spacing, a proof that the importance weight fails, and a replacement proposal.
- Difference from the object in Section 3.4: this file is that object.

## Lowe, Golightly and Sherlock (2023)

- Citation, as printed on the first page: Lowe, T. E., Golightly, A. and Sherlock, C. Accelerating inference for stochastic kinetic models. *Computational Statistics and Data Analysis* 185 (2023), 107760. DOI 10.1016/j.csda.2023.107760.
- Path: `Source papers/38253VoR.pdf`.
- Reading stopped early. The pages used below are article pp. 7, 9–10, 13 and 16–17. The rest of the paper, including the appendices, was not used. Appendix B was not relied on.

The paper accelerates particle Markov chain Monte Carlo for a Markov jump process or a chemical Langevin equation. The surrogate is a linear noise approximation, used as a Langevin gradient, as a bridge, and as the first stage of delayed acceptance. That is a different inferential target from the 2025 incidence filter. Three passages bear on guides.

Long intervals, Section 4.1, p. 7. To alleviate inconsistencies between the linear-noise mean and the chemical Langevin mean, "which can be increasingly problematic over long inter-observation intervals", the filter reinitialises the linear-noise mean and variance at each observation window, following Fearnhead et al. (2014). This sentence is about the surrogate mean inside a chemical Langevin model. It is not a statement about the dSEIR hazard (12) in Whitaker et al. (2025). Fearnhead et al. (2014) was not opened.

Conditioned hazard, Section 4.2.3, pp. 9–10. This is a secondary account. For a Markov jump process, Lowe et al. write a conditioned hazard for reaction \(i\) as the unconditioned hazard times a ratio of observation densities. The numerator is the density at the state after reaction \(i\), which they write as the current state plus the corresponding stoichiometry column, and the denominator is the density at the current state. They say the transition density is typically intractable, and that they follow Golightly and Sherlock (2019) in replacing it by a linear-noise Gaussian transition density. They display two identities for propagating that approximation without reintegrating at every jump, and they attribute the derivation of those identities to Golightly and Sherlock (2019). Sampling then uses Gillespie's direct method with the unconditioned hazard replaced by the conditioned hazard, ignoring the explicit time dependence of the conditioned hazard. The proposal density is the complete-data likelihood with the same replacement.

That paragraph is what Lowe et al. print. It is not a reading of Golightly and Sherlock (2019). The identities are `[NOT READ]` at their source. Part B must not be coded from this page.

Nonlinear paths between observations, Section 5.2, p. 13, the aphid example. "It is clear that the behaviour of the latent process between observations is nonlinear. This precludes the use of bridge constructs that push the particles towards the observations in a linear fashion, such as the modified diffusion bridge of Durham and Gallant (2002)." They use a residual bridge instead. Durham and Gallant (2002) was not opened. The residual bridge is attributed on p. 10 to Whitaker et al. (2017), which was not opened. The warning is about a diffusion bridge on a chemical Langevin path, not about equation (12) of the 2025 paper.

Discussion, Section 6, pp. 16–17. The future-work sentences that were read concern the dimension at which a Langevin proposal keeps its advantage, a simplified gradient that drops the variance dependence, and Hamiltonian Monte Carlo with the full surrogate gradient. No sentence in the pages read of Section 6 asks for a new incidence bridge.

What this paper does not give us: a condition, in the 2025 notation, for when \(h^{*}\) is inconsistent, and a proposal that has been checked against Algorithm 2.

How it differs from Whitaker et al. (2025), Section 3.4: the 2023 conditioned hazard is the jump hazard multiplied by a ratio of observation densities, with that density replaced by a linear-noise approximation, inside a particle MCMC kernel for a chemical kinetic model. The 2025 display following (18) is a Gaussian conditioning formula for Poisson incidence increments of a dS(E)IR model, used as the proposal inside Algorithm 2.

## Jovanovski, Golightly and Picchini (2024)

- Citation, as printed: Jovanovski, P., Golightly, A. and Picchini, U. Towards data-conditional simulation for ABC inference in stochastic differential equations. *Bayesian Analysis* (2024), pp. 1–31. DOI 10.1214/24-BA1467.
- Path: `Source papers/3033124AOV.pdf`.
- Reading stopped early. The pages used below are article pp. 23–26 (the close of the Lotka–Volterra set-up and Section 8). The lookahead algorithm was not read.

The paper constructs a sequential Monte Carlo ABC method whose proposals are data-conditional trajectories, built from a forward lookahead pass and a backward simulation pass, with summary statistics retrained during the run. The model class is a discretely observed stochastic differential equation. It is not a dS(E)IR filter.

Erratic paths, Section 8, p. 26. The largest efficiency gains against forward-only ABC, among the studies they report, come from the more complex cases, "where the solution to the SDE is very erratic." They conjecture that still more erratic paths would show larger accelerations. On the pages read, this is a statement about where their data-conditional proposals help. It is not a statement that a linear Gaussian guide becomes inconsistent.

A bridge is mentioned, pp. 23–24. The particle MCMC reference posterior for the Lotka–Volterra example used a modified diffusion bridge of Durham and Gallant, in the version of Whitaker et al. (2017), to impute between observations. Neither of those papers was opened. The sentences read do not say that this bridge fails when the path is erratic.

The scoping note's join, that the 2024 paper names the same guide-failure gap for erratic diffusion paths, is therefore not a sentence found in Section 8. The sentence that was found is the conjecture about larger speed-ups. Part A should not cite the 2024 discussion as evidence that the 2025 hazard fails.

What this paper does not give us: an incidence proposal, and a diagnostic for \(h^{*}\).

How it differs from Whitaker et al. (2025), Section 3.4: data-conditional simulation here is a forward-backward construction inside ABC for a diffusion. The 2025 guide is a closed-form hazard inside a particle filter for Poisson incidence.

## Golightly and Wilkinson (2015)

- Citation, as printed: Golightly, A. and Wilkinson, D. J. Bayesian inference for Markov jump processes with informative observations. *Statistical Applications in Genetics and Molecular Biology* 2015; 14(2): 169–188. DOI 10.1515/sagmb-2014-0070.
- Path: `Sparse bridge/Literature/Golightly2015-informative-observations.pdf`. Header `%PDF` checked. The file matches the supplied copy byte for byte.
- Reading: Sections 1 to 3.1, including Algorithms 1 to 3 and equation (9). Sections 3.2 to 6 were not used for the claims below.
- Question the paper answers: parameter inference for a Markov jump process when discrete observations are informative, by proposing conditioned trajectories rather than forward simulation.
- Part A: Section 3.1 approximates the remaining reaction counts \(\Delta R_s\) by a Gaussian whose mean and variance are the current hazard times the remaining time \(\Delta s\). That is a constant-hazard assumption on \((s, t]\). The conditioned hazard (9) is the conditional expectation of \(\Delta R_s\) given the Gaussian observation, divided by \(\Delta s\). The observation is of the state, \(Y_t = P' X_t + \varepsilon_t\), not of an incidence increment.
- Part B: Algorithm 2 draws the next event time from an exponential distribution at the current value of (9), ignoring the explicit time dependence between events. Algorithm 3 weights by the complete-data likelihood ratio (10). This is a proposal for the jump process, not for the dSEIR Poisson grid.
- What it does not give: a binomial or negative binomial observation of cumulative incidence, and a statement of when (9) fails. The failure of the constant-hazard step is stated later by Golightly and Sherlock (2019), Section 3.2.
- How it differs from Whitaker et al. (2025), Section 3.4: the 2025 display has the same shape as (9), with the reaction-count vector in place of \(S\Delta R\) and with the binomial or negative binomial variance in place of \(\Sigma\). The 2015 paper is the source Whitaker et al. say they adapt. The adaptation itself is printed only in the 2025 Section 3.4.

## Golightly and Sherlock (2019)

- Citation, as printed: Golightly, A. and Sherlock, C. Efficient sampling of conditioned Markov jump processes. *Statistics and Computing* (2019) 29:1149–1163. DOI 10.1007/s11222-019-09861-5.
- Path: `Sparse bridge/Literature/Golightly2019-conditioned-markov-jump.pdf`. Header `%PDF` checked. The file matches the supplied copy byte for byte.
- Reading: the article through Section 6. Tables were read as printed. The proofs of the linear-noise ODE solution are cited by the paper to Fearnhead et al. (2014), which was not opened.
- Question the paper answers: an approximate bridge for a Markov jump process between a known state and a partial or noisy Gaussian observation, cheap enough to use inside weighted resampling or particle MCMC.
- Part A: Section 3.2 restates the Golightly and Wilkinson hazard as equation (5) and says that normality of the remaining reaction counts, and a hazard that is constant on the whole remaining interval, are often unreasonable. Section 5.1, the death model, says the linear form cannot adequately describe the exponential decay of the true conditioned process, and that effective sample size falls and relative mean squared error rises as the interval length \(T\) increases. Section 6 says that treating the remaining time as a single discretisation makes the bridges less accurate as the inter-observation time increases.
- Part B: the proposal that addresses that failure is the Fearnhead hazard (6), with the transition density replaced by the linear-noise Gaussian. Equation (16) restarts the linear-noise ODEs at the current state. Equation (19) does not restart them: one integration of (11), (13) and (14), then the identities (17) and (18). Sampling uses Gillespie's method with that hazard, ignoring explicit time dependence between events, and truncating to keep the hazard positive. The weight is (3), the complete-data likelihood ratio, and the average unnormalised weight estimates the transition density (4). On the death model and on Lotka–Volterra, the without-restart linear-noise bridge keeps a high effective sample size as \(T\) grows, where (5) does not. The sampler is an MJP bridge under a Gaussian observation of the state. It is not a product of Poisson probabilities on a dSEIR grid, and the observation is not a binomial count of incidence.
- What it does not give: a line-by-line replacement for \(q\) in Whitaker et al. (2025), Algorithm 2. The numerical comparisons use the `deSolve` package. This programme does not add that package.
- How it differs from Whitaker et al. (2025), Section 3.4: equation (5) is the constant-hazard guide the 2025 display adapts. Equation (19) replaces the transition density inside (6), for a different observation and a different path measure.

## Corstanje, van der Meulen and Schauer (2023)

- Citation, as printed: Corstanje, M., van der Meulen, F. and Schauer, M. Conditioning continuous-time Markov processes by guiding. *Stochastics* 2023, 95(6), 963–996. DOI 10.1080/17442508.2022.2150081.
- Path: `Sparse bridge/Literature/Corstanje2023-guiding-ctmc.pdf`. Header `%PDF` checked. The file matches the supplied copy byte for byte.
- Reading: Sections 1, 2 and 4.1, the statement of Theorem 3.3, and Section 4.2 through Theorem 4.9. The appendix and the diffusion application in Section 5 were not used.
- Question the paper answers: when a tractable guided process, obtained by replacing the function in Doob's \(h\)-transform, is equivalent to the process conditioned on its value at a fixed time, and what the likelihood ratio is.
- Part A: not a statement about the 2025 hazard. Theorem 4.2 is the closest discrete example. It conditions an inhomogeneous Poisson process on an exact integer end-point.
- Part B: Definition 2.5 and equation (4) define the guided process. For the Poisson process, the guide \(\tilde h\) is the transition probability (15) of a homogeneous Poisson process, and Theorem 4.2 gives the likelihood ratio (16) under the condition \(\tilde\lambda \le \min \lambda(x)\) on the states between the end-points. The ratio still contains \(h(0, x_0) = \Pr(X_T = x_T \mid X_0 = x_0)\) for the original process. For a state-dependent rate that probability is the intractable transition probability. Example 2.4 says a noisy end-point can be written as a mixture of exact conditionings. Section 4.1 does not carry that mixture out, and it does not treat a binomial observation of an increment on a grid.
- What it does not give: an evaluable weight for Whitaker et al. (2025), Algorithm 2. The factor \(h(0, x_0)\) in (16) is not cancelled by anything printed in Theorem 4.2, and it depends on the particle's starting state.
- How it differs from Whitaker et al. (2025), Section 3.4: guiding here changes the generator of a continuous-time Markov process and corrects with a likelihood ratio that still contains the true transition probability. The 2025 guide is a closed-form Poisson rate on a grid, corrected by the dSEIR transition and the observation mass function.

## Guides still not stored

Cited beside the bridge, and not the replacement:

- Golightly and Kypraios (2018), named with "see also" on pp. 2–3 of Whitaker et al. (2025). The 2025 reference list gives *Statistics and Computing* 28(6), 1215–1230, DOI 10.1007/s11222-017-9789-8. `[PDF NOT STORED]`. Not required to restate Section 3.4.
- Whitaker et al. (2025) supplement, DOI 10.1214/25-BA1547SUPP. `[PDF NOT STORED]`. The main text, p. 26, says it contains further synthetic experiments and linear-noise details for the Ebola comparison.

Named in the opened pages of Lowe et al. (2023) or Jovanovski et al. (2024), and not required to restate the 2025 guide:

- Durham and Gallant (2002), the modified diffusion bridge. `[PDF NOT STORED]`.
- Whitaker, Golightly, Boys and Sherlock (2017), the residual bridge and the version of that diffusion bridge used by Jovanovski et al. `[PDF NOT STORED]`. The 2023 and 2024 reference lists were not copied out in full; the titles were not re-derived here.
- Fearnhead, Giagos and Sherlock (2014). `[PDF NOT STORED]`. Golightly and Sherlock (2019) cite it for the linear-noise solution. The bridge identities (17) and (18) are printed in the 2019 paper and were read there. Lowe et al. cite the same paper for reinitialising the linear noise approximation.

## Comparison

A cell is filled only from a page that was read. "Secondary" means the sentence sits in Lowe et al. (2023) and points at a paper that was not opened.

| Guide | What is propagated | What the proposal conditions on | Importance weight corrects the proposal? | Source used |
| --- | --- | --- | --- | --- |
| Whitaker et al. (2025), display after (18) | Poisson incidence increments of dS(E)IR on the subgrid, with rate \(h^{*}\Delta\tau\) | The next incidence observation, through a Gaussian approximation of remaining incidence and of that observation | Yes, as printed in Algorithm 2, step 2. The ratio uses the dSEIR transition and the observation mass function over \(q\) | Section 3.4 and Algorithm 2, read |
| Lowe et al. (2023), Section 4.2.3, jump-process hazard | A Markov jump process, by Gillespie's method with the conditioned hazard | The observation at the end of the interval, through a ratio of observation densities, with the density replaced by a linear-noise Gaussian | The surrounding scheme is particle MCMC. Whether the bridge density enters an importance weight was not checked beyond the statement that \(q\) is the complete-data likelihood with the conditioned hazard | pp. 9–10, read. The 2019 derivation is secondary |
| Lowe et al. (2023), residual bridge | A discretised chemical Langevin equation | The next observation, after a residual partition | `[NOT READ]` beyond the existence of the construct | Named on p. 10. Whitaker et al. (2017) not opened |
| Modified diffusion bridge of Durham and Gallant | `[PDF NOT STORED]` | Lowe et al., p. 13, say it pushes particles towards the observations in a linear fashion, and that nonlinear behaviour between observations precludes it | `[PDF NOT STORED]` | Durham and Gallant (2002) not stored. The preclusion sentence was read in Lowe et al. |
| Jovanovski et al. (2024) data-conditional simulation | `[NOT READ]`. The abstract and Section 8 describe forward and backward simulation of a diffusion | The observed diffusion path, in the sense of the discussion on pp. 25–26 | The sampler is ABC, not an importance correction of a dSEIR proposal | Section 8 read. The algorithm was not |
| Golightly and Wilkinson (2015), equation (9) | A Markov jump process, by exponential waiting times at the current conditioned hazard (Algorithm 2) | A Gaussian observation of the state. Remaining reaction counts are Gaussian with the hazard frozen on the whole remaining interval | Yes. Algorithm 3 uses the complete-data likelihood ratio (10) | Section 3.1, read |
| Golightly and Sherlock (2019), equation (5) | Same construction as Golightly and Wilkinson (2015), equation (9) | Same Gaussian observation. Section 3.2 says the constant-hazard step is often unreasonable | Yes, through the weight (3) when this hazard is the proposal | Section 3.2, read |
| Golightly and Sherlock (2019), equation (19) | A Markov jump process, by Gillespie's method with the linear-noise conditioned hazard, without restarting the ODEs | The same Gaussian observation, through the linear-noise transition density in the Fearnhead ratio (6) | Yes. The weight is (3), and (4) estimates the transition density | Sections 4.3 and 3.1, read |
| Corstanje et al. (2023), Theorem 4.2 | An inhomogeneous Poisson process, with rates from the guided generator (4) and the homogeneous-Poisson guide (15) | An exact integer end-point \(X_T = x_T\) | The ratio (16) is printed, and it contains the intractable transition probability \(h(0, x_0)\) | Section 4.1, read. Not an Algorithm 2 weight |

## What phase 4 is not allowed to treat as settled

- No opened paper states a numerical spacing at which the 2025 guide fails. Golightly and Sherlock (2019), Section 5.1, report that degradation for a death process, not for dSEIR incidence.
- The 2025 weight is printed. Whether a poor \(h^{*}\) changes the filtering target, or only the weights, is a reading for the theory note, not a theorem in the 2025 paper.
- Equation (19) of Golightly and Sherlock (2019) has been read. It is not a product of dSEIR Poisson probabilities, so it is not yet a replacement for \(q\).
- Theorem 4.2 of Corstanje et al. (2023) has been read. Its likelihood ratio is not free of the intractable transition probability.
