test_that("can link function calls", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("test")

  expect_equal(href_expr_(foo()), "bar.html")
  expect_equal(href_expr_(foo(1, 2, 3)), "bar.html")
  # even if namespaced
  expect_equal(href_expr_(test::foo()), "bar.html")
  expect_equal(href_expr_(test::foo(1, 2, 3)), "bar.html")

  # but function factories are ignored
  expect_equal(href_expr_(foo()(1, 2, 3)), NA_character_)
  # as functions with special syntax
  expect_equal(href_expr_(if (TRUE) 1), NA_character_)
})

test_that("respects href_topic_local args", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context()
  expect_equal(href_expr_(foo()), "reference/bar.html")
  expect_equal(href_expr_(barbar()), NA_character_)

  scoped_file_context("bar")
  expect_equal(href_expr_(foo()), NA_character_)
})

test_that("can link remote objects", {
  scoped_package_context("test")

  expect_equal(href_expr_(MASS::abbey), href_topic_remote("abbey", "MASS"))
  expect_equal(href_expr_(MASS::addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(MASS::addterm.default()), href_topic_remote("addterm", "MASS"))

  # Doesn't exist
  expect_equal(href_expr_(MASS::blah), NA_character_)
})

test_that("can link to functions in registered packages", {
  scoped_package_context("test")
  register_attached_packages("MASS")

  expect_equal(href_expr_(addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(addterm.default()), href_topic_remote("addterm", "MASS"))
})

test_that("can link to functions in base packages", {
  scoped_package_context("test")
  scoped_file_context() # package registry maintained on per-file basis

  expect_equal(href_expr_(abbreviate()), href_topic_remote("abbreviate", "base"))
  expect_equal(href_expr_(median()), href_topic_remote("median", "stats"))
})

test_that("links to home of re-exported functions", {
  # can't easily access exports in 3.1
  expect_equal(href_expr_(addterm()), href_topic_remote("addterm", "MASS"))
})

test_that("fails gracely if can't find re-exported function", {
  scoped_package_context("downlit", c(foo = "reexports"))
  expect_equal(href_expr_(foo()), NA_character_)
})

test_that("can link to remote pkgdown sites", {
  scoped_package_context("test", c(foo = "bar"))

  # use autolink() to avoid R CMD check NOTE
  expect_equal(autolink_url("pkgdown::add_slug"), href_topic_remote("pkgdown", "add_slug"))
  expect_equal(autolink_url("pkgdown::add_slug(1)"), href_topic_remote("pkgdown", "add_slug"))
})

test_that("or local sites, if registered", {
  scoped_package_context("pkgdown", local_packages = c("MASS" = "MASS"))
  expect_equal(href_expr_(MASS::abbey), "MASS/reference/abbey.html")
})

test_that("only links bare symbols if they're infix functions", {
  expect_equal(autolink_url("%in%"), "https://rdrr.io/r/base/match.html")
  expect_equal(autolink_url("foo"), NA_character_)
})

# help --------------------------------------------------------------------

test_that("can link ? calls", {
  scoped_package_context("test", c(foo = "foo", "foo-package" = "foo-package"))
  scoped_file_context("bar")

  expect_equal(href_expr_(?foo), "foo.html")
  expect_equal(href_expr_(?"foo"), "foo.html")
  expect_equal(href_expr_(?test::foo), "foo.html")
  expect_equal(href_expr_(package?foo), "foo-package.html")
})

test_that("can link help calls", {
  scoped_package_context("test", c(foo = "foo", "foo-package" = "foo-package"))
  scoped_file_context("bar")

  expect_equal(href_expr_(help("foo")), "foo.html")
  expect_equal(href_expr_(help("foo", "test")), "foo.html")
  expect_equal(href_expr_(help(package = "MASS")), "https://rdrr.io/pkg/MASS/man")
  expect_equal(href_expr_(help()), NA_character_)
})


# library and friends -----------------------------------------------------

test_that("library() linked to package reference", {
  skip_on_os("solaris")
  scoped_package_context("test", c(foo = "bar"))

  expect_equal(href_expr_(library()), NA_character_)
  expect_equal(href_expr_(library(rlang)), "https://rlang.r-lib.org/reference")
  expect_equal(href_expr_(library(MASS)), "https://rdrr.io/pkg/MASS/man")
})

# vignette ----------------------------------------------------------------

test_that("can link to local articles", {
  scoped_package_context("test", article_index = c(x = "y.html"))
  scoped_file_context(depth = 0)

  expect_equal(href_expr_(vignette("x")), "articles/y.html")
  expect_equal(href_expr_(vignette("x", package = "test")), "articles/y.html")
  expect_equal(href_expr_(vignette("y")), NA_character_)
})

test_that("can link to remote articles", {
  skip_on_cran()
  scoped_package_context("test")

  expect_equal(
    href_expr_(vignette("sha1", "digest")),
    "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )

  expect_equal(
    href_expr_(vignette(package = "digest", "sha1")),
    "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )

  expect_equal(
    href_expr_(vignette("custom-expectation", "testthat")),
    "https://testthat.r-lib.org/articles/custom-expectation.html"
  )
})

test_that("or local sites, if registered", {
  scoped_package_context("pkgdown", local_packages = c("digest" = "digest"))
  expect_equal(href_expr_(vignette("sha1", "digest")), "digest/articles/sha1.html")
})

test_that("fail gracefully with non-working calls", {
  scoped_package_context("test")

  expect_equal(href_expr_(vignette()), NA_character_)
  expect_equal(href_expr_(vignette(package = package)), NA_character_)
  expect_equal(href_expr_(vignette(1, 2)), NA_character_)
  expect_equal(href_expr_(vignette(, )), NA_character_)
})

test_that("spurious functions are not linked (#889)", {
  scoped_package_context("test")

  expect_equal(href_expr_(Authors@R), NA_character_)
  expect_equal(href_expr_(content-home.html), NA_character_)
  expect_equal(href_expr_(toc: depth), NA_character_)
})

test_that("autolink generates HTML if linkable", {
  expect_equal(
    autolink("stats::median()"),
    "<a href='https://rdrr.io/r/stats/median.html'>stats::median()</a>"
  )
  expect_equal(autolink("1 +"), NA_character_)
})
