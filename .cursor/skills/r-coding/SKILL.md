---
name: r-coding
description: "Implements algorithms in base R and comments each block so it maps to the algorithm step, equation, or source section it realises. Prefer a direct, readable translation over a faster or more compact rewrite, and do not add packages when base R will do. Use before any R is written or changed in this repository, including scripts, functions, simulations, MCMC, particle filters, ensemble Kalman filters, ABC, stochastic kinetic models, epidemic models, SDEs, and state-space models, even when no .R file exists yet."
---

# R coding

Computational work in this repository is R that a reader can line up against an algorithm. Read this skill before you create, edit, review, or debug R. Follow it even when a general habit says to write less commentary, use a package, or tighten a loop.

## Before you write

1. Name the algorithm in the user's words.
2. If the work comes from a paper in this repository, open `references/source-papers.md`, then open the cited PDF and the section that states the algorithm. Cite only a section, algorithm number, or equation you have actually read. Do not invent numbering from the title.
3. If no source has been identified, follow the user's own steps and write `Source: as specified in the request` in the file header. Do not invent a paper citation.
4. Start a new algorithm file from `assets/algorithm-template.R`.

A reader who hides the code should still be able to recover the algorithm from the comments.

## Language

Write the implementation in R. Keep scripts, functions, and numerical experiments in R.

## Packages

Stay inside the packages that ship with R and load with it:

`base`, `stats`, `graphics`, `grDevices`, `utils`, `methods`, `grid`, `splines`, `parallel`, `stats4`.

Do not attach or install anything else on your own initiative. That includes tidyverse packages, `data.table`, `purrr`, `ggplot2`, `MASS`, `Matrix`, `coda`, and `Rcpp`.

Write the step in base R when it is a direct translation of the algorithm, including when a package would make the file shorter.

Ask before adding a package. In that question, name the package and the algorithm step that base R cannot express. One agreed dependency is the limit unless the user asks for more. Do not add a `DESCRIPTION`, `renv` lockfile, or package scaffold unless the user asks.

## Shape of the code

Translate the algorithm in the order it is written.

Give each named quantity its own line. Use the algorithm's names for R objects when those names stay readable (`theta`, `log_w`, `x_t`). Put any rename in the symbol table at the top of the file.

Use an explicit `for` or `while` loop when the algorithm iterates over time, particles, proposals, or observations. Use `<-` for assignment.

R indexes from 1. When the algorithm indexes from 0, or uses a time index t = 0, comment the correspondence at the loop.

A slower file that matches the algorithm is the version to keep. Do not replace it with a vectorised form, a matrix form, `apply`, or `vapply` unless the algorithm is already written that way, or the user asks for a faster version. If you add a faster version, leave the direct version in place and comment that the direct version is the reference translation.

Numerical stability is a different question from speed. When a direct evaluation would overflow or underflow, compute the same quantity in a stable form. The comment must show the algorithm's expression and the stable form. Do that for log acceptance probabilities, log weights, and log-sum-exp normalising constants. Do not use stability as a reason to restructure the surrounding algorithm.

Do not profile, byte-compile, or move code to C++ as part of implementing an algorithm.

Set a seed only in a script that runs a study, and comment that the seed is not part of the algorithm. Algorithm functions take their inputs as arguments and return the quantities the algorithm defines, usually as a named `list`.

## Comments

Comments are part of the implementation. They are how the code stays tied to an algorithm the author developed. Keep them when you edit. Update them when the line they describe changes. Do not strip them to shorten a diff.

Every algorithm file starts with the header from `assets/algorithm-template.R`:

- the algorithm name
- the source: PDF filename under `Source papers/`, plus the section, algorithm number, and equation numbers you used, or `as specified in the request`
- a symbol table with the algorithm symbol, the R name, and a short meaning

Before each block, give the step number and restate the update in the algorithm's notation.

On each line that computes a named quantity, comment the symbol and the equation or draw it implements. A comment that only repeats the R is not enough.

Write the algorithmic intent. State the distribution, the acceptance rule, the weight update, or the recursion the line is carrying out.

## Where files go

- Algorithm functions: `R/<algorithm-name>.R`
- Scripts that run a study: `scripts/<study-name>.R`
- Source papers: `Source papers/`

Name files in lowercase with hyphens. A script sources function files from the repository root and calls them. It does not reimplement the algorithm inline.

Match this layout once files exist. If an existing file uses a different arrangement, follow that file and keep its algorithm comments.

## Example

The fragment below is the comment pattern, not an algorithm from the papers. Copy the pattern. Replace the steps with the algorithm you are implementing.

```r
# Algorithm: Random-walk Metropolis-Hastings, one iteration
# Source: as specified in the request (illustration only)
# Symbols:
#   theta      current parameter          theta
#   theta'     proposal                   theta_prop
#   alpha      acceptance probability     alpha

rwmh_step <- function(theta, log_target, proposal_sd) {
  # Step 1. Draw the proposal from the random-walk kernel.
  # theta' = theta + sd * Z, Z ~ N(0, 1)
  theta_prop <- theta + proposal_sd * rnorm(1)

  # Step 2. Log acceptance probability.
  # The random-walk proposal is symmetric, so the kernel ratio is 1.
  # log alpha = log pi(theta') - log pi(theta)
  log_alpha <- log_target(theta_prop) - log_target(theta)

  # Step 3. Accept or reject.
  # Draw u ~ Uniform(0, 1) and accept when log u < log alpha.
  # Compare in the log domain so a tiny alpha does not underflow.
  if (log(runif(1)) < log_alpha) {
    theta <- theta_prop
  }

  # Step 4. Return the parameter after this iteration.
  theta
}
```
