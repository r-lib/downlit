# Syntax highlight and link an HTML page

- Code blocks, identified by `<pre>` tags with class `sourceCode r` or
  any `<pre>` tag inside of `<div class='downlit'>`, are processed with
  [`highlight()`](https://downlit.r-lib.org/reference/highlight.md).

- Inline code, identified by `<code>` tags that contain only text (and
  don't have a header tag (e.g. `<h1>`) or `<a>` as an ancestor) are
  processed processed with
  [`autolink()`](https://downlit.r-lib.org/reference/autolink.md).

Use `downlit_html_path()` to process an `.html` file on disk; use
`downlit_html_node()` to process an in-memory `xml_node` as part of a
larger pipeline.

## Usage

``` r
downlit_html_path(in_path, out_path, classes = classes_pandoc())

downlit_html_node(x, classes = classes_pandoc())
```

## Arguments

- in_path, out_path:

  Input and output paths for HTML file

- classes:

  A mapping between token names and CSS class names. Bundled
  [`classes_pandoc()`](https://downlit.r-lib.org/reference/highlight.md)
  and
  [`classes_chroma()`](https://downlit.r-lib.org/reference/highlight.md)
  provide mappings that (roughly) match Pandoc and chroma (used by hugo)
  classes so you can use existing themes.

- x:

  An `xml2::xml_node`

## Value

`downlit_html_path()` invisibly returns `output_path`;
`downlit_html_node()` modifies `x` in place and returns nothing.

## Examples

``` r
node <- xml2::read_xml("<p><code>base::t()</code></p>")
node
#> {xml_document}
#> <p>
#> [1] <code>base::t()</code>

# node is modified in place
downlit_html_node(node)
node
#> {xml_document}
#> <p>
#> [1] <code>\n  <a href="https://rdrr.io/r/base/t.html">base::t()</a>\ ...
```
