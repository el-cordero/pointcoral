# pointcoral workflow inventory

Inventory date: 2026-06-07

## Repository contents found

The starting workspace was not a git repository. A new package folder was created at
`pointcoral/` and initialized as a git repository with remote:

`https://github.com/el-cordero/pointcoral.git`

Original source files were left in place under `_existing/`.

### R scripts

- `_existing/clean_transects_to_segformer_masks.R`
- `_existing/clean_transects_to_segformer_masks_v2.R`
- `_existing/clean_transects_to_segformer_data_split_v2.R`
- `_existing/clean_transects_to_segformer_masks_qc_test.R`

### Python script

- `_existing/clean_transect_raw.py`

This script is not used as a package dependency. Its workflow was inspected as source
logic for CPCe exported table parsing and editable crosswalk creation.

### Notebooks

No `.Rmd`, `.qmd`, or `.ipynb` notebooks were found in the starting workspace.

### CPCe `.cpc` files

- `_existing/samples/H_211_E_U-1.cpc`
- `_existing/samples/HIW_158_W_U-1.cpc`

### CPCe exports, Excel files, CSV files, TSV files

No standalone `.csv`, `.tsv`, `.xls`, or `.xlsx` data files were present in the
starting workspace. The existing Python script references many external Excel
"Total" and "Data Summary" files on the original user's machine, but those files
were not present here.

### Example images

- `_existing/samples/H_211_E_U-1.jpg`
- `_existing/samples/HIW_158_W_U-1.jpg`

### Existing crosswalk/cross table files

No saved crosswalk file was present in the starting workspace. Crosswalk logic was
embedded in scripts:

- `level1_map`, `class_to_id`, and `class_colors` in the SegFormer mask scripts map
  CPCe abbreviation codes to broad ML classes and class IDs.
- `clean_transect_raw.py` generates or updates `subcategory_crosswalk_editable.csv`
  in an external output folder, then applies mapping patches from several Python
  dictionaries. This file contains the preferred `major_class` and `label_class`
  vocabulary for ecological analysis.

The package therefore includes a generated example crosswalk based on the short
CPCe labels in the R mask scripts, with full labels and major/subclass terms
aligned to `clean_transect_raw.py`. This is an example, not a universal class
system.

## Current workflow summary

### `.cpc` point workflow

The R mask scripts:

1. Recursively discover `.cpc` files.
2. Match each `.cpc` to an image with the same basename and a `.jpg`/`.jpeg`
   extension.
3. Parse CPCe files:
   - line 1: codefile path, original image path, and CPCe header dimensions
   - lines 2-5: ROI vertex coordinates
   - line 6: number of points
   - next `n` lines: point coordinates in CPCe coordinate space
   - next `n` lines: point ID, CPCe label/code, notes field, extra notes field
4. Convert CPCe coordinates to image pixels with proportional scaling.
5. Map CPCe codes to a level-1 class using `level1_map`.
6. Map level-1 classes to integer IDs using `class_to_id`.
7. Write sparse point-seeded PNG masks using an `ignore_index` value of 255.
8. Optionally expand sparse masks with dense prediction CSVs if available.
9. Write point TXT files (`x y class_id`).
10. Write QC overlays showing points and labels on source images.
11. Write manifests, class lookup tables, image checks, exclusions, and mask audits.

The package preserves the tested local `.cpc` parsing and proportional coordinate
conversion. Dense prediction expansion was not promoted to a core user-facing
function because it depends on an external model prediction CSV and is not part of
the requested first package API.

### Dataset split / tiling workflow

`clean_transects_to_segformer_data_split_v2.R`:

1. Reads a mask manifest and optional QC exclusions.
2. Splits images into train/validation/test by image or metadata group.
3. Tiles each image and matching mask into a fixed grid.
4. Writes tiled images, tiled masks, tiled point files, split summaries, and a
   dataset manifest.

The package implements train/validation/test splitting and point-centered patch
extraction. Full image/mask tiling is noted as a future extension.

### CPCe exported ecological table workflow

`clean_transect_raw.py`:

1. Reads CPCe Excel exported "Data Summary" sheets and a special permanent
   transect workbook.
2. Parses survey metadata from filenames and workbook headers.
3. Extracts subcategory percent-cover values into tidy rows.
4. Classifies labels as subcategory, major category, artifact, disease/condition,
   note, or drop.
5. Creates or updates an editable crosswalk.
6. Applies mapping patches for known labels.
7. Produces tidy values, label summaries, QA checks, ecological transect-sum
   checks, coral species summaries, and multitemporal site-depth summaries.

The package includes generic CPCe export reading for CSV/Excel point-like tables
and notes that project-specific summary workbook extraction remains TODO because
the referenced workbooks were not present in this workspace.

## Input formats currently handled by existing scripts

Confirmed locally:

- CPCe `.cpc` files with the structure shown above.
- JPEG images matching `.cpc` basenames.

Handled by inspected scripts but not testable from files in this workspace:

- CPCe dense prediction CSVs with columns such as `image_file`, `x_img`, `y_img`,
  `pred_class`, and `confidence`.
- CPCe Excel "Data Summary" exports (`.xls`/`.xlsx`) in several project-specific
  filename/header layouts.
- Existing editable crosswalk CSVs generated by the Python script.
- Existing mask manifests and point TXT files generated by the R scripts.

## Relationship between sample `.cpc` files and images

The sample `.cpc` files and images are basename-matched:

- `H_211_E_U-1.cpc` <-> `H_211_E_U-1.jpg`
- `HIW_158_W_U-1.cpc` <-> `HIW_158_W_U-1.jpg`

The image paths embedded inside the `.cpc` files are Windows paths from the
original CPCe project. The local samples are matched by basename instead.

Image dimensions:

- `H_211_E_U-1.jpg`: 3023 x 1917
- `HIW_158_W_U-1.jpg`: 3040 x 1912

Each sample `.cpc` file contains 100 points and 100 labels.

## Crosswalk structure inferred from existing logic

The R scripts use:

- raw CPCe code, e.g. `AA`, `SPO`, `CALG`, `PEYS`, `S`
- full biological/benthic label, e.g. `Sponge`, `Coralline algae`,
  `Peyssonnelia`, `Sand`
- mapped major class, e.g. `CORAL (C)`, `SPONGES (S)`,
  `CORALLINE ALGAE (CA)`, `SAND, PAVEMENT, RUBBLE (SPR)`
- subclass/label class, e.g. `subcategory`, `artifact`,
  `disease_or_condition`
- integer class ID
- color hex values for QC/color masks

The Python ecological export script uses:

- `label_clean`
- `label_class`
- `major_class`
- `keep`

The package example crosswalk starts from the R level-1 code map and uses flexible
columns:

- `raw_code`
- `raw_label` (the original short CPCe code)
- `full_label`
- `clean_label`
- `label_class`
- `major_category`
- `ml_class`
- `class_id`
- `include_in_analysis`
- `include_in_ml`
- `color_hex`
- `notes`

Users should inspect their own CPCe labels and provide a project-specific
crosswalk when their codes, benthic categories, species labels, or ML class scheme
differ.

## Main output formats already produced by existing scripts

From the R mask scripts:

- Sparse mask PNG files
- Optional color mask PNG files
- QC overlay JPEG files
- Point TXT files with `x y class_id`
- Mask manifests as CSV
- Class lookup/color lookup CSV
- QC exclusions CSV/XLSX
- Image integrity CSV/XLSX
- Mask value audit CSV/XLSX

From the R split/tiling script:

- Train/validation/test image folders
- Train/validation/test mask folders
- Train/validation/test point TXT folders
- Dataset manifest CSV
- Split count CSVs by tile, image, site, and date
- Split unit CSV

From the Python ecological export script:

- Editable crosswalk CSV
- Collaborator mapping workbook
- Tidy ecological values CSV
- Label summary CSV
- Extraction issues CSV
- Transect sum QA CSVs
- Coral species summaries printed to console
- Multitemporal site-depth summary CSV

## Ambiguities preserved as TODOs in package code

- CPCe header dimensions and ROI vertex extents are both available in `.cpc`
  files. Existing scripts scale by ROI maxima, so the package preserves that
  behavior and stores header dimensions separately where possible.
- The third and fourth fields in CPCe label rows are treated as CPCe notes fields,
  but their exact reviewer/notes semantics are project-specific.
- The project-specific Excel summary workbook parser from the Python script needs
  representative `.xls`/`.xlsx` fixtures before it can be safely translated and
  tested in R.
- Full SegFormer tiling is left as a future extension; the package first exposes
  point labels, point-centered patches, sparse masks, and split manifests.
