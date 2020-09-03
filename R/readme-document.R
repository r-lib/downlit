#' Auto-linking for README files
#'
#' A drop-in replacement for [rmarkdown::github_document] that applies
#' highlighting and auto-linking to the resulting Markdown file.
#' GitHub strips the highlighting when displaying the README file,
#' it is still available when the site is displayed in pkgdown.
#'
#' @param ... Passed on to [rmarkdown::github_document]
#' @examples
#'
#' # Include this into the front matter of your README.Rmd:
#' #
#' # output: downlit::readme_document
#' @export
readme_document <- function(...) {
  check_packages()

  format <- rmarkdown::github_document(...)

  format_pre_knit <- format$pre_knit
  format_post_knit <- format$post_knit

  format_post_processor <- format$post_processor

  old_options <- NULL

  format$pre_knit <- function(...) {
    old_options <<- options(crayon.enabled = TRUE)

    # Run preknit at end
    if (!is.null(format_pre_knit)) {
      format_pre_knit(...)
    }
  }

  format$post_knit <- function(...) {
    if (!is.null(format_post_knit)) {
      out <- format_post_knit(...)
    } else {
      out <- NULL
    }
    options(old_options)
    out
  }

  format$post_processor <- function(front_matter, utf8_input, output_file, clean, quiet) {
    if (!quiet) {
      message("Auto-linking code")
    }
    downlit_md_path(output_file, output_file)

    # Run postprocessor at end, on downlit file
    if (!is.null(format_post_processor)) {
      output_file <- format_post_processor(front_matter, utf8_input, output_file, clean, quiet)
    }

    output_file
  }

  format
}
