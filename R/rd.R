package_rd <- function(path) {
  rd <- dir(path, pattern = "\\.[Rr]d$", full.names = TRUE)
  names(rd) <- basename(rd)
  lapply(rd, rd_file, pkg_path = dirname(path))
}

rd_file <- function(path, pkg_path = NULL) {
  if (getRversion() >= "3.4.0") {
    macros <- tools::loadPkgRdMacros(pkg_path)
  } else {
    macros <- tools::loadPkgRdMacros(pkg_path, TRUE)
  }
  tools::parse_Rd(path, macros = macros, encoding = "UTF-8")
}

extract_alias <- function(x, tag) {
  is_alias <- vapply(x, function(x) attr(x, "Rd_tag") == "\\alias", logical(1))
  unlist(x[is_alias])
}
