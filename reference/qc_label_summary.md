# Summarize point-label QC issues

Reports unmapped labels, rare labels, duplicate points, and class
balance in a compact tibble.

## Usage

``` r
qc_label_summary(points, label_col = "ml_class", rare_threshold = 1L)
```

## Arguments

- points:

  A tidy point table.

- label_col:

  Label column to summarize.

- rare_threshold:

  Count at or below which labels are flagged as rare.

## Value

A QC summary tibble.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
qc_label_summary(read_cpce_file(cpc), label_col = "raw_label")
#> # A tibble: 21 × 4
#>    summary_type  label     n details             
#>    <chr>         <chr> <int> <chr>               
#>  1 class_balance SPO      27 Point count by label
#>  2 class_balance S        21 Point count by label
#>  3 class_balance CALG     18 Point count by label
#>  4 class_balance PEYS      9 Point count by label
#>  5 class_balance LOBO      8 Point count by label
#>  6 class_balance PEFL      7 Point count by label
#>  7 class_balance AA        4 Point count by label
#>  8 class_balance TURF      3 Point count by label
#>  9 class_balance P         2 Point count by label
#> 10 class_balance SS        1 Point count by label
#> # ℹ 11 more rows
```
