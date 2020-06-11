local_devtools_package <- function(path, ..., env = parent.frame()) {
  pkgload::load_all(path, ...)
  defer(pkgload::unload(pkgload::pkg_name(path)), scope = env)
}

defer <- function(expr, scope = parent.frame()) {
  expr <- enquo(expr)

  call <- expr(on.exit(rlang::eval_tidy(!!expr), add = TRUE))
  eval_bare(call, scope)

  invisible()
}
