#' pointcoral: Point-Count Processing for Coral Photoquadrats
#'
#' Imports Coral Point Count with Excel extensions (CPCe) point annotations,
#' matches them to local photoquadrat images, validates labels and coordinates,
#' and computes point-count percent-cover summaries. Optional crosswalks map
#' project-specific CPCe codes to full labels, ecological categories, and
#' machine-learning classes. Quality-control overlays, point-centered patches,
#' sparse weak-label masks, and leakage-aware dataset splits support review and
#' downstream local model development.
#'
#' The package preserves original CPCe labels and coordinates. Users remain
#' responsible for verifying CPCe file variants, image matching, coordinate
#' conversion, crosswalk semantics, sampling design, and the interpretation of
#' point-count estimates. Sparse masks label only neighborhoods around sampled
#' points and are not dense benthic annotations.
#'
#' @keywords internal
#' @importFrom rlang .data
"_PACKAGE"
