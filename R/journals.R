library(tibble)
library(dplyr)
library(magrittr)
library(BiocParallel, quietly = TRUE)
register(SnowParam(2))

# TODO: Equate column names to each other

get_journal_data <- function(data="incities") {
  if (data == "incities") {
    journal_data = as_tibble(read.csv(file = "data/incities2016.csv", header = TRUE))
    journal_data$Title <- journal_data$Full.Journal.Title
    journal_data$Full.Journal.Title <- NULL
  } else if (data == "scimago") {
    journal_data <- read.csv(file = "data/scimago2016.csv", header = TRUE)
    journal_data$ISSN <- journal_data$Issn
    journal_data$Issn <- NULL
    journal_data <- stringr::str_replace(journal_data$ISSN, "ISSN ", "") %>% 
      stringr::str_replace(",", ";")
    journal_data <- as_tibble(journal_data)
  }
  return(journal_data)
}


issn2journal_data <- function(data="incities", issns) {
  if (any(class(data) != "tbl")) {
    data <- get_journal_data(data=data)
  }
  data <- dplyr::filter(data, if_else(
    (data$ISSN %in% stringr::str_split(issns, ";", simplify = TRUE)[,1]), TRUE, 
    if_else(data$ISSN %in% stringr::str_split(issns, ";", simplify = TRUE), TRUE, FALSE)))
  return(data)
}
