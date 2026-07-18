# Contributing to pointcoral

Focused bug fixes, documentation improvements, tests, and well-supported CPCe
format extensions are welcome. Please open an issue before a large change or a
change to the public point-table schema.

Keep each contribution limited to one purpose. Add small deterministic tests,
use installed or synthetic fixtures, regenerate roxygen documentation when
public documentation changes, and describe effects on supported file formats,
coordinate assumptions, label semantics, outputs, and compatibility.

Before submitting a pull request, run:

```r
devtools::document()
devtools::test(stop_on_failure = TRUE)
devtools::build_vignettes()
devtools::check()
pkgdown::build_site(new_process = FALSE, install = TRUE)
pkgdown::check_pkgdown()
```

Examples and tests must work without internet access and write only to temporary
directories. Do not contribute confidential reef images, exact locations of
sensitive resources, client or project identifiers, restricted ecological
data, or annotations whose license does not permit redistribution.

By participating, you agree to follow the
[Code of Conduct](https://github.com/el-cordero/pointcoral/blob/main/CODE_OF_CONDUCT.md).
For usage questions and reproducible bug reports, see the
[support guide](https://github.com/el-cordero/pointcoral/blob/main/SUPPORT.md).
