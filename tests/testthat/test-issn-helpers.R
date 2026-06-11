test_that("get_unique_issns normalizes and deduplicates ISSNs", {
  issns <- c(
    "1234-5678; 8765-4321",
    "12345678",
    "issn 8765-4321",
    NA_character_
  )

  expect_equal(
    get_unique_issns(issns),
    c("12345678", "87654321")
  )
})

test_that("get_journal_data validates and normalizes the journal source", {
  expect_error(
    get_journal_data("not-a-source"),
    "`data` must be one of"
  )

  alias_data <- get_journal_data("incites")
  incities_data <- get_journal_data("incities")
  jcr_data <- get_journal_data("jcr")
  scimagojr_data <- get_journal_data("scimagojr")

  expect_s3_class(alias_data, "tbl_df")
  expect_true(all(c("ISSN", "ISSN.1", "ISSN.2", "Title") %in% names(alias_data)))
  expect_equal(incities_data, jcr_data)
  expect_true(all(c("Journal.Impact.Factor", "Total.Cites") %in% names(jcr_data)))
  expect_false(any(grepl("_", scimagojr_data$Title, fixed = TRUE)))
})
