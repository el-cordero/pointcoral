# Write ML point CSV files

Writes `labels.csv`, `class_lookup.csv`, and split-specific label CSVs
when a `split` column is present.

## Usage

``` r
write_ml_points_csv(points, out_dir)
```

## Arguments

- points:

  An ML-ready point table or tidy point table.

- out_dir:

  Output directory.

## Value

A named list of written file paths.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
ml <- make_ml_points(read_cpce_file(cpc), class_col = "raw_label")
write_ml_points_csv(ml, file.path(tempdir(), "pointcoral-ml-csv-example"))
#> $labels
#> [1] "/tmp/RtmpLwJlKK/pointcoral-ml-csv-example/labels.csv"
#> 
#> $class_lookup
#> [1] "/tmp/RtmpLwJlKK/pointcoral-ml-csv-example/class_lookup.csv"
#> 
#> $labels_train
#> [1] "/tmp/RtmpLwJlKK/pointcoral-ml-csv-example/labels_train.csv"
#> 
#> $labels_val
#> [1] "/tmp/RtmpLwJlKK/pointcoral-ml-csv-example/labels_val.csv"
#> 
#> $labels_test
#> [1] "/tmp/RtmpLwJlKK/pointcoral-ml-csv-example/labels_test.csv"
#> 
```
