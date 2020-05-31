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

## Test for inline html

<ul>
  <li><a href="http://google.com">A link</a></li>
  <li><span class="foo">Span with class</class></li>
  <li><span style="color: green">Span with style</span></li>
  <li><font color="green">Font with color</font></li>
  <li><pre>This is a pre block</pre></li>
</ul>

