# Read CPCe files and exports from a folder

Recursively reads supported CPCe-related files from a folder. `.cpc`
files are parsed with
[`read_cpce_file()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_file.md).
CSV/TSV/XLS/XLSX files are attempted with
[`read_cpce_export()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_export.md).

## Usage

``` r
read_cpce_folder(path, image_root = NULL, recursive = TRUE)
```

## Arguments

- path:

  Folder containing CPCe files/exports.

- image_root:

  Optional image root used to match image paths after import.

- recursive:

  Whether to search recursively.

## Value

A combined tidy point table.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
read_cpce_folder(example_dir, image_root = example_dir, recursive = FALSE)
#> # A tibble: 200 × 36
#>    project_id site  transect survey_date image_id image_file image_path point_id
#>    <chr>      <chr> <chr>    <date>      <chr>    <chr>      <chr>         <int>
#>  1 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        1
#>  2 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        2
#>  3 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        3
#>  4 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        4
#>  5 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        5
#>  6 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        6
#>  7 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        7
#>  8 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        8
#>  9 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…        9
#> 10 NA         Hole… HIW_158… NA          HIW_158… HIW_158_W… /home/run…       10
#> # ℹ 190 more rows
#> # ℹ 28 more variables: cpce_x <dbl>, cpce_y <dbl>, cpce_width <dbl>,
#> #   cpce_height <dbl>, image_width <int>, image_height <int>, x_px <int>,
#> #   y_px <int>, raw_code <chr>, raw_label <chr>, full_label <chr>,
#> #   clean_label <chr>, label_class <chr>, major_category <chr>, ml_class <chr>,
#> #   class_id <int>, reviewer <chr>, notes <chr>, cpce_note_type <chr>,
#> #   cpc_file <chr>, codefile_path <chr>, cpce_image_path <chr>, …
```
