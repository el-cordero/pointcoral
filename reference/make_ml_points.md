# Make an ML-ready point-label table

Creates a compact table suitable for patch classification or weakly
supervised segmentation workflows.

## Usage

``` r
make_ml_points(points, image_root = NULL, class_col = "ml_class")
```

## Arguments

- points:

  A tidy point table.

- image_root:

  Optional image root used to match image paths.

- class_col:

  Label column to use as the ML label.

## Value

A tibble with `image_path`, `image_id`, `x_px`, `y_px`, `label`,
`class_id`, `split`, and available metadata.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
make_ml_points(read_cpce_file(cpc), class_col = "raw_label")
#> # A tibble: 100 × 21
#>    image_path         image_id  x_px  y_px label class_id split project_id site 
#>    <chr>              <chr>    <int> <int> <chr>    <int> <chr> <chr>      <chr>
#>  1 /home/runner/work… HIW_158…    19    11 SPO          7 NA    NA         Hole…
#>  2 /home/runner/work… HIW_158…     7   107 S            6 NA    NA         Hole…
#>  3 /home/runner/work… HIW_158…    26   165 CALG         1 NA    NA         Hole…
#>  4 /home/runner/work… HIW_158…    69   202 SPO          7 NA    NA         Hole…
#>  5 /home/runner/work… HIW_158…    26   243 SPO          7 NA    NA         Hole…
#>  6 /home/runner/work… HIW_158…    43   305 SPO          7 NA    NA         Hole…
#>  7 /home/runner/work… HIW_158…     2   363 PEYS         5 NA    NA         Hole…
#>  8 /home/runner/work… HIW_158…    74   452 CALG         1 NA    NA         Hole…
#>  9 /home/runner/work… HIW_158…    43   469 SPO          7 NA    NA         Hole…
#> 10 /home/runner/work… HIW_158…    18   541 LOBO         2 NA    NA         Hole…
#> # ℹ 90 more rows
#> # ℹ 12 more variables: transect <chr>, survey_date <date>, image_file <chr>,
#> #   point_id <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, reviewer <chr>,
#> #   notes <chr>
```
