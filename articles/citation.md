# Citing pointcoral

Use the citation returned by the installed package so the recorded
version matches the software used in an analysis.

``` r

citation("pointcoral")
```

    ## To cite pointcoral in publications, use:
    ## 
    ##   Cordero E (2026). _pointcoral: Local Point-Count Processing for Coral
    ##   Photoquadrats_. doi:10.32614/CRAN.package.pointcoral
    ##   <https://doi.org/10.32614/CRAN.package.pointcoral>. R package version
    ##   0.1.0, <https://el-cordero.github.io/pointcoral/>.
    ## 
    ## A BibTeX entry for LaTeX users is
    ## 
    ##   @Manual{,
    ##     title = {pointcoral: Local Point-Count Processing for Coral Photoquadrats},
    ##     author = {Elvin Cordero},
    ##     year = {2026},
    ##     note = {R package version 0.1.0},
    ##     doi = {10.32614/CRAN.package.pointcoral},
    ##     url = {https://el-cordero.github.io/pointcoral/},
    ##   }
    ## 
    ## When CPCe software or its random point-count method is used, also cite
    ## Kohler and Gill (2006), doi:10.1016/j.cageo.2005.11.009.

BibTeX can be generated with:

``` r

toBibtex(citation("pointcoral"))
```

## Availability and license

- Website: <https://el-cordero.github.io/pointcoral/>
- Source: <https://github.com/el-cordero/pointcoral>
- CRAN: <https://CRAN.R-project.org/package=pointcoral>
- DOI: <https://doi.org/10.32614/CRAN.package.pointcoral>
- License: MIT
- Current package version: 0.1.0

CRAN published version 0.1.0 on June 19, 2026. Use the installed package
citation so a report remains accurate when a later version is installed.

## CPCe method

When the analysis uses the CPCe software or random point-count method,
also cite the original method paper:

Kohler, K. E. and Gill, S. M. (2006). Coral Point Count with Excel
extensions (CPCe): A Visual Basic program for the determination of coral
and substrate coverage using random point count methodology. *Computers
& Geosciences*, 32(9), 1259–1269.
<https://doi.org/10.1016/j.cageo.2005.11.009>.

The package citation credits the software. The CPCe citation credits the
source annotation software and method; neither substitutes for citing
the survey data, field protocol, image archive, taxonomic authority, or
downstream model.
