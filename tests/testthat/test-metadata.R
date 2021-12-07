test_that("can extract urls for package", {
  # since the package urls might potentially change
  skip_on_cran()

  expect_equal(package_urls("base"), character())
  expect_equal(package_urls("packagethatdoesn'texist"), character())
  expect_equal(package_urls(""), character())
  expect_equal(package_urls("MASS"), "http://www.stats.ox.ac.uk/pub/MASS4/")
})

test_that("can extract urls for uninstalled packages from CRAN", {
  skip_on_cran()
  pkg <- "BMRSr"
  skip_if(requireNamespace(pkg, quietly = TRUE), "BMRSr package is installed")

  # We're testing here that we can find URLs for packages that aren't installed
  # I'm assuming that BMRSr isn't going to be installed (because why would it),
  # but this might not always be true
  expect_equal(package_urls("BMRSr"), "https://bmrsr.arawles.co.uk/")
  expect_equal(package_urls("BMRSr", repos = c()), "https://bmrsr.arawles.co.uk/")

  # Prefers user specified repo
  cran_repo <- "https://cran.rstudio.com"
  fake_repo <- paste0("file:", test_path("fake-repo"))
  expect_equal(package_urls("BMRSr", repos = c(fake_repo)), "https://trick-url.com/")

  # even if CRAN comes first
  expect_equal(
    package_urls("BMRSr", repos = c(CRAN = cran_repo, fake_repo)),
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
