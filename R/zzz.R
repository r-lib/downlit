.onLoad <- function(libname, pkgname) {
  memo_fetch_repo_packages <<- memoise::memoise(fetch_repo_packages)
  memo_fetch_cran_packages <<- memoise::memoise(fetch_cran_packages)
}
