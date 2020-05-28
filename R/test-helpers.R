local_devtools_package <- function(path, ..., env = parent.frame()) {
  pkgload::load_all(path, ...)
  defer(pkgload::unload(pkgload::pkg_name(path)), scope = env)
}
