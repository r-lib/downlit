test_that("can highlight html file", {
  # verify_output() seems to be generating the wrong line endings
  skip_on_os("windows")

  verify_output(test_path("test-downlit-html.txt"), {
    out <- downlit_html_path(test_path("autolink.html"), tempfile())
    cat(brio::read_lines(out), sep = "\n")
  })
})

test_that("special package string gets linked", {
  # TODO: convert to snapshot tests
  html <- xml2::read_xml("<p>before <code>{downlit}</code> after</p>")
  downlit_html_node(html)
  expect_equal(length(xml2::xml_find_all(html, ".//a")), 1)
  expect_equal(length(xml2::xml_find_all(html, ".//code")), 0)

  # But only when it's a real package
  html <- xml2::read_xml("<p>before <code>{notapkg}</code> after</p>")
  downlit_html_node(html)
  expect_equal(length(xml2::xml_find_all(html, ".//a")), 0)
  expect_equal(length(xml2::xml_find_all(html, ".//code")), 1)
})
