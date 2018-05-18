source("global.R")
source("scripts/journals.R")
source("scripts/articles.R")

get_publication_data <- function(journal_source, queries, limit=7500, 
                                 min_year=2008, max_year=2018, min_citations=5) {
  hot_data <- list()
  # Get journal data from incities or scimago
  journal_data <- get_journal_data(data = journal_source)
  # Get article data
  article_data <- get_article_data(queries = queries, limit = limit, min_year = min_year, 
                                   max_year = max_year, min_citations = min_citations)
  article_issns <- get_unique_issns(article_data$journalIssn)
  # Get journal data matching article ISSNs
  journal_data <- issn2journal_data(data = journal_data, issns = article_issns)
  journal_issns <- get_unique_issns(journal_data$ISSN)
  hot_data[["journals"]] <- journal_data
  # Get article data mathcing available ISSNs
  article_data <- issn2article_data(article_data, journal_issns)
  hot_data[["articles"]] <- article_data
  # Combine article data with journal data
  ja_data <- get_articles_with_journal_data(article_data, journal_data)
  hot_data[["combined"]] <- ja_data
  return(hot_data)
}

