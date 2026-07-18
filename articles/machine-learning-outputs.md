# Machine-learning outputs and leakage-aware splits

`pointcoral` prepares local files for downstream ML work. It does not
train, validate, select, or deploy a model.

``` r

library(pointcoral)

example_dir <- system.file("extdata", package = "pointcoral")
points <- read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)
crosswalk <- read_label_crosswalk(file.path(
  example_dir, "pointcoral_example_crosswalk.csv"
))
points <- standardize_labels(points, crosswalk)
```

## Choose the target label deliberately

`raw_label`, `full_label`, `major_category`, and `ml_class` answer
different questions. A broader ML class can improve sample counts while
discarding taxonomic detail. The class scheme should be fixed and
versioned before model evaluation. `include_in_ml` can exclude
explicitly reviewed crosswalk rows.

``` r

qc_label_summary(points, label_col = "ml_class", rare_threshold = 5L) |>
  head(12)
#> # A tibble: 6 × 4
#>   summary_type  label                            n details             
#>   <chr>         <chr>                        <int> <chr>               
#> 1 class_balance SAND, PAVEMENT, RUBBLE (SPR)    74 Point count by label
#> 2 class_balance SPONGES (S)                     44 Point count by label
#> 3 class_balance CORALLINE ALGAE (CA)            31 Point count by label
#> 4 class_balance PEYSSONNELIACEAE                23 Point count by label
#> 5 class_balance MACROALGAE (MA)                 18 Point count by label
#> 6 class_balance CORAL (C)                       10 Point count by label
```

## Split related observations together

Points from one photo share pixels, lighting, camera properties, and
scene context. Never randomly split individual points when the
evaluation claim is about unseen images.

``` r

split_points <- split_ml_points(
  points,
  split_by = "image",
  train = 0.5,
  val = 0,
  test = 0.5,
  seed = 10
)

unique(split_points[c("image_id", "split")])
#> # A tibble: 2 × 2
#>   image_id      split
#>   <chr>         <chr>
#> 1 HIW_158_W_U-1 train
#> 2 H_211_E_U-1   test
```

For monitoring data, image-level separation may still leak transect,
site, date, observer, or camera information. Use `split_by = "transect"`
or `split_by = "site"` when supported by populated metadata, or
construct a project-specific external split when those boundaries are
not sufficient.

## Write point-label tables

``` r

ml_points <- make_ml_points(split_points, class_col = "ml_class")
knitr::kable(
  head(ml_points[c(
    "image_id", "x_px", "y_px", "label", "class_id", "split"
  )], 8),
  caption = "ML-ready rows retain point locations and split membership."
)
```

| image_id      | x_px | y_px | label                        | class_id | split |
|:--------------|-----:|-----:|:-----------------------------|---------:|:------|
| HIW_158_W_U-1 |   19 |   11 | SPONGES (S)                  |        2 | train |
| HIW_158_W_U-1 |    7 |  107 | SAND, PAVEMENT, RUBBLE (SPR) |        8 | train |
| HIW_158_W_U-1 |   26 |  165 | CORALLINE ALGAE (CA)         |        7 | train |
| HIW_158_W_U-1 |   69 |  202 | SPONGES (S)                  |        2 | train |
| HIW_158_W_U-1 |   26 |  243 | SPONGES (S)                  |        2 | train |
| HIW_158_W_U-1 |   43 |  305 | SPONGES (S)                  |        2 | train |
| HIW_158_W_U-1 |    2 |  363 | PEYSSONNELIACEAE             |        5 | train |
| HIW_158_W_U-1 |   74 |  452 | CORALLINE ALGAE (CA)         |        7 | train |

ML-ready rows retain point locations and split membership. {.table}

``` r


labels_dir <- tempfile("pointcoral-labels-")
label_paths <- write_ml_points_csv(ml_points, labels_dir)
basename(unlist(label_paths))
#> [1] "labels.csv"       "class_lookup.csv" "labels_train.csv" "labels_val.csv"  
#> [5] "labels_test.csv"
```

## Extract patches

`patch_size` is a width and height in pixels. It controls visual
context, not a constant physical area unless image scale is constant.

``` r

patch_dir <- tempfile("pointcoral-patches-")
patch_manifest <- extract_point_patches(
  split_points[1:3, ],
  image_root = example_dir,
  out_dir = patch_dir,
  patch_size = 64,
  class_col = "ml_class",
  edge = "pad"
)

transform(
  patch_manifest,
  patch_file = basename(patch_path)
)[c("image_id", "point_id", "label", "split", "patch_file")]
#>        image_id point_id                        label split
#> 1 HIW_158_W_U-1        1                  SPONGES (S) train
#> 2 HIW_158_W_U-1        2 SAND, PAVEMENT, RUBBLE (SPR) train
#> 3 HIW_158_W_U-1        3         CORALLINE ALGAE (CA) train
#>                                           patch_file
#> 1                HIW_158_W_U-1_point_1_SPONGES_S.jpg
#> 2 HIW_158_W_U-1_point_2_SAND_PAVEMENT_RUBBLE_SPR.jpg
#> 3       HIW_158_W_U-1_point_3_CORALLINE_ALGAE_CA.jpg
```

The center-point label is a weak label for the crop. Mixed benthos,
occlusion, blur, annotation ambiguity, and scale variation remain
possible.

## Create sparse masks

``` r

mask_dir <- tempfile("pointcoral-masks-")
mask_manifest <- make_sparse_masks(
  split_points[1:5, ],
  image_root = example_dir,
  out_dir = mask_dir,
  radius = 2,
  ignore_index = 255,
  class_col = "ml_class"
)

transform(mask_manifest, mask_file = basename(mask_path))[
  c("image_id", "image_width", "image_height", "n_points", "mask_file")
]
#>        image_id image_width image_height n_points              mask_file
#> 1 HIW_158_W_U-1         900          566        5 HIW_158_W_U-1_mask.png
```

Only point disks receive class IDs. `ignore_index = 255` means loss
functions should ignore other pixels; it does not mean background. The
current PNG encoding supports class values below 255, so class IDs must
not collide with the ignore value.

## Interpretation boundary

Package outputs make provenance and organization easier. They do not
establish that a class ontology is learnable, splits are independent,
labels are correct, metrics generalize to another survey, or model
predictions are ecologically valid. Document the intended prediction
unit, leakage controls, class version, image preprocessing, external
test set, and uncertainty analysis separately.
