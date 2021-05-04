#' Evaluate code and syntax highlight the results
#'
#' This function runs `code` and captures the output using
#' [evaluate::evaluate()]. It syntax highlights code with [highlight()],
#' and combines all results into a single HTML div.
#'
#' @param code Code to evaluate (as a string).
#' @param fig_save A function with arguments `plot` and `id` that is
#'   responsible for saving `plot` to a file (using `id` to disambiguate
#'   multiple plots in the same chunk). It should return a list with
#'   components `path`, `width`, and `height`.
#' @param env Environment in which to evaluate code; if not supplied,
#'   defaults to a child of the global environment.
#' @param output_handler Custom output handler for `evaluate::evaluate`.
#' @param highlight Optionally suppress highlighting. This is useful for tests.
#' @return An string containing HTML.
#' @inheritParams highlight
#' @export
#' @examples
#' evaluate_and_highlight("1 + 2")
#'
#' # -----------------------------------------------------------------
#' # evaluate_and_highlight() powers pkgdown's documentation formatting so
#' # here I include a few examples to make sure everything looks good
#' # -----------------------------------------------------------------
#'
#' blue <- function(x) paste0("\033[34m", x, "\033[39m")
#' f <- function(x) {
#'   cat("This is some output. My favourite colour is ", blue("blue"), ".\n", sep = "")
#'   message("This is a message. My favourite fruit is ", blue("blueberries"))
#'   warning("Now at stage ", blue("blue"), "!")
#' }
#' f()
evaluate_and_highlight <- function(code,
                                   fig_save,
                                   classes = downlit::classes_pandoc(),
                                   env = NULL,
                                   output_handler = evaluate::new_output_handler(),
                                   highlight = TRUE) {
  env <- env %||% child_env(global_env())

  expr <- evaluate::evaluate(code, child_env(env), new_device = TRUE,
                             output_handler = output_handler)
  replay_html(expr,
    fig_save = fig_save,
    fig_id = unique_id(),
    classes = classes,
    highlight = highlight
  )
}


test_evaluate <- function(code, ..., highlight = TRUE) {
  fig_save <- function(plot, id) {
    list(path = paste0(id, ".png"), width = 10, height = 10)
  }

  code <- paste0(code, "\n")
  cat(evaluate_and_highlight(
    code,
    fig_save = fig_save,
    env = caller_env(),
    highlight = highlight,
    ...
  ))
}

replay_html <- function(x, ...) UseMethod("replay_html", x)

#' @export
replay_html.list <- function(x, ...) {
  # Stitch adjacent source blocks back together
  src <- vapply(x, evaluate::is.source, logical(1))
  # New group whenever not source, or when src after not-src
  group <- cumsum(!src | c(FALSE, src[-1] != src[-length(src)]))

  parts <- split(x, group)
  parts <- lapply(parts, function(x) {
    if (length(x) == 1) return(x[[1]])
    src <- paste0(vapply(x, "[[", "src", FUN.VALUE = character(1)),
      collapse = "")
    structure(list(src = src), class = "source")
  })

  # keep only high level plots
  parts <- merge_low_plot(parts)

  pieces <- character(length(parts))
  dependencies <- list()
  for (i in seq_along(parts)) {
    piece <- replay_html(parts[[i]], ...)
    dependencies <- c(dependencies, attr(piece, "dependencies"))
    pieces[i] <- piece
  }
  res <- paste0(pieces, collapse = "")

  if (is_installed("pkgdown") && utils::packageVersion("pkgdown") >= "1.6.1.9001") {
    # get dependencies from htmlwidgets etc.
    attr(res, "dependencies") <- dependencies
  }

  res
}

#' @export
replay_html.NULL <- function(x, ...) ""

#' @export
replay_html.character <- function(x, ...) {
  label_output(escape_html(x), "output")
}

#' @export
replay_html.value <- function(x, ...) {
  if (!x$visible) return()

  printed <- paste0(utils::capture.output(print(x$value)), collapse = "\n")

  label_output(escape_html(printed))
}

#' @export
replay_html.source <- function(x, ..., classes, highlight = FALSE) {
  if (highlight) {
    html <- highlight(x$src, classes = classes)
  } else {
    html <- escape_html(x$src)
  }

  span(html, class = "input")
}

#' @export
replay_html.warning <- function(x, ...) {
  message <- paste0(span("Warning: ", class = "warning"), escape_html(x$message))
  label_output(message)
}

#' @export
replay_html.message <- function(x, ...) {
  message <- escape_html(paste0(gsub("\n$", "", x$message)))
  label_output(message)
}

#' @export
replay_html.error <- function(x, ...) {
  if (is.null(x$call)) {
    message <- paste0(span("Error: ", class = "error"), escape_html(x$message))
  } else {
    call <- escape_html(paste0(deparse(x$call), collapse = ""))
    message <- paste0(span("Error in ", call, ": ", class = "error"), escape_html(x$message))
  }
  label_output(message)
}

#' @export
replay_html.recordedplot <- function(x, fig_save, fig_id, ...) {
  fig <- fig_save(x, fig_id())
  img <- paste0(
    "<img ",
    "src='", escape_html(fig$path), "' ",
    "alt='' ",
    "width='", fig$width, "' ",
    "height='", fig$height, "' ",
    "/>"
  )
  span(img, class = "img")
}

# helpers -----------------------------------------------------------------


label_output <- function(x, class, prompt = "#> ") {
  lines <- strsplit(x, "\n")[[1]]
  lines <- paste0(escape_html(prompt), lines)
  lines <- fansi::sgr_to_html(lines)

  span(paste0(lines, "\n", collapse = ""), class = "co")
}

span <- function(..., class = NULL) {
  contents <- paste0(...)
  trailing_nl <- grepl("\n$", contents)

  paste0(
    "<span", if (!is.null(class)) paste0(" class='", class, "'"), ">",
    gsub("\n$", "", contents),
    "</span>",
    if (trailing_nl) "\n"
  )
}

unique_id <- function() {
  i <- 0

  function() {
    i <<- i + 1
    i
  }
}

# Knitr functions ------------------------------------------------------------
# The functions below come from package knitr (Yihui Xie) in file plot.R

# get MD5 digests of recorded plots so that merge_low_plot works
digest_plot = function(x, level = 1) {
  if (inherits(x, "otherRecordedplot"))
    return(x)
  if (!is.list(x) || level >= 3) return(structure(digest::digest(x),
                                                  class = "plot_digest"))
  lapply(x, digest_plot, level = level + 1)
}

is_plot_output = function(x) {
  evaluate::is.recordedplot(x) || inherits(x, 'otherRecordedplot')
}

# merge low-level plotting changes
merge_low_plot = function(x, idx = vapply(x, is_plot_output, logical(1L))) {
  idx = which(idx); n = length(idx); m = NULL # store indices that will be removed
  if (n <= 1) return(x)

  # digest of recorded plots
  rp_dg <- lapply(x[idx], digest_plot)

  i1 = idx[1]; i2 = idx[2]  # compare plots sequentially
  for (i in 1:(n - 1)) {
    # remove the previous plot and move its index to the next plot
    if (is_low_change(rp_dg[[i]], rp_dg[[i+1]])) m = c(m, i1)
    i1 = idx[i + 1]
    i2 = idx[i + 2]
  }
  if (is.null(m)) x else x[-m]
}

#' Compare two recorded plots
#'
#' @param p1,p2 Plot results
#'
#' @return Logical value indicating whether `p2` is a low-level update of `p1`.
#' @export
is_low_change = function(p1, p2) {
  UseMethod("is_low_change")
}

#' @export
is_low_change.default = function(p1, p2) {
  p1 = p1[[1]]; p2 = p2[[1]]  # real plot info is in [[1]]
  if ((n2 <- length(p2)) < (n1 <- length(p1))) return(FALSE)  # length must increase
  identical(p1[1:n1], p2[1:n1])
}
