test_that("can link to external topics that use ::", {
  local_options(
    "downlit.package" = "test",
    "downlit.topic_index" = c(foo = "bar")
  )

  verify_output(test_path("test-highlight.txt"), {
    "explicit package"
    cat(highlight("MASS::addterm()"))
    cat(highlight("MASS::addterm"))
    cat(highlight("?MASS::addterm"))

    "implicit package"
    cat(highlight("library(MASS)"))
    cat(highlight("addterm()"))
    cat(highlight("median()")) # base

    "local package"
    cat(highlight("test::foo()"))

    "operators / special syntax"
    cat(highlight("1 + 2 * 3"))
    cat(highlight("x %in% y"))
    cat(highlight("if (FALSE) 1"))
    cat(highlight("f <- function(x = 'a') {}"))

    "ansi escapes + unicode"
    cat(highlight("# \033[34mblue\033[39m"))
  })
})

test_that("unicode is not mangled", {
  expect_equal(highlight("# \u2714"), "<span class='c'># \u2714</span>")
})

test_that("distinguish logical and numeric",{
  expect_equal(highlight("TRUE"), "<span class='kc'>TRUE</span>")
  expect_equal(highlight("FALSE"), "<span class='kc'>FALSE</span>")
  expect_equal(highlight("1"), "<span class='m'>1</span>")
})
test_that("can parse code with carriage returns", {
  lines <- strsplit(highlight("1\r\n2"), "\n")[[1]]

  expect_equal(lines[[1]], "<span class='m'>1</span>")
  expect_equal(lines[[2]], "<span class='m'>2</span>")
})

test_that("syntax can span multiple lines", {
  expect_equal(highlight("f(\n\n)"), "<span class='nf'>f</span>(\n\n)")
  expect_equal(highlight("'\n\n'"), "<span class='s'>'\n\n'</span>")
})

test_that("unparsable code returns NULL", {
  expect_equal(highlight("<"), NA_character_)
  # but pure comments still highlighted
  expect_equal(
    highlight("#"),
    "<span class='c'>#</span>"
  )
})

test_that("code with tab is not mangled", {
  expect_equal(highlight("\tmean(1:3)"),
               "  <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span>(<span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>)")

  expect_equal(highlight("  mean(1:3)"),
               "  <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span>(<span class='m'>1</span><span class='o'>:</span><span class='m'>3</span>)")
})
