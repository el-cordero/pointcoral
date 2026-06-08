# Template for running pointcoral on your own CPCe/photoquadrat project.
#
# Copy this file, then edit the paths below.

if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  active <- rstudioapi::getActiveDocumentContext()$path
  if (!is.null(active) && nzchar(active)) {
    setwd(dirname(active))
  }
}

package_dir <- normalizePath("../pointcoral", mustWork = TRUE)
devtools::load_all(package_dir)

# -------------------------------------------------------------------------
# EDIT THESE PATHS
# -------------------------------------------------------------------------

cpce_dir <- "/path/to/your/cpce_files"
image_root <- "/path/to/your/images"
out_dir <- file.path(getwd(), "outputs", "my_project_run")

# Optional. Leave as NULL for the bare workflow, which uses the raw CPCe labels
# already stored in your .cpc files. Set this to a CSV/XLSX path when you want
# full labels, major categories, subclasses, or custom ML classes.
crosswalk_path <- NULL
# crosswalk_path <- "/path/to/your/crosswalk.csv"

# -------------------------------------------------------------------------
# OPTIONAL SETTINGS
# -------------------------------------------------------------------------

# Use "raw_label" for the bare workflow. Use "ml_class", "major_category",
# "clean_label", or another column after applying a crosswalk.
class_col <- "raw_label"
patch_size <- 224
make_patches <- TRUE
make_masks <- TRUE
make_qc <- TRUE

# -------------------------------------------------------------------------
# RUN
# -------------------------------------------------------------------------

result <- run_pointcoral(
  cpce_dir = cpce_dir,
  image_root = image_root,
  crosswalk_path = crosswalk_path,
  out_dir = out_dir,
  recursive = TRUE,
  class_col = class_col,
  patch_size = patch_size,
  make_patches = make_patches,
  make_masks = make_masks,
  make_qc = make_qc
)

print(result$validation_report)
print(result$crosswalk_check)
message("Label column used: ", result$class_col)

message("Done. Outputs written to: ", out_dir)
