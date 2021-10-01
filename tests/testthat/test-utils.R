test_that("converts Latin1 encoded text to utf8", {
  x <- "'\xfc'"
  Encoding(x) <- "latin1"

  y <- safe_parse(x)[[1]]
  expect_equal(Encoding(y), "UTF-8")
  expect_equal(y, "\u00fc")
})
