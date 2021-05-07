test_that("handles parsing failures gracefully", {
  expect_snapshot(test_evaluate("1 + ", highlight = TRUE))
})

test_that("highlights when requested", {
  expect_snapshot(test_evaluate("1 + \n 2 + 3", highlight = TRUE))
})


test_that("handles basic cases", {
  expect_snapshot({
    test_evaluate("# comment")
    test_evaluate("message('x')")
    test_evaluate("warning('x')")
    test_evaluate("stop('x', call. = FALSE)")
    test_evaluate("f <- function() stop('x'); f()")
  })
})

test_that("each line of input gets span", {
  expect_snapshot({
    test_evaluate("1 +\n 2 +\n 3 +\n 4 +\n 5")
  })
})

test_that("multiple code blocks are combined", {
  expect_snapshot({
    test_evaluate("x <- 1\nx <- 2\nx <- 3")
  })
})

test_that("output always gets trailing nl", {
  # These two calls should produce the same output
  expect_snapshot({
    test_evaluate('cat("a")\ncat("a\\n")')
  })
})

test_that("combines plots as needed", {
  expect_snapshot({
    f1 <- function() plot(1)
    f2 <- function() lines(0:2, 0:2)
    test_evaluate("f1()\nf2()\n")
  })

  expect_snapshot({
    f3 <- function() { plot(1); plot(2) }
    test_evaluate("f3()")
  })
})

test_that("handles other plots", {
  # Check that we can drop the inclusion of the first one
  registerS3method("is_low_change", "fakePlot", function(p1, p2) TRUE,
    envir = asNamespace("downlit")
  )
  registerS3method("replay_html", "fakePlot", function(x, ...) {
    paste0("<HTML for plot ", unclass(x), ">")
  }, envir = asNamespace("downlit"))
  registerS3method("print", "fakePlot", function(x, ...) x)

  expect_snapshot_output({
    f3 <- function() structure(3, class = c("fakePlot", "otherRecordedplot"))
    f4 <- function() structure(4, class = c("fakePlot", "otherRecordedplot"))
    test_evaluate("f3()\nf4()")
  })
})

test_that("ansi escapes are translated to html", {
  expect_snapshot({
    blue <- function(x) paste0("\033[34m", x, "\033[39m")
    f <- function(x) {
      cat("Output: ", blue("blue"), "\n", sep = "")
      inform(paste0("Message: ", blue("blue")))
      warn(blue("blue"))
      abort(blue("blue"))
    }

    test_evaluate("f()\n")
  })
})
