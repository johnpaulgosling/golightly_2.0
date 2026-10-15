# Algorithm: nearest-neighbour prediction of an ensemble Kalman log-likelihood
# Source: notes/05-theory-notes.md, Section 5.2, and
#         Source papers/5417950VOR.pdf, Section 4.2, the inverse-distance average.
# Symbols:
#   ell_knn     surrogate log-likelihood     surr
#   k           neighbour count              k

# Standardise the reference log-parameters, then take the inverse-distance
# average of the stored log-likelihoods. Used for an increment or for a
# cumulative likelihood. The query is not required to be in the reference set.
surrogate_loglik <- function(log_theta_query, log_theta_ref, stored_log) {
  k <- nrow(log_theta_ref)
  scaled <- knn_standardise(log_theta_ref)
  # query on the same scale
  query <- log_theta_query / scaled$scale
  fit <- knn_linear(query, scaled$scaled, k)
  # Section 4.2 weighted average. Here k is the whole reference set when
  # the reference set has size k, so the neighbours are all reference points.
  knn_surrogate_log(fit$dist, stored_log[fit$index])
}
