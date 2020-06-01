test_that("can highlight html file", {
  verify_output(test_path("test-downlit-html.txt"), {
    out <- downlit_html_path(test_path("autolink.html"), tempfile())
    cat(readLines(out), sep = "\n")
  })
})
