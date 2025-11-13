# Generate url for topic/article/package

Generate url for topic/article/package

## Usage

``` r
href_topic(topic, package = NULL, is_fun = FALSE)

href_article(article, package = NULL)

href_package(package)
```

## Arguments

- topic, article:

  Topic/article name

- package:

  Optional package name. If not supplied, will search in all attached
  packages.

- is_fun:

  Only return topics that are (probably) for functions.

## Value

URL topic or article; `NA` if can't find one.

## Examples

``` r
href_topic("t")
#> [1] "https://rdrr.io/r/base/t.html"
href_topic("DOESN'T EXIST")
#> [1] NA
href_topic("href_topic", "downlit")
#> [1] NA

href_package("downlit")
#> [1] "https://downlit.r-lib.org/"
```
