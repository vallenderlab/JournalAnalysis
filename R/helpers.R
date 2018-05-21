#' @title Get Word Cloud
#'
#' @description This function imports a list of pubmed ids and creates a word cloud.
#'
#' @param pubmed_ids A list of pubmed ids
#' @param plot_name Path to the output word cloud
#' @export
get_word_cloud <- function(pubmed_ids, plot_name) {
  abstracts = PubMedWordcloud::getAbstracts(pubmed_ids)
  cleanAbs = PubMedWordcloud::cleanAbstracts(abstracts)
  png(filename = plot_name, units = "in", width = 6, height = 6, res = 300)
  PubMedWordcloud::plotWordCloud(cleanAbs, rot.per = 0, min.freq = 5)
  dev.off()
}

#' @title Save as CSV
#'
#' @description This function saves a tibble or dataframe as a csv file.
#'
#' @param data The dataframe or tibble
#' @param filename Name or path of output file without .csv extension
#' @export
save_as_csv <- function(data, filename) {
  write.csv(data, file = paste0(filename,".csv"), row.names = FALSE)
}

#' @title Install JournalAnalysis Packages
#'
#' @description This function helps user to install packages used in this package
#'
#' @export
install_journalanalysis_packages <- function() {
  required_cran_packages <- c(
    "europepmc",
    "dplyr",
    "tibble",
    "magrittr",
    "stringr",
    "ggplot2",
    "ggthemes",
    "PubMedWordcloud"
  )
  required_bioconductor_packages <- c(
    "BiocParallel"
  )
  required_github_packages <- c()
  # Create a list of packages to install.
  cran_packages_to_install <- required_cran_packages[!(required_cran_packages %in% installed.packages()[, 1])]
  bioconductor_packages_to_install <- required_bioconductor_packages[!(required_bioconductor_packages %in% installed.packages()[, 1])]
  github_packages_to_install <- required_github_packages[!(gsub(".*/", "", required_github_packages) %in% installed.packages()[, 1])]
  
  # Install packages from lists.
  if (length(cran_packages_to_install) > 0) {
    install.packages(cran_packages_to_install, repos = "https://cran.rstudio.com")
  }
  if (length(bioconductor_packages_to_install) > 0) {
    source("https://bioconductor.org/biocLite.R")
    biocLite(bioconductor_packages_to_install)
  }
  if (length(github_packages_to_install) > 0) {
    devtools::install_github(github_packages_to_install)
  }
  
  # Remove unnecessary environment variables.
  remove(required_cran_packages)
  remove(required_bioconductor_packages)
  remove(required_github_packages)
  remove(bioconductor_packages_to_install)
  remove(cran_packages_to_install)
  remove(github_packages_to_install)
}

# Provide sample queries ------------------------------------------------------
#' @export
query1 <- "microbiome AND (psychiatry OR brain OR neurons OR neuroscience OR rhesus OR macaque OR addiction) (NOT ecology)"
#' @export
query2 <- "microbiome AND environmental stress AND (rhesus OR macaque OR brain) (NOT ecology)"
#' @export
query3 <- "microbiome AND (psychiatry OR psychology OR neuroscience) AND (rhesus OR macaque or human or stress or monkey) AND (NOT ecology)"