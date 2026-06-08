# Build, document, test, check, and install pointcoral for local RStudio use.
#
# How to run:
#   1. Open this file in RStudio.
#   2. Source the whole file.
#
# The script assumes this folder is next to the package folder:
#   PointCoralPackage/
#     pointcoral/
#     pointcoral-rstudio-workflows/

if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  active <- rstudioapi::getActiveDocumentContext()$path
  if (!is.null(active) && nzchar(active)) {
    setwd(dirname(active))
  }
}

package_dir <- normalizePath("../pointcoral", mustWork = TRUE)

message("Package directory: ", package_dir)

needed <- c("devtools", "roxygen2", "testthat", "rmarkdown")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0) {
  install.packages(missing)
}

message("Documenting package...")
devtools::document(package_dir)

message("Running tests...")
devtools::test(package_dir)

message("Running R CMD check...")
devtools::check(package_dir, document = FALSE)

message("Installing pointcoral locally...")
devtools::install(package_dir, upgrade = "never", dependencies = TRUE)

message("Done. You can now run library(pointcoral).")
