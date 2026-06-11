#' @title Get Word Cloud
#'
#' @description This function imports a list of pubmed ids and creates a word cloud.
#'
#' @param pubmed_ids A list of pubmed ids
#' @param plot_name Path to the output word cloud
#' @export
get_word_cloud <- function(pubmed_ids, plot_name) {
  abstracts <- PubMedWordcloud::getAbstracts(pubmed_ids)
  cleanAbs <- PubMedWordcloud::cleanAbstracts(abstracts)
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
  write.csv(data, file = paste0(filename, ".csv"), row.names = FALSE)
}

# Standardize ISSNs once so article and journal joins use the same keys.
#' Normalize ISSN values into a stable join format.
#'
#' @param issn_values Character vector of raw ISSN values.
#' @return Character vector of normalized ISSN values.
#' @keywords internal
#' @noRd
normalize_issn_values <- function(issn_values) {
  issn_values <- as.character(issn_values)
  issn_values[is.na(issn_values)] <- ""

  issn_values |>
    stringr::str_to_upper() |>
    stringr::str_replace_all("ISSN\\s+", "") |>
    stringr::str_replace_all("-", "") |>
    stringr::str_replace_all(",", ";") |>
    stringr::str_replace_all(";\\s*", "; ") |>
    stringr::str_squish()
}

#' Split normalized ISSNs into primary and secondary columns.
#'
#' @param issn_values Character vector of raw ISSN values.
#' @return A tibble with `ISSN.1` and `ISSN.2` columns.
#' @keywords internal
#' @noRd
split_normalized_issns <- function(issn_values) {
  normalized_issns <- normalize_issn_values(issn_values)

  if (length(normalized_issns) == 0) {
    return(tibble::tibble(ISSN.1 = character(), ISSN.2 = character()))
  }

  issn_matrix <- stringr::str_split(normalized_issns, "; ", simplify = TRUE, n = 3)

  if (ncol(issn_matrix) < 2) {
    issn_matrix <- cbind(issn_matrix, "")
  }

  tibble::tibble(
    ISSN.1 = issn_matrix[, 1],
    ISSN.2 = issn_matrix[, 2]
  )
}

#' Collect deduplicated ISSNs from raw article or journal fields.
#'
#' @param issn_values Character vector of raw ISSN values.
#' @return Character vector of unique normalized ISSNs.
#' @keywords internal
#' @noRd
collect_unique_issns <- function(issn_values) {
  issn_components <- split_normalized_issns(issn_values)
  unique_issns <- unique(c(issn_components$ISSN.1, issn_components$ISSN.2))

  unique_issns[!is.na(unique_issns) & nzchar(unique_issns)]
}

#' Validate and normalize supported journal source names.
#'
#' @param data Source name supplied by the caller.
#' @return Normalized source name used internally.
#' @keywords internal
#' @noRd
match_journal_source <- function(data) {
  if (!is.character(data) || length(data) != 1 || is.na(data)) {
    stop("`data` must be a single character value.", call. = FALSE)
  }

  normalized_source <- tolower(data)

  if (normalized_source %in% c("incities", "incites", "jcr")) {
    normalized_source <- "incities"
  }

  if (normalized_source %in% c("scimago", "scimagojr")) {
    normalized_source <- "scimago"
  }

  if (!normalized_source %in% c("incities", "scimago")) {
    stop(
      "`data` must be one of \"incities\", \"incites\", \"jcr\", \"scimago\", or \"scimagojr\".",
      call. = FALSE
    )
  }

  normalized_source
}

#' Validate year filter bounds before article retrieval.
#'
#' @param min_year Optional minimum publication year.
#' @param max_year Optional maximum publication year.
#' @return Called for side effects only.
#' @keywords internal
#' @noRd
validate_year_bounds <- function(min_year, max_year) {
  if (!is.null(min_year) && (!is.numeric(min_year) || length(min_year) != 1)) {
    stop("`min_year` must be NULL or a single numeric value.", call. = FALSE)
  }

  if (!is.null(max_year) && (!is.numeric(max_year) || length(max_year) != 1)) {
    stop("`max_year` must be NULL or a single numeric value.", call. = FALSE)
  }

  if (!is.null(min_year) && !is.null(max_year) && min_year > max_year) {
    stop("`min_year` must be less than or equal to `max_year`.", call. = FALSE)
  }
}

#' Choose a conservative default worker count for local parallel work.
#'
#' @param reserve_cores Number of cores to keep free.
#' @return Integer worker count with a minimum of one.
#' @keywords internal
#' @noRd
default_worker_count <- function(reserve_cores = 2L) {
  detected_cores <- parallel::detectCores(logical = TRUE)

  if (is.na(detected_cores)) {
    return(1L)
  }

  max(1L, as.integer(detected_cores) - as.integer(reserve_cores))
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
    "stringr",
    "PubMedWordcloud"
  )
  required_bioconductor_packages <- character()
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
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager", repos = "https://cran.rstudio.com")
    }
    BiocManager::install(bioconductor_packages_to_install, update = FALSE, ask = FALSE)
  }
  if (length(github_packages_to_install) > 0) {
    devtools::install_github(github_packages_to_install)
  }
}

# Provide sample queries ------------------------------------------------------
#' @export
query1 <- "microbiome AND (psychiatry OR brain OR neurons OR neuroscience OR rhesus OR macaque OR addiction) (NOT ecology)"
#' @export
query2 <- "microbiome AND environmental stress AND (rhesus OR macaque OR brain) (NOT ecology)"
#' @export
query3 <- "microbiome AND (psychiatry OR psychology OR neuroscience) AND (rhesus OR macaque or human or stress or monkey) AND (NOT ecology)"
