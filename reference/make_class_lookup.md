# Make a class lookup table

Produces a distinct class lookup table from point data. If no usable
class ID column exists, IDs are assigned in sorted class order starting
at 0.

## Usage

``` r
make_class_lookup(points, class_col = "ml_class", id_col = "class_id")
```

## Arguments

- points:

  A tidy point table.

- class_col:

  Column containing class labels.

- id_col:

  Column containing integer class IDs.

## Value

A tibble with class labels and IDs.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
xwalk <- system.file(
  "extdata", "pointcoral_example_crosswalk.csv",
  package = "pointcoral"
)
pts <- standardize_labels(read_cpce_file(cpc), read_label_crosswalk(xwalk))
make_class_lookup(pts, class_col = "ml_class")
#> # A tibble: 6 × 2
#>   label                        class_id
#>   <chr>                           <int>
#> 1 CORAL (C)                           0
#> 2 SPONGES (S)                         2
#> 3 MACROALGAE (MA)                     4
#> 4 PEYSSONNELIACEAE                    5
#> 5 CORALLINE ALGAE (CA)                7
#> 6 SAND, PAVEMENT, RUBBLE (SPR)        8
```
