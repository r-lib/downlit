.onLoad <- function(libname, pkgname) {
  repo_urls <<- memoise::memoise(repo_urls)
  CRAN_urls <<- memoise::memoise(CRAN_urls)
  BioconductorPkgs <<- memoise::memoise(BioconductorPkgs)
}
