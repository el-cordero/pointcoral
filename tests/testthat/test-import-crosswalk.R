test_that("sample CPCe files are parsed and matched to sibling images", {
  cpc_files <- system.file(
    "extdata",
    c("HIW_158_W_U-1.cpc", "H_211_E_U-1.cpc"),
    package = "pointcoral"
  )

  pts <- lapply(cpc_files, read_cpce_file)

  expect_equal(nrow(pts[[1]]), 100)
  expect_equal(nrow(pts[[2]]), 100)
  expect_true(all(c("cpce_x", "cpce_y", "x_px", "y_px", "raw_code") %in% names(pts[[1]])))
  expect_true(file.exists(pts[[1]]$image_path[1]))
  expect_equal(pts[[1]]$image_width[1], 3040L)
  expect_equal(pts[[2]]$image_height[1], 1917L)
})

test_that("match_images fills image paths and dimensions", {
  example_dir <- system.file("extdata", package = "pointcoral")
  pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
  pts$image_path <- NA_character_
  pts$image_width <- NA_integer_
  pts$image_height <- NA_integer_

  matched <- match_images(pts, image_root = example_dir)

  expect_true(all(!is.na(matched$image_path)))
  expect_equal(unique(matched$image_width), 3040L)
  expect_equal(unique(matched$image_height), 1912L)
})

test_that("crosswalk reading, checking, and standardization work", {
  example_dir <- system.file("extdata", package = "pointcoral")
  pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
  xwalk <- read_label_crosswalk(file.path(example_dir, "pointcoral_example_crosswalk.csv"))

  expect_true(all(c("raw_code", "ml_class", "class_id") %in% names(xwalk)))
  expect_true("NA" %in% xwalk$raw_code)
  expect_equal(xwalk$full_label[xwalk$raw_code == "NA"][1], "Neogoniolithon accretum")
  expect_equal(xwalk$full_label[xwalk$raw_code == "MD"][1], "Madracis decactis")
  expect_equal(xwalk$full_label[xwalk$raw_code == "MM"][1], "Madracis mirabilis")
  expect_equal(xwalk$full_label[xwalk$raw_code == "MF"][1], "Mycetophyllia ferox")
  expect_equal(xwalk$full_label[xwalk$raw_code == "PD"][1], "Porites divaricata")
  expect_equal(xwalk$full_label[xwalk$raw_code == "PF"][1], "Porites furcata")

  report <- check_crosswalk(pts, xwalk)
  expect_false("missing_from_crosswalk" %in% report$issue_type)

  clean <- standardize_labels(pts, xwalk)
  expect_true(all(!is.na(clean$full_label)))
  expect_true(all(!is.na(clean$ml_class)))
  expect_true(all(!is.na(clean$class_id)))
  expect_equal(clean$raw_label[clean$raw_code == "SPO"][1], "SPO")
  expect_equal(clean$full_label[clean$raw_code == "SPO"][1], "Sponge")
  expect_equal(clean$major_category[clean$raw_code == "SPO"][1], "SPONGES (S)")
  expect_equal(clean$ml_class[clean$raw_code == "SPO"][1], "SPONGES (S)")
})

test_that("CPCe output raw tabs are extracted with image names and major categories", {
  raw_tabs <- read_cpce_output_raw_tabs(
    system.file("extdata", "pointcoral_example_cpce_output_raw_tabs.xlsx", package = "pointcoral")
  )

  expect_equal(names(raw_tabs)[1], "image_name")
  expect_equal(names(raw_tabs)[2], "point_index")
  expect_setequal(unique(raw_tabs$image_name), c("Sample_A", "Sample_B"))
  expect_true("cpce_major_category" %in% names(raw_tabs))
  expect_true("major_category" %in% names(raw_tabs))
  expect_false(any(grepl("^deep_cres_", raw_tabs$image_name, ignore.case = TRUE)))
  expect_equal(raw_tabs$point_index[raw_tabs$image_name == "Sample_A"], seq_len(4))
  expect_equal(raw_tabs$point_index[raw_tabs$image_name == "Sample_B"], seq_len(3))

  expect_equal(
    raw_tabs$major_category[raw_tabs$image_name == "Sample_A" & raw_tabs$raw_data == "SPO"],
    "SPONGES (S)"
  )
  expect_equal(
    raw_tabs$major_category[raw_tabs$image_name == "Sample_A" & raw_tabs$raw_data == "PEYS"],
    "PEYSSONNELIACEAE"
  )
  expect_equal(
    raw_tabs$cpce_major_category[raw_tabs$image_name == "Sample_A" & raw_tabs$raw_data == "PEYS"],
    "MA"
  )
})

test_that("check_crosswalk reports unmapped labels", {
  example_dir <- system.file("extdata", package = "pointcoral")
  pts <- read_cpce_file(file.path(example_dir, "HIW_158_W_U-1.cpc"))
  xwalk <- read_label_crosswalk(file.path(example_dir, "pointcoral_example_crosswalk.csv"))
  xwalk <- xwalk[xwalk$raw_code != "SPO", ]

  report <- check_crosswalk(pts, xwalk)
  expect_true("missing_from_crosswalk" %in% report$issue_type)
  expect_error(standardize_labels(pts, xwalk, unknown_action = "error"))
})

test_that("coordinate conversion uses proportional scaling", {
  pts <- tibble::tibble(cpce_x = c(0, 50, 100), cpce_y = c(0, 25, 50))
  out <- convert_cpce_coords(pts, 100, 50, 1000, 500)

  expect_equal(out$x_px, c(0L, 500L, 1000L))
  expect_equal(out$y_px, c(0L, 250L, 500L))
})
