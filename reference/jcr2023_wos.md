# InCites Journal Citation Reports via Web of Science (2023)

Journal-level metrics from a 2023 InCites / Journal Citation Reports
export. Used by \[get_journal_data()\] when \`data = "incities"\`. The
aliases \`incites\` and \`jcr\` refer to the same bundled dataset.

## Usage

``` r
jcr2023_wos
```

## Format

\## \`jcr2023_wos\` A data frame with 21,848 rows and 10 columns:

- journal_name:

  Journal title from the source export.

- issn:

  Print ISSN.

- e_issn:

  Electronic ISSN.

- category:

  One or more JCR subject categories.

- edition:

  Indexed Web of Science edition tags.

- total_citations:

  Total citations in the 2023 source export.

- impact_factor_2023:

  2023 Journal Impact Factor.

- jif_quartile:

  Journal Impact Factor quartile.

- jci_2023:

  2023 Journal Citation Indicator.

- percent_oa_gold:

  Percent gold open access.

## Source

\<https://raw.githubusercontent.com/bjorn-heilagi/journal-citation-reports-wos/refs/heads/main/datasets/jcr_2023_wos.csv\>
accessed 2026-06-10.
