up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

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
