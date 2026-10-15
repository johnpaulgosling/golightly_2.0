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

## Guides not stored

These citations are copied from the reference list of Whitaker et al. (2025), pp. 27–28, which was read. The papers themselves were not.

- Golightly, A. and Sherlock, C. (2019). "Efficient sampling of conditioned Markov jump processes." *Statistics and Computing* 29, 1149–1163. DOI 10.1007/s11222-019-09861-5. `[PDF NOT STORED]`. Required for part B. Whitaker et al. (2025), p. 25, name it as work that could be adapted. Lowe et al. (2023), pp. 9–10, give a secondary account and attribute the derivation of their propagation identities to this paper. That account is not a substitute.
- Corstanje, M., van der Meulen, F. and Schauer, M. (2023). "Conditioning continuous-time Markov processes by guiding." *Stochastics* 95(6), 963–996. DOI 10.1080/17442508.2022.2150081. `[PDF NOT STORED]`. Required for part B, by the same sentence on p. 25. No opened paper states their algorithm. Nothing in this note describes it.
- Golightly, A. and Wilkinson, D. J. (2015). "Bayesian inference for Markov jump processes with informative observations." *Statistical Applications in Genetics and Molecular Biology* 14(2), 169–188. DOI 10.1515/sagmb-2014-0070. `[PDF NOT STORED]`. Whitaker et al. (2025), pp. 2–3 and p. 24, say their bridge adapts this hazard. Until the PDF is stored, the only usable derivation is Section 3.4 of the 2025 paper.

Cited beside the bridge, and not the replacement:

- Golightly and Kypraios (2018), named with "see also" on pp. 2–3 of Whitaker et al. (2025). The 2025 reference list gives *Statistics and Computing* 28(6), 1215–1230, DOI 10.1007/s11222-017-9789-8. `[PDF NOT STORED]`.
- Whitaker et al. (2025) supplement, DOI 10.1214/25-BA1547SUPP. `[PDF NOT STORED]`. The main text, p. 26, says it contains further synthetic experiments and linear-noise details for the Ebola comparison.

Named in the opened pages of Lowe et al. (2023) or Jovanovski et al. (2024), and not required to restate the 2025 guide:

- Durham and Gallant (2002), the modified diffusion bridge. `[PDF NOT STORED]`.
- Whitaker, Golightly, Boys and Sherlock (2017), the residual bridge and the version of that diffusion bridge used by Jovanovski et al. `[PDF NOT STORED]`. The 2023 and 2024 reference lists were not copied out in full; the titles were not re-derived here.
- Fearnhead, Giagos and Sherlock (2014), cited by Lowe et al. for reinitialising the linear noise approximation. `[PDF NOT STORED]`.

## Comparison

A cell is filled only from a page that was read. "Secondary" means the sentence sits in Lowe et al. (2023) and points at a paper that was not opened.

| Guide | What is propagated | What the proposal conditions on | Importance weight corrects the proposal? | Source used |
| --- | --- | --- | --- | --- |
| Whitaker et al. (2025), display after (18) | Poisson incidence increments of dS(E)IR on the subgrid, with rate \(h^{*}\Delta\tau\) | The next incidence observation, through a Gaussian approximation of remaining incidence and of that observation | Yes, as printed in Algorithm 2, step 2. The ratio uses the dSEIR transition and the observation mass function over \(q\) | Section 3.4 and Algorithm 2, read |
| Lowe et al. (2023), Section 4.2.3, jump-process hazard | A Markov jump process, by Gillespie's method with the conditioned hazard | The observation at the end of the interval, through a ratio of observation densities, with the density replaced by a linear-noise Gaussian | The surrounding scheme is particle MCMC. Whether the bridge density enters an importance weight was not checked beyond the statement that \(q\) is the complete-data likelihood with the conditioned hazard | pp. 9–10, read. The 2019 derivation is secondary |
| Lowe et al. (2023), residual bridge | A discretised chemical Langevin equation | The next observation, after a residual partition | `[NOT READ]` beyond the existence of the construct | Named on p. 10. Whitaker et al. (2017) not opened |
| Modified diffusion bridge of Durham and Gallant | `[PDF NOT STORED]` | Lowe et al., p. 13, say it pushes particles towards the observations in a linear fashion, and that nonlinear behaviour between observations precludes it | `[PDF NOT STORED]` | Durham and Gallant (2002) not stored. The preclusion sentence was read in Lowe et al. |
| Jovanovski et al. (2024) data-conditional simulation | `[NOT READ]`. The abstract and Section 8 describe forward and backward simulation of a diffusion | The observed diffusion path, in the sense of the discussion on pp. 25–26 | The sampler is ABC, not an importance correction of a dSEIR proposal | Section 8 read. The algorithm was not |
| Golightly and Wilkinson (2015) | `[PDF NOT STORED]` | `[PDF NOT STORED]` | `[PDF NOT STORED]` | Named by Whitaker et al. (2025), pp. 2–3 and p. 24 |
| Golightly and Sherlock (2019) | `[PDF NOT STORED]` | `[PDF NOT STORED]` at the source. The secondary account is the Lowe row above | `[PDF NOT STORED]` | Named by Whitaker et al. (2025), p. 25 |
| Corstanje, van der Meulen and Schauer (2023) | `[PDF NOT STORED]` | `[PDF NOT STORED]` | `[PDF NOT STORED]` | Named by Whitaker et al. (2025), p. 25 |

## What phase 4 is not allowed to treat as settled

- No opened paper states a numerical spacing at which the 2025 guide fails.
- No opened paper shows that a bad \(h^{*}\) changes the target of Algorithm 2 rather than the quality of the proposal. The weight is printed; the implication is not.
- No replacement proposal has been read at its source. The Lowe account of the 2019 hazard is a pointer, not an implementation.
