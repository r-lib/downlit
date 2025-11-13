# Highlight and link a code block

This function:

- syntax highlights code

- links function calls to their documentation (where possible)

- in comments, translates ANSI escapes in to HTML equivalents.

## Usage

``` r
highlight(text, classes = classes_chroma(), pre_class = NULL, code = FALSE)

classes_pandoc()

classes_chroma()
```

## Arguments

- text:

  String of code to highlight and link.

- classes:

  A mapping between token names and CSS class names. Bundled
  `classes_pandoc()` and `classes_chroma()` provide mappings that
  (roughly) match Pandoc and chroma (used by hugo) classes so you can
  use existing themes.

- pre_class:

  Class(es) to give output `<pre>`.

- code:

  If `TRUE`, wrap output in a `<code>` block

## Value

If `text` is valid R code, an HTML `<pre>` tag. Otherwise, `NA`.

A string containing syntax highlighted HTML or `NA` (if `text` isn't
parseable).

## Options

downlit provides a number of options to control the details of the
linking. They are particularly important if you want to generate "local"
links.

- `downlit.package`: name of the current package. Determines when
  `topic_index` and `article_index`

- `downlit.topic_index` and `downlit.article_index`: named character
  vector that maps from topic/article name to path.

- `downlit.rdname`: name of current Rd file being documented (if any);
  used to avoid self-links.

- `downlit.attached`: character vector of currently attached R packages.

- `downlit.local_packages`: named character vector providing relative
  paths (value) to packages (name) that can be reached with relative
  links from the target HTML document.

- `downlit.topic_path` and `downlit.article_path`: paths to reference
  topics and articles/vignettes relative to the "current" file.

## Examples

``` r
cat(highlight("1 + 1"))
#> <span><span class='m'>1</span> <span class='o'>+</span> <span class='m'>1</span></span>
cat(highlight("base::t(1:3)"))
#> <span><span class='nf'>base</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/base/t.html'>t</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span></span>

# Unparseable R code returns NA
cat(highlight("base::t("))
#> NA
```
