# Read `_raw` sheets from a CPCe output workbook

CPCe output workbooks often contain one worksheet per image, with raw
point annotation worksheets named like `image_name_raw`. This function
reads only those raw worksheets, skips `deep_cres_..._raw` worksheets by
default, keeps the raw worksheet columns, adds `image_name` and
`point_index` as the first columns, and adds a full `major_category`
column using a label crosswalk. `point_index` is a 1-based row index
within each raw worksheet, matching the CPCe point order.

## Usage

``` r
read_cpce_output_raw_tabs(
  path,
  crosswalk = NULL,
  skip_deep_cres = TRUE,
  sheet_pattern = "_raw$"
)
```

## Arguments

- path:

  Path to a CPCe output `.xls` or `.xlsx` workbook.

- crosswalk:

  Optional label crosswalk data frame or path. When `NULL`, the bundled
  example crosswalk is used. The raw CPCe label in the workbook is
  joined to `raw_code` or `raw_label`.

- skip_deep_cres:

  Whether to skip worksheets whose names start with `deep_cres_`. Those
  sheets use a different layout.

- sheet_pattern:

  Regular expression used to identify raw worksheets. Defaults to sheets
  ending in `_raw`.

## Value

A tibble combining all selected raw worksheets. The first columns are
`image_name` and `point_index`. The original CPCe raw major/group column
is preserved as `cpce_major_category` when present.

## Examples

``` r
xlsx <- system.file(
  "extdata", "pointcoral_example_cpce_output_raw_tabs.xlsx",
  package = "pointcoral"
)
read_cpce_output_raw_tabs(xlsx)
#> # A tibble: 7 × 11
#>   image_name point_index raw_data notes cpce_major_category frame_limits
#>   <chr>            <int> <chr>    <lgl> <chr>               <chr>       
#> 1 Sample_A             1 SPO      NA    S                   *           
#> 2 Sample_A             2 PEYS     NA    MA                  NA          
#> 3 Sample_A             3 S        NA    SPR                 NA          
#> 4 Sample_A             4 CALG     NA    CA                  NA          
#> 5 Sample_B             1 LOBO     NA    MA                  NA          
#> 6 Sample_B             2 SS       NA    C                   NA          
#> 7 Sample_B             3 P        NA    SPR                 NA          
#> # ℹ 5 more variables: frame_image_name <chr>, cpc_filename <chr>,
#> #   major_category <chr>, start_stop <chr>, image_cpc_file <chr>
```
