# Algorithm: k nearest neighbours by a linear scan and by a KD-tree
# Source: Source papers/5417950VOR.pdf, Section 4.2, the inverse-distance
#         surrogate. The tree operations follow the cost discussion in
#         Literature/1509.00172v2.pdf, Section 2, as used in
#         notes/05-theory-notes.md, Section 5.3.
#         An exact tree is used. Approximate neighbours are not implemented.
# Symbols:
#   theta^{[i]}   stored parameter            points, rows
#   d_{[i]}       distance to neighbour i     dist
#   k             neighbour count             k

# Euclidean distance. One evaluation, counted by the caller.
knn_distance <- function(a, b) {
  # d(a, b) = ||a - b||
  sqrt(sum((a - b)^2))
}

# Linear scan. Section 4.2 does not name the search. This is the list.
knn_linear <- function(query, points, k) {
  n <- nrow(points)
  d <- numeric(n)
  # Step. Distance to every stored point. Cost O(n).
  for (i in 1:n) {
    d[i] <- knn_distance(query, points[i, ])
  }
  ord <- order(d)
  list(index = ord[seq_len(k)], dist = d[ord[seq_len(k)]], n_dist = n)
}

# Build a balanced axis-cycling tree. Median split.
# points: n x d matrix. Returns a nested list.
knn_tree_build <- function(index, points, depth) {
  if (length(index) == 0) {
    return(NULL)
  }
  d <- ncol(points)
  if (length(index) == 1) {
    # a single stored point is a leaf
    return(list(at = index, axis = (depth %% d) + 1, left = NULL, right = NULL))
  }
  axis <- (depth %% d) + 1
  # leaf median on this axis, as a balance rule
  coord <- points[index, axis]
  med <- median(coord)
  # tie: take the first index at the median
  at <- index[which(coord == med)[1]]
  if (is.na(at)) {
    at <- index[which.min(abs(coord - med))]
  }
  left_index <- index[coord < points[at, axis]]
  right_index <- index[coord > points[at, axis]]
  # remaining ties other than `at` go right
  ties <- index[coord == points[at, axis]]
  ties <- ties[ties != at]
  right_index <- c(right_index, ties)
  list(
    at = at,
    axis = axis,
    left = knn_tree_build(left_index, points, depth + 1),
    right = knn_tree_build(right_index, points, depth + 1)
  )
}

# Exact k nearest neighbours. Prune a branch only when k neighbours are
# already stored and the axis gap exceeds the current k-th distance.
knn_tree_search <- function(node, query, points, k, best) {
  if (is.null(node)) {
    return(best)
  }
  # distance to the point stored at this node
  dist_here <- knn_distance(query, points[node$at, ])
  best$n_dist <- best$n_dist + 1
  best$index <- c(best$index, node$at)
  best$dist <- c(best$dist, dist_here)
  if (length(best$dist) > k) {
    ord <- order(best$dist)[seq_len(k)]
    best$index <- best$index[ord]
    best$dist <- best$dist[ord]
  }
  axis <- node$axis
  gap <- query[axis] - points[node$at, axis]
  if (gap < 0) {
    near <- node$left
    far <- node$right
  } else {
    near <- node$right
    far <- node$left
  }
  best <- knn_tree_search(near, query, points, k, best)
  kth <- if (length(best$dist) < k) Inf else max(best$dist)
  # visit the far side only if the query ball reaches it
  if (abs(gap) <= kth) {
    best <- knn_tree_search(far, query, points, k, best)
  }
  best
}

knn_tree <- function(query, points, k) {
  n <- nrow(points)
  tree <- knn_tree_build(seq_len(n), points, depth = 0)
  best <- knn_tree_search(
    tree, query, points, k,
    best = list(index = integer(0), dist = numeric(0), n_dist = 0)
  )
  ord <- order(best$dist)
  list(index = best$index[ord], dist = best$dist[ord], n_dist = best$n_dist)
}

# Inverse-distance log-likelihood, Section 4.2.
# If a neighbour sits at distance 0, the surrogate equals that stored value.
knn_surrogate_log <- function(dist, stored_log) {
  if (any(dist == 0)) {
    # log hat p_knn = log hat p_enkf at the coincident neighbour
    return(stored_log[which(dist == 0)[1]])
  }
  w <- 1 / dist
  # weighted average of stored log ensemble Kalman likelihoods
  sum(w * stored_log) / sum(w)
}

# Standardise columns by their standard deviations. A zero standard
# deviation is left unscaled. Metric chosen in the design note.
knn_standardise <- function(points) {
  s <- apply(points, 2, stats::sd)
  s[s == 0 | is.na(s)] <- 1
  list(scaled = sweep(points, 2, s, "/"), scale = s)
}
