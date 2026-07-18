# Write QC overlays for point annotations

Writes one overlay image per source image.

## Usage

``` r
write_qc_overlays(points, image_root, out_dir, label_col = "ml_class")
```

## Arguments

- points:

  A tidy point table.

- image_root:

  Image root used to match images when needed.

- out_dir:

  Output directory.

- label_col:

  Label column to draw.

## Value

A manifest tibble of written overlays.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
write_qc_overlays(
  pts[1:5, ],
  image_root = example_dir,
  out_dir = file.path(tempdir(), "pointcoral-qc-example"),
  label_col = "raw_label"
)
#> # A tibble: 1 × 5
#>   image_path                            image_id overlay_path n_points label_col
#>   <chr>                                 <chr>    <chr>           <int> <chr>    
#> 1 /home/runner/work/_temp/Library/poin… HIW_158… /tmp/RtmpLw…        5 raw_label
```
