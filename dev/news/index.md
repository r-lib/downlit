# Changelog

## downlit (development version)

- Fix broken test

## downlit 0.4.4

CRAN release: 2024-06-10

- Use simpler parsing algorithm for R 4.0, which avoids crash with
  certain UTF-8 characters
  ([\#189](https://github.com/r-lib/downlit/issues/189)).

## downlit 0.4.3

CRAN release: 2023-06-29

- Fix for upcoming R-devel
  ([\#169](https://github.com/r-lib/downlit/issues/169)).

## downlit 0.4.2

CRAN release: 2022-07-05

- [`highlight()`](https://downlit.r-lib.org/dev/reference/highlight.md)
  no longer errors if a package imputed to have been attached isn’t
  installed.

- Correctly link
  [`requireNamespace(MASS)`](https://rdrr.io/r/base/ns-load.html)
  ([\#151](https://github.com/r-lib/downlit/issues/151)).

## downlit 0.4.1

CRAN release: 2022-06-24

### Syntax highlighting

- Supports new base pipe `|>` syntax
  ([\#126](https://github.com/r-lib/downlit/issues/126)).

- Every line get its own `<span>` to match pandoc
  ([\#122](https://github.com/r-lib/downlit/issues/122)).

- Multi-line tokens (e.g. strings) now get a `<span>` per line
  ([\#139](https://github.com/r-lib/downlit/issues/139)).

- Very long strings or other tokens are no longer truncated
  ([@dmurdoch](https://github.com/dmurdoch),
  [\#128](https://github.com/r-lib/downlit/issues/128)).

### Auto-linkg

- Function calls (in inline and code blocks) will no longer to
  non-function topics
  ([\#135](https://github.com/r-lib/downlit/issues/135)).

- Re-exports detection no longer relies on name of `.Rd` file
  ([\#134](https://github.com/r-lib/downlit/issues/134)).

- Link to correct topic with `::()` and
  [`utils::help()`](https://rdrr.io/r/utils/help.html)
  ([@IndrajeetPatil](https://github.com/IndrajeetPatil),
  [\#131](https://github.com/r-lib/downlit/issues/131)).

- Generate correct link for Bioconductor vignettes
  ([@zeehio](https://github.com/zeehio),
  [\#145](https://github.com/r-lib/downlit/issues/145))

## downlit 0.4.0

CRAN release: 2021-10-29

### Syntax highlighting

- Messages, warnings, and errors now get a much more minimal style.
  Messages are styled the same way as output; and warnings and errors
  only style the “Warning” or “Error” text. This makes these types of
  output easier to read, and easier for package developers to style
  themselves.

- Messages, warnings, and errors now retrieve their text using
  [`conditionMessage()`](https://rdrr.io/r/base/conditions.html), which
  supports more advanced types of conditions
  ([@davidchall](https://github.com/davidchall),
  [\#100](https://github.com/r-lib/downlit/issues/100)).

- The overall structure of the syntax highlighting has been overhauled.
  Now each line is wrapped in a `<span>` with class `r-in` (input code),
  `r-out` (output printed to console), `r-plot` (plots), `r-msg`
  (messages), `r-wrn` (warnings), and `r-err` (errors). Additionally,
  the prompt (`#>`) is wrapped in a `<span class="r-pr">`. Altogether,
  these changes should give much more flexibility for styling with CSS
  ([\#90](https://github.com/r-lib/downlit/issues/90)).

- ANSI escapes no longer generate invalid HTML
  ([\#79](https://github.com/r-lib/downlit/issues/79)).

- Changes to better support for HTML widgets and rgl in pkgdown
  ([@dmurdoch](https://github.com/dmurdoch),
  [\#78](https://github.com/r-lib/downlit/issues/78)). In particular,
  [`evaluate_and_highlight()`](https://downlit.r-lib.org/dev/reference/evaluate_and_highlight.md)
  now returns an additional attribute containing all extra dependencies
  needed to render the returned HTML.

### Auto-linking

- Packages attached when you call
  [`library(package)`](https://rdrr.io/r/base/library.html) (including
  by the tidyverse), are now taken into account when autolinking
  ([\#87](https://github.com/r-lib/downlit/issues/87)).

- In code blocks, custom infix operators are now autolinked
  ([\#89](https://github.com/r-lib/downlit/issues/89)). In inline code,
  infix operators are no longer autolinked; this lead to too many false
  positives. You can still link with (e.g.)
  [`?"-"`](https://rdrr.io/r/base/Arithmetic.html)
  ([\#86](https://github.com/r-lib/downlit/issues/86)).

- Inline calls with arguments (e.g. `foo(1, 2)`) are no longer
  auto-linked, as intended and documented
  ([\#82](https://github.com/r-lib/downlit/issues/82)).

- Autolinking `vignette(foo, package = "pkg")` no longer errors if `pkg`
  is not installed ([\#85](https://github.com/r-lib/downlit/issues/85)).

- Unusual help calls (e.g. `help(a$b)`), no longer generate errors
  ([\#77](https://github.com/r-lib/downlit/issues/77)).

- Rare warning about incomplete final line in
  `autolink_url("pkgname::foo")` is now suppressed
  ([@dmurdoch](https://github.com/dmurdoch), pkgdown#1419).

- [`href_package()`](https://downlit.r-lib.org/dev/reference/href_topic.md)
  is now exported
  ([\#103](https://github.com/r-lib/downlit/issues/103)).

- Auto-linking is more likely to succeed when the remote package is not
  installed as downlit now looks for the URL using
  [`tools::CRAN_package_db()`](https://rdrr.io/r/tools/CRANtools.html)
  for CRAN packages, and and
  [`available.packages()`](https://rdrr.io/r/utils/available.packages.html)
  for packages installed from non-CRAN repos
  ([@ARawles](https://github.com/ARawles),
  [\#108](https://github.com/r-lib/downlit/issues/108)).

- Functions in HTML `<summary>` elements are no longer autolinked
  ([@gadenbuie](https://github.com/gadenbuie),
  [\#105](https://github.com/r-lib/downlit/issues/105)).

## downlit 0.2.1

CRAN release: 2020-11-04

- When auto-linking `vignette(foo)`, downlit now looks for a vignette
  named foo in the packages it knows to be attached
  ([\#61](https://github.com/r-lib/downlit/issues/61)).

- Can now force highlighting of any `<pre>` by wrapping it inside a
  `<div>` with `class = "downlit"`. This is useful in cases where it may
  otherwise be hard to set the class of the `<pre>`.

- In comments, `\u2029` is converted to `\033` to make it possible to
  preserve ANSI escapes when passed through xml2.

- No longer errors on library calls with named but empty arguments.

## downlit 0.2.0

CRAN release: 2020-09-25

- Autolinking can use metadata stored in package itself with pkgdown
  setting `deploy.install_metadata`; this is useful for packages that
  only have private websites
  ([@matthewstrasiotto](https://github.com/matthewstrasiotto),
  [\#29](https://github.com/r-lib/downlit/issues/29))

- Autolinking guesses reference and article urls for pkgdown sites that
  haven’t set url ([@krlmlr](https://github.com/krlmlr),
  [\#44](https://github.com/r-lib/downlit/issues/44)).

- R6 classes are autolinked when a new object is created i.e. in
  `r6_object$new()`, `r6_object` will link to its docs
  ([\#59](https://github.com/r-lib/downlit/issues/59),
  [@maelle](https://github.com/maelle)).

- R6 methods are no longer autolinked as if they were functions of the
  same name ([\#54](https://github.com/r-lib/downlit/issues/54),
  [@maelle](https://github.com/maelle)).

- [`classes_pandoc()`](https://downlit.r-lib.org/dev/reference/highlight.md)
  and
  [`classes_chroma()`](https://downlit.r-lib.org/dev/reference/highlight.md)
  have been thoroughly revieweed to produce syntax highlighting as
  similar as possible to RStudio.

- [`downlit_html_path()`](https://downlit.r-lib.org/dev/reference/downlit_html_path.md)
  has a more flexible XPath identifying R code blocks, and a `classes`
  argument ([\#53](https://github.com/r-lib/downlit/issues/53),
  [@maelle](https://github.com/maelle),
  [@cderv](https://github.com/cderv))

- Trailing `/` are no longer stripped from URLs
  ([\#45](https://github.com/r-lib/downlit/issues/45),
  [@krlmlr](https://github.com/krlmlr)).

- Removed extra newline in `<pre>` output
  ([\#42](https://github.com/r-lib/downlit/issues/42),
  [@krlmlr](https://github.com/krlmlr)).

## downlit 0.1.0

CRAN release: 2020-09-01

- Added a `NEWS.md` file to track changes to the package.
