# Template for running pointcoral on your own CPCe/photoquadrat project.
#
# Copy this file, then edit the four paths below.

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
crosswalk_path <- "/path/to/your/crosswalk.csv"
out_dir <- file.path(getwd(), "outputs", "my_project_run")

# -------------------------------------------------------------------------
# OPTIONAL SETTINGS
# -------------------------------------------------------------------------

class_col <- "ml_class"
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

message("Done. Outputs written to: ", out_dir)
