test_that("can link to external topics that use ::", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("test")

  verify_output(test_path("test-highlight.txt"), {
    "explicit package"
    cat(highlight("MASS::addterm()"))
    cat(highlight("MASS::addterm"))
    cat(highlight("?MASS::addterm"))

    "implicit package"
    register_attached_packages("MASS")
    cat(highlight("addterm()"))
    cat(highlight("median()")) # base

    "local package"
    cat(highlight("test::foo()"))

    "operators / special syntax"
    cat(highlight("1 + 2 * 3"))
    cat(highlight("x %in% y"))
    cat(highlight("if (FALSE) 1"))
    cat(highlight("f <- function(x = 'a') {}"))
  })
})

test_that("can parse code with carriage returns", {
  scoped_package_context("test")

  expect_equal(
    highlight("1\r\n2"),
    "<span class='fl'>1</span>\n<span class='fl'>2</span>"
  )
})

test_that("unparsable code returns NULL", {
  expect_equal(highlight("<"), NULL)
})
