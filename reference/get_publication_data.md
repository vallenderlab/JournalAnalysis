# Get Publication Data

This function uses a journal source to combine data based on queries.

## Usage

``` r
get_publication_data(
  journal_source,
  queries,
  limit = 7500,
  min_year = NULL,
  max_year = NULL,
  min_citations = 5,
  n_cores = default_worker_count()
)
```

## Arguments

- journal_source:

  Journal metrics source: \`incities\` (InCites / JCR) or \`scimago\`.
  Aliases \`incites\`, \`jcr\`, and \`scimagojr\` are also accepted.

- queries:

  Use one or multiple queries

- limit:

  A minimum number of articles

- min_year:

  Minimum year to search

- max_year:

  Maximum year to search

- min_citations:

  Minimum number of citations in a journal

- n_cores:

  Number of cores to use across multiple queries.

## Value

A list of data objects including journals, articles, and combined data.
