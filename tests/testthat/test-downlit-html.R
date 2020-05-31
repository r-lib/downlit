test_that("multiplication works", {
  verify_output(test_path("test-downlit-html.txt"), {
    out <- downlit_html(test_path("autolink.html"), tempfile())
    cat(readLines(out), sep = "\n")
  })
})
