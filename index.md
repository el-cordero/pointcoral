# pointcoral

![pointcoral hexagon logo with CPCe sampling points, branching coral,
and turquoise reef shapes](reference/figures/logo.png)

## From CPCe points to reviewable coral data products

`pointcoral` imports local Coral Point Count with Excel extensions
(CPCe) annotations, matches points to photoquadrat images, checks labels
and coordinates, calculates point-count percent cover, creates visual
quality-control overlays, and prepares local machine-learning datasets.

[Get
started](https://el-cordero.github.io/pointcoral/articles/pointcoral-workflow.html)
[See
examples](https://el-cordero.github.io/pointcoral/articles/examples.html)
[Function reference](https://el-cordero.github.io/pointcoral/reference/)

[Website](https://el-cordero.github.io/pointcoral/) ·
[Articles](https://el-cordero.github.io/pointcoral/articles/) ·
[Reference](https://el-cordero.github.io/pointcoral/reference/) ·
[News](https://el-cordero.github.io/pointcoral/news/) ·
[Citation](https://el-cordero.github.io/pointcoral/articles/citation.html)
· [Source](https://github.com/el-cordero/pointcoral) ·
[Issues](https://github.com/el-cordero/pointcoral/issues) ·
[CRAN](https://CRAN.R-project.org/package=pointcoral)

## Who it serves

`pointcoral` is for coral-reef analysts, benthic ecologists, image
annotators, data managers, and machine-learning practitioners who need
to reuse CPCe point annotations without sending project data to a web
platform. It runs locally and requires no CoralNet or MERMAID account,
cloud API, or Python environment.

- ### Import

  Read tested text `.cpc` files, CPCe `_raw` workbook tabs, and
  recognizable point tables.

- ### Standardize

  Preserve raw CPCe codes while optionally joining project-reviewed full
  labels and ecological classes.

- ### Review

  Validate coordinates and labels, calculate summaries, and inspect
  point placement on the source image.

- ### Export

  Write tidy tables, split-aware point labels, image patches, and sparse
  weak-label masks.

## Installation

### Released installation

Install the released package from CRAN:

``` r

install.packages("pointcoral")
```

### Development installation

Install the current development source from GitHub with `pak`:

``` r

install.packages("pak")
pak::pak("el-cordero/pointcoral")
```

## Five-minute workflow

The installed package includes two small CPCe files, two matching JPEG
images, an example crosswalk, and a small CPCe output workbook. The
crosswalk is an illustration, not a universal coral taxonomy or benthic
ontology.

``` r

library(pointcoral)

example_dir <- system.file("extdata", package = "pointcoral")
points <- read_cpce_folder(
  example_dir,
  image_root = example_dir,
  recursive = FALSE
)

validation <- validate_points(points)
validation
#> # A tibble: 1 × 4
#>   check severity     n details
#>   <chr> <chr>    <int> <chr>
#> 1 ok    info         0 No validation issues detected
```

The raw labels inside the CPCe files are enough to calculate a cover
summary:

``` r

raw_cover <- summarize_images(points, class_col = "raw_label")
head(raw_cover, 6)
#> # A tibble: 6 × 7
#>   site             transect      image_id      raw_label     n n_points percent
#>   <chr>            <chr>         <chr>         <chr>     <int>    <int>   <dbl>
#> 1 Hole in the Wall HIW_158_W_U-1 HIW_158_W_U-1 AA            4      100       4
#> 2 Hole in the Wall HIW_158_W_U-1 HIW_158_W_U-1 CALG         18      100      18
#> 3 Hole in the Wall HIW_158_W_U-1 HIW_158_W_U-1 LOBO          8      100       8
#> 4 Hole in the Wall HIW_158_W_U-1 HIW_158_W_U-1 P             2      100       2
#> 5 Hole in the Wall HIW_158_W_U-1 HIW_158_W_U-1 PEFL          7      100       7
#> 6 Hole in the Wall HIW_158_W_U-1 HIW_158_W_U-1 PEYS          9      100       9
```

Apply a reviewed crosswalk only when standardized labels are needed:

``` r

crosswalk <- read_label_crosswalk(file.path(
  example_dir, "pointcoral_example_crosswalk.csv"
))
check_crosswalk(points, crosswalk) |>
  dplyr::count(issue_type)
#> # A tibble: 1 × 2
#>   issue_type           n
#>   <chr>            <int>
#> 1 unused_in_points   101

points_clean <- standardize_labels(points, crosswalk)
major_cover <- summarize_images(points_clean, class_col = "major_category")
head(major_cover, 6)
#> # A tibble: 6 × 7
#>   site             transect      image_id  major_category     n n_points percent
#>   <chr>            <chr>         <chr>     <chr>          <int>    <int>   <dbl>
#> 1 Hole in the Wall HIW_158_W_U-1 HIW_158_… CORAL (C)          5      100       5
#> 2 Hole in the Wall HIW_158_W_U-1 HIW_158_… CORALLINE ALG…    18      100      18
#> 3 Hole in the Wall HIW_158_W_U-1 HIW_158_… MACROALGAE (M…    11      100      11
#> 4 Hole in the Wall HIW_158_W_U-1 HIW_158_… PEYSSONNELIAC…    16      100      16
#> 5 Hole in the Wall HIW_158_W_U-1 HIW_158_… SAND, PAVEMEN…    23      100      23
#> 6 Hole in the Wall HIW_158_W_U-1 HIW_158_… SPONGES (S)       27      100      27
```

![Horizontal bar chart of mean point-count cover across two bundled
photoquadrats, with sand pavement and rubble highest, followed by
sponges, coralline algae, Peyssonneliaceae, macroalgae, and
coral.](reference/figures/sample-cover-summary.png)

Package-generated example from 200 bundled CPCe points. It demonstrates
the workflow; it is not a population estimate for a reef or monitoring
program.

## Core outputs

- tidy point tables that retain original CPCe codes and coordinates;
- image-, transect-, site-, or custom-group point-count summaries;
- crosswalk and point-table validation reports;
- annotated source images for coordinate and label review;
- train/validation/test labels split by image, transect, or site;
- point-centered classification patches; and
- sparse masks whose unlabeled pixels remain an ignore value.

![Reef photoquadrat with many small CPCe point circles and short label
codes overlaid for visual coordinate and label
review.](reference/figures/sample-qc-overlay.jpg)

Inspect overlays before trusting summaries or ML exports, especially
when old CPCe paths or a different coordinate geometry are involved.

## Assumptions and interpretation boundaries

**Point-count output is design dependent.** Percent cover is the
percentage of retained points assigned to a label within the requested
grouping. Its ecological interpretation depends on point placement,
annotation quality, image selection, sampling design, and any
aggregation across images, transects, sites, or dates.

- [`read_cpce_file()`](https://el-cordero.github.io/pointcoral/reference/read_cpce_file.md)
  is tested against the bundled text `.cpc` structure; other CPCe
  variants require project-level verification.
- Image matching uses file basenames. Duplicate basenames are ambiguous
  and should be resolved before analysis.
- CPCe coordinates are proportionally scaled to image pixel dimensions.
  Both axes use pixel units; inspect QC overlays whenever source
  geometry differs.
- Raw labels are always preserved. The bundled crosswalk must be checked
  against the project’s CPCe codefile before final ecological
  interpretation.
- Split by image, transect, or site as appropriate to prevent related
  points from leaking across model evaluation subsets.
- Sparse masks label only small disks around annotated points. They are
  weak supervision, not dense human-verified segmentation truth.
- The package prepares data products; it does not establish taxonomic
  correctness, sampling representativeness, model accuracy, or
  ecological causation.

See [interpretation and
limitations](https://el-cordero.github.io/pointcoral/articles/interpretation-limitations.html)
for the full guidance.

## CPCe method reference

Kohler, K. E. and Gill, S. M. (2006). Coral Point Count with Excel
extensions (CPCe): A Visual Basic program for the determination of coral
and substrate coverage using random point count methodology. *Computers
& Geosciences*, 32(9), 1259–1269.
[doi:10.1016/j.cageo.2005.11.009](https://doi.org/10.1016/j.cageo.2005.11.009).

Run `citation("pointcoral")` for the package citation.

## Documentation, support, and participation

- [Get
  started](https://el-cordero.github.io/pointcoral/articles/pointcoral-workflow.html)
- [Worked
  examples](https://el-cordero.github.io/pointcoral/articles/examples.html)
- [Function
  reference](https://el-cordero.github.io/pointcoral/reference/)
- [Issue tracker](https://github.com/el-cordero/pointcoral/issues)
- [Contributing
  guide](https://github.com/el-cordero/pointcoral/blob/main/CONTRIBUTING.md)
- [Code of
  Conduct](https://github.com/el-cordero/pointcoral/blob/main/CODE_OF_CONDUCT.md)
- [Support
  guide](https://github.com/el-cordero/pointcoral/blob/main/SUPPORT.md)
- [Security
  policy](https://github.com/el-cordero/pointcoral/blob/main/SECURITY.md)

Do not post confidential images, exact sensitive-site locations, private
project identifiers, credentials, or restricted ecological data in
public issues.
