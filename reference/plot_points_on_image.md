# Plot CPCe points on an image

Draws point halos and labels on an image and returns a `magick-image`
object.

## Usage

``` r
plot_points_on_image(
  image_path,
  points,
  label_col = "ml_class",
  point_size = 8
)
```

## Arguments

- image_path:

  Path to an image.

- points:

  Point rows for that image.

- label_col:

  Column to use for text labels.

- point_size:

  Point radius in pixels.

## Value

A `magick-image` overlay.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
plot_points_on_image(pts$image_path[1], pts[1:5, ], label_col = "raw_label")
#> # A tibble: 1 × 7
#>   format width height colorspace matte filesize density
#>   <chr>  <int>  <int> <chr>      <lgl>    <int> <chr>  
#> 1 PNG      900    566 sRGB       FALSE   827697 72x72  
```
