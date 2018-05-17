library(europepmc)
library(dplyr)
library(BiocParallel, quietly = TRUE)
register(SnowParam(2))

get_article_data <- function(queries, limit=7500, min_year=2008, max_year=2018, min_citations=5) {
  # Cycle through multiple queries and create a union of unique journal articles
  for (query in queries) {
    if (exists("eps")) {
      temp <- epmc_search(query = query, limit=limit)
      temp <- dplyr::select(temp, one_of(colnames(eps)))
      eps <- dplyr::select(eps, one_of(colnames(temp)))
      eps <- dplyr::union(eps, temp)
    } else {
    eps <- epmc_search(query = query, limit=limit)
    }
  }
  # Filter by min/max year and min citation
  if (!is.null(min_year)){
    eps <- dplyr::filter(eps, pubYear > min_year)
  }
  message(sprintf("Removed records published before %s.", min_year))
  if (!is.null(max_year)){
    eps <- dplyr::filter(eps, pubYear < max_year)
    message(sprintf("Removed records published after %s.", max_year))
  }
  if(!is.null(min_citations)) {
    eps <- dplyr::filter(eps, citedByCount > min_citations)
    message(sprintf("Removed records with less than %s citations.", min_citations))
  }
  # Remove pmid, doi and authors iwth NA values
  eps <- dplyr::filter(eps, !is.na(pmid) & !is.na(doi) & !is.na(authorString))
  message("Removed records with NA values for pmid, doi, and authors.")
  message(sprintf("%s records passed the filter.", length(rownames(eps))))
  eps$journalIssn <- stringr::str_replace(eps$journalIssn, "x", "X")
  eps$journalIssn <- stringr::str_replace_all(eps$journalIssn, "-", "")
  print(eps)
  return(eps)
}

get_unique_issns <- function(issns){
  issns_df <- as.data.frame(stringr::str_split(issns, "; ", simplify = TRUE, n=3))
  primary_issns <- issns_df$V1
  secondary_issns <- filter(issns_df, V2 != "")$V2
  issns <- c(as.character(primary_issns), as.character(secondary_issns))
  #issns <- unique(issns)
  return(issns)
}