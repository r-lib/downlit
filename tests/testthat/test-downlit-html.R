test_that("can highlight html file", {
  # verify_output() seems to be generating the wrong line endings
  skip_on_os("windows")

  verify_output(test_path("test-downlit-html.txt"), {
    out <- downlit_html_path(test_path("autolink.html"), tempfile())
    cat(brio::read_lines(out), sep = "\n")
  })
})

test_that("highlight all pre inside div.downlit", {
  html <- xml2::read_xml("
    <body>
    <div class = 'downlit'>
      <pre>1 + 2</pre>
      <pre>3 + 4</pre>
    </div>
    <pre>No hightlight</pre>
    </body>"
  )
  downlit_html_node(html)
  expect_snapshot_output(show_xml(html))
})

test_that("special package string gets linked", {
  html <- xml2::read_xml("<p>before <code>{downlit}</code> after</p>")
  downlit_html_node(html)
  expect_snapshot_output(show_xml(html))

  # But only when it's a real package
  html <- xml2::read_xml("<p>before <code>{notapkg}</code> after</p>")
  downlit_html_node(html)
  expect_snapshot_output(show_xml(html))
})

test_that("keeps all pre classes", {
  html <- xml2::read_xml("
    <div class='sourceCode'>
      <pre class='sourceCode r my-class'>
        <code class='sourceCode r'>
          <span>Hello</span>
        </code>
      </pre>
    </div>"
  )
  downlit_html_node(html)
  expect_snapshot_output(show_xml(html))
})
