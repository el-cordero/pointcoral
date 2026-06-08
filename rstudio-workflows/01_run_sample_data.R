# Run pointcoral on the bundled sample CPCe files/images.
#
# This is the fastest way to confirm that the package works on your machine.

if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  active <- rstudioapi::getActiveDocumentContext()$path
  if (!is.null(active) && nzchar(active)) {
    setwd(dirname(active))
  }
}

package_dir <- normalizePath("../pointcoral", mustWork = TRUE)
devtools::load_all(package_dir)

example_dir <- file.path(package_dir, "inst", "extdata")
out_dir <- file.path(getwd(), "outputs", "sample_run")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Bare minimum: CPCe files plus matching images. The raw labels in the CPCe
# files are used directly for summaries, QC overlays, patches, and masks.
result <- run_pointcoral(
  cpce_dir = example_dir,
  image_root = example_dir,
  out_dir = out_dir,
  recursive = FALSE,
  patch_size = 224,
  make_patches = TRUE,
  make_masks = TRUE,
  make_qc = TRUE
)

message("Bare sample run complete.")
message("Outputs written to: ", out_dir)
message("Label column used: ", result$class_col)

print(result$validation_report)
print(head(result$ml_points))

# Optional bonus: apply the bundled crosswalk to convert short raw labels like
# SPO/CALG/PEYS into full labels, major classes, and project-specific ML classes.
crosswalk_path <- file.path(example_dir, "pointcoral_example_crosswalk.csv")
standardized_out_dir <- file.path(getwd(), "outputs", "sample_run_with_crosswalk")

standardized <- run_pointcoral(
  cpce_dir = example_dir,
  image_root = example_dir,
  out_dir = standardized_out_dir,
  crosswalk_path = crosswalk_path,
  recursive = FALSE,
  class_col = "ml_class",
  patch_size = 224,
  make_patches = FALSE,
  make_masks = TRUE,
  make_qc = TRUE
)

message("Standardized sample run complete.")
message("Standardized outputs written to: ", standardized_out_dir)
print(head(standardized$points_clean[, c("raw_label", "full_label", "major_category", "class_id")]))

if (interactive()) {
  utils::browseURL(out_dir)
}
