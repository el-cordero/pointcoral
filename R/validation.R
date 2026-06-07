#' Validate a point table
#'
#' Checks required fields, missing coordinates, duplicated point IDs within
#' images, coordinates outside image bounds, missing image files, and missing
#' image dimensions.
#'
#' @param points A tidy point table.
#'
#' @return A validation report tibble.
#' @export
validate_points <- function(points) {
  points <- tibble::as_tibble(points)

  report <- list()

  add_issue <- function(check, severity, n, details) {
    tibble::tibble(
      check = check,
      severity = severity,
      n = as.integer(n),
      details = details
    )
  }

  required <- c("image_id", "point_id", "raw_label")
  missing_required <- setdiff(required, names(points))
  if (length(missing_required) > 0L) {
    report <- c(report, list(add_issue(
      "required_fields", "error", length(missing_required),
      paste(missing_required, collapse = ", ")
    )))
  }

  if ("raw_label" %in% names(points)) {
    missing_labels <- points |>
      dplyr::filter(is.na(.data$raw_label) | .data$raw_label == "")
    if (nrow(missing_labels) > 0L) {
      report <- c(report, list(add_issue(
        "missing_raw_labels", "warning", nrow(missing_labels),
        "Rows with missing raw_label values"
      )))
    }
  }

  coord_cols <- intersect(c("cpce_x", "cpce_y", "x_px", "y_px"), names(points))
  if (length(coord_cols) == 0L) {
    report <- c(report, list(add_issue(
      "missing_coordinates", "error", nrow(points),
      "No CPCe or image coordinate columns found"
    )))
  } else {
    missing_cpce <- if (all(c("cpce_x", "cpce_y") %in% names(points))) {
      is.na(points$cpce_x) | is.na(points$cpce_y)
    } else {
      rep(TRUE, nrow(points))
    }
    missing_pixel <- if (all(c("x_px", "y_px") %in% names(points))) {
      is.na(points$x_px) | is.na(points$y_px)
    } else {
      rep(TRUE, nrow(points))
    }
    missing_coords <- points[missing_cpce & missing_pixel, , drop = FALSE]
    if (nrow(missing_coords) > 0L) {
      report <- c(report, list(add_issue(
        "missing_coordinates", "warning", nrow(missing_coords),
        "Rows missing both CPCe and image pixel coordinate pairs"
      )))
    }
  }

  if (all(c("image_id", "point_id") %in% names(points))) {
    dup <- points |>
      dplyr::count(.data$image_id, .data$point_id, name = "n") |>
      dplyr::filter(.data$n > 1)
    if (nrow(dup) > 0L) {
      report <- c(report, list(add_issue(
        "duplicate_point_ids", "warning", nrow(dup),
        "Duplicated point_id values within image_id"
      )))
    }
  }

  if (all(c("x_px", "y_px", "image_width", "image_height") %in% names(points))) {
    outside <- points |>
      dplyr::filter(
        !is.na(.data$x_px), !is.na(.data$y_px),
        !is.na(.data$image_width), !is.na(.data$image_height),
        .data$x_px < 1 |
          .data$y_px < 1 |
          .data$x_px > .data$image_width |
          .data$y_px > .data$image_height
      )
    if (nrow(outside) > 0L) {
      report <- c(report, list(add_issue(
        "coordinates_outside_image", "warning", nrow(outside),
        "Pixel coordinates outside image bounds"
      )))
    }
  }

  if ("image_path" %in% names(points)) {
    missing_paths <- points |>
      dplyr::filter(!is.na(.data$image_path), !file.exists(.data$image_path)) |>
      dplyr::distinct(.data$image_path)
    if (nrow(missing_paths) > 0L) {
      report <- c(report, list(add_issue(
        "missing_image_files", "warning", nrow(missing_paths),
        paste(utils::head(missing_paths$image_path, 10), collapse = "; ")
      )))
    }
  }

  if (all(c("image_path", "image_width", "image_height") %in% names(points))) {
    missing_dims <- points |>
      dplyr::filter(!is.na(.data$image_path), is.na(.data$image_width) | is.na(.data$image_height)) |>
      dplyr::distinct(.data$image_path)
    if (nrow(missing_dims) > 0L) {
      report <- c(report, list(add_issue(
        "missing_image_dimensions", "warning", nrow(missing_dims),
        "Image paths are present but dimensions are missing"
      )))
    }
  }

  if (length(report) == 0L) {
    return(add_issue("ok", "info", 0L, "No validation issues detected"))
  }

  dplyr::bind_rows(report)
}

#' Summarize point-label QC issues
#'
#' Reports unmapped labels, rare labels, duplicate points, and class balance in a
#' compact tibble.
#'
#' @param points A tidy point table.
#' @param label_col Label column to summarize.
#' @param rare_threshold Count at or below which labels are flagged as rare.
#'
#' @return A QC summary tibble.
#' @export
qc_label_summary <- function(points, label_col = "ml_class", rare_threshold = 1L) {
  points <- tibble::as_tibble(points)
  if (!label_col %in% names(points)) {
    cli::cli_abort("{.arg points} does not contain label column {.field {label_col}}.")
  }
  if (!"raw_label" %in% names(points)) points$raw_label <- NA_character_
  if (!"raw_code" %in% names(points)) points$raw_code <- NA_character_

  class_balance <- points |>
    dplyr::count(label = .data[[label_col]], name = "n") |>
    dplyr::mutate(summary_type = "class_balance", details = "Point count by label")

  rare <- class_balance |>
    dplyr::filter(!is.na(.data$label), .data$n <= rare_threshold) |>
    dplyr::mutate(summary_type = "rare_label", details = "Rare label count")

  unmapped <- points |>
    dplyr::mutate(.pc_missing_class_id = if ("class_id" %in% names(points)) is.na(.data$class_id) else FALSE) |>
    dplyr::filter(is.na(.data[[label_col]]) | .data[[label_col]] == "" | .data$.pc_missing_class_id) |>
    dplyr::count(label = dplyr::coalesce(.data$raw_label, .data$raw_code), name = "n") |>
    dplyr::mutate(summary_type = "unmapped_label", details = "Missing class label or class_id")

  duplicates <- if (all(c("image_id", "point_id") %in% names(points))) {
    points |>
      dplyr::count(.data$image_id, .data$point_id, name = "n") |>
      dplyr::filter(.data$n > 1) |>
      dplyr::transmute(
        label = paste(.data$image_id, .data$point_id, sep = ":"),
        n = .data$n,
        summary_type = "duplicate_point",
        details = "Duplicated point_id within image_id"
      )
  } else {
    tibble::tibble(label = character(), n = integer(), summary_type = character(), details = character())
  }

  dplyr::bind_rows(class_balance, rare, unmapped, duplicates) |>
    dplyr::select(.data$summary_type, .data$label, .data$n, .data$details) |>
    dplyr::arrange(.data$summary_type, dplyr::desc(.data$n), .data$label)
}
