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
  })
})

# Output labelling --------------------------------------------------------

test_that("prompt added to start of each line", {
  expect_equal(label_lines("a\nb\n\n", prompt = "#"), c("#a", "#b", "#"))
})

test_that("prompt is escaped", {
  expect_equal(label_lines("\n", prompt = ">"), "&gt;")
})

test_that("input is escaped", {
  expect_equal(label_lines(">", prompt = ""), "&gt;")
})

test_that("class generates line-by-line span", {
  expect_equal(
    label_lines("a\nb", "X", prompt = ""),
    c("<span class='X'>a</span>", "<span class='X'>b</span>")
  )
})
