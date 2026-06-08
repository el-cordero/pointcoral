#' Write a complete pointcoral dataset from imported points
#'
#' Runs the common local workflow: validation, ecological summaries,
#' train/validation/test splits, ML label CSVs, optional point patches, optional
#' sparse masks, and optional QC overlays. If `crosswalk` is `NULL`, the
#' workflow uses the raw CPCe labels already stored in the point table. A
#' crosswalk is an optional standardization layer for full labels, ecological
#' major classes, and custom ML classes.
#'
#' @param points Imported point data.
#' @param image_root Image root for matching images.
#' @param out_dir Output directory.
#' @param crosswalk Optional crosswalk data frame or path.
#' @param patch_size Patch size for point-centered patches.
#' @param make_patches,make_masks,make_qc Whether to write optional outputs.
#' @param class_col Class column to use for ML labels.
#'
#' @return A list containing paths, tibbles, and manifests.
#' @export
write_pointcoral_dataset <- function(points,
                                     image_root,
                                     out_dir,
                                     crosswalk = NULL,
                                     patch_size = 224,
                                     make_patches = TRUE,
                                     make_masks = FALSE,
                                     make_qc = TRUE,
                                     class_col = "ml_class") {
  points_raw <- tibble::as_tibble(points)

  tables_dir <- file.path(out_dir, "tables")
  ml_dir <- file.path(out_dir, "ml")
  patches_dir <- file.path(out_dir, "patches")
  masks_dir <- file.path(out_dir, "sparse_masks")
  qc_dir <- file.path(out_dir, "qc")

  for (dir in c(tables_dir, ml_dir, patches_dir, masks_dir, qc_dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }

  points_raw_path <- file.path(tables_dir, "points_raw.csv")
  readr::write_csv(points_raw, points_raw_path)

  crosswalk_report <- tibble::tibble()
  points_clean <- points_raw

  if (!is.null(crosswalk)) {
    crosswalk_tbl <- if (is.character(crosswalk) && length(crosswalk) == 1L) {
      read_label_crosswalk(crosswalk)
    } else {
      tibble::as_tibble(crosswalk)
    }

    crosswalk_report <- check_crosswalk(points_raw, crosswalk_tbl)
    points_clean <- standardize_labels(points_raw, crosswalk_tbl, unknown_action = "warn")
  }

  effective_class_col <- pc_resolve_label_col(
    points_clean,
    preferred = class_col,
    arg = "class_col",
    inform = TRUE
  )
  points_clean <- pc_add_class_ids(points_clean, class_col = effective_class_col)

  points_clean_path <- file.path(tables_dir, "points_clean.csv")
  readr::write_csv(points_clean, points_clean_path)

  crosswalk_check_path <- file.path(tables_dir, "crosswalk_check.csv")
  readr::write_csv(crosswalk_report, crosswalk_check_path)

  validation_report <- validate_points(points_clean)
  validation_path <- file.path(tables_dir, "validation_report.csv")
  readr::write_csv(validation_report, validation_path)

  summary_paths <- write_summary_tables(
    points_clean,
    out_dir = tables_dir,
    class_cols = c("major_category", "clean_label", effective_class_col)
  )

  split_points <- split_ml_points(points_clean, split_by = "image", seed = 1)
  ml_points <- make_ml_points(split_points, image_root = image_root, class_col = effective_class_col)
  ml_paths <- write_ml_points_csv(ml_points, ml_dir)

  patch_manifest <- tibble::tibble()
  if (isTRUE(make_patches)) {
    patch_manifest <- extract_point_patches(
      split_points,
      image_root = image_root,
      out_dir = patches_dir,
      patch_size = patch_size,
      class_col = effective_class_col,
      edge = "skip"
    )
  }

  mask_manifest <- tibble::tibble()
  if (isTRUE(make_masks)) {
    mask_manifest <- make_sparse_masks(
      split_points,
      image_root = image_root,
      out_dir = masks_dir,
      class_col = effective_class_col
    )
  }

  label_summary <- qc_label_summary(points_clean, label_col = effective_class_col)
  label_summary_path <- file.path(qc_dir, "label_summary.csv")
  readr::write_csv(label_summary, label_summary_path)

  qc_manifest <- tibble::tibble()
  if (isTRUE(make_qc)) {
    qc_manifest <- write_qc_overlays(
      split_points,
      image_root = image_root,
      out_dir = qc_dir,
      label_col = effective_class_col
    )
  }

  list(
    paths = c(
      list(
        points_raw = points_raw_path,
        points_clean = points_clean_path,
        validation_report = validation_path,
        crosswalk_check = crosswalk_check_path,
        label_summary = label_summary_path
      ),
      summary_paths,
      ml_paths
    ),
    points_raw = points_raw,
    points_clean = points_clean,
    validation_report = validation_report,
    crosswalk_check = crosswalk_report,
    class_col = effective_class_col,
    ml_points = ml_points,
    patch_manifest = patch_manifest,
    mask_manifest = mask_manifest,
    qc_manifest = qc_manifest,
    label_summary = label_summary
  )
}

#' Run the full pointcoral workflow from folders
#'
#' Reads CPCe files/exports from a folder, matches images, validates points, and
#' writes analysis/ML-ready outputs. A crosswalk is optional. Without one,
#' `pointcoral` uses the raw labels already stored in the CPCe files. With one,
#' it standardizes those raw labels to full labels, ecological classes, and
#' custom ML classes.
#'
#' @param cpce_dir Folder containing CPCe files or exports.
#' @param image_root Folder containing source images.
#' @param out_dir Output directory.
#' @param crosswalk_path Optional path to a user-supplied label crosswalk.
#' @param recursive Whether to search `cpce_dir` recursively.
#' @param class_col Class column to use for ML labels.
#' @param patch_size Patch size for point-centered patches.
#' @param make_patches,make_masks,make_qc Whether to write optional outputs.
#'
#' @return A list from [write_pointcoral_dataset()].
#' @export
run_pointcoral <- function(cpce_dir,
                           image_root,
                           out_dir,
                           crosswalk_path = NULL,
                           recursive = TRUE,
                           class_col = "ml_class",
                           patch_size = 224,
                           make_patches = TRUE,
                           make_masks = FALSE,
                           make_qc = TRUE) {
  points <- read_cpce_folder(
    path = cpce_dir,
    image_root = image_root,
    recursive = recursive
  )

  write_pointcoral_dataset(
    points = points,
    image_root = image_root,
    out_dir = out_dir,
    crosswalk = crosswalk_path,
    patch_size = patch_size,
    make_patches = make_patches,
    make_masks = make_masks,
    make_qc = make_qc,
    class_col = class_col
  )
}
