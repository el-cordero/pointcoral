# Write ecological summary tables

Writes image-, transect-, and site-level summaries for one or more class
columns, plus a class lookup table when possible.

## Usage

``` r
write_summary_tables(
  points,
  out_dir,
  class_cols = c("major_category", "clean_label", "ml_class")
)
```

## Arguments

- points:

  A tidy point table.

- out_dir:

  Output directory for summary CSV files.

- class_cols:

  Class columns to summarize.

## Value

A named list of written file paths.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
pts <- read_cpce_file(cpc)
out_dir <- file.path(tempdir(), "pointcoral-summary-example")
write_summary_tables(pts, out_dir, class_cols = "raw_label")
#> $image_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-summary-example/image_summary.csv"
#> 
#> $transect_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-summary-example/transect_summary.csv"
#> 
#> $site_summary
#> [1] "/tmp/RtmpLwJlKK/pointcoral-summary-example/site_summary.csv"
#> 
#> $class_lookup
#> [1] "/tmp/RtmpLwJlKK/pointcoral-summary-example/class_lookup.csv"
#> 
```
