extract_package_attach <- function(expr) {
  if (is.expression(expr)) {
    packages <- lapply(expr, extract_package_attach)
    unlist(packages)
  } else if (is_call(expr)) {
    if (is_call(expr, c("library", "require"))) {
      expr <- call_standardise(expr)
      if (!is_true(expr$character.only)) {
        as.character(expr$package)
      } else {
        character()
      }
    } else {
      args <- as.list(expr[-1])
      unlist(lapply(args, extract_package_attach))
    }
  } else {
    character()
  }
}

# Helper for testing
extract_package_attach_ <- function(expr) {
  extract_package_attach(enexpr(expr))
}

register_attached_packages <- function(packages) {
  packages <- add_depends(packages)
  options("downlit.attached" = union(packages, getOption("downlit.attached")))
}

add_depends <- function(packages) {
  if ("tidyverse" %in% packages && is_installed("tidyverse")) {
    core <- getNamespace("tidyverse")$core
    packages <- union(packages, core)
  }

  # add packages attached by depends
  depends <- unlist(lapply(packages, package_depends))
  union(packages, depends)
}

package_depends <- function(package) {
  path_meta <- system.file("Meta", "package.rds", package = package)
  meta <- readRDS(path_meta)
  names(meta$Depends)
}
