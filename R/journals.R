library(tibble)
library(dplyr)
library(magrittr)
library(BiocParallel, quietly = TRUE)
register(SnowParam(2))

# TODO: Equate column names to each other

get_journal_data <- function(data="incities") {
  if (data == "incities") {
    journal_data <- as_tibble(read.csv(file = "data/incities2016.csv", header = TRUE))
    journal_data$Title <- journal_data$Full.Journal.Title
    journal_data$Full.Journal.Title <- NULL
    journal_data$ISSN <- stringr::str_replace(journal_data$ISSN, "-", "")
  } else if (data == "scimago") {
    journal_data <- as.tibble(read.csv(file = "data/scimago2016.csv", header = TRUE))
    journal_data$ISSN <- journal_data$Issn
    journal_data$Issn <- NULL
    journal_data$ISSN <- stringr::str_replace(journal_data$ISSN, "ISSN ", "")
    journal_data$ISSN <- stringr::str_replace(journal_data$ISSN, ",", ";")
    issn_df <- as.data.frame(stringr::str_split(journal_data$ISSN, "; ", simplify = TRUE))
    journal_data <- dplyr::mutate(journal_data, ISSN.1 = issn_df$V1, ISSN.2 = issn_df$V2)
  }
  return(journal_data)
}


issn2journal_data <- function(data="incities", issns) {
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
