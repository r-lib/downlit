test_that("can highlight html file", {
  # verify_output() seems to be generating the wrong line endings
  skip_on_os("windows")

  verify_output(test_path("test-downlit-html.txt"), {
    out <- downlit_html_path(test_path("autolink.html"), tempfile())
    cat(brio::read_lines(out), sep = "\n")
  })
})

test_that("Special package string gets linked", {
  node <- xml2::read_xml("<p><code>{downlit}</code> is a nice package.</p>")
  downlit_html_node(node)
  expect_equal(xml2::xml_attr(xml2::xml_find_first(node, ".//a"), "href"),
               "https://downlit.r-lib.org/")

  node2 <- xml2::read_xml("<p><code>{notapkgnamebutwhoknows}</code> is a nice package. <code>{notapkgnamebutwhoknows}</code> is cool too.</p>")
  downlit_html_node(node2)
  # xml2::xml_contents(node2) is still wrong! but as.character() isn't.
  expect_equal(length(xml2::xml_find_first(node2, ".//code")),
               0)
})

test_that("remove_placeholders", {
  collapse <- function(x) paste(xml2::xml_contents(x), collapse = "")

  x <- xml2::read_xml("<p><code>{downlit}</code> is a nice package.</p>")
  x1 <- x
  remove_placeholders(x)
  expect_equal(collapse(x), collapse(x1))

  x <- xml2::read_xml("<p><downlitspan>{downlit}</downlitspan> is a nice package.</p>")
  remove_placeholders(x)
  expect_equal(collapse(x), "{downlit} is a nice package.")

  x <- xml2::read_xml("<p><downlitspan>lalala <downlitspan>{downlit}</downlitspan></downlitspan> is a nice package.</p>")
  remove_placeholders(x)
  expect_equal(collapse(x), "lalala {downlit} is a nice package.")

  x <- xml2::read_xml("<p><downlitspan></downlitspan> is a nice package.</p>")
  remove_placeholders(x)
  expect_equal(collapse(x), " is a nice package.")

  x <- xml2::read_xml("<p><downlitspan><p>blabla</p></downlitspan> is a nice package.</p>")
  remove_placeholders(x)
  expect_equal(collapse(x), "<p>blabla</p> is a nice package.")
})
