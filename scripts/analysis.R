source("R/journals.R")
source("R/articles.R")

journal_data <- get_journal_data(data = "scimago")


q1 <- "microbiome AND (psychiatry OR brain OR neurons OR neuroscience OR rhesus OR macaque OR addiction) (NOT ecology)"
q2 <- "microbiome AND environmental stress AND (rhesus OR macaque OR brain) (NOT ecology)"

# Get article data
article_data <- get_article_data(queries = c(q1, q2), limit = 15000, min_citations = 10)
article_issns <- get_unique_issns(article_data$journalIssn)

# Get journal data matching article ISSNs
journal_data <- issn2journal_data(data = journal_data, issns = article_issns)
journal_issns <- get_unique_issns(journal_data$ISSN)

# Get article data mathcing available ISSNs
article_data <- issn2article_data(article_data, journal_issns)

# Combine article data with journal data
ja_data <- get_articles_with_journal_data(article_data, journal_data)

write.csv(ja_data, "query_results/microbiome_articles.csv")
write.csv(journal_data, "query_results/microbiome_journals.csv")
