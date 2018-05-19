# TODO: Equate column names to each other
#' @title Get Journal Data
#'
#' @description This function retrieves journal data from an existing data file.
#'
#' @param data A data source included in the package's data folder. Can be scimago or incities.
#' @return A tibble of the journal data.
#' @export
get_journal_data <- function(data="incities") {
  if (data == "incities") {
    journal_data <- as.tibble(JournalAnalysis::incities2016)
    journal_data$Title <- journal_data$Full.Journal.Title
    journal_data$Full.Journal.Title <- NULL
    journal_data$ISSN <- stringr::str_replace(journal_data$ISSN, "-", "")
  } else if (data == "scimago") {
    journal_data <- as.tibble(JournalAnalysis::scimago2016)
    journal_data$ISSN <- journal_data$Issn
    journal_data$Issn <- NULL
    journal_data$ISSN <- stringr::str_replace(journal_data$ISSN, "ISSN ", "")
    journal_data$ISSN <- stringr::str_replace(journal_data$ISSN, ",", ";")
    issn_df <- as.data.frame(stringr::str_split(journal_data$ISSN, "; ", simplify = TRUE))
    journal_data <- dplyr::mutate(journal_data, ISSN.1 = issn_df$V1, ISSN.2 = issn_df$V2)
  }
  return(journal_data)
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
  if (!"tbl" %in% class(data)) {
    data <- get_journal_data(data = data)
  }
  if ("ISSN.1" %in% colnames(data)) {
    data <- dplyr::filter(data, (ISSN.1 %in% issns) | (ISSN.2 %in% issns))
  } else {
    data <- dplyr::filter(data, ISSN %in% issns)
  }
  return(data)
}
