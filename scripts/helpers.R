library(PubMedWordcloud)

get_word_cloud <- function(pubmed_ids, plot_name) {
  abstracts = getAbstracts(pubmed_ids)
  cleanAbs = cleanAbstracts(abstracts)
  png(filename = plot_name, units = "in", width = 6, height = 6, res = 300)
  plotWordCloud(cleanAbs, rot.per = 0, min.freq = 5)
  dev.off()
}


save_as_csv <- function(data, filename) {
  write.csv(data, file = paste0(filename,".csv"), row.names = FALSE)
}