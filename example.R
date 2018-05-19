source("global.R")

# Create a results folder first!!!
# Decide on a query
# Generate pubmed data
pub_data <- get_publication_data(journal_source = "scimago", queries = query3, limit = 30000, min_citations = 5)

pmids <- pub_data$articles$pmid

# Get abstracts from pmids and create a wordcloud from the pubmed abstracts
get_word_cloud(pubmed_ids = pmids, plot_name = "results/example_wordcloud.png")


# Decide on categorical words to keep
cats <- "Multidisciplinary|Neuroscience|Psychology|Psychiatry"


# Select "best" journals based on median
# Only keep journals based on above categories
# Only keep journals
best_journals <- filter(pub_data$journals, SJR >= median(pub_data$journals$SJR) & grepl(cats, Categories) & Type == "journal")

# Decide on columns to keep
cols_to_keep <- c("Title", "Rank", "Type", "SJR", "Country", "Categories")
best_journals <- subset(best_journals, select=cols_to_keep)

# Save as a csv file
save_as_csv(best_journals, filename = "results/highest_impact_relevant_journals")