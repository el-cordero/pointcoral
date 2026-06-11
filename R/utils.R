# Internal helpers ---------------------------------------------------------

pc_image_extensions <- c(
  ".jpg", ".jpeg", ".png", ".tif", ".tiff",
  ".JPG", ".JPEG", ".PNG", ".TIF", ".TIFF"
)

pc_point_columns <- c(
  "project_id", "site", "transect", "survey_date", "image_id",
  "image_file", "image_path", "point_id", "cpce_x", "cpce_y",
  "cpce_width", "cpce_height", "image_width", "image_height",
  "x_px", "y_px", "raw_code", "raw_label", "full_label",
  "clean_label", "label_class", "major_category", "ml_class",
  "class_id", "reviewer", "notes"
)

pc_normalize_path <- function(path, must_work = FALSE) {
  if (length(path) == 0 || all(is.na(path))) {
    return(path)
  }

  out <- normalizePath(path, winslash = "/", mustWork = must_work)
  out[is.na(path)] <- NA_character_
  out
}

pc_safe_slug <- function(x) {
  x <- as.character(x)
  x <- stringr::str_replace_all(x, "[^A-Za-z0-9_-]+", "_")
  x <- stringr::str_replace_all(x, "_+", "_")
  x <- stringr::str_replace_all(x, "^_|_$", "")
  dplyr::if_else(is.na(x) | x == "", "missing", x)
}

pc_bool <- function(x, default = TRUE) {
  if (is.logical(x)) {
    return(dplyr::coalesce(x, default))
  }

  x_chr <- tolower(trimws(as.character(x)))
  out <- dplyr::case_when(
    x_chr %in% c("true", "t", "yes", "y", "1", "include", "included") ~ TRUE,
    x_chr %in% c("false", "f", "no", "n", "0", "exclude", "excluded") ~ FALSE,
    TRUE ~ default
  )
  out
}

pc_read_table <- function(path, na = c("", "NA")) {
  ext <- tolower(tools::file_ext(path))

  out <- switch(ext,
    csv = readr::read_csv(path, na = na, show_col_types = FALSE),
    tsv = readr::read_tsv(path, na = na, show_col_types = FALSE),
    txt = readr::read_delim(path, delim = "\t", na = na, show_col_types = FALSE),
    xls = readxl::read_excel(path, na = na),
    xlsx = readxl::read_excel(path, na = na),
    cli::cli_abort("Unsupported table extension: {.file {path}}")
  )

  janitor::clean_names(tibble::as_tibble(out))
}

pc_parse_csv_line <- function(line) {
  out <- utils::read.csv(
    text = line,
    header = FALSE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  as.character(out[1, ])
}

pc_path_parts <- function(path) {
  path <- gsub("\\\\", "/", as.character(path))
  unlist(strsplit(path, "/", fixed = TRUE), use.names = FALSE)
}

pc_extract_image_metadata_from_path <- function(path) {
  parts <- pc_path_parts(path)
  image_file <- basename(gsub("\\\\", "/", path))
  image_id <- tools::file_path_sans_ext(image_file)

  depth_i <- grep("meters?$|m$", parts, ignore.case = TRUE)
  depth_i <- if (length(depth_i) > 0) depth_i[length(depth_i)] else NA_integer_
  site <- if (!is.na(depth_i) && depth_i > 1) parts[depth_i - 1] else NA_character_

  tibble::tibble(
    image_file = image_file,
    image_id = image_id,
    site = site,
    transect = image_id,
    cpce_image_path = path
  )
}

pc_get_image_info <- function(path) {
  if (is.na(path) || !file.exists(path)) {
    return(tibble::tibble(
      image_path = as.character(path),
      image_width = NA_integer_,
      image_height = NA_integer_,
      image_ok = FALSE,
      image_error = ifelse(is.na(path), "missing path", "file does not exist")
    ))
  }

  tryCatch(
    {
      info <- magick::image_info(magick::image_read(path))
      tibble::tibble(
        image_path = pc_normalize_path(path, must_work = TRUE),
        image_width = as.integer(info$width[1]),
        image_height = as.integer(info$height[1]),
        image_ok = TRUE,
        image_error = NA_character_
      )
    },
    error = function(e) {
      tibble::tibble(
        image_path = pc_normalize_path(path, must_work = FALSE),
        image_width = NA_integer_,
        image_height = NA_integer_,
        image_ok = FALSE,
        image_error = conditionMessage(e)
      )
    }
  )
}

pc_find_sibling_image <- function(cpc_path) {
  base <- tools::file_path_sans_ext(cpc_path)
  candidates <- paste0(base, pc_image_extensions)
  hit <- candidates[file.exists(candidates)]
  if (length(hit) == 0) {
    return(NA_character_)
  }
  pc_normalize_path(hit[1], must_work = TRUE)
}

pc_complete_point_columns <- function(points) {
  points <- tibble::as_tibble(points)
  missing <- setdiff(pc_point_columns, names(points))

  for (col in missing) {
    points[[col]] <- switch(col,
      point_id = NA_integer_,
      cpce_x = NA_real_,
      cpce_y = NA_real_,
      cpce_width = NA_real_,
      cpce_height = NA_real_,
      image_width = NA_integer_,
      image_height = NA_integer_,
      x_px = NA_integer_,
      y_px = NA_integer_,
      class_id = NA_integer_,
      survey_date = as.Date(NA),
      NA_character_
    )
  }

  front <- intersect(pc_point_columns, names(points))
  rest <- setdiff(names(points), front)
  points[, c(front, rest), drop = FALSE]
}

pc_require_columns <- function(data, cols, arg = "data") {
  missing <- setdiff(cols, names(data))
  if (length(missing) > 0) {
    cli::cli_abort(
      "{.arg {arg}} is missing required column{?s}: {.field {missing}}."
    )
  }
  invisible(data)
}

pc_has_columns <- function(data, cols) {
  all(cols %in% names(data))
}

pc_available_columns <- function(data, cols) {
  intersect(cols, names(data))
}

pc_col_has_values <- function(data, col) {
  col %in% names(data) &&
    any(!is.na(data[[col]]) & as.character(data[[col]]) != "")
}

pc_resolve_label_col <- function(data,
                                 preferred = "ml_class",
                                 candidates = c(
                                   "ml_class", "major_category", "clean_label",
                                   "full_label", "raw_label", "raw_code"
                                 ),
                                 arg = "class_col",
                                 inform = FALSE) {
  data <- tibble::as_tibble(data)

  if (!is.null(preferred) && pc_col_has_values(data, preferred)) {
    return(preferred)
  }

  fallback <- candidates[vapply(candidates, pc_col_has_values, logical(1), data = data)]
  if (length(fallback) > 0L) {
    fallback <- fallback[1]
    if (isTRUE(inform) && !is.null(preferred) && !identical(preferred, fallback)) {
      cli::cli_inform(c(
        "Using {.field {fallback}} as the label column.",
        "i" = "{.field {preferred}} is missing or empty. This is expected for a bare CPCe workflow without a crosswalk."
      ))
    }
    return(fallback)
  }

  cli::cli_abort(c(
    "Could not find a usable label column in {.arg data}.",
    "i" = "Tried {.field {unique(c(preferred, candidates))}}.",
    "i" = "Bare CPCe workflows need at least {.field raw_label} or {.field raw_code}."
  ))
}

pc_add_class_ids <- function(points, class_col, id_col = "class_id") {
  points <- tibble::as_tibble(points)
  pc_require_columns(points, class_col, "points")

  if (!id_col %in% names(points)) {
    points[[id_col]] <- NA_integer_
  }

  lookup <- make_class_lookup(points, class_col = class_col, id_col = id_col)
  if (nrow(lookup) == 0L) {
    return(points)
  }

  names(lookup)[names(lookup) == "class_id"] <- ".pc_class_id"

  points <- points |>
    dplyr::left_join(lookup, by = stats::setNames("label", class_col))
  points[[id_col]] <- dplyr::coalesce(
    as.integer(points[[id_col]]),
    as.integer(points$.pc_class_id)
  )
  points$.pc_class_id <- NULL

  points
}

pc_make_unique_file <- function(path) {
  if (!file.exists(path)) {
    return(path)
  }

  ext <- tools::file_ext(path)
  stem <- tools::file_path_sans_ext(path)
  i <- 2L
  repeat {
    candidate <- paste0(stem, "_", i, ifelse(ext == "", "", paste0(".", ext)))
    if (!file.exists(candidate)) {
      return(candidate)
    }
    i <- i + 1L
  }
}

pc_draw_disk <- function(mask, cx, cy, radius, value) {
  h <- nrow(mask)
  w <- ncol(mask)

  cx <- as.integer(round(cx))
  cy <- as.integer(round(cy))
  radius <- as.integer(radius)

  if (is.na(cx) || is.na(cy) || is.na(value)) {
    return(mask)
  }

  x_min <- max(1L, cx - radius)
  x_max <- min(w, cx + radius)
  y_min <- max(1L, cy - radius)
  y_max <- min(h, cy + radius)

  for (yy in y_min:y_max) {
    for (xx in x_min:x_max) {
      if (((xx - cx)^2 + (yy - cy)^2) <= radius^2) {
        mask[yy, xx] <- as.integer(value)
      }
    }
  }

  mask
}

pc_write_png_mask <- function(mask, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  arr <- array(0, dim = c(nrow(mask), ncol(mask), 1))
  arr[, , 1] <- mask
  png::writePNG(arr / 255, target = path)
  path
}

pc_read_png_mask <- function(path) {
  img <- png::readPNG(path)
  if (length(dim(img)) == 3) {
    img <- img[, , 1]
  }
  mask <- as.integer(round(img * 255))
  dim(mask) <- dim(img)
  mask
}
