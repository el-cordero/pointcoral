# pointcoral workflow inventory

Inventory date: 2026-06-08

This note summarizes the package-facing workflows, supported inputs, bundled
example data, output formats, and planned extensions for `pointcoral`.

## Package Scope

`pointcoral` is designed for local CPCe/photoquadrat point-count workflows. It
can be used in two ways:

- Bare workflow: read CPCe point annotations and use the raw labels already
  stored in the `.cpc` files.
- Standardized workflow: apply a user-supplied crosswalk to map raw CPCe labels
  to full labels, ecological classes, ML classes, and class IDs.

The package is intentionally local and open-source. It does not require MERMAID,
CoralNet accounts, cloud APIs, Python, or closed platforms.

## Supported Inputs

Tested with bundled fixtures:

- CPCe `.cpc` files following the sample text structure.
- CPCe output workbooks with raw worksheets ending in `_raw`.
- JPEG images matched to `.cpc` files by basename.
- CSV crosswalk files with raw label/code columns and output class columns.

Implemented with generic readers and requiring project validation:

- Point-like CSV, TSV, XLS, or XLSX exports with recognizable label and
  coordinate columns.
- User-provided crosswalk tables in CSV, TSV, XLS, or XLSX format.

Planned or project-specific formats that need representative fixtures before
the package should claim full support:

- CPCe Excel "Data Summary" workbooks.
- Permanent transect workbook layouts.
- Dense prediction CSV expansion for pseudo-mask growth.
- Full image/mask tiling for semantic-segmentation training.

## Bundled Example Data

The package includes two `.cpc` files and two matching JPEG images in
`inst/extdata`.

The sample files are matched by basename:

- `H_211_E_U-1.cpc` with `H_211_E_U-1.jpg`
- `HIW_158_W_U-1.cpc` with `HIW_158_W_U-1.jpg`

Each bundled `.cpc` file contains 100 point annotations. CPCe paths embedded
inside `.cpc` files may refer to older local image locations, so the package
matches images by basename against `image_root`.

## CPCe Parsing Model

The tested `.cpc` parser reads:

1. Header row with CPCe codefile path, image path, and header dimensions.
2. Four ROI vertex rows.
3. Point count row.
4. Point coordinate rows in CPCe coordinate space.
5. Point label rows containing point ID, raw label, and optional notes.

The parser preserves original CPCe coordinates in `cpce_x` and `cpce_y`. When
image dimensions are available, `convert_cpce_coords()` scales CPCe coordinates
to image pixels and stores the results in `x_px` and `y_px`.

## Label Model

Bare CPCe workflow:

- `raw_code` and `raw_label` store the original short CPCe labels.
- Summaries, QC overlays, ML labels, patches, and sparse masks can use
  `raw_label` directly.
- Class IDs can be generated from the observed raw labels when a crosswalk is
  not supplied.

Standardized workflow:

- `read_label_crosswalk()` reads a user-supplied mapping table.
- `check_crosswalk()` reports unmapped labels, unused mappings, duplicates,
  missing class IDs, and excluded classes.
- `standardize_labels()` preserves raw labels and joins standardized fields such
  as `full_label`, `clean_label`, `label_class`, `major_category`, `ml_class`,
  and `class_id`.
- `read_cpce_output_raw_tabs()` extracts CPCe workbook sheets ending in `_raw`,
  skips `deep_cres_` sheets by default, preserves workbook group/category codes,
  and adds full `major_category` values.

The bundled example crosswalk is illustrative. Users should inspect their own
CPCe labels and provide a project-specific crosswalk when their codes, benthic
categories, species labels, or ML class scheme differ.

## Core Point Table

Where available, pointcoral returns:

- `project_id`
- `site`
- `transect`
- `survey_date`
- `image_id`
- `image_file`
- `image_path`
- `point_id`
- `cpce_x`
- `cpce_y`
- `cpce_width`
- `cpce_height`
- `image_width`
- `image_height`
- `x_px`
- `y_px`
- `raw_code`
- `raw_label`
- `full_label`
- `clean_label`
- `label_class`
- `major_category`
- `ml_class`
- `class_id`
- `reviewer`
- `notes`

Extra source columns are preserved.

## Current Outputs

Ecological outputs:

- Raw and cleaned point CSV files.
- Validation reports.
- Image-level summary tables.
- Transect-level summary tables.
- Site-level summary tables.
- Class lookup tables.

Machine-learning outputs:

- `labels.csv`
- Split-specific label CSV files.
- Point-centered image patches.
- Patch manifest CSV.
- Sparse weak-label semantic masks.
- Sparse mask manifest CSV.
- Optional helper exports for local CoralNet-style point CSVs, YOLO-style
  classification patches, and SegFormer-style sparse masks.

QC outputs:

- Image overlays showing points and labels.
- Overlay manifest CSV.
- Label summary CSV with class balance, rare labels, unmapped labels, and
  duplicate point checks.

## Implementation Notes

- Raw CPCe labels and coordinates are always preserved.
- Crosswalks are optional and project-specific.
- Unmapped labels are never silently dropped.
- Sparse masks are weak labels, not dense human-annotated segmentation masks.
- File-writing functions return paths or manifests so downstream workflows can
  inspect what was created.

## TODO

- Add representative tests for project-specific CPCe summary workbooks.
- Add tests for additional CPCe export layouts as users provide fixtures.
- Add optional full-image tiling workflows for segmentation training.
- Expand documentation with more real-world crosswalk examples from different
  label systems.
