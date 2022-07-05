.onLoad <- function(libname, pkgname) {
  repo_urls <<- memoise::memoise(repo_urls)
  CRAN_urls <<- memoise::memoise(CRAN_urls)

  # Silence R CMD check note, since only used in memoised function
  withr::local_envvar
}
