test_that("can link to external topics that use ::", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("test")

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
    cat(highlight("# \u2714"))
  })
})

test_that("can parse code with carriage returns", {
  scoped_package_context("test")

  lines <- strsplit(highlight("1\r\n2"), "\n")[[1]]

  expect_equal(lines[[1]], "<span class='m'>1</span>")
  expect_equal(lines[[2]], "<span class='m'>2</span>")
})

test_that("unparsable code returns NULL", {
  expect_equal(highlight("<"), NA_character_)
  # but pure comments still highlighted
  expect_equal(
    highlight("#"),
    "<span class='c'>#</span>"
  )
})
