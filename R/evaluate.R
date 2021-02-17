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
#' @return An string containing HTML.
#' @inheritParams highlight
#' @export
#' @examples
#' evaluate_and_highlight("1 + 2")
evaluate_and_highlight <- function(code,
                                   fig_save,
                                   classes = downlit::classes_pandoc(),
                                   env = NULL,
                                   output_handler = evaluate::default_output_handler) {
  env <- env %||% child_env(global_env())

  expr <- evaluate::evaluate(code, child_env(env), new_device = TRUE,
                             output_handler = output_handler)
  replay_html(expr, fig_save = fig_save, fig_id = unique_id(), classes = classes)
}

#' Convert object to HTML
#'
#' @param x Object to display
#'
#' @return character vector containing html
#' @export
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
  for (i in seq_along(parts)) {
    pieces[i] <- replay_html(parts[[i]], ...)
  }
  res <- paste0(pieces, collapse = "")

  # convert ansi escapes
  res <- fansi::sgr_to_html(res)
  res
}

#' @export
replay_html.NULL <- function(x, ...) ""

#' @export
replay_html.character <- function(x, ...) {
  label_output(x)
}

#' @export
replay_html.value <- function(x, ...) {
  if (!x$visible) return()

  printed <- paste0(utils::capture.output(print(x$value)), collapse = "\n")
  label_output(printed)
}

#' @export
replay_html.source <- function(x, ..., classes) {
  html <- highlight(x$src, classes = classes)
  paste0("<div class='input'>", html, "</div>")
}

#' @export
replay_html.warning <- function(x, ...) {
  message <- paste0("Warning: ", x$message)
  label_output(message, "warning")
}

#' @export
replay_html.message <- function(x, ...) {
  message <- gsub("\n$", "", x$message)
  label_output(message, "message")
}

#' @export
replay_html.error <- function(x, ...) {
  if (is.null(x$call)) {
    message <- paste0("Error: ", x$message)
  } else {
    call <- paste0(deparse(x$call), collapse = "")
    message <- paste0("Error in ", call, ": ", x$message)
  }
  label_output(message, "error")
}

#' @export
replay_html.recordedplot <- function(x, fig_save, fig_id, ...) {
  fig <- fig_save(x, fig_id())

  paste0(
    "<div class='img'>",
    "<img src='", escape_html(fig$path), "' alt='' width='", fig$width, "' height='", fig$height, "' />",
    "</div>"
  )

}

# helpers -----------------------------------------------------------------

label_lines <- function(x, class = NULL, prompt = "#> ") {
  lines <- strsplit(x, "\n")[[1]]
  lines <- escape_html(lines)

  if (!is.null(class)) {
    lines <- sprintf("<span class='%s'>%s</span>", class, lines)
  }

  paste0(escape_html(prompt), lines)
}

label_output <- function(x, class = NULL, prompt = "#> ") {
  lines <- label_lines(x, class = class, prompt = prompt)
  paste0(
    "<div class='output co'>",
    paste0(lines, collapse = "\n"),
    "</div>"
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
  if (!is.list(x) || level >= 3) return(structure(digest::digest(x),
                                                  class = "plot_digest"))
  lapply(x, digest_plot, level = level + 1)
}

is_plot_output = function(x) {
  evaluate::is.recordedplot(x) ||
    inherits(x, 'knit_other_plot')
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
is_low_change.plot_digest = function(p1, p2) {
  if (!inherits(p2, "plot_digest"))
    return(FALSE)
  p1 = p1[[1]]; p2 = p2[[1]]  # real plot info is in [[1]]
  if (length(p2) < (n1 <- length(p1))) return(FALSE)  # length must increase
  identical(p1[1:n1], p2[1:n1])
}

#' @export
is_low_change.default = function(p1, p2) FALSE
