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
  packages <- union(packages, context_get("packages"))
  context_set("packages", packages)
}
