is_infix <- function(x) {
  ops <- c(
    "::", ":::", "$", "@", "[", "[[", "^", "-", "+", ":", "*", "/",
    "<", ">", "<=", ">=", "==", "!=", "!", "&", "&&", "|", "||", "~",
    "->", "->>", "<-", "<<-", "=", "?"
  )

  grepl("^%.*%$", x) || x %in% ops
}

is_prefix <- function(x) {
  if (is_infix(x)) {
    return(FALSE)
  }

  special <- c(
    "(", "{", "if", "for", "while", "repeat", "next", "break", "function"
  )
  if (x %in% special) {
    return(FALSE)
  }

  TRUE
}

devtools_loaded <- function(x) {
  if (!x %in% loadedNamespaces()) {
    return(FALSE)
  }
  ns <- .getNamespace(x)
  env_has(ns, ".__DEVTOOLS__")
}

invert_index <- function(x) {
  stopifnot(is.list(x))

  if (length(x) == 0)
    return(list())

  key <- rep(names(x), lengths(x))
  val <- unlist(x, use.names = FALSE)

  split(key, val)
}

safe_parse <- function(text) {
  text <- gsub("\r", "", text)
  tryCatch(
    parse(text = text, keep.source = TRUE, encoding = "UTF-8"),
    error = function(e) NULL
  )
}


extract_curly_package <- function(x) {
  # regex adapted from https://github.com/r-lib/usethis/blob/d5857737b4780c3c3d8fe6fb44ef70e81796ac8e/R/description.R#L134
  if (! grepl("^\\{[a-zA-Z][a-zA-Z0-9.]+\\}$", x)) {
    return(NA)
  }

  # remove first curly brace
  x <- sub("\\{", "", x)
  # remove second curly brace and return
  x <- sub("\\}", "", x)

  x
}


show_xml <- function(x) {
  cat(as.character(x, options = c("format", "no_declaration")))
}
