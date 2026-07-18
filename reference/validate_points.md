# Validate a point table

Checks required fields, missing coordinates, duplicated point IDs within
images, coordinates outside image bounds, missing image files, and
missing image dimensions.

## Usage

``` r
validate_points(points)
```

## Arguments

- points:

  A tidy point table.

## Value

A validation report tibble.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
validate_points(read_cpce_file(cpc))
#> # A tibble: 1 × 4
#>   check severity     n details                      
#>   <chr> <chr>    <int> <chr>                        
#> 1 ok    info         0 No validation issues detected
```
