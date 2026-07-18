# Summarize points at transect level

Summarize points at transect level

## Usage

``` r
summarize_transects(points, class_col = "major_category")
```

## Arguments

- points:

  A tidy point table.

- class_col:

  Class/label column to summarize.

## Value

A transect-level summary tibble.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
summarize_transects(read_cpce_file(cpc), class_col = "raw_label")
#> # A tibble: 10 × 6
#>    site             transect      raw_label     n n_points percent
#>    <chr>            <chr>         <chr>     <int>    <int>   <dbl>
#>  1 Hole in the Wall HIW_158_W_U-1 AA            4      100       4
#>  2 Hole in the Wall HIW_158_W_U-1 CALG         18      100      18
#>  3 Hole in the Wall HIW_158_W_U-1 LOBO          8      100       8
#>  4 Hole in the Wall HIW_158_W_U-1 P             2      100       2
#>  5 Hole in the Wall HIW_158_W_U-1 PEFL          7      100       7
#>  6 Hole in the Wall HIW_158_W_U-1 PEYS          9      100       9
#>  7 Hole in the Wall HIW_158_W_U-1 S            21      100      21
#>  8 Hole in the Wall HIW_158_W_U-1 SPO          27      100      27
#>  9 Hole in the Wall HIW_158_W_U-1 SS            1      100       1
#> 10 Hole in the Wall HIW_158_W_U-1 TURF          3      100       3
```
