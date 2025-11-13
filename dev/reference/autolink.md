# Automatically link inline code

Automatically link inline code

## Usage

``` r
autolink(text)

autolink_url(text)
```

## Arguments

- text:

  String of code to highlight and link.

## Value

If `text` is linkable, an HTML link for `autolink()`, and or just the
URL for `autolink_url()`. Both return `NA` if the text is not linkable.

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
autolink("stats::median()")
#> [1] "<a href='https://rdrr.io/r/stats/median.html'>stats::median()</a>"
autolink("vignette('grid', package = 'grid')")
#> [1] "<a href='https://cran.rstudio.com/web/packages/grid/vignettes/grid.pdf'>vignette('grid', package = 'grid')</a>"

autolink_url("stats::median()")
#> [1] "https://rdrr.io/r/stats/median.html"
```
