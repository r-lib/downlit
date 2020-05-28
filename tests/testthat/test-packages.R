test_that("extracts typical library()/require() calls", {
  expect_equal(extract_package_attach_(library("blah")), "blah")
  expect_equal(extract_package_attach_(library(blah)), "blah")
  expect_equal(extract_package_attach_(require("blah")), "blah")
  expect_equal(extract_package_attach_(require(blah)), "blah")
})

test_that("detects in nested code", {
  expect_equal(extract_package_attach_({
    library(a)
    x <- 2
    {
      library(b)
      y <- 3
      {
        library(c)
        z <- 4
      }
    }
  }), c("a", "b", "c"))
})

test_that("handles expressions", {
  # which will usually come from parse()d code
  #
  x <- expression(
    x <- 1,
    library("a"),
    y <- 2,
    library("b")
  )
  expect_equal(extract_package_attach(x), c("a", "b"))
})

test_that("detects with non-standard arg order", {
  local_options(warnPartialMatchArgs = FALSE)

  expect_equal(extract_package_attach_(library(quiet = TRUE, pa = "a")), "a")
  expect_equal(extract_package_attach_(library(quiet = TRUE, a)), "a")
})

test_that("doesn't include if character.only = TRUE", {
  expect_equal(
    extract_package_attach_(library(x, character.only = TRUE)),
    character()
  )
})
