#' Syntax highlight and link an HTML page
#'
#' @description
#' * Code blocks, identified by `<pre>` tags with class `sourceCode` and `r`,
#'   processed with [highlight()].
#'
#' * Inline code, identified by `<code>` tags that contain only text
#'   (and don't have a header tag (e.g. `<h1>`) or `<a>` as an ancestor)
#'   are processed processed with [autolink()].
#'
#' Use `downlit_html_path()` to process an `.html` file on disk;
#' use `downlit_html_node()` to process an in-memory `xml_node` as part of a
#' larger pipeline.
#'
#' @param in_path,out_path Input and output paths for HTML file
#' @param x An `xml2::xml_node`
#' @return `downlit_html_path()` invisibly returns `output_path`;
#'   `downlit_html_node()` modifies `x` in place and returns nothing.
#' @export
#' @examples
#' node <- xml2::read_xml("<p><code>base::t()</code></p>")
#' node
#'
#' # node is modified in place
#' downlit_html_node(node)
#' node
downlit_html_path <- function(in_path, out_path) {
  if (!is_installed("xml2")) {
    abort("xml2 package required .html transformation")
  }

  html <- xml2::read_html(in_path, encoding = "UTF-8")
  downlit_html_node(html)
  xml2::write_html(html, out_path, format = FALSE)

  invisible(out_path)
}

#' @export
#' @rdname downlit_html_path
downlit_html_node <- function(x) {
  stopifnot(inherits(x, "xml_node"))

  # <pre class="sourceCode r">
  xpath_block <- ".//pre[contains(@class, 'sourceCode r')] | .//pre[@class='r']"
  tweak_children(x, xpath_block, highlight,
    pre_class = "downlit",
    classes = classes_pandoc(),
    replace = "node"
  )

  # Identify <code> containing only text (i.e. no children) that are
  # are not descendants of a header or link
  bad_ancestor <- c("h1", "h2", "h3", "h4", "h5", "a")
  bad_ancestor <- paste0("ancestor::", bad_ancestor, collapse = "|")
  xpath_inline <- paste0(".//code[count(*) = 0 and not(", bad_ancestor, ")]")
  tweak_children(x, xpath_inline, autolink, replace = "contents")

  invisible()
}

tweak_children <- function(node, xpath, fun, ..., replace = c("node", "contents")) {
  replace <- arg_match(replace)

  nodes <- xml2::xml_find_all(node, xpath)

  text <- xml2::xml_text(nodes)
  replacement <- map_chr(text, fun, ...)
  to_update <- !is.na(replacement)

  old <- nodes[to_update]
  if (replace == "contents") {
    old <- xml2::xml_contents(old)
  }
  new <- lapply(replacement[to_update], as_xml)
  xml2::xml_replace(old, new, .copy = FALSE)

  invisible()
}

as_xml <- function(x) {
  xml2::xml_contents(xml2::xml_contents(xml2::read_html(x)))[[1]]
}
