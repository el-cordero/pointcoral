# Changelog

## pointcoral 0.1.0

CRAN release: 2026-06-19

### Initial CRAN submission candidate

- Added CPCe `.cpc` import, image matching, label crosswalk support,
  ecological summaries, ML point CSV export, point patch extraction,
  sparse mask creation, QC overlays, and high-level workflow wrappers.
- Added sample CPCe/image fixtures and an example editable crosswalk.
- Added
  [`read_cpce_output_raw_tabs()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_output_raw_tabs.md)
  for extracting CPCe output workbook sheets ending in `_raw`, adding
  image names from sheet names, preserving CPCe point order with
  `point_index`, preserving CPCe group codes, and adding full
  `major_category` values.
- Added a Bootstrap 5 pkgdown website with a beginner route, grouped
  function reference, workflow examples, scientific interpretation
  guidance, citation information, and accessible coral-themed styling.
- Added source-controlled README generation, contributor and support
  policies, cross-platform R CMD check, pkgdown deployment, and optional
  OIDC Codecov workflows.
