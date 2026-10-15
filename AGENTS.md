# Agent instructions

## Prose

- Before drafting or editing any prose, read `STYLE.md`. It sets the writing style, derived from the papers in `Source papers/`.
- British English spellings are mandatory (for example *summarise*, *behaviour*, *modelling*). Never use em dashes.
- Run `scripts/check_british_spelling.sh` on text you write and fix what it flags, other than the exceptions listed in `STYLE.md` section 2.3.
- The target venue is the Journal of Computational and Graphical Statistics, which asks for American spelling at submission. Write British English by default and convert only when the user asks for a submission-ready version (`STYLE.md` section 12.1). Use "we" as the default voice. Scope is research papers only.
- Do not invent citations, results or numbers. Mark gaps with `[CITATION NEEDED]` and tell the user.

## R code

Computational work in this repository is R. Before you create, edit, review, or debug any R, read `.cursor/skills/r-coding/SKILL.md` and follow that skill.

- Write implementations in base R. Do not add a package on your own initiative.
- Comment each step so it maps to the algorithm: step number, equation or draw, and the source you actually used.
- Prefer a direct translation of the algorithm. A slower, explicit version is the one to keep.
- Keep those comments when you edit them. They link the code to the algorithm.

The skill's `references/source-papers.md` lists the papers in `Source papers/`. Its `assets/algorithm-template.R` is the starting point for a new algorithm file.
