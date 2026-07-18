# Export point labels in a simple CoralNet-style CSV

This helper writes local point labels only. It does not connect to
CoralNet.

## Usage

``` r
export_coralnet_points(points, out_dir)
```

## Arguments

- points:

  A tidy point table.

- out_dir:

  Output directory.

## Value

Path to the written CSV.

## Examples

``` r
cpc <- system.file("extdata", "HIW_158_W_U-1.cpc", package = "pointcoral")
export_coralnet_points(
  read_cpce_file(cpc),
  file.path(tempdir(), "pointcoral-coralnet-example")
)
#> [1] "/tmp/RtmpLwJlKK/pointcoral-coralnet-example/coralnet_points.csv"
```
