#' @return Either `NULL` if `text` is not valid R code, or an HTML
#'   string representing a code block.
highlight <- function(text, classes = classes_pandoc()) {
  parsed <- parse_data(text)
  if (is.null(parsed)) {
    return()
  }

  # Figure out which packages are attached to the search path. This is a
  # hack because loading a package will affect code _before_ the library()
  # call. But it should lead to relatively few false positives and is simple.
  packages <- extract_package_attach(parsed$expr)
  register_attached_packages(packages)

  # Highlight, link, and escape
  out <- parsed$data
  out$class <- token_class(out$token, classes)
  out$href <- token_href(out$token, out$text)
  out$escaped <- escape_html(out$text)

  # Update input - basic idea from prettycode
  changed <- !is.na(out$href) | !is.na(out$class) | out$text != out$escaped
  changes <- out[changed, , drop = FALSE]
  changes_by_line <- split(changes, changes$line1)
  lines <- strsplit(text, "\r?\n")[[1]]

  for (change in changes_by_line) {
    i <- change$line1[[1]]
    new <- style_token(change$escaped, change$href, change$class)

    lines[[i]] <- replace_in_place(
      lines[[i]],
      start = change$col1,
      end = change$col2,
      replacement = new
    )
  }
  paste0(lines, collapse = "\n")
}

style_token <- function(x, href = NA, class = NA) {
  x <- ifelse(is.na(href), x, paste0("<a href='", href, "'>", x, "</a>"))
  x <- ifelse(is.na(class), x, paste0("<span class='", class, "'>", x, "</span>"))
  x
}

# From prettycode:::replace_in_place
replace_in_place <- function(str, start, end, replacement) {
  stopifnot(
    length(str) == 1, length(start) == length(end),
    length(end) == length(replacement)
  )

  keep <- substring(str, c(1, end + 1), c(start - 1, nchar(str)))
  pieces <- character(length(replacement) * 2 + 1)
  even <- seq_along(replacement) * 2
  odd <- c(1, even + 1)
  pieces[even] <- replacement
  pieces[odd] <- keep
  paste0(pieces, collapse = "")
}

parse_data <- function(text) {
  stopifnot(is.character(text), length(text) == 1)

  text <- gsub("\r", "", text)
  expr <- tryCatch(
    parse(text = text, keep.source = TRUE),
    error = function(e) NULL
  )

  # Failed to parse, or yielded empty expression
  if (length(expr) == 0) {
    return(NULL)
  }

  list(expr = expr, data = utils::getParseData(expr))
}

# Highlighting ------------------------------------------------------------

token_class <- function(token, classes) {
  token <- token_type(token)
  unname(classes[token])
}

# Collapse token types to a smaller set of categories that we care about
# for syntax highlighting
# https://github.com/wch/r-source/blob/trunk/src/main/gram.c#L511
token_type <- function(x) {
  special <- c("IF", "ELSE", "REPEAT", "WHILE", "FOR", "IN", "NEXT", "BREAK")
  infix <- c(
    "'-'", "'+'", "'!'", "'~'", "'?'", "':'", "'*'", "'/'", "'^'", "'~'",
    "SPECIAL", "LT", "GT", "EQ", "GE", "LE", "AND", "AND2", "OR",
    "OR2", "LEFT_ASSIGN", "RIGHT_ASSIGN", "'$'", "'@'", "EQ_ASSIGN"
  )

  x[x %in% special] <- "special"
  x[x %in% infix] <- "infix"
  x
}

# Pandoc styles are based on KDE default styles:
# https://docs.kde.org/stable5/en/applications/katepart/highlight.html#kate-highlight-default-styles
# But are given a two letter abbreviations (presumably to reduce generated html size)
#
# Default syntax highlighting def for R:
# https://github.com/KDE/syntax-highlighting/blob/master/data/syntax/r.xml
classes_pandoc <- function() {
  c(
    "NUM_CONST" = "fl",
    "STR_CONST" = "st",
    "NULL_CONST" = "kw",
    "FUNCTION" = "fu",
    "special" = "co",
    "infix" = "op",
    "SYMBOL" = "kw",
    "SYMBOL_FUNCTION_CALL" = "fu",
    "SYMBOL_PACKAGE" = "kw",
    "SYMBOL_FORMALS" = "kw",
    "COMMENT" = "co"
  )
}

# Linking -----------------------------------------------------------------

token_href <- function(token, text) {
  href <- rep(NA, length(token))

  # Highlight namespaced function calls. In the parsed tree, these are
  # SYMBOL_PACKAGE then NS_GET/NS_GET_INT then SYMBOL_FUNCTION_CALL/SYMBOL
  ns_pkg <- which(token %in% "SYMBOL_PACKAGE")
  ns_fun <- ns_pkg + 2L

  href[ns_fun] <- map2_chr(text[ns_fun], text[ns_pkg], href_topic)

  # Then highlight all remaining calls, using loaded packages registered
  # above. These maintained at a higher-level, because (e.g) in .Rmds you want
  # earlier library() statements to affect the highlighting of later blocks
  fun <- which(token %in% "SYMBOL_FUNCTION_CALL")
  fun <- setdiff(fun, ns_fun)
  href[fun] <- map_chr(text[fun], href_topic_local)

  # Highlight packages
  lib_call <- which(
    token == "SYMBOL_FUNCTION_CALL" & text %in% c("library", "require")
  )
  pkg <- lib_call + 3 # expr + '(' + STR_CONST
  href[pkg] <- map_chr(gsub("['\"]", "", text[pkg]), href_package)

  href
}

map_chr <- function(.x, .f, ...) {
  vapply(.x, .f, ..., FUN.VALUE = character(1))
}
map2_chr <- function(.x, .y, .f, ...) {
  vapply(seq_along(.x), function(i) .f(.x[[i]], .y[[i]], ...), character(1))
}

# Escaping ----------------------------------------------------------------

escape_html <- function(x) {
  x <- gsub("&", "&amp;", x)
  x <- gsub("<", "&lt;", x)
  x <- gsub(">", "&gt;", x)
  x
}
