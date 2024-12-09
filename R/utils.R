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

standardise_text <- function(x) {
  x <- enc2utf8(x)
  x <- gsub("\t", "  ", x, fixed = TRUE, useBytes = TRUE)
  x <- gsub("\r", "", x, fixed = TRUE, useBytes = TRUE)
  # \033 can't be represented in xml (and hence is ignored by xml2)
  # so we convert to \u2029 in order to survive a round trip
  x <- gsub("\u2029", "\033", x, fixed = TRUE, useBytes = TRUE)
  x
}

safe_parse <- function(text, standardise = TRUE) {
  if (standardise) {
    text <- standardise_text(text)
  }

  lines <- strsplit(text, "\n", fixed = TRUE, useBytes = TRUE)[[1]]
  srcfile <- srcfilecopy("test.r", lines)

  tryCatch(
    parse(text = text, keep.source = TRUE, encoding = "UTF-8", srcfile = srcfile),
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
