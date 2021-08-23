register <- new.env()
.onLoad <- function(libname, pkgname) {
  # Create a `register` environment to store the function to create the default package ref link
  register$package_ref_function <- rdrr_package_ref

  # Create `memoised` versions of the `fetch_` packages because we'll likely be doing them
  # more than once and they're costly
  memo_fetch_repo_packages <<- memoise::memoise(fetch_repo_packages)
  memo_fetch_cran_packages <<- memoise::memoise(fetch_cran_packages)
}
