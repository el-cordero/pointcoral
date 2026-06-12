# pointcoral 0.1.0

## Initial CRAN submission candidate

- Added CPCe `.cpc` import, image matching, label crosswalk support,
  ecological summaries, ML point CSV export, point patch extraction, sparse
  mask creation, QC overlays, and high-level workflow wrappers.
- Added sample CPCe/image fixtures and an example editable crosswalk.
- Added `read_cpce_output_raw_tabs()` for extracting CPCe output workbook
  sheets ending in `_raw`, adding image names from sheet names, preserving CPCe
  point order with `point_index`, preserving CPCe group codes, and adding full
  `major_category` values.
