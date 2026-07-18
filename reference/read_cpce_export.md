# Read a CPCe CSV or Excel export

Reads generic CPCe-like point exports from CSV, TSV, XLS, or XLSX files,
cleans column names, and maps common coordinate/label columns to the
pointcoral tidy point schema. Project-specific ecological "Data Summary"
workbooks are not fully translated yet because representative workbook
fixtures are not bundled with the package.

## Usage

``` r
read_cpce_export(path)
```

## Arguments

- path:

  Path to a CSV, TSV, XLS, or XLSX export.

## Value

A tidy point table when point-like columns are present.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
pts <- read_cpce_file(cpc)
tmp <- tempfile(fileext = ".csv")
readr::write_csv(pts[, c("image_file", "point_id", "x_px", "y_px", "raw_label")], tmp)
read_cpce_export(tmp)
#> # A tibble: 100 × 27
#>    project_id site  transect survey_date image_id image_file image_path point_id
#>    <chr>      <chr> <chr>    <date>      <chr>    <chr>      <chr>         <int>
#>  1 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                1
#>  2 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                2
#>  3 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                3
#>  4 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                4
#>  5 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                5
#>  6 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                6
#>  7 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                7
#>  8 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                8
#>  9 NA         NA    NA       NA          HIW_158… HIW_158_W… NA                9
#> 10 NA         NA    NA       NA          HIW_158… HIW_158_W… NA               10
#> # ℹ 90 more rows
#> # ℹ 19 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <dbl>,
#> #   y_px <dbl>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, source_file <chr>
```
