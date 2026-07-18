# Interpretation, assumptions, and limitations

`pointcoral` makes CPCe-derived workflows reproducible and reviewable.
It does not remove the assumptions of image-based point-count sampling
or create information absent from the annotations.

## Supported inputs are deliberately bounded

The text `.cpc` parser is tested against the installed fixtures: a
header, four ROI vertices, point count, coordinate rows, and label rows.
Generic delimited and spreadsheet readers require recognizable point,
label, and coordinate columns. CPCe workbooks with `_raw` sheets have a
dedicated reader. Other CPCe versions, permanent-transect layouts,
summary workbooks, and project exports need representative validation
before support should be claimed.

## Labels and crosswalks

Raw CPCe codes remain the source record. A crosswalk is project metadata
that can add full labels, analysis classes, ML classes, inclusion flags,
IDs, and colors. The installed example is illustrative and may contain
vocabulary, taxonomic resolution, or groupings that do not match another
protocol.

Review every observed raw code and resolve missing or duplicate
mappings. Keep the crosswalk under version control with the analysis.
Label standardization does not establish taxonomic correctness.

## Point-count percentages

For a requested group, `percent` is the number of retained points
assigned to a class divided by all retained points in that group,
multiplied by 100. Interpretation depends on:

- how images, quadrats, transects, sites, and dates were selected;
- how points were placed and whether they are independent or weighted;
- image quality, field of view, and obscured or excluded areas;
- annotation protocol, observer consistency, and label uncertainty; and
- the statistical method used to combine or compare sampling units.

The summary functions do not estimate design-based variance, confidence
intervals, temporal trends, causal effects, or population-wide reef
condition.

## Coordinates and imagery

Coordinate conversion is proportional scaling from CPCe coordinate
dimensions to image pixel dimensions. It assumes matching orientation
and extent. Image matching by basename is convenient for stale embedded
paths but can be ambiguous. QC overlays should be inspected for every
new project format.

Pixel distances are not physical distances unless the project supplies
and validates a pixel-to-field scale. Patch size and sparse-mask radius
therefore do not automatically represent the same benthic area across
images.

## Quality-control output

Table validation and image overlays can reveal missing fields, invalid
bounds, duplicate IDs, missing files, and visually implausible
placement. Passing those checks is necessary but not sufficient. It does
not confirm the source file, the sampling protocol, the label, or the
ecological interpretation.

## Machine-learning output

Image points share visual context. Split at a level that matches the
intended generalization claim and keeps related observations together.
Site- or transect-level leakage may remain after an image-level split.

Point-centered crops use the point label for a patch that may contain
mixed content. Sparse masks encode class disks only near sampled points
and use an ignore value elsewhere. They are weak supervision, not dense
segmentation truth, background maps, or model predictions.

`pointcoral` does not fit models or validate model performance. External
test data, leakage audits, class-balance analysis, calibration,
uncertainty, out-of-distribution evaluation, and ecological review
remain downstream responsibilities.

## Reproducible reporting checklist

Record at least the package version, CPCe and image file identities,
parsing route, coordinate assumptions, crosswalk version, exclusions,
summary grouping, split unit and seed, patch size, mask radius and
ignore value, and any manual corrections. Use `citation("pointcoral")`
for package citation and cite the CPCe method separately when
appropriate.
