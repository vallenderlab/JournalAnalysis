#' @title Get Publication Data
#'
#' @description This function uses a journal source to combine data based on queries.
#'
#' @param journal_source Journal metrics source: `incities` (InCites / JCR) or
#'   `scimago`. Aliases `incites`, `jcr`, and `scimagojr` are also accepted.
#' @param queries Use one or multiple queries
#' @param limit A minimum number of articles
#' @param min_year Minimum year to search
#' @param max_year Maximum year to search
#' @param min_citations Minimum number of citations in a journal
#' @param n_cores Number of cores to use across multiple queries.
#' @return A list of data objects including journals, articles, and combined data.
#' @export
get_publication_data <- function(journal_source, queries, limit=7500,
                                 min_year=NULL, max_year=NULL, min_citations=5,
                                 n_cores=default_worker_count()) {
  if (!is.character(queries) || length(queries) == 0 || anyNA(queries)) {
    stop("`queries` must be a non-empty character vector.", call. = FALSE)
  }

  hot_data <- list()

  # Get journal data from InCites (incities) or Scimago
  journal_data <- get_journal_data(data = journal_source)

  # Get article data
  article_data <- get_article_data(
    queries = queries, limit = limit, min_year = min_year,
    max_year = max_year, min_citations = min_citations, n_cores = n_cores
  )
  article_issns <- get_unique_issns(article_data$journalIssn)

  # Get journal data matching article ISSNs
  journal_data <- issn_to_journal_data(data = journal_data, issns = article_issns)
  journal_issns <- get_unique_issns(journal_data$ISSN)
  hot_data[["journals"]] <- journal_data

  # Get article data mathcing available ISSNs
  article_data <- issn_to_article_data(article_data, journal_issns)
  hot_data[["articles"]] <- article_data

  # Combine article data with journal data
  ja_data <- get_articles_with_journal_data(article_data, journal_data)
  hot_data[["combined"]] <- ja_data

  hot_data
}
