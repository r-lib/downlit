test_that("evaluate_and_highlight works", {
  verify_output(test_path("test-evaluate.txt"), {
    "Parsing failure"
    cat(evaluate_and_highlight("1 + "))

    "Basic ouput"
    cat(evaluate_and_highlight("# comment"))
    cat(evaluate_and_highlight("message('x')"))
    cat(evaluate_and_highlight("warning('x')"))
    cat(evaluate_and_highlight("stop('x', call. = FALSE)"))

    "Plots"
    fig_save <- function(plot, id) list(path = paste0(id, ".png"), width = 10, height = 10)
    f1 <- function() plot(1)
    f2 <- function() lines(0:2, 0:2)
    cat(evaluate_and_highlight("f1()\nf2()", fig_save = fig_save, env = environment()))

    "Other plots"
    f3 <- function()
      structure(3, class = c("fakePlot", "otherRecordedplot"))
    f4 <- function()
      structure(4, class = c("fakePlot", "otherRecordedplot"))
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
                     envir = asNamespace("downlit"))
    registerS3method("replay_html", "fakePlot",
                     replay_html.fakePlot,
                     envir = asNamespace("downlit"))
    registerS3method("print", "fakePlot",
                     print.fakePlot)
    cat(evaluate_and_highlight("f3()\nf4()", env = environment(),
                               fig_save = fig_save,
                               output_handler = evaluate::new_output_handler(value = print)))
  })
})

test_that("custom infix operators are linked, but regular are not", {
  expect_snapshot_output(cat(highlight("x %in% y")))
  expect_snapshot_output(cat(highlight("x + y")))
})

test_that("ansi escapes are translated to html", {
  blue <- function(x) paste0("\033[34m", x, "\033[39m")
  f <- function(x) {
    cat("Output: ", blue("blue"), "\n")
    inform(paste0("Message: ", blue("blue")))
    warn(blue("blue"))
    abort(blue("blue"))
  }

  expect_snapshot_output(cat(evaluate_and_highlight("f()", env = environment())))
})
