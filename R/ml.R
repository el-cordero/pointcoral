#' Make an ML-ready point-label table
#'
#' Creates a compact table suitable for patch classification or weakly
#' supervised segmentation workflows.
#'
#' @param points A tidy point table.
#' @param image_root Optional image root used to match image paths.
#' @param class_col Label column to use as the ML label.
#'
#' @return A tibble with `image_path`, `image_id`, `x_px`, `y_px`, `label`,
#'   `class_id`, `split`, and available metadata.
#' @export
make_ml_points <- function(points, image_root = NULL, class_col = "ml_class") {
  points <- tibble::as_tibble(points)
  if (!is.null(image_root)) {
    points <- match_images(points, image_root = image_root)
  }
  class_col <- pc_resolve_label_col(points, preferred = class_col, arg = "class_col")
  pc_require_columns(points, c("image_id", "x_px", "y_px", class_col), "points")

  if ("include_in_ml" %in% names(points)) {
    excluded <- sum(!pc_bool(points$include_in_ml), na.rm = TRUE)
    if (excluded > 0L) {
      cli::cli_inform("Excluding {excluded} point row{?s} where include_in_ml is false.")
    }
    points <- points[pc_bool(points$include_in_ml), , drop = FALSE]
  }

  points <- pc_add_class_ids(points, class_col = class_col, id_col = "class_id")

  if (!"split" %in% names(points)) {
    points$split <- NA_character_
  }

  metadata_cols <- pc_available_columns(
    points,
    c(
      "project_id", "site", "transect", "survey_date", "image_file",
      "point_id", "raw_code", "raw_label", "full_label", "clean_label",
      "label_class", "major_category",
      "reviewer", "notes"
    )
  )

  points |>
    dplyr::transmute(
      image_path = .data$image_path,
      image_id = .data$image_id,
      x_px = as.integer(.data$x_px),
      y_px = as.integer(.data$y_px),
      label = .data[[class_col]],
      class_id = as.integer(.data$class_id),
      split = .data$split,
      dplyr::across(dplyr::all_of(metadata_cols))
    )
}

#' Split ML points into train/validation/test sets
#'
#' Assigns split labels by image, transect, or site to avoid leakage. Splits are
#' reproducible with `seed`.
#'
#' @param points A tidy point table.
#' @param split_by One of `"image"`, `"transect"`, or `"site"`.
#' @param train,val,test Split proportions.
#' @param seed Random seed.
#'
#' @return The input table with `split` and `split_unit` columns.
#' @export
split_ml_points <- function(points,
                            split_by = c("image", "transect", "site"),
                            train = 0.7,
                            val = 0.15,
                            test = 0.15,
                            seed = 1) {
  split_by <- match.arg(split_by)
  points <- tibble::as_tibble(points)
  if (!"split" %in% names(points)) {
    points$split <- NA_character_
  }

  total <- train + val + test
  if (!isTRUE(all.equal(total, 1))) {
    cli::cli_abort("Split proportions must sum to 1.")
  }

  unit <- switch(split_by,
    image = {
      pc_require_columns(points, "image_id", "points")
      points$image_id
    },
    transect = {
      pc_require_columns(points, "transect", "points")
      site <- if ("site" %in% names(points)) points$site else rep(NA_character_, nrow(points))
      paste(site, points$transect, sep = "__")
    },
    site = {
      pc_require_columns(points, "site", "points")
      points$site
    }
  )

  points$split_unit <- as.character(unit)
  units <- unique(stats::na.omit(points$split_unit))
  if (length(units) == 0L) {
    cli::cli_abort("No non-missing split units found for split_by = {.val {split_by}}.")
  }

  set.seed(seed)
  units <- sample(units)
  n_units <- length(units)
  raw_counts <- c(train = train, val = val, test = test) * n_units
  counts <- floor(raw_counts)
  remainder <- n_units - sum(counts)
  if (remainder > 0L) {
    add_to <- order(raw_counts - counts, decreasing = TRUE)[seq_len(remainder)]
    counts[add_to] <- counts[add_to] + 1L
  }

  split_labels <- rep(names(counts), counts)
  split_table <- tibble::tibble(split_unit = units, split = split_labels)

  points |>
    dplyr::left_join(split_table, by = "split_unit", suffix = c("", "_new")) |>
    dplyr::mutate(split = dplyr::coalesce(.data$split_new, .data$split)) |>
    dplyr::select(-dplyr::all_of("split_new"))
}

#' Extract point-centered image patches
#'
#' Extracts square image patches centered on CPCe points and writes a manifest.
#'
#' @param points A tidy point table.
#' @param image_root Image root used to match images when `image_path` is absent.
#' @param out_dir Output patch directory.
#' @param patch_size Patch width/height in pixels.
#' @param class_col Class column used for folder names and labels.
#' @param edge `"skip"` skips points too close to an edge; `"pad"` pads images
#'   with black pixels before cropping.
#'
#' @return A patch manifest tibble.
#' @export
extract_point_patches <- function(points,
                                  image_root,
                                  out_dir,
                                  patch_size = 224,
                                  class_col = "ml_class",
                                  edge = c("skip", "pad")) {
  edge <- match.arg(edge)
  points <- tibble::as_tibble(points)
  if (!"image_path" %in% names(points) || all(is.na(points$image_path))) {
    points <- match_images(points, image_root = image_root)
  }
  class_col <- pc_resolve_label_col(points, preferred = class_col, arg = "class_col")
  points <- pc_add_class_ids(points, class_col = class_col, id_col = "class_id")
  pc_require_columns(points, c("image_path", "image_id", "point_id", "x_px", "y_px", class_col), "points")

  if (!"split" %in% names(points)) {
    points$split <- "train"
  }

  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  half <- floor(patch_size / 2)

  image_groups <- split(points, points$image_path)
  manifest <- purrr::imap_dfr(image_groups, function(df, image_path) {
    if (is.na(image_path) || !file.exists(image_path)) {
      cli::cli_warn("Skipping patches for missing image {.file {image_path}}.")
      return(tibble::tibble())
    }

    img <- magick::image_read(image_path)
    info <- magick::image_info(img)
    width <- as.integer(info$width[1])
    height <- as.integer(info$height[1])

    purrr::map_dfr(seq_len(nrow(df)), function(i) {
      row <- df[i, , drop = FALSE]
      x <- as.integer(row$x_px)
      y <- as.integer(row$y_px)
      label <- as.character(row[[class_col]])
      split <- as.character(row$split %||% "train")

      if (is.na(x) || is.na(y) || is.na(label) || label == "") {
        return(tibble::tibble())
      }

      x0 <- x - half
      y0 <- y - half
      x1 <- x0 + patch_size - 1L
      y1 <- y0 + patch_size - 1L

      if (edge == "skip" && (x0 < 1L || y0 < 1L || x1 > width || y1 > height)) {
        return(tibble::tibble())
      }

      crop_img <- img
      crop_x <- x0 - 1L
      crop_y <- y0 - 1L

      if (edge == "pad") {
        pad <- patch_size
        crop_img <- magick::image_extent(
          img,
          geometry = sprintf("%dx%d+%d+%d", width + 2L * pad, height + 2L * pad, pad, pad),
          color = "black"
        )
        crop_x <- crop_x + pad
        crop_y <- crop_y + pad
      }

      patch_dir <- file.path(out_dir, pc_safe_slug(split), pc_safe_slug(label))
      dir.create(patch_dir, recursive = TRUE, showWarnings = FALSE)
      patch_file <- file.path(
        patch_dir,
        sprintf(
          "%s_point_%s_%s.jpg",
          pc_safe_slug(row$image_id),
          pc_safe_slug(row$point_id),
          pc_safe_slug(label)
        )
      )
      patch_file <- pc_make_unique_file(patch_file)

      patch <- magick::image_crop(
        crop_img,
        geometry = sprintf("%dx%d+%d+%d", patch_size, patch_size, crop_x, crop_y)
      )
      magick::image_write(patch, path = patch_file, format = "jpeg", quality = 95)

      tibble::tibble(
        patch_path = pc_normalize_path(patch_file, must_work = TRUE),
        image_path = pc_normalize_path(image_path, must_work = TRUE),
        image_id = row$image_id,
        point_id = row$point_id,
        x_px = x,
        y_px = y,
        label = label,
        class_id = if ("class_id" %in% names(row)) as.integer(row$class_id) else NA_integer_,
        split = split,
        patch_size = patch_size
      )
    })
  })

  manifest_path <- file.path(out_dir, "patch_manifest.csv")
  readr::write_csv(manifest, manifest_path)
  manifest
}

#' Write ML point CSV files
#'
#' Writes `labels.csv`, `class_lookup.csv`, and split-specific label CSVs when a
#' `split` column is present.
#'
#' @param points An ML-ready point table or tidy point table.
#' @param out_dir Output directory.
#'
#' @return A named list of written file paths.
#' @export
write_ml_points_csv <- function(points, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  points <- tibble::as_tibble(points)

  labels_path <- file.path(out_dir, "labels.csv")
  readr::write_csv(points, labels_path)
  paths <- list(labels = labels_path)

  class_col <- if ("label" %in% names(points)) "label" else "ml_class"
  lookup <- make_class_lookup(points, class_col = class_col, id_col = "class_id")
  lookup_path <- file.path(out_dir, "class_lookup.csv")
  readr::write_csv(lookup, lookup_path)
  paths$class_lookup <- lookup_path

  if ("split" %in% names(points)) {
    for (split_name in c("train", "val", "test")) {
      split_points <- points |>
        dplyr::filter(.data$split == split_name)
      split_path <- file.path(out_dir, paste0("labels_", split_name, ".csv"))
      readr::write_csv(split_points, split_path)
      paths[[paste0("labels_", split_name)]] <- split_path
    }
  }

  paths
}

#' Create sparse semantic segmentation masks from point labels
#'
#' Writes sparse masks where point neighborhoods contain `class_id` values and
#' all unlabeled pixels are `ignore_index`. These are weak labels, not dense
#' human-annotated segmentation masks.
#'
#' @param points A tidy point table.
#' @param image_root Image root used to match images when needed.
#' @param out_dir Output directory.
#' @param radius Disk radius in pixels around each point.
#' @param ignore_index Pixel value for unlabeled pixels.
#' @param background_index Reserved background value. Included for downstream
#'   schemas; unlabeled pixels still default to `ignore_index`.
#' @param class_col Label column used to assign `class_id` values when they are
#'   missing. Defaults to `ml_class`, with automatic fallback to raw CPCe labels
#'   for bare workflows without a crosswalk.
#'
#' @return A mask manifest tibble.
#' @export
make_sparse_masks <- function(points,
                              image_root,
                              out_dir,
                              radius = 3,
                              ignore_index = 255,
                              background_index = 0,
                              class_col = "ml_class") {
  points <- tibble::as_tibble(points)
  if (!"image_path" %in% names(points) || all(is.na(points$image_path))) {
    points <- match_images(points, image_root = image_root)
  }
  class_col <- pc_resolve_label_col(points, preferred = class_col, arg = "class_col")
  points <- pc_add_class_ids(points, class_col = class_col, id_col = "class_id")
  pc_require_columns(points, c("image_path", "image_id", "x_px", "y_px", "class_id"), "points")

  mask_dir <- file.path(out_dir, "masks")
  dir.create(mask_dir, recursive = TRUE, showWarnings = FALSE)

  valid_points <- points |>
    dplyr::filter(!is.na(.data$image_path), !is.na(.data$class_id))

  manifest <- valid_points |>
    split(valid_points$image_path) |>
    purrr::imap_dfr(function(df, image_path) {
      info <- pc_get_image_info(image_path)
      if (!isTRUE(info$image_ok[1])) {
        cli::cli_warn("Skipping sparse mask for {.file {image_path}}: {info$image_error[1]}")
        return(tibble::tibble())
      }

      mask <- matrix(
        as.integer(ignore_index),
        nrow = info$image_height[1],
        ncol = info$image_width[1]
      )

      for (i in seq_len(nrow(df))) {
        mask <- pc_draw_disk(
          mask = mask,
          cx = df$x_px[i],
          cy = df$y_px[i],
          radius = radius,
          value = df$class_id[i]
        )
      }

      mask_file <- file.path(mask_dir, paste0(pc_safe_slug(df$image_id[1]), "_mask.png"))
      mask_file <- pc_make_unique_file(mask_file)
      pc_write_png_mask(mask, mask_file)

      tibble::tibble(
        image_path = pc_normalize_path(image_path, must_work = TRUE),
        image_id = df$image_id[1],
        mask_path = pc_normalize_path(mask_file, must_work = TRUE),
        image_width = info$image_width[1],
        image_height = info$image_height[1],
        n_points = nrow(df),
        radius = radius,
        ignore_index = as.integer(ignore_index),
        background_index = as.integer(background_index)
      )
    })

  manifest_path <- file.path(out_dir, "manifest.csv")
  readr::write_csv(manifest, manifest_path)
  manifest
}

#' Export point labels in a simple CoralNet-style CSV
#'
#' This helper writes local point labels only. It does not connect to CoralNet.
#'
#' @param points A tidy point table.
#' @param out_dir Output directory.
#'
#' @return Path to the written CSV.
#' @export
export_coralnet_points <- function(points, out_dir) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  ml <- make_ml_points(points)
  out <- ml |>
    dplyr::transmute(
      image_name = basename(.data$image_path),
      row = .data$y_px,
      column = .data$x_px,
      label = .data$label,
      point_id = .data$point_id
    )
  path <- file.path(out_dir, "coralnet_points.csv")
  readr::write_csv(out, path)
  path
}

#' Export YOLO-style classification patches
#'
#' Extracts point-centered patches into split/class folders and writes a patch
#' manifest.
#'
#' @param points A tidy point table.
#' @param image_root Image root.
#' @param out_dir Output directory.
#' @param patch_size Patch size in pixels.
#'
#' @return A patch manifest tibble.
#' @export
export_yolo_classification <- function(points, image_root, out_dir, patch_size = 224) {
  extract_point_patches(
    points = points,
    image_root = image_root,
    out_dir = out_dir,
    patch_size = patch_size,
    class_col = "ml_class",
    edge = "skip"
  )
}

#' Export SegFormer-style sparse masks
#'
#' Writes sparse weak-label masks and a manifest. These are not dense
#' segmentation annotations.
#'
#' @param points A tidy point table.
#' @param image_root Image root.
#' @param out_dir Output directory.
#' @param radius Point disk radius.
#'
#' @return A mask manifest tibble.
#' @export
export_segformer_sparse <- function(points, image_root, out_dir, radius = 3) {
  make_sparse_masks(
    points = points,
    image_root = image_root,
    out_dir = out_dir,
    radius = radius
  )
}
