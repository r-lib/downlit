# downlit

<!-- badges: start -->
[![R build status](https://github.com/r-lib/downlit/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/downlit/actions)
[![Codecov test coverage](https://codecov.io/gh/r-lib/downlit/branch/master/graph/badge.svg)](https://codecov.io/gh/r-lib/downlit?branch=master)
<!-- badges: end -->

The goal of downlit is to provide syntax highlighting and automatic linking of R code in a way that is easily used from RMarkdown packages like [pkgdown](http://pkgdown.r-lib.org/), [bookdown](https://bookdown.org), and [hugodown](http://github.com/r-lib/hugodown/issues).

## Features

downlit has two slightly different highlighting/linking engines, one for multiline code blocks (focussed primarily on highlighting), and one for inline code (focussed primarily on linking).

Multiline code blocks have:

* Code syntax highlighted using R's parser.
* Function calls automatically linked to their corresponding documentation.
* Comments styled by transforming ANSI escapes sequences to their HTML 
  equivalents (thanks [fansi](https://github.com/brodieG/fansi) package).

The following forms of inline code are recognised and automatically linked:

* `fun()`, `pkg::fun()`.
* `?fun`, `pkg::fun`, `type?topic`.
* `help("fun")`, `help("fun", package = "package")`, `help(package = "package")`.
* `vignette("name")`, `vignette("name", package = "package")`.
* `library(pacakge)`, `require(package)`, `requireNamespace("package")`.

### Cross-package links

If pkgdown can find a pkgdown site for the remote package, it will link to it; otherwise it will link to <http://rdrr.io/> for documentation, and CRAN for vignettes. In order for a pkgdown site to be findable, it needs to be listed in two places:

*   In the `URL` field in the `DESCRIPTION`, as in
    [dplyr](https://github.com/tidyverse/dplyr/blob/85faf79c1fd74f4b4f95319e5be6a124a8075502/DESCRIPTION#L15):
  
    ```
    URL: http://dplyr.tidyverse.org, https://github.com/tidyverse/dplyr
    ```

*   In the `url` field in `_pkgdown.yml`, as in 
    [dplyr](https://github.com/tidyverse/dplyr/blob/master/_pkgdown.yml#L1)
    
    ```yaml
    url: https://dplyr.tidyverse.org
    ```
    
    When this field is defined, pkgdown generate a public facing
    [`pkgdown.yml` file](https://dplyr.tidyverse.org/pkgdown.yml) that 
    provides metadata about the site:
    
    ```yaml
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

So when you build a pkgdown site that links to the dplyr documentation (e.g., `dplyr::mutate()`), pkgdown looks first in dplyr's `DESCRIPTION` to find its website, then it looks for `pkgdown.yml`, and uses the metadata to generate the correct links.
