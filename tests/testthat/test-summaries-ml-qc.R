test_points_clean <- function() {
  example_dir <- system.file("extdata", package = "pointcoral")
  pts <- read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)
  xwalk <- read_label_crosswalk(file.path(example_dir, "pointcoral_example_crosswalk.csv"))
  standardize_labels(pts, xwalk)
}

test_that("summary percentages are computed by group", {
  pts <- test_points_clean()
  expect_equal(pts$raw_label[pts$raw_code == "PEFL"][1], "PEFL")
  expect_equal(pts$full_label[pts$raw_code == "PEFL"][1], "Peyssonnelia flavescens")
  expect_equal(pts$major_category[pts$raw_code == "PEFL"][1], "PEYSSONNELIACEAE")

  image_summary <- summarize_images(pts, class_col = "major_category")

  totals <- image_summary |>
    dplyr::group_by(image_id) |>
    dplyr::summarise(total = sum(percent), .groups = "drop")

  expect_equal(nrow(totals), 2)
  expect_true(all(abs(totals$total - 100) < 1e-8))
})

test_that("bare CPCe workflow works without a crosswalk", {
  example_dir <- system.file("extdata", package = "pointcoral")
  pts <- read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)

  expect_true(all(!is.na(pts$raw_label)))
  expect_true(all(is.na(pts$major_category)))

  image_summary <- summarize_images(pts)
  expect_true("raw_label" %in% names(image_summary))

  totals <- image_summary |>
    dplyr::group_by(image_id) |>
    dplyr::summarise(total = sum(percent), .groups = "drop")
  expect_true(all(abs(totals$total - 100) < 1e-8))

  split <- split_ml_points(pts, split_by = "image", train = 0.5, val = 0, test = 0.5, seed = 10)
  ml <- make_ml_points(split)
  expect_setequal(sort(unique(ml$label)), sort(unique(pts$raw_label)))
  expect_true(all(!is.na(ml$class_id)))

  out_dir <- tempfile("bare-pointcoral-")
  result <- run_pointcoral(
    cpce_dir = example_dir,
    image_root = example_dir,
    out_dir = out_dir,
    recursive = FALSE,
    make_patches = FALSE,
    make_masks = TRUE,
    make_qc = FALSE
  )

  expect_equal(result$class_col, "raw_label")
  expect_equal(nrow(result$crosswalk_check), 0)
  expect_true(file.exists(result$paths$points_clean))
  expect_true(file.exists(result$paths$labels))
  expect_true(nrow(result$mask_manifest) > 0)
  expect_true(all(!is.na(result$points_clean$class_id)))
})

test_that("train validation test splitting avoids image leakage", {
  pts <- test_points_clean()
  split <- split_ml_points(pts, split_by = "image", train = 0.5, val = 0, test = 0.5, seed = 10)

  leakage <- split |>
    dplyr::distinct(image_id, split) |>
    dplyr::count(image_id) |>
    dplyr::filter(n > 1)

  expect_equal(nrow(leakage), 0)
  expect_setequal(sort(unique(split$split)), c("test", "train"))
})

test_that("patch extraction writes patches and a manifest", {
  pts <- test_points_clean()
  pts <- split_ml_points(pts, split_by = "image", train = 1, val = 0, test = 0, seed = 1)
  small <- pts[1:3, ]
  out_dir <- tempfile("patches-")

  manifest <- extract_point_patches(
    small,
    image_root = system.file("extdata", package = "pointcoral"),
    out_dir = out_dir,
    patch_size = 32,
    edge = "pad"
  )

  expect_equal(nrow(manifest), 3)
  expect_true(all(file.exists(manifest$patch_path)))
  info <- magick::image_info(magick::image_read(manifest$patch_path[1]))
  expect_equal(info$width[1], 32)
  expect_equal(info$height[1], 32)
})

test_that("sparse masks have source image dimensions and class IDs", {
  pts <- test_points_clean()
  small <- pts[1:3, ]
  out_dir <- tempfile("masks-")

  manifest <- make_sparse_masks(
    small,
    image_root = system.file("extdata", package = "pointcoral"),
    out_dir = out_dir,
    radius = 2
  )

  expect_equal(nrow(manifest), 1)
  expect_true(file.exists(manifest$mask_path[1]))

  mask <- png::readPNG(manifest$mask_path[1])
  if (length(dim(mask)) == 3) mask <- mask[, , 1]
  vals <- sort(unique(as.integer(round(mask * 255))))

  expect_equal(nrow(mask), manifest$image_height[1])
  expect_equal(ncol(mask), manifest$image_width[1])
  expect_true(255L %in% vals)
  expect_true(any(unique(small$class_id) %in% vals))
})

test_that("validation reports missing labels and bad coordinates", {
  pts <- test_points_clean()
  bad <- pts
  bad$raw_label[1] <- NA_character_
  bad$x_px[2] <- bad$image_width[2] + 100L

  report <- validate_points(bad)

  expect_true("missing_raw_labels" %in% report$check)
  expect_true("coordinates_outside_image" %in% report$check)
})

test_that("QC overlays are written", {
  pts <- test_points_clean()
  small <- pts[1:3, ]
  out_dir <- tempfile("qc-")

  manifest <- write_qc_overlays(
    small,
    image_root = system.file("extdata", package = "pointcoral"),
    out_dir = out_dir
  )

  expect_equal(nrow(manifest), 1)
  expect_true(file.exists(manifest$overlay_path[1]))
})
