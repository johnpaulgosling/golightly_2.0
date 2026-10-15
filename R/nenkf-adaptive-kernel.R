# Algorithm: pre-proposal choice between Metropolis-Hastings and delayed acceptance
# Source: notes/05-theory-notes.md, Section 5.4.
#         The kernels themselves are Algorithm B and Algorithm C of that note,
#         from Source papers/5417950VOR.pdf, Algorithm 6 and Section 4.2.
# Symbols:
#   t            observation time index          t
#   t_switch     last time at which plain MH    t_switch
#                is used

# The choice depends only on t. It is made before the proposal.
# notes/06-simulation-design.md sets t_switch = 8 for the pilot (T = 16).
choose_move_kernel <- function(t, t_switch) {
  # plain Metropolis-Hastings while the series so far is short
  if (t <= t_switch) {
    "mh"
  } else {
    "da"
  }
}
