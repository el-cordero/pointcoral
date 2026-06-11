# Build README figures from bundled sample CPCe files/images.
#
# Run from the package root:
#   Rscript data-raw/build-readme-figures.R

library(dplyr)
library(magick)
library(png)

`%||%` <- function(x, y) {
  if (length(x) == 0 || is.na(x)) y else x
}

if (!requireNamespace("pointcoral", quietly = TRUE)) {
  devtools::load_all(".", quiet = TRUE)
} else {
  library(pointcoral)
}

dir.create("man/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("man/figures/readme-demo", recursive = TRUE, showWarnings = FALSE)

example_dir <- system.file("extdata", package = "pointcoral")
if (example_dir == "") {
  example_dir <- "inst/extdata"
}

crosswalk_path <- file.path(example_dir, "pointcoral_example_crosswalk.csv")

points_raw <- read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)
crosswalk <- read_label_crosswalk(crosswalk_path)
points_clean <- standardize_labels(points_raw, crosswalk)
points_split <- split_ml_points(points_clean, split_by = "image", train = 0.5, val = 0, test = 0.5, seed = 3)

readr::write_csv(
  summarize_images(points_clean, class_col = "major_category"),
  "man/figures/readme-demo/image_summary_sample.csv"
)

# 1. QC overlay ------------------------------------------------------------
one_image <- unique(points_clean$image_path)[1]
one_points <- points_clean[points_clean$image_path == one_image, ]

qc_img <- plot_points_on_image(
  image_path = one_image,
  points = one_points,
  label_col = "raw_label",
  point_size = 9
)

qc_img <- image_resize(qc_img, "1200x")
image_write(qc_img, "man/figures/sample-qc-overlay.jpg", quality = 90)

# 2. Percent-cover chart ---------------------------------------------------
summary_major <- summarize_points(
  points_clean,
  by = character(),
  class_col = "major_category"
) |>
  arrange(desc(percent))

chart_path <- "man/figures/sample-cover-summary.png"
old_chart_par <- NULL
chart_device_open <- FALSE
png(chart_path, width = 1600, height = 950, res = 160, bg = "white")
chart_device_open <- TRUE
old_chart_par <- par(no.readonly = TRUE)
on.exit(
  {
    if (isTRUE(chart_device_open)) {
      if (!is.null(old_chart_par)) {
        par(old_chart_par)
      }
      dev.off()
    }
  },
  add = TRUE
)
par(mar = c(5, 15, 4, 2), family = "sans")
bar_cols <- c(
  "#33cc66", "#3399ff", "#d8c28a", "#8b0000", "#cc3366",
  "#ff4d4d", "#ffd700", "#bdbdbd"
)
bp <- barplot(
  height = summary_major$percent,
  names.arg = summary_major$major_category,
  horiz = TRUE,
  las = 1,
  xlim = c(0, max(summary_major$percent) + 8),
  col = rep(bar_cols, length.out = nrow(summary_major)),
  border = NA,
  xlab = "Percent cover from CPCe points",
  main = "Sample photoquadrat point-count summary"
)
grid(nx = NULL, ny = NA, col = "#eeeeee")
box(bty = "l")
text(
  x = summary_major$percent + 1,
  y = bp,
  labels = paste0(round(summary_major$percent, 1), "%"),
  cex = 0.8
)
par(old_chart_par)
old_chart_par <- NULL
dev.off()
chart_device_open <- FALSE

# 3. Patch contact sheet ---------------------------------------------------
patch_dir <- tempfile("pointcoral-readme-patches-")
patch_manifest <- extract_point_patches(
  points_split[1:12, ],
  image_root = example_dir,
  out_dir = patch_dir,
  patch_size = 224,
  class_col = "clean_label",
  edge = "pad"
)

patch_imgs <- lapply(seq_len(nrow(patch_manifest)), function(i) {
  img <- image_read(patch_manifest$patch_path[i])
  img <- image_border(img, color = "#ffffff", geometry = "8x8")
  image_annotate(
    img,
    text = patch_manifest$label[i],
    size = 16,
    color = "white",
    strokecolor = "black",
    gravity = "southwest",
    location = "+8+8"
  )
})

patch_sheet <- image_montage(
  image_join(patch_imgs),
  tile = "4x3",
  geometry = "260x260+8+8",
  bg = "#f7f9fb"
)
image_write(patch_sheet, "man/figures/sample-patch-contact-sheet.jpg", format = "jpeg", quality = 92)

# 4. Sparse mask preview ---------------------------------------------------
mask_dir <- tempfile("pointcoral-readme-masks-")
mask_manifest <- make_sparse_masks(
  one_points,
  image_root = example_dir,
  out_dir = mask_dir,
  radius = 18
)

mask <- png::readPNG(mask_manifest$mask_path[1])
if (length(dim(mask)) == 3) {
  mask <- mask[, , 1]
}
mask_vals <- as.integer(round(mask * 255))
dim(mask_vals) <- dim(mask)

class_lookup <- make_class_lookup(points_clean, class_col = "ml_class", id_col = "class_id")
palette <- c(
  "#ff4d4d", "#ff944d", "#3399ff", "#cc66ff", "#33cc66",
  "#cc3366", "#66cc99", "#8b0000", "#d8c28a", "#8c564b",
  "#000000", "#ffd700", "#9acd32", "#00ffff", "#bdbdbd"
)
color_for <- setNames(palette[seq_len(nrow(class_lookup))], class_lookup$class_id)

rgb_arr <- array(1, dim = c(nrow(mask_vals), ncol(mask_vals), 3))
rgb_arr[] <- 0.95
for (class_id in names(color_for)) {
  if (is.na(class_id) || class_id == "") {
    next
  }
  idx <- which(mask_vals == as.integer(class_id), arr.ind = TRUE)
  if (length(idx) > 0 && NROW(idx) > 0) {
    rgb <- grDevices::col2rgb(color_for[[class_id]]) / 255
    rgb_arr[idx[, 1], idx[, 2], 1] <- rgb[1]
    rgb_arr[idx[, 1], idx[, 2], 2] <- rgb[2]
    rgb_arr[idx[, 1], idx[, 2], 3] <- rgb[3]
  }
}

sparse_path <- tempfile(fileext = ".png")
png::writePNG(rgb_arr, sparse_path)
sparse_img <- image_read(sparse_path) |>
  image_resize("1200x") |>
  image_annotate(
    text = "Sparse mask preview: colored disks are CPCe point labels; pale pixels are ignore_index",
    size = 24,
    color = "black",
    boxcolor = "#ffffffcc",
    gravity = "northwest",
    location = "+20+20"
  )
image_write(sparse_img, "man/figures/sample-sparse-mask-preview.png", format = "png")
unlink(sparse_path)

# 5. Crosswalk and point preview tables as CSVs for README verification -----
crosswalk_preview <- crosswalk |>
  filter(raw_code %in% c("SPO", "CALG", "PEYS", "PEFL", "LOBO", "S", "P", "AA", "SS")) |>
  select(raw_label, full_label, label_class, major_category, class_id)

readr::write_csv(crosswalk_preview, "man/figures/readme-demo/crosswalk_preview.csv")

point_preview <- points_clean |>
  select(image_id, point_id, x_px, y_px, raw_label, full_label, major_category, class_id) |>
  slice(1:10)

readr::write_csv(point_preview, "man/figures/readme-demo/point_preview.csv")

message("README figures written to man/figures/")
