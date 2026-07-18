# pointcoral: Point-Count Processing for Coral Photoquadrats

Imports Coral Point Count with Excel extensions (CPCe) point
annotations, matches them to local photoquadrat images, validates labels
and coordinates, and computes point-count percent-cover summaries.
Optional crosswalks map project-specific CPCe codes to full labels,
ecological categories, and machine-learning classes. Quality-control
overlays, point-centered patches, sparse weak-label masks, and
leakage-aware dataset splits support review and downstream local model
development.

## Details

The package preserves original CPCe labels and coordinates. Users remain
responsible for verifying CPCe file variants, image matching, coordinate
conversion, crosswalk semantics, sampling design, and the interpretation
of point-count estimates. Sparse masks label only neighborhoods around
sampled points and are not dense benthic annotations.

## See also

Useful links:

- <https://el-cordero.github.io/pointcoral/>

- <https://github.com/el-cordero/pointcoral>

- Report bugs at <https://github.com/el-cordero/pointcoral/issues>

## Author

**Maintainer**: Elvin Cordero <elvin.cordero@seamountgeo.com>
([ORCID](https://orcid.org/0009-0003-8025-283X))
