#' Summarize point counts and percent cover
#'
#' Counts point labels by grouping variables and returns percent cover within
#' each group.
#'
#' @param points A tidy point table.
#' @param by Grouping columns.
#' @param class_col Class/label column to summarize.
#'
#' @return A summary tibble with `n`, `n_points`, and `percent`.
#' @export
summarize_points <- function(points,
                             by = c("site", "transect", "image_id"),
                             class_col = "major_category") {
  points <- tibble::as_tibble(points)
  pc_require_columns(points, class_col, "points")
  by <- pc_available_columns(points, by)

  if (length(by) == 0L) {
    by <- character()
  }

  group_cols <- c(by, class_col)

  counts <- points |>
    dplyr::filter(!is.na(.data[[class_col]]), .data[[class_col]] != "") |>
    dplyr::count(dplyr::across(dplyr::all_of(group_cols)), name = "n")

  totals <- points |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::summarise(n_points = dplyr::n(), .groups = "drop")

  if (length(by) == 0L) {
    counts$n_points <- nrow(points)
  } else {
    counts <- counts |>
      dplyr::left_join(totals, by = by)
  }

  counts |>
    dplyr::mutate(percent = .data$n / .data$n_points * 100) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(by)), .data[[class_col]])
}

#' Summarize points at image level
#'
#' @param points A tidy point table.
#' @param class_col Class/label column to summarize.
#'
#' @return An image-level summary tibble.
#' @export
summarize_images <- function(points, class_col = "major_category") {
  summarize_points(points, by = c("site", "transect", "image_id"), class_col = class_col)
}

#' Summarize points at transect level
#'
#' @param points A tidy point table.
#' @param class_col Class/label column to summarize.
#'
#' @return A transect-level summary tibble.
#' @export
summarize_transects <- function(points, class_col = "major_category") {
  summarize_points(points, by = c("site", "transect"), class_col = class_col)
}

#' Summarize points at site level
#'
#' @param points A tidy point table.
#' @param class_col Class/label column to summarize.
#'
#' @return A site-level summary tibble.
#' @export
summarize_sites <- function(points, class_col = "major_category") {
  summarize_points(points, by = "site", class_col = class_col)
}

#' Write ecological summary tables
#'
#' Writes image-, transect-, and site-level summaries for one or more class
#' columns, plus a class lookup table when possible.
#'
#' @param points A tidy point table.
#' @param out_dir Output directory for summary CSV files.
#' @param class_cols Class columns to summarize.
#'
#' @return A named list of written file paths.
#' @export
write_summary_tables <- function(points,
                                 out_dir,
                                 class_cols = c("major_category", "clean_label", "ml_class")) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  points <- tibble::as_tibble(points)
  class_cols <- intersect(class_cols, names(points))

  if (length(class_cols) == 0L) {
    cli::cli_abort("None of {.arg class_cols} were present in {.arg points}.")
  }

  paths <- list()

  for (i in seq_along(class_cols)) {
    class_col <- class_cols[i]
    suffix <- if (i == 1L) "" else paste0("_", pc_safe_slug(class_col))

    image_summary <- summarize_images(points, class_col = class_col)
    transect_summary <- summarize_transects(points, class_col = class_col)
    site_summary <- summarize_sites(points, class_col = class_col)

    image_path <- file.path(out_dir, paste0("image_summary", suffix, ".csv"))
    transect_path <- file.path(out_dir, paste0("transect_summary", suffix, ".csv"))
    site_path <- file.path(out_dir, paste0("site_summary", suffix, ".csv"))

    readr::write_csv(image_summary, image_path)
    readr::write_csv(transect_summary, transect_path)
    readr::write_csv(site_summary, site_path)

    paths[[paste0("image_summary", suffix)]] <- image_path
    paths[[paste0("transect_summary", suffix)]] <- transect_path
    paths[[paste0("site_summary", suffix)]] <- site_path
  }

  if ("ml_class" %in% names(points)) {
    lookup <- make_class_lookup(points, class_col = "ml_class", id_col = "class_id")
    lookup_path <- file.path(out_dir, "class_lookup.csv")
    readr::write_csv(lookup, lookup_path)
    paths$class_lookup <- lookup_path
  }

  paths
}
