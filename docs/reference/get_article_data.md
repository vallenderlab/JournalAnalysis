# Get Article Data

This function retrieves article data from europe pmc.

## Usage

``` r
get_article_data(
  queries,
  limit = 7500,
  min_year = NULL,
  max_year = NULL,
  min_citations = 5,
  n_cores = default_worker_count()
)
```

## Arguments

- queries:

  Input a Europe PMC query

- limit:

  Minimum number of articles to retrieve

- min_year:

  Minimum publication year

- max_year:

  Maximum publication year

- min_citations:

  Minimum number of citations per article

- n_cores:

  Number of cores to use across multiple queries.

## Value

A tibble of the article data
