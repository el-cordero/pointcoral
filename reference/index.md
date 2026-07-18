# Package index

## Import CPCe annotations and match images

Read supported CPCe files and tables, match images, and convert
coordinates.

- [`read_cpce_file()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_file.md)
  :

  Read one CPCe `.cpc` file

- [`read_cpce_export()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_export.md)
  : Read a CPCe CSV or Excel export

- [`read_cpce_output_raw_tabs()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_output_raw_tabs.md)
  :

  Read `_raw` sheets from a CPCe output workbook

- [`read_cpce_folder()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_folder.md)
  : Read CPCe files and exports from a folder

- [`match_images()`](https://el-cordero.github.io/pointcoral/reference/match_images.md)
  : Match CPCe point rows to image files

- [`convert_cpce_coords()`](https://el-cordero.github.io/pointcoral/reference/convert_cpce_coords.md)
  : Convert CPCe coordinates to image pixel coordinates

## Standardize labels and classes

Read, check, and apply project-specific label crosswalks.

- [`read_label_crosswalk()`](https://el-cordero.github.io/pointcoral/reference/read_label_crosswalk.md)
  : Read a label crosswalk
- [`check_crosswalk()`](https://el-cordero.github.io/pointcoral/reference/check_crosswalk.md)
  : Check a label crosswalk against point data
- [`standardize_labels()`](https://el-cordero.github.io/pointcoral/reference/standardize_labels.md)
  : Standardize CPCe labels with a crosswalk
- [`make_class_lookup()`](https://el-cordero.github.io/pointcoral/reference/make_class_lookup.md)
  : Make a class lookup table

## Validate and visually review points

Detect table problems and create image-based quality-control products.

- [`validate_points()`](https://el-cordero.github.io/pointcoral/reference/validate_points.md)
  : Validate a point table
- [`qc_label_summary()`](https://el-cordero.github.io/pointcoral/reference/qc_label_summary.md)
  : Summarize point-label QC issues
- [`plot_points_on_image()`](https://el-cordero.github.io/pointcoral/reference/plot_points_on_image.md)
  : Plot CPCe points on an image
- [`write_qc_overlays()`](https://el-cordero.github.io/pointcoral/reference/write_qc_overlays.md)
  : Write QC overlays for point annotations

## Calculate and write point-count summaries

Summarize observed point labels at image, transect, site, or custom
levels.

- [`summarize_points()`](https://el-cordero.github.io/pointcoral/reference/summarize_points.md)
  : Summarize point counts and percent cover
- [`summarize_images()`](https://el-cordero.github.io/pointcoral/reference/summarize_images.md)
  : Summarize points at image level
- [`summarize_transects()`](https://el-cordero.github.io/pointcoral/reference/summarize_transects.md)
  : Summarize points at transect level
- [`summarize_sites()`](https://el-cordero.github.io/pointcoral/reference/summarize_sites.md)
  : Summarize points at site level
- [`write_summary_tables()`](https://el-cordero.github.io/pointcoral/reference/write_summary_tables.md)
  : Write ecological summary tables

## Prepare machine-learning datasets

Split, export, crop, and encode point annotations for local downstream
workflows.

- [`split_ml_points()`](https://el-cordero.github.io/pointcoral/reference/split_ml_points.md)
  : Split ML points into train/validation/test sets
- [`make_ml_points()`](https://el-cordero.github.io/pointcoral/reference/make_ml_points.md)
  : Make an ML-ready point-label table
- [`write_ml_points_csv()`](https://el-cordero.github.io/pointcoral/reference/write_ml_points_csv.md)
  : Write ML point CSV files
- [`extract_point_patches()`](https://el-cordero.github.io/pointcoral/reference/extract_point_patches.md)
  : Extract point-centered image patches
- [`make_sparse_masks()`](https://el-cordero.github.io/pointcoral/reference/make_sparse_masks.md)
  : Create sparse semantic segmentation masks from point labels
- [`export_coralnet_points()`](https://el-cordero.github.io/pointcoral/reference/export_coralnet_points.md)
  : Export point labels in a simple CoralNet-style CSV
- [`export_yolo_classification()`](https://el-cordero.github.io/pointcoral/reference/export_yolo_classification.md)
  : Export YOLO-style classification patches
- [`export_segformer_sparse()`](https://el-cordero.github.io/pointcoral/reference/export_segformer_sparse.md)
  : Export SegFormer-style sparse masks

## Run end-to-end workflows

Coordinate the common import, summary, QC, and export steps.

- [`write_pointcoral_dataset()`](https://el-cordero.github.io/pointcoral/reference/write_pointcoral_dataset.md)
  : Write a complete pointcoral dataset from imported points
- [`run_pointcoral()`](https://el-cordero.github.io/pointcoral/reference/run_pointcoral.md)
  : Run the full pointcoral workflow from folders

## Package overview

- [`pointcoral`](https://el-cordero.github.io/pointcoral/reference/pointcoral-package.md)
  [`pointcoral-package`](https://el-cordero.github.io/pointcoral/reference/pointcoral-package.md)
  : pointcoral: Point-Count Processing for Coral Photoquadrats
