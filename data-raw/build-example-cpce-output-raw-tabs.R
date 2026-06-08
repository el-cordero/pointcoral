# Build a small CPCe output workbook fixture with `_raw` sheets.
#
# The fixture is intentionally tiny. It is only for examples and tests of
# read_cpce_output_raw_tabs().

library(tibble)
library(writexl)

sample_a <- tibble(
  `Raw Data` = c("SPO", "PEYS", "S", "CALG"),
  Notes = c(NA, NA, NA, NA),
  `Major Category` = c("S", "MA", "SPR", "CA"),
  `Frame limits` = c("*", NA, NA, NA),
  `Frame image name` = "C:/example/Sample_A.jpg",
  `CPC filename` = "C:/example/Sample_A.cpc"
)

sample_b <- tibble(
  `Raw Data` = c("LOBO", "SS", "P"),
  Notes = c(NA, NA, NA),
  Group = c("MA", "C", "SPR"),
  `Start/stop` = c("*", NA, NA),
  `Image/CPC file` = c(
    "Frame image file: C:/example/Sample_B.jpg",
    "CPC filename: C:/example/Sample_B.cpc",
    NA
  )
)

deep_cres_other_format <- tibble(
  label = c("SPO", "S"),
  value = c(1, 2)
)

summary_sheet <- tibble(
  field = c("note"),
  value = c("Non-raw sheet ignored by read_cpce_output_raw_tabs().")
)

writexl::write_xlsx(
  list(
    Sample_A_raw = sample_a,
    Sample_B_raw = sample_b,
    deep_cres_Sample_C_raw = deep_cres_other_format,
    `Data Summary` = summary_sheet
  ),
  path = "inst/extdata/pointcoral_example_cpce_output_raw_tabs.xlsx"
)
