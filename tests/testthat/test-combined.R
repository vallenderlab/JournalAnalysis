test_that("get_articles_with_journal_data warns and skips unmatched rows", {
  article_data <- tibble::tibble(
    id = 1:3,
    journalIssn = c("1234-5678", "1111-1111; 2222-2222", "9999-9999"),
    ISSN.1 = c("12345678", "11111111", "99999999"),
    ISSN.2 = c("", "22222222", "")
  )

  journal_data <- tibble::tibble(
    Title = c("Journal A", "Journal B"),
    ISSN = c("12345678", "22222222"),
    ISSN.1 = c("12345678", "22222222"),
    ISSN.2 = c("", ""),
    Rank = c(1, 2)
  )

  expect_warning(
    combined_data <- JournalAnalysis:::get_articles_with_journal_data(article_data, journal_data),
    "Skipping 1 article record\\(s\\) with no matching journal ISSN"
  )

  expect_equal(combined_data$id, c(1, 2))
  expect_equal(anyDuplicated(names(combined_data)), 0)
  expect_false(any(c("ISSN.x", "ISSN.y", "ISSN.1.y", "ISSN.2.y") %in% names(combined_data)))
  expect_true(all(c("Title", "Rank") %in% names(combined_data)))
})
