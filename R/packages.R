extract_package_attach <- function(expr) {
  if (is.expression(expr)) {
    packages <- lapply(expr, extract_package_attach)
    unlist(packages)
  } else if (is_call(expr)) {
    if (is_call(expr, c("library", "require"))) {
      if (is_call(expr, "library")) {
        expr <- match.call(library, expr)
      } else {
        expr <- match.call(require, expr)
      }

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

meta_packages <- c("tidyverse", "tidymodels")
add_depends <- function(packages) {
  for (meta in meta_packages) {
    if (meta %in% packages && is_installed(meta)) {
      core <- getNamespace(meta)$core
      packages <- union(packages, core)
    }
  }

  # add packages attached by depends
  depends <- unlist(lapply(packages, package_depends))
  union(packages, depends)
}

package_depends <- function(package) {
  if (!is_installed(package)) {
    return(character())
  }

  if (!is.null(devtools_meta(package))) {
    path_desc <- system.file("DESCRIPTION", package = "pkgdown")
    deps <- desc::desc_get_deps(path_desc)
    depends <- deps$package[deps$type == "Depends"]
    depends <- depends[depends != "R"]
    return(depends)
  }

  path_meta <- system.file("Meta", "package.rds", package = package)
  meta <- readRDS(path_meta)
  names(meta$Depends)
}

# from https://github.com/r-lib/pkgdown/blob/8e0838e273462cec420dfa20f240c684a33425d9/R/utils.r#L62
devtools_meta <- function(x) {
  ns <- .getNamespace(x)
  ns[[".__DEVTOOLS__"]]
}
