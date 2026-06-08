#' Convert CPCe coordinates to image pixel coordinates
#'
#' Converts point coordinates from the CPCe coordinate space to actual image
#' pixels by proportional scaling. Original CPCe coordinates are preserved.
#'
#' @param points A data frame with `cpce_x` and `cpce_y` columns.
#' @param cpce_width,cpce_height CPCe coordinate-space width and height. If
#'   `NULL`, the function uses `points$cpce_width` and `points$cpce_height`.
#' @param image_width,image_height Image width and height in pixels. If `NULL`,
#'   the function uses `points$image_width` and `points$image_height`.
#'
#' @return A tibble with updated `x_px` and `y_px` columns.
#' @export
#'
#' @examples
#' pts <- tibble::tibble(cpce_x = c(0, 50, 100), cpce_y = c(0, 25, 50))
#' convert_cpce_coords(pts, 100, 50, 1000, 500)
convert_cpce_coords <- function(points,
                                cpce_width = NULL,
                                cpce_height = NULL,
                                image_width = NULL,
                                image_height = NULL) {
  points <- tibble::as_tibble(points)
  pc_require_columns(points, c("cpce_x", "cpce_y"), "points")

  n <- nrow(points)

  use_arg <- function(value, col) {
    if (is.null(value)) {
      pc_require_columns(points, col, "points")
      return(points[[col]])
    }
    if (length(value) == 1L) {
      return(rep(value, n))
    }
    if (length(value) != n) {
      cli::cli_abort("{.arg {col}} must have length 1 or the same length as {.arg points}.")
    }
    value
  }

  cpce_width <- as.numeric(use_arg(cpce_width, "cpce_width"))
  cpce_height <- as.numeric(use_arg(cpce_height, "cpce_height"))
  image_width <- as.numeric(use_arg(image_width, "image_width"))
  image_height <- as.numeric(use_arg(image_height, "image_height"))

  points$cpce_width <- cpce_width
  points$cpce_height <- cpce_height
  points$image_width <- as.integer(image_width)
  points$image_height <- as.integer(image_height)

  ok <- !is.na(points$cpce_x) &
    !is.na(points$cpce_y) &
    !is.na(cpce_width) &
    !is.na(cpce_height) &
    !is.na(image_width) &
    !is.na(image_height) &
    cpce_width != 0 &
    cpce_height != 0

  x_px <- rep(NA_integer_, n)
  y_px <- rep(NA_integer_, n)
  x_px[ok] <- as.integer(round(points$cpce_x[ok] / cpce_width[ok] * image_width[ok]))
  y_px[ok] <- as.integer(round(points$cpce_y[ok] / cpce_height[ok] * image_height[ok]))

  points$x_px <- x_px
  points$y_px <- y_px
  points
}

#' Read one CPCe `.cpc` file
#'
#' Reads the tested text `.cpc` format used by the bundled examples: header row,
#' four ROI vertices, point count, point coordinate rows, and point label rows.
#' If an image with the same basename is present next to the `.cpc` file, image
#' dimensions are read and `x_px`/`y_px` are calculated.
#'
#' @param path Path to a `.cpc` file.
#'
#' @return A tidy point table.
#' @export
#'
#' @examples
#' cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
#' pts <- read_cpce_file(cpc)
#' dplyr::glimpse(pts)
read_cpce_file <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort("CPCe file does not exist: {.file {path}}")
  }

  lines <- readLines(path, warn = FALSE)
  if (length(lines) < 7L) {
    cli::cli_abort("CPCe file is too short to parse: {.file {path}}")
  }

  header <- pc_parse_csv_line(lines[1])
  codefile_path <- header[1] %||% NA_character_
  image_path_cpce <- header[2] %||% NA_character_
  cpce_header_width <- suppressWarnings(as.numeric(header[3]))
  cpce_header_height <- suppressWarnings(as.numeric(header[4]))

  roi <- purrr::map_dfr(seq_len(4), function(i) {
    vals <- strsplit(lines[i + 1L], ",", fixed = TRUE)[[1]]
    tibble::tibble(
      roi_vertex = i,
      roi_x = suppressWarnings(as.numeric(vals[1])),
      roi_y = suppressWarnings(as.numeric(vals[2]))
    )
  })

  n_points <- suppressWarnings(as.integer(lines[6]))
  if (is.na(n_points) || n_points < 1L) {
    cli::cli_abort("Could not parse point count in {.file {path}}.")
  }

  expected_lines <- 6L + (2L * n_points)
  if (length(lines) < expected_lines) {
    cli::cli_abort(
      "CPCe file has {length(lines)} lines but expected at least {expected_lines}: {.file {path}}"
    )
  }

  point_lines <- lines[seq.int(7L, 6L + n_points)]
  points <- purrr::map_dfr(seq_along(point_lines), function(i) {
    vals <- strsplit(point_lines[i], ",", fixed = TRUE)[[1]]
    tibble::tibble(
      point_id = as.integer(i),
      cpce_x = suppressWarnings(as.numeric(vals[1])),
      cpce_y = suppressWarnings(as.numeric(vals[2]))
    )
  })

  label_lines <- lines[seq.int(7L + n_points, 6L + (2L * n_points))]
  labels <- purrr::map_dfr(label_lines, function(line) {
    vals <- pc_parse_csv_line(line)
    # TODO: CPCe label rows can contain optional note fields after the label.
    # The bundled samples use field 2 as the label, field 3 as a note type,
    # and field 4 as the note value.
    tibble::tibble(
      point_id = suppressWarnings(as.integer(vals[1])),
      raw_code = vals[2] %||% NA_character_,
      raw_label = vals[2] %||% NA_character_,
      cpce_note_type = vals[3] %||% NA_character_,
      notes = vals[4] %||% NA_character_
    )
  })

  image_meta <- pc_extract_image_metadata_from_path(image_path_cpce)
  sibling_image <- pc_find_sibling_image(path)
  image_info <- pc_get_image_info(sibling_image)

  # TODO: CPCe header dimensions and ROI extents are both available. The bundled
  # sample geometry is most consistent with scaling by ROI maxima, so
  # pointcoral uses that behavior here.
  cpce_width <- max(roi$roi_x, na.rm = TRUE)
  cpce_height <- max(roi$roi_y, na.rm = TRUE)
  if (!is.finite(cpce_width)) cpce_width <- cpce_header_width
  if (!is.finite(cpce_height)) cpce_height <- cpce_header_height

  out <- points |>
    dplyr::left_join(labels, by = "point_id") |>
    dplyr::mutate(
      project_id = NA_character_,
      site = image_meta$site[1],
      transect = image_meta$transect[1],
      survey_date = as.Date(NA),
      image_id = image_meta$image_id[1],
      image_file = image_meta$image_file[1],
      image_path = image_info$image_path[1],
      cpce_width = cpce_width,
      cpce_height = cpce_height,
      image_width = image_info$image_width[1],
      image_height = image_info$image_height[1],
      reviewer = NA_character_,
      full_label = NA_character_,
      clean_label = NA_character_,
      label_class = NA_character_,
      major_category = NA_character_,
      ml_class = NA_character_,
      class_id = NA_integer_,
      cpc_file = pc_normalize_path(path, must_work = TRUE),
      codefile_path = codefile_path,
      cpce_image_path = image_path_cpce,
      cpce_header_width = cpce_header_width,
      cpce_header_height = cpce_header_height,
      roi_x_min = min(roi$roi_x, na.rm = TRUE),
      roi_x_max = max(roi$roi_x, na.rm = TRUE),
      roi_y_min = min(roi$roi_y, na.rm = TRUE),
      roi_y_max = max(roi$roi_y, na.rm = TRUE)
    )

  if (!is.na(out$image_width[1]) && !is.na(out$image_height[1])) {
    out <- convert_cpce_coords(out)
  } else {
    out$x_px <- NA_integer_
    out$y_px <- NA_integer_
  }

  pc_complete_point_columns(out)
}

#' Read a CPCe CSV or Excel export
#'
#' Reads generic CPCe-like point exports from CSV, TSV, XLS, or XLSX files,
#' cleans column names, and maps common coordinate/label columns to the
#' pointcoral tidy point schema. Project-specific ecological "Data Summary"
#' workbooks are not fully translated yet because representative workbook
#' fixtures are not bundled with the package.
#'
#' @param path Path to a CSV, TSV, XLS, or XLSX export.
#'
#' @return A tidy point table when point-like columns are present.
#' @export
read_cpce_export <- function(path) {
  dat <- pc_read_table(path)

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

  dat <- dat |>
    copy_first("point_id", c("point", "point_number", "point_no", "id")) |>
    copy_first("image_file", c("image", "photo", "filename", "file", "image_name")) |>
    copy_first("image_path", c("path", "photo_path", "image_full_path")) |>
    copy_first("cpce_x", c("x_cpce", "x", "x_coord", "x_coordinate", "column")) |>
    copy_first("cpce_y", c("y_cpce", "y", "y_coord", "y_coordinate", "row")) |>
    copy_first("x_px", c("x_pixel", "x_img", "pixel_x")) |>
    copy_first("y_px", c("y_pixel", "y_img", "pixel_y")) |>
    copy_first("raw_code", c("code", "cpce_code", "label_code")) |>
    copy_first("raw_label", c("label", "class", "category", "benthic_label", "label_original")) |>
    copy_first("site", c("location", "site_name")) |>
    copy_first("transect", c("transect_name", "transect_id")) |>
    copy_first("survey_date", c("date", "sample_date"))

  if (!"raw_label" %in% names(dat) && "raw_code" %in% names(dat)) {
    dat$raw_label <- dat$raw_code
  }
  if (!"raw_code" %in% names(dat) && "raw_label" %in% names(dat)) {
    dat$raw_code <- dat$raw_label
  }

  has_label <- any(c("raw_code", "raw_label") %in% names(dat))
  has_coord <- all(c("cpce_x", "cpce_y") %in% names(dat)) ||
    all(c("x_px", "y_px") %in% names(dat))

  if (!has_label || !has_coord) {
    cli::cli_abort(c(
      "Could not identify point-like CPCe export columns in {.file {path}}.",
      "i" = "Need at least a raw label/code column and coordinate columns."
    ))
  }

  if (!"point_id" %in% names(dat)) {
    dat$point_id <- seq_len(nrow(dat))
  }
  if (!"image_file" %in% names(dat) && "image_path" %in% names(dat)) {
    dat$image_file <- basename(dat$image_path)
  }
  if (!"image_id" %in% names(dat) && "image_file" %in% names(dat)) {
    dat$image_id <- tools::file_path_sans_ext(basename(dat$image_file))
  }

  numeric_cols <- intersect(
    c(
      "point_id", "cpce_x", "cpce_y", "x_px", "y_px", "cpce_width",
      "cpce_height", "image_width", "image_height", "class_id"
    ),
    names(dat)
  )
  dat[numeric_cols] <- lapply(dat[numeric_cols], function(x) suppressWarnings(as.numeric(x)))
  if ("point_id" %in% names(dat)) dat$point_id <- as.integer(dat$point_id)
  if ("class_id" %in% names(dat)) dat$class_id <- as.integer(dat$class_id)

  if (pc_has_columns(dat, c("cpce_x", "cpce_y", "cpce_width", "cpce_height", "image_width", "image_height")) &&
    !pc_has_columns(dat, c("x_px", "y_px"))) {
    dat <- convert_cpce_coords(dat)
  }

  dat$source_file <- pc_normalize_path(path, must_work = TRUE)
  pc_complete_point_columns(dat)
}

#' Read CPCe files and exports from a folder
#'
#' Recursively reads supported CPCe-related files from a folder. `.cpc` files
#' are parsed with [read_cpce_file()]. CSV/TSV/XLS/XLSX files are attempted with
#' [read_cpce_export()].
#'
#' @param path Folder containing CPCe files/exports.
#' @param image_root Optional image root used to match image paths after import.
#' @param recursive Whether to search recursively.
#'
#' @return A combined tidy point table.
#' @export
read_cpce_folder <- function(path, image_root = NULL, recursive = TRUE) {
  if (!dir.exists(path)) {
    cli::cli_abort("CPCe folder does not exist: {.file {path}}")
  }

  files <- fs::dir_ls(path, recurse = recursive, type = "file")
  supported <- files[tolower(tools::file_ext(files)) %in% c("cpc", "csv", "tsv", "txt", "xls", "xlsx")]
  supported <- supported[!grepl("crosswalk|class_lookup|lookup", basename(supported), ignore.case = TRUE)]

  if (length(supported) == 0L) {
    cli::cli_abort("No supported CPCe files found in {.file {path}}.")
  }

  out <- purrr::map(supported, function(file) {
    tryCatch(
      {
        ext <- tolower(tools::file_ext(file))
        if (identical(ext, "cpc")) {
          read_cpce_file(file)
        } else {
          read_cpce_export(file)
        }
      },
      error = function(e) {
        cli::cli_warn("Skipping {.file {file}}: {conditionMessage(e)}")
        NULL
      }
    )
  })

  out <- purrr::compact(out)
  if (length(out) == 0L) {
    cli::cli_abort("No CPCe files could be read successfully from {.file {path}}.")
  }

  points <- dplyr::bind_rows(out)
  if (!is.null(image_root)) {
    points <- match_images(points, image_root = image_root)
  }
  points
}

#' Match CPCe point rows to image files
#'
#' Matches `image_file` values in a point table to files under `image_root`.
#' Image dimensions are filled in, and pixel coordinates are calculated when
#' CPCe and image dimensions are available.
#'
#' @param points A pointcoral point table.
#' @param image_root Root folder containing images.
#' @param image_col Column in `points` containing image file names.
#'
#' @return A point table with `image_path`, `image_width`, and `image_height`.
#' @export
match_images <- function(points, image_root, image_col = "image_file") {
  points <- tibble::as_tibble(points)
  if (!dir.exists(image_root)) {
    cli::cli_abort("Image root does not exist: {.file {image_root}}")
  }

  if (!image_col %in% names(points)) {
    cli::cli_abort("{.arg points} does not contain image column {.field {image_col}}.")
  }

  image_files <- fs::dir_ls(image_root, recurse = TRUE, type = "file")
  image_files <- image_files[tolower(paste0(".", tools::file_ext(image_files))) %in% tolower(pc_image_extensions)]

  if (length(image_files) == 0L) {
    cli::cli_abort("No image files found under {.file {image_root}}.")
  }

  index <- tibble::tibble(
    image_file_match = basename(image_files),
    image_path_new = pc_normalize_path(as.character(image_files), must_work = TRUE)
  )

  duplicates <- index |>
    dplyr::count(.data$image_file_match) |>
    dplyr::filter(.data$n > 1)

  if (nrow(duplicates) > 0L) {
    cli::cli_warn(
      "Duplicate image basenames found under {.file {image_root}}; using the first match for: {.field {duplicates$image_file_match}}"
    )
  }

  index <- index |>
    dplyr::distinct(.data$image_file_match, .keep_all = TRUE)

  points$image_file_match <- basename(as.character(points[[image_col]]))
  matched <- points |>
    dplyr::left_join(index, by = "image_file_match")

  missing_images <- matched |>
    dplyr::filter(is.na(.data$image_path_new)) |>
    dplyr::distinct(.data$image_file_match)

  if (nrow(missing_images) > 0L) {
    cli::cli_warn(
      "Could not match {nrow(missing_images)} image filename{?s}: {.field {missing_images$image_file_match}}"
    )
  }

  matched$image_path <- dplyr::coalesce(matched$image_path_new, matched$image_path)
  matched$image_file <- dplyr::coalesce(matched$image_file, matched$image_file_match)
  matched$image_id <- dplyr::coalesce(
    matched$image_id,
    tools::file_path_sans_ext(basename(matched$image_file))
  )

  info <- matched |>
    dplyr::filter(!is.na(.data$image_path)) |>
    dplyr::distinct(.data$image_path) |>
    dplyr::pull(.data$image_path) |>
    purrr::map_dfr(pc_get_image_info)

  matched <- matched |>
    dplyr::select(-dplyr::all_of("image_path_new")) |>
    dplyr::left_join(
      info |>
        dplyr::transmute(
          image_path_info = .data$image_path,
          image_width_new = .data$image_width,
          image_height_new = .data$image_height
        ),
      by = c("image_path" = "image_path_info")
    ) |>
    dplyr::mutate(
      image_width = dplyr::coalesce(.data$image_width, .data$image_width_new),
      image_height = dplyr::coalesce(.data$image_height, .data$image_height_new)
    ) |>
    dplyr::select(-dplyr::all_of(c("image_width_new", "image_height_new", "image_file_match")))

  can_convert <- pc_has_columns(matched, c("cpce_x", "cpce_y", "cpce_width", "cpce_height", "image_width", "image_height"))
  if (can_convert && (!"x_px" %in% names(matched) || all(is.na(matched$x_px)))) {
    matched <- convert_cpce_coords(matched)
  } else if (can_convert) {
    needs <- is.na(matched$x_px) | is.na(matched$y_px)
    converted <- convert_cpce_coords(matched)
    matched$x_px[needs] <- converted$x_px[needs]
    matched$y_px[needs] <- converted$y_px[needs]
  }

  pc_complete_point_columns(matched)
}

`%||%` <- function(x, y) {
  if (length(x) == 0 || is.na(x)) y else x
}
