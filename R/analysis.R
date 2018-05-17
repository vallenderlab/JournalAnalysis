source("R/journals.R")
source("R/articles.R")


journal_data <- get_journal_data(data="scimago")


q1 <- "microbiome AND (psychiatry OR brain OR neurons OR neuroscience OR rhesus OR macaque OR addiction) (NOT ecology)"
q2 <- "microbiome AND environmental stress AND (rhesus OR macaque OR brain) (NOT ecology)"

article_data <- get_article_data(queries = c(q1, q2), limit = 15000, min_citations = 10)
article_issns <- get_unique_issns(article_data$journalIssn)

journal_data <- issn2journal_data(data=journal_data, issns = article_issns)