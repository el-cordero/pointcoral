# pointcoral RStudio workflows

This folder sits outside the R package directory on purpose. It is a practical
workspace for building, installing, and trying `pointcoral` in RStudio without
editing package internals.

Recommended order:

1. Open this folder in RStudio or set your working directory to this folder.
2. Run `00_build_install_pointcoral.R`.
3. Run `01_run_sample_data.R`.
4. Open and knit `pointcoral_rstudio_walkthrough.Rmd`.
5. Copy `02_run_my_data_template.R` for your own CPCe folder, image folder, and
   crosswalk.

The scripts assume this layout:

```text
PointCoralPackage/
  pointcoral/
  pointcoral-rstudio-workflows/
```

The output from sample runs is written into:

```text
pointcoral-rstudio-workflows/outputs/
```

You can delete that `outputs/` folder at any time. It is ignored by git.
