#' Plot CPCe points on an image
#'
#' Draws point halos and labels on an image and returns a `magick-image` object.
#'
#' @param image_path Path to an image.
#' @param points Point rows for that image.
#' @param label_col Column to use for text labels.
#' @param point_size Point radius in pixels.
#'
#' @return A `magick-image` overlay.
#' @export
plot_points_on_image <- function(image_path,
                                 points,
                                 label_col = "ml_class",
                                 point_size = 8) {
  points <- tibble::as_tibble(points)
  pc_require_columns(points, c("x_px", "y_px"), "points")

  if (!label_col %in% names(points)) {
    cli::cli_abort("{.arg points} does not contain label column {.field {label_col}}.")
  }
  if (!file.exists(image_path)) {
    cli::cli_abort("Image does not exist: {.file {image_path}}")
  }

  img <- magick::image_read(image_path)
  info <- magick::image_info(img)
  tmp <- tempfile(fileext = ".png")

  grDevices::png(tmp, width = info$width[1], height = info$height[1], bg = "white")
  on.exit(
    {
      grDevices::dev.off()
      unlink(tmp)
    },
    add = TRUE
  )

  graphics::par(mar = c(0, 0, 0, 0))
  graphics::plot.new()
  graphics::plot.window(
    xlim = c(0, info$width[1]),
    ylim = c(info$height[1], 0),
    asp = 1
  )
  graphics::rasterImage(grDevices::as.raster(img), 0, info$height[1], info$width[1], 0)

  ok <- !is.na(points$x_px) & !is.na(points$y_px)
  points <- points[ok, , drop = FALSE]

  if (nrow(points) > 0L) {
    graphics::symbols(
      x = points$x_px,
      y = points$y_px,
      circles = rep(point_size * 1.8, nrow(points)),
      inches = FALSE,
      add = TRUE,
      fg = "white",
      bg = NA,
      lwd = 3
    )
    graphics::symbols(
      x = points$x_px,
      y = points$y_px,
      circles = rep(point_size, nrow(points)),
      inches = FALSE,
      add = TRUE,
      fg = "red",
      bg = NA,
      lwd = 2
    )

    point_labels <- if ("point_id" %in% names(points)) points$point_id else seq_len(nrow(points))
    labels <- paste0(point_labels, ":", points[[label_col]])
    label_cex <- max(0.75, min(2.2, point_size / 7))
    graphics::text(
      points$x_px + point_size + 3,
      points$y_px - point_size - 3,
      labels = labels,
      col = "black",
      cex = label_cex,
      font = 2,
      pos = 4
    )
    graphics::text(
      points$x_px + point_size + 3,
      points$y_px - point_size - 3,
      labels = labels,
      col = "yellow",
      cex = label_cex * 0.96,
      font = 2,
      pos = 4
    )
  }

  grDevices::dev.off()
  on.exit(NULL, add = FALSE)
  out <- magick::image_read(tmp)
  unlink(tmp)
  out
}

#' Write QC overlays for point annotations
#'
#' Writes one overlay image per source image.
#'
#' @param points A tidy point table.
#' @param image_root Image root used to match images when needed.
#' @param out_dir Output directory.
#' @param label_col Label column to draw.
#'
#' @return A manifest tibble of written overlays.
#' @export
write_qc_overlays <- function(points,
                              image_root,
                              out_dir,
                              label_col = "ml_class") {
  points <- tibble::as_tibble(points)
  if (!"image_path" %in% names(points) || all(is.na(points$image_path))) {
    points <- match_images(points, image_root = image_root)
  }
  pc_require_columns(points, c("image_path", "image_id", "x_px", "y_px", label_col), "points")

  overlay_dir <- file.path(out_dir, "overlays")
  dir.create(overlay_dir, recursive = TRUE, showWarnings = FALSE)

  valid_points <- points |>
    dplyr::filter(!is.na(.data$image_path))

  manifest <- valid_points |>
    split(valid_points$image_path) |>
    purrr::imap_dfr(function(df, image_path) {
      if (!file.exists(image_path)) {
        cli::cli_warn("Skipping QC overlay for missing image {.file {image_path}}.")
        return(tibble::tibble())
      }

      overlay <- plot_points_on_image(
        image_path = image_path,
        points = df,
        label_col = label_col
      )

      out_file <- file.path(overlay_dir, paste0(pc_safe_slug(df$image_id[1]), "_qc.jpg"))
      out_file <- pc_make_unique_file(out_file)
      magick::image_write(overlay, path = out_file, format = "jpeg", quality = 85)

      tibble::tibble(
        image_path = pc_normalize_path(image_path, must_work = TRUE),
        image_id = df$image_id[1],
        overlay_path = pc_normalize_path(out_file, must_work = TRUE),
        n_points = nrow(df),
        label_col = label_col
      )
    })

  manifest_path <- file.path(out_dir, "overlay_manifest.csv")
  readr::write_csv(manifest, manifest_path)
  manifest
}
