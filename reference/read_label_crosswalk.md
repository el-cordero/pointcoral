# Read a label crosswalk

Reads a CSV, TSV, XLS, or XLSX crosswalk table, cleans column names,
recognizes common synonyms, and validates that the table contains at
least one raw label/code key and at least one output class field.

## Usage

``` r
read_label_crosswalk(path)
```

## Arguments

- path:

  Path to a crosswalk file.

## Value

A tidy crosswalk tibble.

## Examples

``` r
xwalk <- system.file(
  "extdata", "pointcoral_example_crosswalk.csv",
  package = "pointcoral"
)
read_label_crosswalk(xwalk)
#> # A tibble: 116 × 12
#>    raw_code raw_label full_label clean_label label_class major_category ml_class
#>    <chr>    <chr>     <chr>      <chr>       <chr>       <chr>          <chr>   
#>  1 AC       AC        Acropora … Acropora c… subcategory CORAL (C)      CORAL (…
#>  2 AP       AP        Acropora … Acropora p… subcategory CORAL (C)      CORAL (…
#>  3 APR      APR       Acropora … Acropora p… subcategory CORAL (C)      CORAL (…
#>  4 AA       AA        Agaricia   Agaricia    subcategory CORAL (C)      CORAL (…
#>  5 AF       AF        Agaricia … Agaricia f… subcategory CORAL (C)      CORAL (…
#>  6 AG       AG        Agaricia … Agaricia g… subcategory CORAL (C)      CORAL (…
#>  7 AH       AH        Undaria h… Undaria hu… subcategory CORAL (C)      CORAL (…
#>  8 AT       AT        Agaricia … Agaricia t… subcategory CORAL (C)      CORAL (…
#>  9 AU       AU        Agaricia … Agaricia u… subcategory CORAL (C)      CORAL (…
#> 10 AL       AL        Agaricia … Agaricia l… subcategory CORAL (C)      CORAL (…
#> # ℹ 106 more rows
#> # ℹ 5 more variables: class_id <int>, include_in_analysis <lgl>,
#> #   include_in_ml <lgl>, color_hex <chr>, notes <chr>
```
