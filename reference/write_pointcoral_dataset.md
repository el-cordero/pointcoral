# Write a complete pointcoral dataset from imported points

Runs the common local workflow: validation, ecological summaries,
train/validation/test splits, ML label CSVs, optional point patches,
optional sparse masks, and optional QC overlays. If `crosswalk` is
`NULL`, the workflow uses the raw CPCe labels already stored in the
point table. A crosswalk is an optional standardization layer for full
labels, ecological major classes, and custom ML classes.

## Usage

``` r
write_pointcoral_dataset(
  points,
  image_root,
  out_dir,
  crosswalk = NULL,
  patch_size = 224,
  make_patches = TRUE,
  make_masks = FALSE,
  make_qc = TRUE,
  class_col = "ml_class"
)
```

## Arguments

- points:

  Imported point data.

- image_root:

  Image root for matching images.

- out_dir:

  Output directory.

- crosswalk:

  Optional crosswalk data frame or path.

- patch_size:

  Patch size for point-centered patches.

- make_patches, make_masks, make_qc:

  Whether to write optional outputs.

- class_col:

  Class column to use for ML labels.

## Value

A list containing paths, tibbles, and manifests.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)
write_pointcoral_dataset(
  points = pts,
  image_root = example_dir,
  out_dir = file.path(tempdir(), "pointcoral-dataset-example"),
  make_patches = FALSE,
  make_masks = FALSE,
  make_qc = FALSE,
  class_col = "raw_label"
)
#> $paths
#> $paths$points_raw
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/points_raw.csv"
#> 
#> $paths$points_clean
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/points_clean.csv"
#> 
#> $paths$validation_report
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/validation_report.csv"
#> 
#> $paths$crosswalk_check
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/crosswalk_check.csv"
#> 
#> $paths$label_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/qc/label_summary.csv"
#> 
#> $paths$image_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/image_summary.csv"
#> 
#> $paths$transect_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/transect_summary.csv"
#> 
#> $paths$site_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/site_summary.csv"
#> 
#> $paths$class_lookup
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/tables/class_lookup.csv"
#> 
#> $paths$labels
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/ml/labels.csv"
#> 
#> $paths$class_lookup
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/ml/class_lookup.csv"
#> 
#> $paths$labels_train
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/ml/labels_train.csv"
#> 
#> $paths$labels_val
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/ml/labels_val.csv"
#> 
#> $paths$labels_test
#> [1] "/tmp/RtmpLwJlKK/pointcoral-dataset-example/ml/labels_test.csv"
#> 
#> 
#> $points_raw
#> # A tibble: 200 × 36
#>    project_id site  transect survey_date image_id image_file image_path point_id
#>    <chr>      <chr> <chr>    <date>      <chr>    <chr>      <chr>         <int>
#>  1 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        1
#>  2 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        2
#>  3 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        3
#>  4 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        4
#>  5 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        5
#>  6 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        6
#>  7 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        7
#>  8 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        8
#>  9 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        9
#> 10 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…       10
#> # ℹ 190 more rows
#> # ℹ 28 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <int>,
#> #   y_px <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, cpce_note_type <chr>,
#> #   cpc_file <chr>, codefile_path <chr>, cpce_image_path <chr>, …
#> 
#> $points_clean
#> # A tibble: 200 × 36
#>    project_id site  transect survey_date image_id image_file image_path point_id
#>    <chr>      <chr> <chr>    <date>      <chr>    <chr>      <chr>         <int>
#>  1 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        1
#>  2 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        2
#>  3 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        3
#>  4 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        4
#>  5 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        5
#>  6 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        6
#>  7 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        7
#>  8 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        8
#>  9 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        9
#> 10 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…       10
#> # ℹ 190 more rows
#> # ℹ 28 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <int>,
#> #   y_px <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, cpce_note_type <chr>,
#> #   cpc_file <chr>, codefile_path <chr>, cpce_image_path <chr>, …
#> 
#> $validation_report
#> # A tibble: 1 × 4
#>   check severity     n details                      
#>   <chr> <chr>    <int> <chr>                        
#> 1 ok    info         0 No validation issues detected
#> 
#> $crosswalk_check
#> # A tibble: 0 × 0
#> 
#> $class_col
#> [1] "raw_label"
#> 
#> $ml_points
#> # A tibble: 200 × 21
#>    image_path         image_id  x_px  y_px label class_id split project_id site 
#>    <chr>              <chr>    <int> <int> <chr>    <int> <chr> <chr>      <chr>
#>  1 /home/runner/work… HIW_158…    19    11 SPO         12 train NA         Hole…
#>  2 /home/runner/work… HIW_158…     7   107 S           11 train NA         Hole…
#>  3 /home/runner/work… HIW_158…    26   165 CALG         1 train NA         Hole…
#>  4 /home/runner/work… HIW_158…    69   202 SPO         12 train NA         Hole…
#>  5 /home/runner/work… HIW_158…    26   243 SPO         12 train NA         Hole…
#>  6 /home/runner/work… HIW_158…    43   305 SPO         12 train NA         Hole…
#>  7 /home/runner/work… HIW_158…     2   363 PEYS        10 train NA         Hole…
#>  8 /home/runner/work… HIW_158…    74   452 CALG         1 train NA         Hole…
#>  9 /home/runner/work… HIW_158…    43   469 SPO         12 train NA         Hole…
#> 10 /home/runner/work… HIW_158…    18   541 LOBO         2 train NA         Hole…
#> # ℹ 190 more rows
#> # ℹ 12 more variables: transect <chr>, survey_date <date>, image_file <chr>,
#> #   point_id <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, reviewer <chr>,
#> #   notes <chr>
#> 
#> $patch_manifest
#> # A tibble: 0 × 0
#> 
#> $mask_manifest
#> # A tibble: 0 × 0
#> 
#> $qc_manifest
#> # A tibble: 0 × 0
#> 
#> $label_summary
#> # A tibble: 18 × 4
#>    summary_type  label     n details             
#>    <chr>         <chr> <int> <chr>               
#>  1 class_balance S        65 Point count by label
#>  2 class_balance SPO      44 Point count by label
#>  3 class_balance CALG     31 Point count by label
#>  4 class_balance PEYS     13 Point count by label
#>  5 class_balance LOBO      9 Point count by label
#>  6 class_balance P         9 Point count by label
#>  7 class_balance PEFL      7 Point count by label
#>  8 class_balance MICR      6 Point count by label
#>  9 class_balance AA        4 Point count by label
#> 10 class_balance MFRN      4 Point count by label
#> 11 class_balance TURF      3 Point count by label
#> 12 class_balance PEGI      2 Point count by label
#> 13 class_balance MME       1 Point count by label
#> 14 class_balance PEME      1 Point count by label
#> 15 class_balance SS        1 Point count by label
#> 16 rare_label    MME       1 Rare label count    
#> 17 rare_label    PEME      1 Rare label count    
#> 18 rare_label    SS        1 Rare label count    
#> 
```
