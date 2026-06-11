# TODO: Equate column names to each other
#' @title Get Journal Data
#'
#' @description This function retrieves journal data from an existing data file.
#'
#' @param data A bundled journal source. Use `incities` (InCites / JCR) or
#'   `scimago`. The aliases `incites`, `jcr`, and `scimagojr` are also accepted.
#' @return A tibble of the journal data.
#' @export
get_journal_data <- function(data = "incities") {
  data <- match_journal_source(data)

  if (data == "incities") {
    journal_data <- tibble::as_tibble(JournalAnalysis::jcr2023_wos)
    journal_data <- dplyr::mutate(
      journal_data,
      Rank = dplyr::row_number(),
      Title = journal_name,
      Full.Journal.Title = journal_name,
      ISSN = dplyr::if_else(
        !is.na(e_issn) & nzchar(e_issn),
        paste(issn, e_issn, sep = "; "),
        issn
      ),
      Total.Cites = total_citations,
      Journal.Impact.Factor = impact_factor_2023,
      JIF.Quartile = jif_quartile,
      JCI.2023 = jci_2023,
      Percent.OA.Gold = percent_oa_gold
    )
  } else {
    journal_data <- tibble::as_tibble(JournalAnalysis::scimagojr2025)
    journal_data <- dplyr::mutate(journal_data, ISSN = Issn)
    journal_data <- dplyr::mutate(
      journal_data,
      Title = stringr::str_replace_all(Title, "_", " ")
    )
  }

  journal_data <- dplyr::mutate(
    journal_data,
    ISSN = normalize_issn_values(ISSN)
  )
  journal_data <- dplyr::bind_cols(journal_data, split_normalized_issns(journal_data$ISSN))

  journal_data
}

#' @title ISSN to Journal Data
#'
#' @description This function retrieves journal data from an existing data file.
#'
#' @param data The data source of the journal
#' @param issns The issns from the journal source
#' @return A tibble of the data filtered by ISSN
#' @export
issn_to_journal_data <- function(data, issns) {
  if (!inherits(data, "tbl_df")) {
    data <- get_journal_data(data = data)
  }

  normalized_issns <- collect_unique_issns(issns)

  if (!all(c("ISSN.1", "ISSN.2") %in% colnames(data)) && "ISSN" %in% colnames(data)) {
    data <- dplyr::bind_cols(data, split_normalized_issns(data$ISSN))
  }

  dplyr::filter(data, (ISSN.1 %in% normalized_issns) | (ISSN.2 %in% normalized_issns))
}
