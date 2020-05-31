#' Automatically link references and articles in an HTML page
#'
#' @description
#' The autolinker has two components built around two XPath expressions:
#'
#' * Multiline code blocks are identified by `<pre>` tags with
#'   class `sourceCode` and `r`, and are processed with [highlight()].
#'
#' * Inline code is identified by `<code>` tags that contain only text,
#'   don't have a header tag (e.g. `<h1>`) or `<a>` as an ancestor,
#'   and are porcessed processed with [autolink()].
#'
#' Use `downlit_html()` to process an `.html` file on disk;
#' use `downlit_xml_node()` to process an `xml_node` as part of a larger
#' pipeline.
#'
#' @param input_path,output_path Input and output paths for HTML file
#' @param node An `xml2::xml_node`
#' @return Invisibly returns `output_path`.
#' @export
downlit_html <- function(input_path, output_path) {
  if (!is_installed("xml2")) {
    abort("`xml2` package required for `download_html()`")
  }

  html <- xml2::read_html(input_path, encoding = "UTF-8")
  downlit_xml_node(html)
  xml2::write_html(html, output_path, format = FALSE)

  invisible(output_path)
}

#' @export
#' @rdname downlit_html
downlit_xml_node <- function(node) {
  stopifnot(inherits(node, "xml_node"))

  # <pre class="sourceCode r">
  xpath_block <- ".//pre[contains(@class, 'sourceCode r')]"
  tweak_children(node, xpath_block, highlight, replace = "node")

  # Identify <code> containing only text (i.e. no children) that are
  # are not descendants of a header or link
  bad_ancestor <- c("h1", "h2", "h3", "h4", "h5", "a")
  bad_ancestor <- paste0("ancestor::", bad_ancestor, collapse = "|")
  xpath_inline <- paste0(".//code[count(*) = 0 and not(", bad_ancestor, ")]")
  tweak_children(node, xpath_inline, autolink, replace = "contents")

  invisible()
}

tweak_children <- function(node, xpath, fun, replace = c("node", "contents")) {
  replace <- arg_match(replace)

  nodes <- xml2::xml_find_all(node, xpath)

  text <- xml2::xml_text(nodes)
  replacement <- map_chr(text, fun)
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
