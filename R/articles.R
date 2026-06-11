#' @title Get Article Data
#'
#' @description This function retrieves article data from europe pmc.
#'
#' @param queries Input a Europe PMC query
#' @param limit Minimum number of articles to retrieve
#' @param min_year Minimum publication year
#' @param max_year Maximum publication year
#' @param min_citations Minimum number of citations per article
#' @param n_cores Number of cores to use across multiple queries.
#' @return A tibble of the article data
#' @export
get_article_data <- function(queries, limit=7500, min_year=NULL, max_year=NULL,
                             min_citations=5, n_cores=default_worker_count()) {
  if (!is.character(queries) || length(queries) == 0 || anyNA(queries)) {
    stop("`queries` must be a non-empty character vector.", call. = FALSE)
  }

  if (!is.numeric(limit) || length(limit) != 1 || is.na(limit) || limit <= 0) {
    stop("`limit` must be a single positive numeric value.", call. = FALSE)
  }

  validate_year_bounds(min_year = min_year, max_year = max_year)

  if (!is.null(min_citations) &&
      (!is.numeric(min_citations) || length(min_citations) != 1 || is.na(min_citations))) {
    stop("`min_citations` must be NULL or a single numeric value.", call. = FALSE)
  }

  if (!is.numeric(n_cores) || length(n_cores) != 1 || is.na(n_cores) || n_cores < 1) {
    stop("`n_cores` must be a single positive numeric value.", call. = FALSE)
  }

  limit <- as.integer(limit)
  n_cores <- as.integer(n_cores)

  # Query-level parallelism helps when the user passes multiple search strings.
  if (length(queries) > 1 && n_cores > 1 && .Platform$OS.type != "windows") {
    search_results <- parallel::mclapply(
      queries,
      function(query) europepmc::epmc_search(query = query, limit = limit),
      mc.cores = min(n_cores, length(queries))
    )
  } else {
    search_results <- lapply(
      queries,
      function(query) europepmc::epmc_search(query = query, limit = limit)
    )
  }

  # Cycle through multiple queries and create a union of unique journal articles
  eps <- NULL
  for (temp in search_results) {
    if (is.null(eps)) {
      eps <- temp
    } else {
      temp <- dplyr::select(temp, dplyr::any_of(colnames(eps)))
      eps <- dplyr::select(eps, dplyr::any_of(colnames(temp)))
      eps <- dplyr::union(eps, temp)
    }
  }

  eps <- dplyr::mutate(
    eps,
    pubYear = suppressWarnings(as.integer(.data$pubYear)),
    citedByCount = suppressWarnings(as.numeric(.data$citedByCount))
  )

  # Filter by min/max year and min citation
  if (!is.null(min_year)) {
    eps <- dplyr::filter(eps, !is.na(.data$pubYear) & .data$pubYear >= min_year)
    message(sprintf("Removed records published before %s.", min_year))
  }
  if (!is.null(max_year)) {
    eps <- dplyr::filter(eps, !is.na(.data$pubYear) & .data$pubYear <= max_year)
    message(sprintf("Removed records published after %s.", max_year))
  }
  if (!is.null(min_citations)) {
    eps <- dplyr::filter(
      eps,
      !is.na(.data$citedByCount) & .data$citedByCount >= min_citations
    )
    message(sprintf("Removed records with less than %s citations.", min_citations))
  }

  # Remove pmid, doi and authors with NA values
  eps <- dplyr::filter(
    eps,
    !is.na(.data$pmid) &
      !is.na(.data$doi) &
      !is.na(.data$authorString)
  )
  message("Removed records with NA values for pmid, doi, and authors.")
  message(sprintf("%s records passed the filter.", nrow(eps)))

  issn_components <- split_normalized_issns(eps$journalIssn)
  eps <- dplyr::mutate(eps, journalIssn = normalize_issn_values(.data$journalIssn))
  eps <- dplyr::bind_cols(eps, issn_components)

  eps
}

#' @title Get Unique ISSNs
#'
#' @description This function filters ISSNs.
#'
#' @param issns The issns from the articles
#' @return A tibble of filtered issns
#' @export
get_unique_issns <- function(issns) {
  collect_unique_issns(issns)
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
  normalized_issns <- collect_unique_issns(issns)

  dplyr::filter(
    data,
    (.data$ISSN.1 %in% normalized_issns) | (.data$ISSN.2 %in% normalized_issns)
  )
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
#' @keywords internal
get_articles_with_journal_data <- function(article_data, journal_data) {
  article_data <- dplyr::mutate(article_data, .article_row = dplyr::row_number())

  article_issn_index <- dplyr::bind_rows(
    dplyr::transmute(article_data, .article_row, matched_issn = .data$ISSN.1),
    dplyr::transmute(article_data, .article_row, matched_issn = .data$ISSN.2)
  ) |>
    dplyr::filter(!is.na(.data$matched_issn) & nzchar(.data$matched_issn)) |>
    dplyr::distinct()

  journal_issn_index <- dplyr::bind_rows(
    dplyr::mutate(journal_data, matched_issn = .data$ISSN.1),
    dplyr::mutate(journal_data, matched_issn = .data$ISSN.2)
  ) |>
    dplyr::filter(!is.na(.data$matched_issn) & nzchar(.data$matched_issn)) |>
    dplyr::mutate(.journal_match = TRUE) |>
    dplyr::distinct(.data$matched_issn, .keep_all = TRUE)

  article_journal_matches <- dplyr::left_join(
    article_issn_index,
    journal_issn_index,
    by = "matched_issn"
  )

  unmatched_articles <- article_journal_matches |>
    dplyr::group_by(.data$.article_row) |>
    dplyr::summarise(has_match = any(!is.na(.data$.journal_match)), .groups = "drop") |>
    dplyr::filter(!.data$has_match)

  if (nrow(unmatched_articles) > 0) {
    warning(
      sprintf(
        "Skipping %s article record(s) with no matching journal ISSN.",
        nrow(unmatched_articles)
      ),
      call. = FALSE
    )
  }

  matched_journal_data <- article_journal_matches |>
    dplyr::filter(!is.na(.data$.journal_match)) |>
    dplyr::distinct(.data$.article_row, .keep_all = TRUE) |>
    dplyr::select(
      -.data$.journal_match,
      -.data$matched_issn,
      -dplyr::any_of(c("ISSN", "ISSN.1", "ISSN.2"))
    )

  dplyr::left_join(article_data, matched_journal_data, by = ".article_row") |>
    dplyr::filter(!.data$.article_row %in% unmatched_articles$.article_row) |>
    dplyr::select(-.data$.article_row)
}
