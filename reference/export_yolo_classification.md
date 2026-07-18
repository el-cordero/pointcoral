# Export YOLO-style classification patches

Extracts point-centered patches into split/class folders and writes a
patch manifest.

## Usage

``` r
export_yolo_classification(points, image_root, out_dir, patch_size = 224)
```

## Arguments

- points:

  A tidy point table.

- image_root:

  Image root.

- out_dir:

  Output directory.

- patch_size:

  Patch size in pixels.

## Value

A patch manifest tibble.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
export_yolo_classification(
  pts[20:25, ],
  image_root = example_dir,
  out_dir = file.path(tempdir(), "pointcoral-yolo-example"),
  patch_size = 64
)
#> # A tibble: 6 × 10
#>   patch_path       image_path image_id point_id  x_px  y_px label class_id split
#>   <chr>            <chr>      <chr>       <int> <int> <int> <chr>    <int> <chr>
#> 1 /tmp/RtmpLwJlKK… /home/run… HIW_158…       20   168   517 PEFL         1 train
#> 2 /tmp/RtmpLwJlKK… /home/run… HIW_158…       21   262    35 SPO          3 train
#> 3 /tmp/RtmpLwJlKK… /home/run… HIW_158…       22   260    89 CALG         0 train
#> 4 /tmp/RtmpLwJlKK… /home/run… HIW_158…       23   215   151 PEYS         2 train
#> 5 /tmp/RtmpLwJlKK… /home/run… HIW_158…       24   206   196 SPO          3 train
#> 6 /tmp/RtmpLwJlKK… /home/run… HIW_158…       25   218   273 CALG         0 train
#> # ℹ 1 more variable: patch_size <dbl>
```
