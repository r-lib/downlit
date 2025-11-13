test_that("can extract urls for package", {
  # since the package urls might potentially change
  skip_on_cran()

  expect_equal(package_urls("base"), character())
  expect_equal(package_urls("packagethatdoesn'texist"), character())
  expect_equal(package_urls(""), character())
  expect_equal(package_urls("MASS"), "http://www.stats.ox.ac.uk/pub/MASS4/")
})

test_that("can extract urls for uninstalled packages from CRAN", {
  # Pretend that rlang isn't installed
  local_mocked_bindings(is_installed = function(...) FALSE)

  rlang_urls <- c("https://rlang.r-lib.org", "https://github.com/r-lib/rlang")
  expect_equal(package_urls("rlang"), rlang_urls)

  # Always adds CRAN
  expect_equal(package_urls("rlang", repos = c()), rlang_urls)

  # But prefers user specified repo
  fake_repo <- paste0("file:", test_path("fake-repo"))
  expect_equal(
    package_urls("rlang", repos = fake_repo),
    "https://trick-url.com/"
  )

  # even if CRAN comes first
  cran_repo <- "https://cran.rstudio.com"
  expect_equal(
    package_urls("rlang", repos = c(CRAN = cran_repo, fake_repo)),
    "https://trick-url.com/"
  )
})

test_that("handle common url formats", {
  ab <- c("https://a.com", "https://b.com")

  expect_equal(parse_urls("https://a.com,https://b.com"), ab)
  expect_equal(parse_urls("https://a.com, https://b.com"), ab)
  expect_equal(parse_urls("https://a.com https://b.com"), ab)
  expect_equal(parse_urls("https://a.com (comment) https://b.com"), ab)
})
