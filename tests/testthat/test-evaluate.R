test_that("handles parsing failures gracefully", {
  expect_snapshot(test_evaluate("1 + "))
})

test_that("handles basic cases", {
  expect_snapshot({
    test_evaluate("# comment")
    test_evaluate("message('x')")
    test_evaluate("warning('x')")
    test_evaluate("stop('x', call. = FALSE)")
  })
})

test_that("combines plots as needed", {
  expect_snapshot({
    f1 <- function() plot(1)
    f2 <- function() lines(0:2, 0:2)
    test_evaluate("f1()\nf2()\n")
  })
})

test_that("handles other plots", {

  # Check that we can drop the inclusion of the first one
  is_low_change.fakePlot <- function(p1, p2) TRUE
  print.fakePlot <- function(x, ...) {
    x
  }
  replay_html.fakePlot <- function(x, ...) {
    paste("Text for plot ", unclass(x))
  }
  registerS3method("is_low_change", "fakePlot",
    is_low_change.fakePlot,
    envir = asNamespace("downlit")
  )
  registerS3method("replay_html", "fakePlot",
    replay_html.fakePlot,
    envir = asNamespace("downlit")
  )
  registerS3method(
    "print", "fakePlot",
    print.fakePlot
  )
  expect_snapshot_output({
    f3 <- function() structure(3, class = c("fakePlot", "otherRecordedplot"))
    f4 <- function() structure(4, class = c("fakePlot", "otherRecordedplot"))
    evaluate_and_highlight(
      "f3()\nf4()",
      env = environment(),
      output_handler = evaluate::new_output_handler(value = print)
    )
  })
})

test_that("ansi escapes are translated to html", {
  blue <- function(x) paste0("\033[34m", x, "\033[39m")
  f <- function(x) {
    cat("Output: ", blue("blue"), "\n")
    inform(paste0("Message: ", blue("blue")))
    warn(blue("blue"))
    abort(blue("blue"))
  }

  expect_snapshot_output(test_evaluate("f()\n"))
})
