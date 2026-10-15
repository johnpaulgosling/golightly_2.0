# Search log

Date of the searches: 15 October 2026. The searches were web searches. A paper was filed only when it changed the theory agenda for at least one of E1 to E6. Papers already summarised in `notes/02-literature-summary.md` were not filed again.

## Gap 1. Nearest-neighbour screens inside SMC2 or an ensemble Kalman likelihood

Query: KD-tree nearest neighbour delayed acceptance SMC2 ensemble Kalman likelihood Sherlock Golightly.

What was opened: the arXiv HTML for Sherlock, Golightly and Henderson (arXiv:1509.00172), already filed; the arXiv HTML and a text extract of Golightly et al. (arXiv:2511.21497), which is the 2026 paper already read as `Source papers/5417950VOR.pdf`; the arXiv HTML for Golightly, Henderson and Sherlock on efficient SMC2 for stochastic kinetic models (arXiv:1704.02791). That last paper is SMC2 with a particle filter and a resample-move. It does not put a KD-tree inside the move.

Filed: nothing new. The 2026 paper itself is the implementation that puts the nearest-neighbour screen inside the nested ensemble Kalman filter. No other implementation was found.

## Gap 2. Gradients of an ensemble Kalman likelihood

Query: differentiable ensemble Kalman filter likelihood gradient Chen Adams Zemel autodiff. The query used a wrong author list. The paper that the results returned is Chen, Sanz-Alonso and Willett.

What was opened: arXiv:2107.07687 and a text extract of the SIAM Journal on Mathematics of Data Science version. The stored file is the arXiv preprint. A reduced-order follow-up was visible only as a search snippet and was not opened.

Filed: `Literature/Chen2022-autodifferentiable-enkf.pdf`. It changes E3. The summary block says how.

A second query for ensemble sensitivity analysis, beyond this paper, was not run. It is listed under Saturation as a search that was not done.

## Gap 3. Surrogate weights inside SMC

Query: surrogate likelihood weights SMC2 bias nearest neighbour Bon Lee Drovandi.

What was opened: arXiv:2009.03699 and the *Statistics and Computing* record for Bon, Lee and Drovandi (2021). The stored file is the arXiv preprint. The paper uses the surrogate as a screen and calibrates it from full-likelihood evaluations. It does not replace the incremental weight.

Filed: `Literature/Bon2021-smc-surrogate-likelihoods.pdf`. It changes E4, by tightening the constraint: the published SMC surrogate keeps the expensive likelihood as the target. No theorem was seen that bounds the distance from a nearest-neighbour weight to the ensemble Kalman posterior.

A further query for an SMC2 algorithm weighted by a nearest-neighbour likelihood returned the 2026 paper and Bon et al. again. Nothing further was filed.

## Gap 4. Cost against parameter dimension and observation dimension

Query: ensemble MCMC EnKF likelihood variance observation dimension parameter dimension Drovandi Katzfuss.

What was opened: the project Euclid record and a Warwick author manuscript of Drovandi et al. (2022), already filed as `Literature/ensemble.pdf`; an author PDF of Katzfuss, Stroud and Wikle linked from a Georgetown page. That PDF is the same review as arXiv:1704.06988, already filed. The variance statement found there is Proposition 2, already summarised. No additional paper reported a grid of static-parameter dimension against observation dimension for a nested ensemble Kalman filter.

Filed: nothing new.

## Gap 5. Work that cites Golightly et al. (2026) or Temfack and Wyse

Query: Golightly Heaps Sherlock Wadkin Wilkinson nested ensemble Kalman filter 2026 citations.

What was opened: the *Statistics and Computing* record (doi:10.1007/s11222-026-10899-5), which reported no citing documents in the snippet returned, and arXiv:2511.21497. No follow-up extension was found.

Second query: Temfack Wyse ensemble SMC2 epidemic EnKF citations 2025 2026.

What was opened: the record for Temfack and Wyse, *Epidemics* (2025), on an online SMC2 window, and the *PLOS Computational Biology* record for the ensemble SMC2 paper already summarised from arXiv:2512.05650v4. The 2025 *Epidemics* paper uses a particle Metropolis–Hastings kernel on a recent window of observations. It does not add a delayed-acceptance screen, a tree, a gradient move, or a surrogate weight. It was not filed, because it does not change E1 to E6. No paper was found that extends the 2026 nested filter.

Filed: nothing new.

## Saturation

Queries run: the five numbered gaps, with a second query on gaps 2 (author correction, same paper), 3 (nearest-neighbour SMC2 weights) and 5 (Temfack and Wyse).

Papers added to `Literature/` and to `notes/02-literature-summary.md`: Katzfuss, Stroud and Wikle (arXiv:1704.06988v2); Fearnhead and Taylor (arXiv:1005.1193v2); Botha, Kohn, South and Drovandi (arXiv:2307.11553v1); Christen and Fox (author preprint); Sherlock, Thiery and Golightly (arXiv:1506.08155v3); Liu and West (author PDF); Chen, Sanz-Alonso and Willett (arXiv:2107.07687v2); Bon, Lee and Drovandi (arXiv:2009.03699v2).

Gaps that remain empty:

- Gap 1. No KD-tree inside SMC2 or an ensemble Kalman likelihood, other than the list search in Golightly et al. (2026) and the batch MCMC tree in Sherlock, Golightly and Henderson.
- Gap 3, the bound. No theorem was found that bounds the distance between a nearest-neighbour weight and the ensemble Kalman posterior.
- Gap 5. No published extension of Golightly et al. (2026) was found.

Searches that were not run, and that would have been next: ensemble sensitivity analysis as a score, if a free PDF exists; local likelihood approximations inside delayed acceptance other than Bon et al. and Sherlock, Golightly and Henderson. The five gaps have each been searched, and the new papers have been summarised, so the search stops here.
