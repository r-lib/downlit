test_that("multiplication works", {
  # since the package urls might potentially change
  skip_on_cran()

  expect_equal(package_urls("base"), character())
  expect_equal(package_urls("packagethatdoesn'texist"), character())
  expect_equal(package_urls("MASS"), "http://www.stats.ox.ac.uk/pub/MASS4")
  expect_equal(package_urls("rlang"), c("http://rlang.r-lib.org", "https://github.com/r-lib/rlang"))
})
