# Match CPCe point rows to image files

Matches `image_file` values in a point table to files under
`image_root`. Image dimensions are filled in, and pixel coordinates are
calculated when CPCe and image dimensions are available.

## Usage

``` r
match_images(points, image_root, image_col = "image_file")
```

## Arguments

- points:

  A pointcoral point table.

- image_root:

  Root folder containing images.

- image_col:

  Column in `points` containing image file names.

## Value

A point table with `image_path`, `image_width`, and `image_height`.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
pts$image_path <- NA_character_
match_images(pts, image_root = example_dir)
#> # A tibble: 100 × 36
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
#> # ℹ 90 more rows
#> # ℹ 28 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <int>,
#> #   y_px <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, cpce_note_type <chr>,
#> #   cpc_file <chr>, codefile_path <chr>, cpce_image_path <chr>, …
```
