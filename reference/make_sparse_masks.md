# Create sparse semantic segmentation masks from point labels

Writes sparse masks where point neighborhoods contain `class_id` values
and all unlabeled pixels are `ignore_index`. These are weak labels, not
dense human-annotated segmentation masks.

## Usage

``` r
make_sparse_masks(
  points,
  image_root,
  out_dir,
  radius = 3,
  ignore_index = 255,
  background_index = 0,
  class_col = "ml_class"
)
```

## Arguments

- points:

  A tidy point table.

- image_root:

  Image root used to match images when needed.

- out_dir:

  Output directory.

- radius:

  Disk radius in pixels around each point.

- ignore_index:

  Pixel value for unlabeled pixels.

- background_index:

  Reserved background value. Included for downstream schemas; unlabeled
  pixels still default to `ignore_index`.

- class_col:

  Label column used to assign `class_id` values when they are missing.
  Defaults to `ml_class`, with automatic fallback to raw CPCe labels for
  bare workflows without a crosswalk.

## Value

A mask manifest tibble.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
out_dir <- file.path(tempdir(), "pointcoral-masks-example")
make_sparse_masks(
  pts[1:3, ],
  image_root = example_dir,
  out_dir = out_dir,
  radius = 2,
  class_col = "raw_label"
)
#> # A tibble: 1 × 9
#>   image_path         image_id mask_path image_width image_height n_points radius
#>   <chr>              <chr>    <chr>           <int>        <int>    <int>  <dbl>
#> 1 /home/runner/work… HIW_158… /tmp/Rtm…         900          566        3      2
#> # ℹ 2 more variables: ignore_index <int>, background_index <int>
```
