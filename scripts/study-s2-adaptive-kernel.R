# Study S2. Plain Metropolis-Hastings, delayed acceptance, and the time switch.
# The seed is set in scripts/ou-pilot-run.R and is not part of the algorithm.
# S1 is written by the same call because the neighbour counts come from the
# delayed-acceptance rows. Settings: Kalman extensions/notes/06-simulation-design.md.
source("scripts/ou-pilot-run.R")
run_s1_s2()
