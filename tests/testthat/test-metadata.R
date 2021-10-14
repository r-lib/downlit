test_that("can extract urls for package", {
  # since the package urls might potentially change
  skip_on_cran()

  expect_equal(package_urls("base"), character())
  expect_equal(package_urls("packagethatdoesn'texist"), character())
  expect_equal(package_urls(""), character())
  expect_equal(package_urls("MASS"), "http://www.stats.ox.ac.uk/pub/MASS4/")
})

test_that("handle common url formats", {
  ab <- c("https://a.com", "https://b.com")

  expect_equal(parse_urls("https://a.com,https://b.com"), ab)
  expect_equal(parse_urls("https://a.com, https://b.com"), ab)
  expect_equal(parse_urls("https://a.com https://b.com"), ab)
  expect_equal(parse_urls("https://a.com (comment) https://b.com"), ab)
})
