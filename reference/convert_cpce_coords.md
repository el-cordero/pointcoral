# Convert CPCe coordinates to image pixel coordinates

Converts point coordinates from the CPCe coordinate space to actual
image pixels by proportional scaling. Original CPCe coordinates are
preserved.

## Usage

``` r
convert_cpce_coords(
  points,
  cpce_width = NULL,
  cpce_height = NULL,
  image_width = NULL,
  image_height = NULL
)
```

## Arguments

- points:

  A data frame with `cpce_x` and `cpce_y` columns.

- cpce_width, cpce_height:

  CPCe coordinate-space width and height. If `NULL`, the function uses
  `points$cpce_width` and `points$cpce_height`.

- image_width, image_height:

  Image width and height in pixels. If `NULL`, the function uses
  `points$image_width` and `points$image_height`.

## Value

A tibble with updated `x_px` and `y_px` columns.

## Examples

``` r
pts <- tibble::tibble(cpce_x = c(0, 50, 100), cpce_y = c(0, 25, 50))
convert_cpce_coords(pts, 100, 50, 1000, 500)
#> # A tibble: 3 × 8
#>   cpce_x cpce_y cpce_width cpce_height image_width image_height  x_px  y_px
#>    <dbl>  <dbl>      <dbl>       <dbl>       <int>        <int> <int> <int>
#> 1      0      0        100          50        1000          500     0     0
#> 2     50     25        100          50        1000          500   500   250
#> 3    100     50        100          50        1000          500  1000   500
```
