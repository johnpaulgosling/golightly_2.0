# Application choice

The simulations in `notes/06-simulation-findings.md` already compare cost and posterior error on a model whose likelihood is known. A real series is useful here only if it changes that conclusion.

## Oak processionary moth

Section 5.3 of Golightly et al. (2026) is a single real removals series. The extensions that survived the pilot change the cost of rejuvenation, the incremental weight, or the Rao-Blackwellised correction. Those comparisons were already made on the Ornstein–Uhlenbeck pilot, where a gold-standard mean exists. The moth series has no gold-standard MCMC in the 2026 paper. Re-running it would not add a comparison the pilot cannot make, and the pilot was not the published moth setting.

## Ebola and COVID-19 incidence

Whitaker, Golightly, Gillespie and Kypraios, Sections 4.2 and 4.3 of `Source papers/4992336VoR.pdf`, use weekly incidence: 53 observations from Sierra Leone and 25 from New York. The observation is a count, through a binomial or negative binomial model, not a vector with observation dimension above 10. The New York analysis gives the contact rate and the reporting rate their own latent paths. That is outside the static low-dimensional parameter and high-dimensional observation regime in the scaling account.

## Decision

No new data set. The manuscript has no application section. This decline is the outcome of the task.
