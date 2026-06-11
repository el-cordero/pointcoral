#' Read a label crosswalk
#'
#' Reads a CSV, TSV, XLS, or XLSX crosswalk table, cleans column names, recognizes
#' common synonyms, and validates that the table contains at least one raw
#' label/code key and at least one output class field.
#'
#' @param path Path to a crosswalk file.
#'
#' @return A tidy crosswalk tibble.
#' @export
#'
#' @examples
#' xwalk <- system.file(
#'   "extdata", "pointcoral_example_crosswalk.csv",
#'   package = "pointcoral"
#' )
#' read_label_crosswalk(xwalk)
read_label_crosswalk <- function(path) {
  crosswalk <- pc_read_table(path, na = c("", "N/A", "#N/A"))

  copy_first <- function(df, target, candidates) {
    if (target %in% names(df)) {
      return(df)
    }
    hit <- intersect(candidates, names(df))
    if (length(hit) > 0) {
      df[[target]] <- df[[hit[1]]]
    }
    df
  }

  crosswalk <- crosswalk |>
    copy_first("raw_code", c("cpce_code", "label_code", "code")) |>
    copy_first("raw_label", c("cpce_label", "label", "label_original")) |>
    copy_first("full_label", c("species", "species_or_type", "full_name", "taxon", "label_full")) |>
    copy_first("clean_label", c("full_label", "label_clean", "cleaned_label", "standard_label")) |>
    copy_first("label_class", c("subcategory_type", "subclass", "class_type")) |>
    copy_first("major_category", c("major_class", "level1_class", "benthic_category")) |>
    copy_first("ml_class", c("machine_learning_class", "model_class", "class_name")) |>
    copy_first("include_in_analysis", c("keep", "include", "analysis_include")) |>
    copy_first("include_in_ml", c("ml_include", "training_include"))

  if (!"ml_class" %in% names(crosswalk) && "major_category" %in% names(crosswalk)) {
    crosswalk$ml_class <- crosswalk$major_category
  }
  if (!"full_label" %in% names(crosswalk) && "clean_label" %in% names(crosswalk)) {
    crosswalk$full_label <- crosswalk$clean_label
  }
  if (!"clean_label" %in% names(crosswalk) && "full_label" %in% names(crosswalk)) {
    crosswalk$clean_label <- crosswalk$full_label
  }

  raw_cols <- intersect(c("raw_code", "raw_label"), names(crosswalk))
  if (length(raw_cols) == 0L) {
    cli::cli_abort(c(
      "Crosswalk must contain at least one raw CPCe key column.",
      "i" = "Supported key columns include {.field raw_code} and {.field raw_label}."
    ))
  }

  output_cols <- intersect(
    c("clean_label", "major_category", "ml_class", "class_id"),
    names(crosswalk)
  )
  if (length(output_cols) == 0L) {
    cli::cli_abort(c(
      "Crosswalk must contain at least one output class column.",
      "i" = "Supported output columns include {.field clean_label}, {.field major_category}, {.field ml_class}, and {.field class_id}."
    ))
  }

  if ("class_id" %in% names(crosswalk)) {
    crosswalk$class_id <- suppressWarnings(as.integer(crosswalk$class_id))
  }
  if ("include_in_analysis" %in% names(crosswalk)) {
    crosswalk$include_in_analysis <- pc_bool(crosswalk$include_in_analysis, default = TRUE)
  }
  if ("include_in_ml" %in% names(crosswalk)) {
    crosswalk$include_in_ml <- pc_bool(crosswalk$include_in_ml, default = TRUE)
  }

  tibble::as_tibble(crosswalk)
}

pc_choose_crosswalk_by <- function(points, crosswalk, by = NULL) {
  if (!is.null(by)) {
    return(by)
  }

  candidates <- list(
    raw_code = "raw_code",
    raw_label = "raw_label"
  )

  for (nm in names(candidates)) {
    if (nm %in% names(points) && candidates[[nm]] %in% names(crosswalk)) {
      return(stats::setNames(candidates[[nm]], nm))
    }
  }

  cli::cli_abort(c(
    "Could not choose crosswalk join columns automatically.",
    "i" = "Provide {.arg by}, for example {.code by = \"raw_code\"} or {.code by = c(raw_label = \"raw_label\")}."
  ))
}

pc_join_columns <- function(by) {
  if (is.null(names(by)) || all(names(by) == "")) {
    list(points = unname(by), crosswalk = unname(by))
  } else {
    list(points = names(by), crosswalk = unname(by))
  }
}

#' Standardize CPCe labels with a crosswalk
#'
#' Joins raw CPCe labels/codes to user-defined clean labels, ecological
#' categories, ML classes, and class IDs. Raw labels and raw codes are always
#' preserved.
#'
#' @param points A tidy point table.
#' @param crosswalk A crosswalk data frame, usually from [read_label_crosswalk()].
#' @param by Optional join columns. Use a character vector for same-name joins
#'   or a named vector where names are point-table columns and values are
#'   crosswalk columns.
#' @param unknown_action How to handle labels not found in the crosswalk:
#'   `"warn"` keeps rows and warns, `"keep"` keeps rows silently, `"drop"`
#'   drops unmapped rows with a warning, and `"error"` stops.
#'
#' @return A tidy point table with standardized label columns.
#' @export
#'
#' @examples
#' cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
#' xwalk <- system.file(
#'   "extdata", "pointcoral_example_crosswalk.csv",
#'   package = "pointcoral"
#' )
#' pts <- read_cpce_file(cpc)
#' standardize_labels(pts, read_label_crosswalk(xwalk))
standardize_labels <- function(points,
                               crosswalk,
                               by = NULL,
                               unknown_action = c("warn", "keep", "drop", "error")) {
  unknown_action <- match.arg(unknown_action)
  points <- tibble::as_tibble(points)
  crosswalk <- tibble::as_tibble(crosswalk)
  by <- pc_choose_crosswalk_by(points, crosswalk, by)
  join_cols <- pc_join_columns(by)

  pc_require_columns(points, join_cols$points, "points")
  pc_require_columns(crosswalk, join_cols$crosswalk, "crosswalk")

  dup <- crosswalk |>
    dplyr::count(dplyr::across(dplyr::all_of(join_cols$crosswalk)), name = ".pc_n") |>
    dplyr::filter(.data$.pc_n > 1)

  if (nrow(dup) > 0L) {
    cli::cli_warn(
      "Crosswalk contains duplicate mappings for {nrow(dup)} key value{?s}; using the first mapping for standardization. Run check_crosswalk() for details."
    )
    crosswalk <- crosswalk |>
      dplyr::distinct(dplyr::across(dplyr::all_of(join_cols$crosswalk)), .keep_all = TRUE)
  }

  mapping_cols <- setdiff(names(crosswalk), join_cols$crosswalk)
  xwalk <- crosswalk
  names(xwalk)[match(mapping_cols, names(xwalk))] <- paste0(".pc_xwalk_", mapping_cols)
  xwalk$.pc_has_crosswalk <- TRUE

  joined <- dplyr::left_join(points, xwalk, by = by)
  unmapped <- is.na(joined$.pc_has_crosswalk)
  n_unmapped <- sum(unmapped)

  if (n_unmapped > 0L) {
    key_preview <- joined[unmapped, join_cols$points, drop = FALSE] |>
      dplyr::distinct() |>
      utils::head(10)

    msg <- paste(
      utils::capture.output(print(key_preview, n = 10)),
      collapse = "\n"
    )

    if (identical(unknown_action, "error")) {
      cli::cli_abort(c(
        "{n_unmapped} point row{?s} did not match the crosswalk.",
        "i" = msg
      ))
    }
    if (identical(unknown_action, "warn")) {
      cli::cli_warn(c(
        "{n_unmapped} point row{?s} did not match the crosswalk and were kept.",
        "i" = msg
      ))
    }
    if (identical(unknown_action, "drop")) {
      cli::cli_warn("{n_unmapped} unmapped point row{?s} dropped because {.code unknown_action = \"drop\"}.")
      joined <- joined[!unmapped, , drop = FALSE]
    }
  }

  standard_cols <- c(
    "full_label", "clean_label", "label_class", "major_category", "ml_class", "class_id",
    "include_in_analysis", "include_in_ml", "color_hex"
  )

  for (col in standard_cols) {
    xcol <- paste0(".pc_xwalk_", col)
    if (xcol %in% names(joined)) {
      if (!col %in% names(joined)) {
        joined[[col]] <- joined[[xcol]]
      } else {
        joined[[col]] <- dplyr::coalesce(joined[[xcol]], joined[[col]])
      }
    }
  }

  drop_cols <- grep("^\\.pc_xwalk_|^\\.pc_has_crosswalk$", names(joined), value = TRUE)
  joined <- joined[, setdiff(names(joined), drop_cols), drop = FALSE]

  if ("class_id" %in% names(joined)) {
    joined$class_id <- suppressWarnings(as.integer(joined$class_id))
  }

  pc_complete_point_columns(joined)
}

#' Check a label crosswalk against point data
#'
#' Reports labels in CPCe data missing from the crosswalk, crosswalk labels not
#' present in current data, duplicate mappings, missing class IDs, and excluded
#' classes.
#'
#' @param points A tidy point table.
#' @param crosswalk A crosswalk data frame.
#' @param by Optional join columns. See [standardize_labels()].
#'
#' @return A tibble report.
#' @export
#'
#' @examples
#' cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
#' xwalk <- system.file(
#'   "extdata", "pointcoral_example_crosswalk.csv",
#'   package = "pointcoral"
#' )
#' pts <- read_cpce_file(cpc)
#' check_crosswalk(pts, read_label_crosswalk(xwalk))
check_crosswalk <- function(points, crosswalk, by = NULL) {
  points <- tibble::as_tibble(points)
  crosswalk <- tibble::as_tibble(crosswalk)
  by <- pc_choose_crosswalk_by(points, crosswalk, by)
  join_cols <- pc_join_columns(by)

  point_keys <- points |>
    dplyr::distinct(dplyr::across(dplyr::all_of(join_cols$points)))
  cross_keys <- crosswalk |>
    dplyr::distinct(dplyr::across(dplyr::all_of(join_cols$crosswalk)))

  names(cross_keys) <- join_cols$points

  missing_from_crosswalk <- dplyr::anti_join(point_keys, cross_keys, by = join_cols$points)
  unused_in_points <- dplyr::anti_join(cross_keys, point_keys, by = join_cols$points)

  dup <- crosswalk |>
    dplyr::count(dplyr::across(dplyr::all_of(join_cols$crosswalk)), name = "n") |>
    dplyr::filter(.data$n > 1)
  names(dup)[seq_along(join_cols$crosswalk)] <- join_cols$points

  missing_class_id <- if ("class_id" %in% names(crosswalk)) {
    crosswalk |>
      dplyr::filter(is.na(.data$class_id)) |>
      dplyr::mutate(n = 1L)
  } else {
    tibble::tibble(n = integer())
  }

  excluded <- crosswalk |>
    dplyr::mutate(
      include_in_analysis = if ("include_in_analysis" %in% names(crosswalk)) {
        pc_bool(.data$include_in_analysis)
      } else {
        TRUE
      },
      include_in_ml = if ("include_in_ml" %in% names(crosswalk)) {
        pc_bool(.data$include_in_ml)
      } else {
        TRUE
      }
    ) |>
    dplyr::filter(!.data$include_in_analysis | !.data$include_in_ml) |>
    dplyr::mutate(n = 1L)

  make_report <- function(df, issue_type, severity, details) {
    if (nrow(df) == 0L) {
      return(tibble::tibble())
    }

    df <- tibble::as_tibble(df)
    for (col in c("raw_code", "raw_label", "full_label", "clean_label", "label_class", "major_category", "ml_class", "class_id")) {
      if (!col %in% names(df)) df[[col]] <- NA
    }
    if (!"n" %in% names(df)) df$n <- 1L

    tibble::tibble(
      issue_type = issue_type,
      severity = severity,
      raw_code = as.character(df$raw_code),
      raw_label = as.character(df$raw_label),
      full_label = as.character(df$full_label),
      clean_label = as.character(df$clean_label),
      label_class = as.character(df$label_class),
      major_category = as.character(df$major_category),
      ml_class = as.character(df$ml_class),
      class_id = suppressWarnings(as.integer(df$class_id)),
      n = as.integer(df$n),
      details = details
    )
  }

  dplyr::bind_rows(
    make_report(missing_from_crosswalk, "missing_from_crosswalk", "warning", "Present in points but missing from crosswalk"),
    make_report(unused_in_points, "unused_in_points", "info", "Present in crosswalk but absent from current points"),
    make_report(dup, "duplicate_mapping", "error", "Crosswalk key maps more than once"),
    make_report(missing_class_id, "missing_class_id", "warning", "Crosswalk row has no class_id"),
    make_report(excluded, "excluded_class", "info", "Crosswalk row is marked for exclusion")
  )
}

#' Make a class lookup table
#'
#' Produces a distinct class lookup table from point data. If no usable class ID
#' column exists, IDs are assigned in sorted class order starting at 0.
#'
#' @param points A tidy point table.
#' @param class_col Column containing class labels.
#' @param id_col Column containing integer class IDs.
#'
#' @return A tibble with class labels and IDs.
#' @export
#'
#' @examples
#' cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
#' xwalk <- system.file(
#'   "extdata", "pointcoral_example_crosswalk.csv",
#'   package = "pointcoral"
#' )
#' pts <- standardize_labels(read_cpce_file(cpc), read_label_crosswalk(xwalk))
#' make_class_lookup(pts, class_col = "ml_class")
make_class_lookup <- function(points, class_col = "ml_class", id_col = "class_id") {
  points <- tibble::as_tibble(points)
  pc_require_columns(points, class_col, "points")

  out <- points |>
    dplyr::filter(!is.na(.data[[class_col]]), .data[[class_col]] != "") |>
    dplyr::distinct(label = .data[[class_col]], class_id = if (id_col %in% names(points)) .data[[id_col]] else NA_integer_) |>
    dplyr::arrange(.data$label)

  if (nrow(out) == 0L) {
    return(tibble::tibble(label = character(), class_id = integer()))
  }

  if (all(is.na(out$class_id))) {
    out$class_id <- seq_len(nrow(out)) - 1L
  } else if (any(is.na(out$class_id))) {
    cli::cli_warn("Some classes are missing class IDs in {.field {id_col}}.")
  }

  out |>
    dplyr::arrange(.data$class_id, .data$label)
}
