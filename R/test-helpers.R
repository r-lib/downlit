local_devtools_package <- function(path, ..., env = parent.frame()) {
  pkgload::load_all(path, ..., quiet = TRUE)
  defer(pkgload::unload(pkgload::pkg_name(path)), scope = env)
}

defer <- function(expr, scope = parent.frame()) {
  expr <- enquo(expr)

  call <- expr(on.exit(rlang::eval_tidy(!!expr), add = TRUE))
  eval_bare(call, scope)

  invisible()
}

skip_if_installed <- function (pkg) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    testthat::skip(paste0(pkg, " could be loaded"))
  }
  return(invisible(TRUE))
}
