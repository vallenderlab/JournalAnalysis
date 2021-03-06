#' @title Get Article Data
#'
#' @description This function retrieves article data from europe pmc.
#'
#' @param queries Input a Europe PMC query
#' @param limit Minimum number of articles to retrieve
#' @param min_year Minimum publication year
#' @param max_year Maximum publication year
#' @param min_citations Minimum number of citations per article
#' @return A tibble of the article data
#' @export
get_article_data <- function(queries, limit=7500, min_year=2008, max_year=2018, min_citations=5) {
  BiocParallel::SnowParam(2)
  # Cycle through multiple queries and create a union of unique journal articles
  for (query in queries) {
    if (exists("eps")) {
      temp <- europepmc::epmc_search(query = query, limit = limit)
      temp <- dplyr::select(temp, one_of(colnames(eps)))
      eps <- dplyr::select(eps, one_of(colnames(temp)))
      eps <- dplyr::union(eps, temp)
    } else {
      eps <- europepmc::epmc_search(query = query, limit = limit)
    }
  }
  # Filter by min/max year and min citation
  if (!is.null(min_year)) {
    eps <- dplyr::filter(eps, pubYear > min_year)
  }
  message(sprintf("Removed records published before %s.", min_year))
  if (!is.null(max_year)) {
    eps <- dplyr::filter(eps, pubYear < max_year)
    message(sprintf("Removed records published after %s.", max_year))
  }
  if (!is.null(min_citations)) {
    eps <- dplyr::filter(eps, citedByCount > min_citations)
    message(sprintf("Removed records with less than %s citations.", min_citations))
  }
  # Remove pmid, doi and authors with NA values
  eps <- dplyr::filter(eps, !is.na(pmid) & !is.na(doi) & !is.na(authorString))
  message("Removed records with NA values for pmid, doi, and authors.")
  message(sprintf("%s records passed the filter.", length(rownames(eps))))
  eps$journalIssn <- stringr::str_replace(eps$journalIssn, "x", "X")
  eps$journalIssn <- stringr::str_replace_all(eps$journalIssn, "-", "")
  issns_df <- as.data.frame(stringr::str_split(eps$journalIssn, "; ", simplify = TRUE, n = 3))
  eps <- dplyr::mutate(eps, ISSN.1 = issns_df$V1, ISSN.2 = issns_df$V2)
  return(eps)
}

#' @title Get Unique ISSNs
#'
#' @description This function filters ISSNs.
#'
#' @param issns The issns from the articles
#' @return A tibble of filtered issns
#' @export
get_unique_issns <- function(issns) {
  issns_df <- as.data.frame(stringr::str_split(issns, "; ", simplify = TRUE, n = 3))
  primary_issns <- issns_df$V1
  secondary_issns <- dplyr::filter(issns_df, V2 != "")
  issns <- c(as.character(primary_issns), as.character(secondary_issns))
  # issns <- unique(issns)
  return(issns)
}

#' @title ISSN to Article Data
#'
#' @description This function filters article data by ISSN.
#'
#' @param data The data tibble of the articles
#' @param issns The issns from the articles
#' @return A tibble of the articles filtered by ISSNs
#' @export
issn_to_article_data <- function(data, issns) {
  data <- dplyr::filter(data, (ISSN.1 %in% issns) | (ISSN.2 %in% issns))
  return(data)
}

#' @title Get Articles With Journal Data
#'
#' @description FUNCTION_DESCRIPTION
#'
#' @param article_data DESCRIPTION.
#' @param journal_data DESCRIPTION.
#'
#' @return RETURN_DESCRIPTION
#' @examples
#' # ADD_EXAMPLES_HERE
get_articles_with_journal_data <- function(article_data, journal_data) {
  BiocParallel::SnowParam(2)
  new_df <- NULL
  for (i in 1:length(article_data$id)) {
    I1 <- as.character(article_data$ISSN.1[i])
    I2 <- as.character(article_data$ISSN.2[i])
    a_data <- article_data[i, ]

    if (I1 %in% journal_data$ISSN.1) {
      j_data <- dplyr::filter(journal_data, ISSN.1 == I1)
      ja_data <- dplyr::left_join(a_data, j_data, by = "ISSN.1")
    } else if (I1 %in% journal_data$ISSN.2) {
      j_data <- dplyr::filter(journal_data, ISSN.2 == I1)
      ja_data <- dplyr::left_join(a_data, j_data, by = c("ISSN.1" = "ISSN.2"))
    } else if (I2 %in% journal_data$ISSN.1) {
      j_data <- dplyr::filter(journal_data, ISSN.1 == I2)
      ja_data <- dplyr::left_join(a_data, j_data, by = c("ISSN.2" = "ISSN.1"))
    } else if (I2 %in% journal_data$ISSN.2) {
      j_data <- dplyr::filter(journal_data, ISSN.2 == I2)
      ja_data <- dplyr::left_join(a_data, j_data, by = "ISSN.2")
    } else {
      stop("ISSN didn not match")
    }
    if (is.null(new_df)) {
      new_df <- ja_data
    } else {
      new_df <- dplyr::bind_rows(new_df, ja_data)
    }
  }
  return(new_df)
}
