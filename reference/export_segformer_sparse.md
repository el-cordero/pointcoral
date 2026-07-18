# Export SegFormer-style sparse masks

Writes sparse weak-label masks and a manifest. These are not dense
segmentation annotations.

## Usage

``` r
export_segformer_sparse(points, image_root, out_dir, radius = 3)
```

## Arguments

- points:

  A tidy point table.

- image_root:

  Image root.

- out_dir:

  Output directory.

- radius:

  Point disk radius.

## Value

A mask manifest tibble.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
export_segformer_sparse(
  pts[1:3, ],
  image_root = example_dir,
  out_dir = file.path(tempdir(), "pointcoral-segformer-example"),
  radius = 2
)
#> # A tibble: 1 × 9
#>   image_path         image_id mask_path image_width image_height n_points radius
#>   <chr>              <chr>    <chr>           <int>        <int>    <int>  <dbl>
#> 1 /home/runner/work… HIW_158… /tmp/Rtm…         900          566        3      2
#> # ℹ 2 more variables: ignore_index <int>, background_index <int>
```
