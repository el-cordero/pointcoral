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
crosswalk_path <- file.path(example_dir, "pointcoral_example_crosswalk.csv")
out_dir <- file.path(getwd(), "outputs", "sample_run")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

result <- run_pointcoral(
  cpce_dir = example_dir,
  image_root = example_dir,
  crosswalk_path = crosswalk_path,
  out_dir = out_dir,
  recursive = FALSE,
  class_col = "ml_class",
  patch_size = 224,
  make_patches = TRUE,
  make_masks = TRUE,
  make_qc = TRUE
)

message("Sample run complete.")
message("Outputs written to: ", out_dir)

print(result$validation_report)
print(head(result$ml_points))

if (interactive()) {
  utils::browseURL(out_dir)
}
