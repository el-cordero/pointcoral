# Build the bundled example crosswalk.
#
# This table keeps raw CPCe labels as the original short codes from `.cpc`
# files and maps them to full species/type labels plus the `major_class` and
# `label_class` vocabulary used in `_existing/clean_transect_raw.py`.
#
# The original CPCe codefile referenced inside the sample `.cpc` files was not
# present in the workspace, so users should still review this example against
# their own CPCe codefile and project-specific crosswalk.

library(tibble)
library(readr)

class_ids <- c(
  "CORAL (C)" = 0L,
  "GORGONIANS (G)" = 1L,
  "SPONGES (S)" = 2L,
  "ZOANTHIDS (Z)" = 3L,
  "MACROALGAE (MA)" = 4L,
  "PEYSSONNELIACEAE" = 5L,
  "CALCAREOUS GREEN" = 6L,
  "CORALLINE ALGAE (CA)" = 7L,
  "SAND, PAVEMENT, RUBBLE (SPR)" = 8L,
  "DEAD CORAL WITH ALGAE (DCA)" = 9L,
  "DISEASED CORALS (DC)" = 10L,
  "OTHER LIVE (OL)" = 11L,
  "ASCIDIAN" = 12L,
  "TAPE, WAND, SHADOW (TWS)" = 13L,
  "UNKNOWNS (U)" = 14L
)

class_colors <- c(
  "CORAL (C)" = "#ff4d4d",
  "GORGONIANS (G)" = "#ff944d",
  "SPONGES (S)" = "#3399ff",
  "ZOANTHIDS (Z)" = "#cc66ff",
  "MACROALGAE (MA)" = "#33cc66",
  "PEYSSONNELIACEAE" = "#cc3366",
  "CALCAREOUS GREEN" = "#66cc99",
  "CORALLINE ALGAE (CA)" = "#8b0000",
  "SAND, PAVEMENT, RUBBLE (SPR)" = "#d8c28a",
  "DEAD CORAL WITH ALGAE (DCA)" = "#8c564b",
  "DISEASED CORALS (DC)" = "#000000",
  "OTHER LIVE (OL)" = "#ffd700",
  "ASCIDIAN" = "#9acd32",
  "TAPE, WAND, SHADOW (TWS)" = "#00ffff",
  "UNKNOWNS (U)" = "#bdbdbd"
)

rows <- tribble(
  ~raw_code, ~full_label, ~label_class, ~major_category,
  "AC", "Acropora cervicornis", "subcategory", "CORAL (C)",
  "AP", "Acropora prolifera", "subcategory", "CORAL (C)",
  "APR", "Acropora prolifera", "subcategory", "CORAL (C)",
  "AA", "Agaricia", "subcategory", "CORAL (C)",
  "AF", "Agaricia fragilis", "subcategory", "CORAL (C)",
  "AG", "Agaricia grahamae", "subcategory", "CORAL (C)",
  "AH", "Undaria humili", "subcategory", "CORAL (C)",
  "AT", "Agaricia tenuifolia", "subcategory", "CORAL (C)",
  "AU", "Agaricia undata", "subcategory", "CORAL (C)",
  "AL", "Agaricia lamarcki", "subcategory", "CORAL (C)",
  "CB", "Colpophyllia breviserialis", "subcategory", "CORAL (C)",
  "CN", "Colpophyllia natans", "subcategory", "CORAL (C)",
  "CORAL", "Coral", "subcategory", "CORAL (C)",
  "CORJU", "Coral juvenile", "subcategory", "CORAL (C)",
  "DCY", "Dendrogyra cylindrus", "subcategory", "CORAL (C)",
  "DST", "Dichocoenia stellaris", "subcategory", "CORAL (C)",
  "DSO", "Dichocoenia stokesi", "subcategory", "CORAL (C)",
  "DC", "Diploria", "subcategory", "CORAL (C)",
  "DL", "Diploria labyrinthiformis", "subcategory", "CORAL (C)",
  "DS", "Diploria strigosa", "subcategory", "CORAL (C)",
  "EF", "Eusmilia fastigiata", "subcategory", "CORAL (C)",
  "FF", "Favia fragum", "subcategory", "CORAL (C)",
  "IS", "Isophyllia", "subcategory", "CORAL (C)",
  "LC", "Leptoseris cucullata", "subcategory", "CORAL (C)",
  "MD", "Madracis", "subcategory", "CORAL (C)",
  "MM", "Meandrina meandrites", "subcategory", "CORAL (C)",
  "MPHA", "Madracis pharensis", "subcategory", "CORAL (C)",
  "MOSA", "Montastraea", "subcategory", "CORAL (C)",
  "MAR", "Montastraea annularis", "subcategory", "CORAL (C)",
  "MME", "Meandrina meandrites", "subcategory", "CORAL (C)",
  "MILA", "Millipora", "subcategory", "CORAL (C)",
  "MILC", "Millipora", "subcategory", "CORAL (C)",
  "MILS", "Millipora", "subcategory", "CORAL (C)",
  "MA", "Montastraea annularis", "subcategory", "CORAL (C)",
  "MC", "Montastraea cavernosa", "subcategory", "CORAL (C)",
  "MFAV", "Orbicella faveolata", "subcategory", "CORAL (C)",
  "MFRN", "Orbicella franksi", "subcategory", "CORAL (C)",
  "MAN", "Montastraea annularis", "subcategory", "CORAL (C)",
  "MAL", "Agaricia lamarcki", "subcategory", "CORAL (C)",
  "MDA", "Madracis", "subcategory", "CORAL (C)",
  "MF", "Montastrea faveolata", "subcategory", "CORAL (C)",
  "ML", "Agaricia lamarcki", "subcategory", "CORAL (C)",
  "OD", "Oculina", "subcategory", "CORAL (C)",
  "PA", "Porites astreoides", "subcategory", "CORAL (C)",
  "PB", "Porites", "subcategory", "CORAL (C)",
  "PD", "Porites", "subcategory", "CORAL (C)",
  "PF", "Porites", "subcategory", "CORAL (C)",
  "PP", "Porites porites", "subcategory", "CORAL (C)",
  "SC", "Scolymia cubensis", "subcategory", "CORAL (C)",
  "SL", "Scolymia lacera", "subcategory", "CORAL (C)",
  "SR", "Siderastrea radians", "subcategory", "CORAL (C)",
  "SS", "Siderastrea siderea", "subcategory", "CORAL (C)",
  "SB", "Solenastrea bournoni", "subcategory", "CORAL (C)",
  "SH", "Solenastrea hyades", "subcategory", "CORAL (C)",
  "SM", "Stephanocoenia michelinii", "subcategory", "CORAL (C)",
  "TA", "Tubastraea aurea", "subcategory", "CORAL (C)",
  "BRI", "Briareum", "subcategory", "GORGONIANS (G)",
  "ERY", "Erythropodium", "subcategory", "GORGONIANS (G)",
  "EUN", "Eunicea", "subcategory", "GORGONIANS (G)",
  "GORG", "Gorgonian", "subcategory", "GORGONIANS (G)",
  "ICIL", "Iciligorgia", "subcategory", "GORGONIANS (G)",
  "MUR", "Muricea", "subcategory", "GORGONIANS (G)",
  "MOPS", "Muriceopsis", "subcategory", "GORGONIANS (G)",
  "PAURA", "Plexaura", "subcategory", "GORGONIANS (G)",
  "PRELA", "Plexaurella", "subcategory", "GORGONIANS (G)",
  "PSDP", "Pseudoplexaura", "subcategory", "GORGONIANS (G)",
  "PSPT", "Pseudopterogorgia", "subcategory", "GORGONIANS (G)",
  "PTER", "Pterogorgia", "subcategory", "GORGONIANS (G)",
  "SPO", "Sponge", "subcategory", "SPONGES (S)",
  "PAL", "Palythoa sp.", "subcategory", "ZOANTHIDS (Z)",
  "ZO", "Zoanthid", "subcategory", "ZOANTHIDS (Z)",
  "DICT", "Dictyota", "subcategory", "MACROALGAE (MA)",
  "LIAG", "Liagora", "subcategory", "MACROALGAE (MA)",
  "LOBO", "Lobophora variegata", "subcategory", "MACROALGAE (MA)",
  "MACA", "Macroalgae", "subcategory", "MACROALGAE (MA)",
  "PAD", "Padina", "subcategory", "MACROALGAE (MA)",
  "SARG", "Sargassum", "subcategory", "MACROALGAE (MA)",
  "SCHIZ", "Schizothrix", "subcategory", "MACROALGAE (MA)",
  "TURF", "Turf", "subcategory", "MACROALGAE (MA)",
  "WRAN", "Wrangelia", "subcategory", "MACROALGAE (MA)",
  "MICR", "Microdictyon", "subcategory", "MACROALGAE (MA)",
  "RHIP", "Rhipiliopsis", "subcategory", "MACROALGAE (MA)",
  "VERD", "Verdigela sp", "subcategory", "MACROALGAE (MA)",
  "HALI", "Halimeda", "subcategory", "CALCAREOUS GREEN",
  "PEYS", "Peyssonnelia", "subcategory", "PEYSSONNELIACEAE",
  "PEBO", "Peyssonnelia boergessenii", "subcategory", "PEYSSONNELIACEAE",
  "PEFL", "Peyssonnelia flavescens", "subcategory", "PEYSSONNELIACEAE",
  "PEGI", "Peyssonnelia gigaspora", "subcategory", "PEYSSONNELIACEAE",
  "PEIR", "Peyssonnelia iridescens", "subcategory", "PEYSSONNELIACEAE",
  "PEME", "Peyssonnelia megasorus", "subcategory", "PEYSSONNELIACEAE",
  "PY", "Peyssonnelia", "subcategory", "PEYSSONNELIACEAE",
  "AMP", "Amphiroa", "subcategory", "CORALLINE ALGAE (CA)",
  "CALG", "Coralline algae", "subcategory", "CORALLINE ALGAE (CA)",
  "NA", "Neogoniolithon", "subcategory", "CORALLINE ALGAE (CA)",
  "POR", "Porolithon", "subcategory", "CORALLINE ALGAE (CA)",
  "ASC", "Ascidian", "subcategory", "ASCIDIAN",
  "O", "Other", "subcategory", "OTHER LIVE (OL)",
  "P", "Pavement", "subcategory", "SAND, PAVEMENT, RUBBLE (SPR)",
  "R", "Rubble", "subcategory", "SAND, PAVEMENT, RUBBLE (SPR)",
  "S", "Sand", "subcategory", "SAND, PAVEMENT, RUBBLE (SPR)",
  "UNK", "Unknown", "subcategory", "UNKNOWNS (U)",
  "SHAD", "Shadow", "artifact", "TAPE, WAND, SHADOW (TWS)",
  "TAPE", "Tape", "artifact", "TAPE, WAND, SHADOW (TWS)",
  "WAND", "Wand", "artifact", "TAPE, WAND, SHADOW (TWS)",
  "DCOR", "Diseased coral", "disease_or_condition", "DISEASED CORALS (DC)",
  "DCA", "Dead coral with algae", "subcategory", "DEAD CORAL WITH ALGAE (DCA)",
  "DG", "Dead gorgonian", "subcategory", "DEAD CORAL WITH ALGAE (DCA)",
  "ODC", "Old dead coral", "subcategory", "DEAD CORAL WITH ALGAE (DCA)",
  "RDC", "Recently dead coral", "subcategory", "DEAD CORAL WITH ALGAE (DCA)"
)

crosswalk <- rows
crosswalk$raw_label <- crosswalk$raw_code
crosswalk$clean_label <- crosswalk$full_label
crosswalk$ml_class <- crosswalk$major_category
crosswalk$class_id <- unname(class_ids[crosswalk$major_category])
crosswalk$include_in_analysis <- TRUE
crosswalk$include_in_ml <- TRUE
crosswalk$color_hex <- unname(class_colors[crosswalk$major_category])
crosswalk$notes <- paste(
  "Example mapping aligned to _existing/clean_transect_raw.py major_class/label_class vocabulary.",
  "Raw labels remain CPCe short codes; clean/full labels are species or benthic type names.",
  "Review against your project CPCe codefile before analysis."
)

crosswalk <- crosswalk[, c(
  "raw_code", "raw_label", "full_label", "clean_label", "label_class",
  "major_category", "ml_class", "class_id", "include_in_analysis",
  "include_in_ml", "color_hex", "notes"
)]

write_csv(crosswalk, "inst/extdata/pointcoral_example_crosswalk.csv")
