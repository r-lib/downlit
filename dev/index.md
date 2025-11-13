# downlit

The goal of downlit is to provide syntax highlighting and automatic
linking of R code in a way that is easily used from RMarkdown packages
like [pkgdown](https://pkgdown.r-lib.org/),
[bookdown](https://bookdown.org), and
[hugodown](https://hugodown.r-lib.org/).

## Installation

Install downlit from CRAN with:

``` r
install.packages("downlit")
```

## Features

downlit has two slightly different highlighting/linking engines:

- [`highlight()`](https://downlit.r-lib.org/dev/reference/highlight.md)
  works with multiline code blocks and does syntax highlighting,
  function linking, and comment styling.
- [`autolink()`](https://downlit.r-lib.org/dev/reference/autolink.md)
  works with inline code and only does linking.

Multiline code blocks have:

- Code syntax highlighted using R’s parser.
- Function calls automatically linked to their corresponding
  documentation.
- Comments styled by transforming ANSI escapes sequences to their HTML
  equivalents (thanks [fansi](https://github.com/brodieG/fansi)
  package).

The following forms of inline code are recognized and automatically
linked:

- `fun()`, `pkg::fun()`.
- `?fun`, `pkg::fun`, `type?topic`.
- `help("fun")`, `help("fun", package = "package")`,
  [`help(package = "package")`](https://rdrr.io/pkg/package/man).
- `vignette("name")`, `vignette("name", package = "package")`.
- [`library(package)`](https://rdrr.io/r/base/library.html),
  [`require(package)`](https://rdrr.io/r/base/library.html),
  [`requireNamespace("package")`](https://rdrr.io/r/base/ns-load.html).
- `{package}` gets linked (if possible) *and formatted as plain text*.

### Cross-package links

If downlit can find a pkgdown site for the remote package, it will link
to it; otherwise it will link to <https://rdrr.io/> for documentation,
and CRAN for vignettes. In order for a pkgdown site to be findable, it
needs to be listed in two places:

- In the `URL` field in the `DESCRIPTION`, as in
  [dplyr](https://github.com/tidyverse/dplyr/blob/85faf79c1fd74f4b4f95319e5be6a124a8075502/DESCRIPTION#L15):

      URL: https://dplyr.tidyverse.org, https://github.com/tidyverse/dplyr

- In the `url` field in `_pkgdown.yml`, as in
  [dplyr](https://github.com/tidyverse/dplyr/blob/master/_pkgdown.yml#L1)

  ``` yaml
  url: https://dplyr.tidyverse.org
  ```

  When this field is defined, pkgdown generates a public facing
  [`pkgdown.yml` file](https://dplyr.tidyverse.org/pkgdown.yml) that
  provides metadata about the site:

  ``` yaml
  pandoc: '2.2'
  pkgdown: 1.3.0
  pkgdown_sha: ~
  articles:
    compatibility: compatibility.html
    dplyr: dplyr.html
  urls:
    reference: https://dplyr.tidyverse.org/reference
    article: https://dplyr.tidyverse.org/articles
  ```

So when you build a pkgdown site that links to the dplyr documentation
(e.g., `dplyr::mutate()`), pkgdown looks first in dplyr’s `DESCRIPTION`
to find its website, then it looks for `pkgdown.yml`, and uses the
metadata to generate the correct links.

## Usage

downlit is designed to be used by other packages, and I expect most uses
of downlit will use it via another package
(e.g. [hugodown](https://github.com/r-lib/hugodown)). If you want to use
it in your own package, you’ll typically want to apply it as part of
some bigger transformation process. You can get some sense of how this
might work by reading the source code of
[`downlit_html()`](https://github.com/r-lib/downlit/blob/master/R/downlit-html.R)
and
[`downlit_md()`](https://github.com/r-lib/downlit/blob/master/R/downlit-md.R),
which transform HTML and markdown documents respectively.
