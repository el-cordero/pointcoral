# Check a label crosswalk against point data

Reports labels in CPCe data missing from the crosswalk, crosswalk labels
not present in current data, duplicate mappings, missing class IDs, and
excluded classes.

## Usage

``` r
check_crosswalk(points, crosswalk, by = NULL)
```

## Arguments

- points:

  A tidy point table.

- crosswalk:

  A crosswalk data frame.

- by:

  Optional join columns. See
  [`standardize_labels()`](https://el-cordero.github.io/pointcoral/reference/standardize_labels.md).

## Value

A tibble report.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
xwalk <- system.file(
  "extdata", "pointcoral_example_crosswalk.csv",
  package = "pointcoral"
)
pts <- read_cpce_file(cpc)
check_crosswalk(pts, read_label_crosswalk(xwalk))
#> # A tibble: 106 × 12
#>    issue_type     severity raw_code raw_label full_label clean_label label_class
#>    <chr>          <chr>    <chr>    <chr>     <chr>      <chr>       <chr>      
#>  1 unused_in_poi… info     AC       NA        NA         NA          NA         
#>  2 unused_in_poi… info     AP       NA        NA         NA          NA         
#>  3 unused_in_poi… info     APR      NA        NA         NA          NA         
#>  4 unused_in_poi… info     AF       NA        NA         NA          NA         
#>  5 unused_in_poi… info     AG       NA        NA         NA          NA         
#>  6 unused_in_poi… info     AH       NA        NA         NA          NA         
#>  7 unused_in_poi… info     AT       NA        NA         NA          NA         
#>  8 unused_in_poi… info     AU       NA        NA         NA          NA         
#>  9 unused_in_poi… info     AL       NA        NA         NA          NA         
#> 10 unused_in_poi… info     CB       NA        NA         NA          NA         
#> # ℹ 96 more rows
#> # ℹ 5 more variables: major_category <chr>, ml_class <chr>, class_id <int>,
#> #   n <int>, details <chr>
```
