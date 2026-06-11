#' InCites Journal Citation Reports via Web of Science (2023)
#'
#' Journal-level metrics from a 2023 InCites / Journal Citation Reports export.
#' Used by [get_journal_data()] when `data = "incities"`. The aliases `incites`
#' and `jcr` refer to the same bundled dataset.
#'
#' @format ## `jcr2023_wos`
#' A data frame with 21,848 rows and 10 columns:
#' \describe{
#'   \item{journal_name}{Journal title from the source export.}
#'   \item{issn}{Print ISSN.}
#'   \item{e_issn}{Electronic ISSN.}
#'   \item{category}{One or more JCR subject categories.}
#'   \item{edition}{Indexed Web of Science edition tags.}
#'   \item{total_citations}{Total citations in the 2023 source export.}
#'   \item{impact_factor_2023}{2023 Journal Impact Factor.}
#'   \item{jif_quartile}{Journal Impact Factor quartile.}
#'   \item{jci_2023}{2023 Journal Citation Indicator.}
#'   \item{percent_oa_gold}{Percent gold open access.}
#' }
#'
#' @source
#' <https://raw.githubusercontent.com/bjorn-heilagi/journal-citation-reports-wos/refs/heads/main/datasets/jcr_2023_wos.csv>
#' accessed 2026-06-10.
"jcr2023_wos"

#' SCImago Journal & Country Rank (2025)
#'
#' Journal-level metrics from SCImago Journal & Country Rank for 2025.
#' Used by [get_journal_data()] when `data = "scimago"` or `data = "scimagojr"`.
#'
#' @format ## `scimagojr2025`
#' A data frame with 32,193 rows and 25 columns:
#' \describe{
#'   \item{Rank}{SCImago rank from the source export.}
#'   \item{Sourceid}{SCImago source identifier.}
#'   \item{Title}{Journal title, with underscores replaced by spaces.}
#'   \item{Type}{Publication type, such as journal or book series.}
#'   \item{Issn}{ISSN string from the source export.}
#'   \item{Publisher}{Publisher name.}
#'   \item{Open.Access}{Open access flag from the source export.}
#'   \item{Open.Access.Diamond}{Diamond open access flag.}
#'   \item{SJR}{SCImago Journal Rank indicator.}
#'   \item{SJR.Best.Quartile}{Best quartile (Q1-Q4).}
#'   \item{H.index}{H-index.}
#'   \item{Total.Docs...2025.}{Documents published in 2025.}
#'   \item{Total.Docs...3years.}{Documents in the prior three years.}
#'   \item{Total.Refs.}{Total references.}
#'   \item{Total.Citations..3years.}{Citations in the prior three years.}
#'   \item{Citable.Docs...3years.}{Citable documents in the prior three years.}
#'   \item{Citations...Doc...2years.}{Citations per document, two-year window.}
#'   \item{Ref....Doc.}{References per document.}
#'   \item{X.Female}{Percent female authorship from the source export.}
#'   \item{Overton}{Overton indicator from the source export.}
#'   \item{Country}{Country of publication.}
#'   \item{Region}{World region.}
#'   \item{Coverage}{Source coverage years.}
#'   \item{Categories}{Subject categories assigned by SCImago.}
#'   \item{Areas}{Broad subject areas assigned by SCImago.}
#' }
#'
#' @source
#' Local source file `data/scimagojr_2025.csv`, accessed 2026-06-10 from
#' <https://www.scimagojr.com/journalrank.php>.
"scimagojr2025"
