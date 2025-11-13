# Evaluate code and syntax highlight the results

This function runs `code` and captures the output using
[`evaluate::evaluate()`](https://downlit.r-lib.org/dev/reference/evaluate.r-lib.org/reference/evaluate.md).
It syntax higlights code with
[`highlight()`](https://downlit.r-lib.org/dev/reference/highlight.md),
and intermingles it with output.

## Usage

``` r
evaluate_and_highlight(
  code,
  fig_save,
  classes = downlit::classes_pandoc(),
  env = NULL,
  output_handler = evaluate::new_output_handler(),
  highlight = TRUE
)
```

## Arguments

- code:

  Code to evaluate (as a string).

- fig_save:

  A function with arguments `plot` and `id` that is responsible for
  saving `plot` to a file (using `id` to disambiguate multiple plots in
  the same chunk). It should return a list with components `path`,
  `width`, and `height`.

- classes:

  A mapping between token names and CSS class names. Bundled
  [`classes_pandoc()`](https://downlit.r-lib.org/dev/reference/highlight.md)
  and
  [`classes_chroma()`](https://downlit.r-lib.org/dev/reference/highlight.md)
  provide mappings that (roughly) match Pandoc and chroma (used by hugo)
  classes so you can use existing themes.

- env:

  Environment in which to evaluate code; if not supplied, defaults to a
  child of the global environment.

- output_handler:

  Custom output handler for
  [`evaluate::evaluate()`](https://downlit.r-lib.org/dev/reference/evaluate.r-lib.org/reference/evaluate.md).

- highlight:

  Optionally suppress highlighting. This is useful for tests.

## Value

An string containing HTML with a `dependencies` attribute giving an
additional htmltools dependencies required to render the HTML.

## Examples

``` r
cat(evaluate_and_highlight("1 + 2"))
#> <span class='r-in'><span><span class='fl'>1</span> <span class='op'>+</span> <span class='fl'>2</span></span></span>
#> <span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 3</span>
cat(evaluate_and_highlight("x <- 1:10\nmean(x)"))
#> <span class='r-in'><span><span class='va'>x</span> <span class='op'>&lt;-</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>10</span></span></span>
#> <span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='op'>(</span><span class='va'>x</span><span class='op'>)</span></span></span>
#> <span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 5.5</span>

# -----------------------------------------------------------------
# evaluate_and_highlight() powers pkgdown's documentation formatting so
# here I include a few examples to make sure everything looks good
# -----------------------------------------------------------------

blue <- function(x) paste0("\033[34m", x, "\033[39m")
f <- function(x) {
  cat("This is some output. My favourite colour is ", blue("blue"), ".\n", sep = "")
  message("This is a message. My favourite fruit is ", blue("blueberries"))
  warning("Now at stage ", blue("blue"), "!")
}
f()
#> This is some output. My favourite colour is blue.
#> This is a message. My favourite fruit is blueberries
#> Warning: Now at stage blue!

plot(1:10)
```
