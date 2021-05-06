#' Evaluate code and syntax highlight the results
#'
#' This function runs `code` and captures the output using
#' [evaluate::evaluate()]. It syntax higlights code with [highlight()], and
#' intermingles it with output.
#'
#' @param code Code to evaluate (as a string).
#' @param fig_save A function with arguments `plot` and `id` that is
#'   responsible for saving `plot` to a file (using `id` to disambiguate
#'   multiple plots in the same chunk). It should return a list with
#'   components `path`, `width`, and `height`.
#' @param env Environment in which to evaluate code; if not supplied,
#'   defaults to a child of the global environment.
#' @param output_handler Custom output handler for [evaluate::evaluate()].
#' @param highlight Optionally suppress highlighting. This is useful for tests.
#' @param multi_pre Use newer style where each block of input/output gets
#'   it's own `<pre>`? Automatically enabled by pkgdown when you use bs4.
#' @return An string containing HTML.
#' @inheritParams highlight
#' @export
#' @examples
#' cat(evaluate_and_highlight("1 + 2"))
#' cat(evaluate_and_highlight("x <- 1:10\nmean(x)"))
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
                                   multi_pre = FALSE,
                                   highlight = TRUE) {
  env <- env %||% child_env(global_env())

  expr <- evaluate::evaluate(code, child_env(env), new_device = TRUE,
                             output_handler = output_handler)
  replay_html(expr,
    fig_save = fig_save,
    fig_id = unique_id(),
    classes = classes,
    highlight = highlight,
    multi_pre = multi_pre
  )
}


test_evaluate <- function(code, ..., highlight = FALSE, multi_pre = TRUE) {
  fig_save <- function(plot, id) {
    list(path = paste0(id, ".png"), width = 10, height = 10)
  }

  cat(evaluate_and_highlight(
    code,
    fig_save = fig_save,
    env = caller_env(),
    highlight = highlight,
    multi_pre = multi_pre,
    ...
  ))
}

replay_html <- function(x, ...) UseMethod("replay_html", x)

#' @export
replay_html.list <- function(x, ...) {
  # keep only high level plots
  x <- merge_low_plot(x)

  # Stitch adjacent source blocks back together
  src <- vapply(x, evaluate::is.source, logical(1))
  # New group whenever not source, or when src after not-src
  group <- cumsum(!src | c(FALSE, src[-1] != src[-length(src)]))

  parts <- split(x, group)
  x <- lapply(parts, function(x) {
    if (length(x) == 1) return(x[[1]])
    src <- paste0(map_chr(x, "[[", "src"), collapse = "")
    structure(list(src = src), class = "source")
  })

  pieces <- character(length(x))
  dependencies <- list()
  for (i in seq_along(x)) {
    piece <- replay_html(x[[i]], ...)
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
replay_html.character <- function(x, ..., multi_pre = FALSE) {
  label_output(escape_html(x), "r-out", multi_pre = multi_pre)
}

#' @export
replay_html.value <- function(x, ..., multi_pre = FALSE) {
  if (!x$visible) return()

  printed <- paste0(utils::capture.output(print(x$value)), collapse = "\n")

  label_output(escape_html(printed), "r-out", multi_pre = multi_pre)
}

#' @export
replay_html.source <- function(x, ..., classes, multi_pre = FALSE, highlight = FALSE) {
  if (highlight) {
    html <- highlight(x$src, classes = classes)
  }
  if (!highlight || is.na(html)) {
    html <- escape_html(x$src)
  }

  label_input(html, "r-in", multi_pre = multi_pre)
}

#' @export
replay_html.warning <- function(x, ..., multi_pre = FALSE) {
  message <- paste0(span("Warning: ", class = "warning"), escape_html(x$message))
  label_output(message, "r-wrn", multi_pre = multi_pre)
}

#' @export
replay_html.message <- function(x, ..., multi_pre = FALSE) {
  message <- escape_html(paste0(gsub("\n$", "", x$message)))
  label_output(message, "r-msg", multi_pre = multi_pre)
}

#' @export
replay_html.error <- function(x, ..., multi_pre = FALSE) {
  if (is.null(x$call)) {
    prefix <- "Error:"
  } else {
    prefix <- paste0("Error in ", escape_html(paste0(deparse(x$call), collapse = "")))
  }
  message <- paste0(span(prefix, class = "error"), " ", escape_html(x$message))
  label_output(message, "r-err", multi_pre = multi_pre)
}

#' @export
replay_html.recordedplot <- function(x, fig_save, fig_id, ..., multi_pre = FALSE) {
  fig <- fig_save(x, fig_id())
  img <- paste0(
    "<img ",
    "src='", escape_html(fig$path), "' ",
    "alt='' ",
    "width='", fig$width, "' ",
    "height='", fig$height, "' ",
    "/>"
  )
  block(img, "r-plt", multi_pre = multi_pre)
}

# helpers -----------------------------------------------------------------

label_output <- function(x, class, multi_pre = TRUE) {
  lines <- strsplit(x, "\n")[[1]]
  lines <- fansi::sgr_to_html(lines)
  lines <- paste0("#&gt;", " ", lines)

  block(lines, paste(class, "co"), multi_pre = multi_pre)
}

label_input <- function(x, class, multi_pre = TRUE) {
  lines <- strsplit(x, "\n")[[1]]
  block(lines, class, multi_pre = multi_pre)
}

block <- function(lines, class = NULL, multi_pre = TRUE) {
  if (multi_pre) {
    paste0(
      "<pre class='", class, "'><code class='sourceCode r'>",
      paste0(lines, collapse = "\n"),
      "</code></pre>\n"
    )
  } else {
    lines <- span(lines, class = class)
    paste0(lines, "\n", collapse = "")
  }
}

span <- function(..., class = NULL) {
  paste0(
    "<span", if (!is.null(class)) paste0(" class='", class, "'"), ">",
    ...,
    "</span>"
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
