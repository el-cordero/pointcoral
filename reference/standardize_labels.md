# Standardize CPCe labels with a crosswalk

Joins raw CPCe labels/codes to user-defined clean labels, ecological
categories, ML classes, and class IDs. Raw labels and raw codes are
always preserved.

## Usage

``` r
standardize_labels(
  points,
  crosswalk,
  by = NULL,
  unknown_action = c("warn", "keep", "drop", "error")
)
```

## Arguments

- points:

  A tidy point table.

- crosswalk:

  A crosswalk data frame, usually from
  [`read_label_crosswalk()`](https://el-cordero.github.io/pointcoral/reference/read_label_crosswalk.md).

- by:

  Optional join columns. Use a character vector for same-name joins or a
  named vector where names are point-table columns and values are
  crosswalk columns.

- unknown_action:

  How to handle labels not found in the crosswalk: `"warn"` keeps rows
  and warns, `"keep"` keeps rows silently, `"drop"` drops unmapped rows
  with a warning, and `"error"` stops.

## Value

A tidy point table with standardized label columns.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
xwalk <- system.file(
  "extdata", "pointcoral_example_crosswalk.csv",
  package = "pointcoral"
)
pts <- read_cpce_file(cpc)
standardize_labels(pts, read_label_crosswalk(xwalk))
#> # A tibble: 100 × 39
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
#> # ℹ 31 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <int>,
#> #   y_px <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, cpce_note_type <chr>,
#> #   cpc_file <chr>, codefile_path <chr>, cpce_image_path <chr>, …
```
