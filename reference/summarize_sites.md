# Summarize points at site level

Summarize points at site level

## Usage

``` r
summarize_sites(points, class_col = "major_category")
```

## Arguments

- points:

  A tidy point table.

- class_col:

  Class/label column to summarize.

## Value

A site-level summary tibble.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
summarize_sites(read_cpce_file(cpc), class_col = "raw_label")
#> # A tibble: 10 × 5
#>    site             raw_label     n n_points percent
#>    <chr>            <chr>     <int>    <int>   <dbl>
#>  1 Hole in the Wall AA            4      100       4
#>  2 Hole in the Wall CALG         18      100      18
#>  3 Hole in the Wall LOBO          8      100       8
#>  4 Hole in the Wall P             2      100       2
#>  5 Hole in the Wall PEFL          7      100       7
#>  6 Hole in the Wall PEYS          9      100       9
#>  7 Hole in the Wall S            21      100      21
#>  8 Hole in the Wall SPO          27      100      27
#>  9 Hole in the Wall SS            1      100       1
#> 10 Hole in the Wall TURF          3      100       3
```
