# Rebuild bundled journal metrics from the raw CSV snapshots in data/.

normalize_scimagojr2025 <- function(path) {
  scimagojr2025 <- read.csv2(path, stringsAsFactors = FALSE, check.names = TRUE)

  scimagojr2025$Title <- gsub("_", " ", scimagojr2025$Title, fixed = TRUE)
  scimagojr2025$Publisher.1 <- NULL

  scimagojr2025
}

normalize_jcr2023_wos <- function(path) {
  jcr2023_wos <- read.csv(path, stringsAsFactors = FALSE, check.names = TRUE)

  parse_numeric_field <- function(values) {
    values[values == ""] <- NA_character_
    values <- gsub(",", "", values, fixed = TRUE)
    values <- sub("^<", "", values)
    as.numeric(values)
  }

  jcr2023_wos$total_citations <- parse_numeric_field(jcr2023_wos$total_citations)
  jcr2023_wos$impact_factor_2023 <- parse_numeric_field(jcr2023_wos$impact_factor_2023)
  jcr2023_wos$jci_2023 <- parse_numeric_field(jcr2023_wos$jci_2023)
  jcr2023_wos$percent_oa_gold <- parse_numeric_field(jcr2023_wos$percent_oa_gold)

  jcr2023_wos
}

scimagojr2025 <- normalize_scimagojr2025("data/scimagojr_2025.csv")
jcr2023_wos <- normalize_jcr2023_wos("data/jcr_2023_wos.csv")

save(scimagojr2025, file = "data/scimagojr_2025.rda", compress = "bzip2")
save(jcr2023_wos, file = "data/jcr2023_wos.rda", compress = "bzip2")
