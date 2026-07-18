# Extract point-centered image patches

Extracts square image patches centered on CPCe points and writes a
manifest.

## Usage

``` r
extract_point_patches(
  points,
  image_root,
  out_dir,
  patch_size = 224,
  class_col = "ml_class",
  edge = c("skip", "pad")
)
```

## Arguments

- points:

  A tidy point table.

- image_root:

  Image root used to match images when `image_path` is absent.

- out_dir:

  Output patch directory.

- patch_size:

  Patch width/height in pixels.

- class_col:

  Class column used for folder names and labels.

- edge:

  `"skip"` skips points too close to an edge; `"pad"` pads images with
  black pixels before cropping.

## Value

A patch manifest tibble.

## Examples

``` r
example_dir <- system.file("extdata", package = "pointcoral")
pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
out_dir <- file.path(tempdir(), "pointcoral-patches-example")
extract_point_patches(
  pts[1:3, ],
  image_root = example_dir,
  out_dir = out_dir,
  patch_size = 64,
  class_col = "raw_label",
  edge = "pad"
)
#> # A tibble: 3 × 10
#>   patch_path       image_path image_id point_id  x_px  y_px label class_id split
#>   <chr>            <chr>      <chr>       <int> <int> <int> <chr>    <int> <chr>
#> 1 /tmp/RtmpLwJlKK… /home/run… HIW_158…        1    19    11 SPO          2 train
#> 2 /tmp/RtmpLwJlKK… /home/run… HIW_158…        2     7   107 S            1 train
#> 3 /tmp/RtmpLwJlKK… /home/run… HIW_158…        3    26   165 CALG         0 train
#> # ℹ 1 more variable: patch_size <dbl>
```
