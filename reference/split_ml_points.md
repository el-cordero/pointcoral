# Split ML points into train/validation/test sets

Assigns split labels by image, transect, or site to avoid leakage.
Splits are reproducible with `seed`.

## Usage

``` r
split_ml_points(
  points,
  split_by = c("image", "transect", "site"),
  train = 0.7,
  val = 0.15,
  test = 0.15,
  seed = 1
)
```

## Arguments

- points:

  A tidy point table.

- split_by:

  One of `"image"`, `"transect"`, or `"site"`.

- train, val, test:

  Split proportions.

- seed:

  Random seed.

## Value

The input table with `split` and `split_unit` columns.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)
split_ml_points(pts, split_by = "image", train = 0.5, val = 0, test = 0.5)
#> # A tibble: 200 × 38
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
#> # ℹ 30 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <int>,
#> #   y_px <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, cpce_note_type <chr>,
#> #   cpc_file <chr>, codefile_path <chr>, cpce_image_path <chr>, …
```
