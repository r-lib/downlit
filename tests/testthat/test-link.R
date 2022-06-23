test_that("can link function calls", {
  local_options(
    "downlit.package" = "test",
    "downlit.topic_index" = c(foo = "bar")
  )

  expect_equal(href_expr_(foo()), "bar.html")
  # even if namespaced
  expect_equal(href_expr_(test::foo()), "bar.html")

  # but functions with arguments are ignored
  expect_equal(href_expr_(foo(1, 2, 3)), NA_character_)
  # as are function factories are ignored
  expect_equal(href_expr_(foo()(1, 2, 3)), NA_character_)
  expect_equal(href_expr_(test::foo()(1, 2, 3)), NA_character_)
})

test_that("base function calls linked", {
  expect_equal(href_expr_(median()), href_topic_remote("median", "stats"))
})

test_that("respects options that define current location", {
  local_options(
    "downlit.topic_index" = c(bar = "bar"),
    "downlit.topic_path" = "myref/"
  )

  # when not in an Rd file, link with topic_path
  local_options("downlit.rdname" = "")
  expect_equal(href_expr_(bar()), "myref/bar.html")

  # don't link to self
  local_options("downlit.rdname" = "bar")
  expect_equal(href_expr_(bar()), NA_character_)
})

test_that("can link remote objects", {
  expect_equal(href_expr_(MASS::abbey), href_topic_remote("abbey", "MASS"))
  expect_equal(href_expr_(MASS::addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(MASS::addterm.default()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(base::`::`), href_topic_remote("::", "base"))

  # Doesn't exist
  expect_equal(href_expr_(MASS::blah), NA_character_)
})

test_that("can link to functions in registered packages", {
  local_options("downlit.attached" = "MASS")

  expect_equal(href_expr_(addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(addterm.default()), href_topic_remote("addterm", "MASS"))
})

test_that("can link to package names in registered packages", {
  expect_equal(
    autolink_curly("{downlit}"),
    "<a href='https://downlit.r-lib.org/'>downlit</a>"
  )

  expect_equal(autolink_curly("{package}"), NA_character_)

  # No curly = no link
  expect_equal(autolink_curly(""), NA_character_)
})

test_that("can link to functions in base packages", {
  expect_equal(href_expr_(abbreviate()), href_topic_remote("abbreviate", "base"))
  expect_equal(href_expr_(median()), href_topic_remote("median", "stats"))
})

test_that("links to home of re-exported functions", {
  expect_equal(href_expr_(testthat::`%>%`), href_topic_remote("%>%", "magrittr"))
})

test_that("fails gracely if can't find re-exported function", {
  local_options(
    "downlit.package" = "downlit",
    "downlit.topic_index" = c(foo = "reexports")
  )
  expect_equal(href_expr_(foo()), NA_character_)
})

test_that("can link to remote pkgdown sites", {
  # use autolink() to avoid R CMD check NOTE
  expect_equal(autolink_url("pkgdown::add_slug"), href_topic_remote("pkgdown", "add_slug"))
  expect_equal(autolink_url("pkgdown::add_slug(1)"), href_topic_remote("pkgdown", "add_slug"))
})

test_that("or local sites, if registered", {
  local_options("downlit.local_packages" = c("MASS" = "MASS"))
  expect_equal(href_expr_(MASS::abbey), "MASS/reference/abbey.html")
})

test_that("bare bare symbols are not linked", {
  expect_equal(autolink_url("%in%"), NA_character_)
  expect_equal(autolink_url("foo"), NA_character_)
})

test_that("returns NA for bad inputs", {
  expect_equal(autolink_url(""), NA_character_)
  expect_equal(autolink_url("a; b"), NA_character_)
  expect_equal(autolink_url("1"), NA_character_)
  expect_equal(autolink_url("ls *t??ne.pb"), NA_character_)
})

# help --------------------------------------------------------------------

test_that("can link ? calls", {
  local_options(
    "downlit.package" = "test",
    "downlit.topic_index" = c(foo = "foo", "foo-package" = "foo-package")
  )

  expect_equal(href_expr_(?foo), "foo.html")
  expect_equal(href_expr_(?"foo"), "foo.html")
  expect_equal(href_expr_(?test::foo), "foo.html")
  expect_equal(href_expr_(package?foo), "foo-package.html")
})

test_that("can link help calls", {
  local_options(
    "downlit.package" = "test",
    "downlit.topic_index" = c(foo = "foo", "foo-package" = "foo-package")
  )

  expect_equal(href_expr_(help("foo")), "foo.html")
  expect_equal(href_expr_(help("foo", "test")), "foo.html")
  expect_equal(href_expr_(help(package = "MASS")), "https://rdrr.io/pkg/MASS/man")
  expect_equal(href_expr_(help()), "https://rdrr.io/r/utils/help.html")
  expect_equal(href_expr_(help(a$b)), NA_character_)
})

# library and friends -----------------------------------------------------

test_that("library() linked to package reference", {
  skip_on_cran() # in case URLs change
  skip_on_os("solaris")

  expect_equal(href_expr_(library(rlang)), "https://rlang.r-lib.org")
  expect_equal(href_expr_(library(MASS)), "http://www.stats.ox.ac.uk/pub/MASS4/")
})

test_that("except when not possible", {
  expect_equal(href_expr_(library()), "https://rdrr.io/r/base/library.html")
  expect_equal(href_expr_(library(doesntexist)), "https://rdrr.io/r/base/library.html")
  expect_equal(href_expr_(library(package = )), "https://rdrr.io/r/base/library.html")
  expect_equal(href_expr_(library("x", "y", "z")), "https://rdrr.io/r/base/library.html")
})

# vignette ----------------------------------------------------------------

test_that("can link to local articles", {
  local_options(
    "downlit.package" = "test",
    "downlit.article_index" = c(x = "y.html"),
    "downlit.article_path" = "my_path/",
  )

  expect_equal(href_expr_(vignette("x")), "my_path/y.html")
  expect_equal(href_expr_(vignette("x", package = "test")), "my_path/y.html")
  expect_equal(href_expr_(vignette("y")), NA_character_)
})

test_that("can link to bioconductor vignettes", {
  skip_if_not_installed("MassSpecWavelet")

  # local_options(
  #   "repos" = c("CRAN" = "https://cran.rstudio.com")
  #)

  expect_equal(
    href_expr_(vignette("MassSpecWavelet", "MassSpecWavelet")),
    "https://bioconductor.org/packages/release/bioc/vignettes/MassSpecWavelet/inst/doc/MassSpecWavelet.html"
  )
})

test_that("can link to remote articles", {
  skip_on_cran()

  expect_equal(
    href_expr_(vignette("sha1", "digest")),
    "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )
  expect_equal(href_expr_(vignette("blah1", "digest")), NA_character_)

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
  local_options("downlit.local_packages" = c("digest" = "digest"))
  expect_equal(href_expr_(vignette("sha1", "digest")), "digest/articles/sha1.html")
})

test_that("looks in attached packages", {
  local_options("downlit.attached" = c("grid", "digest"))

  expect_equal(
    href_expr_(vignette("sha1")),
    "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )
  expect_equal(
    href_expr_(vignette("moveline")),
    "https://cran.rstudio.com/web/packages/grid/vignettes/moveline.pdf"
  )
})

test_that("fail gracefully with non-working calls", {
  expect_equal(href_expr_(vignette()), "https://rdrr.io/r/utils/vignette.html")
  expect_equal(href_expr_(vignette(package = package)), NA_character_)
  expect_equal(href_expr_(vignette(1, 2)), NA_character_)
  expect_equal(href_expr_(vignette(, )), NA_character_)
})

test_that("spurious functions are not linked (#889)", {
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

test_that("href_package can handle non-existing packages", {
  expect_equal(href_package("NotAPackage"), NA_character_)
})

# find_reexport_source ----------------------------------------------------

test_that("can find functions", {
  expect_equal(find_reexport_source(is.null), "base")
  expect_equal(find_reexport_source(mean), "base")
})

test_that("can find other objects", {
  expect_equal(find_reexport_source(na_cpl, "downlit", "na_cpl"), "rlang")
  expect_equal(find_reexport_source(na_cpl, "downlit", "MISSING"), NA_character_)
})
