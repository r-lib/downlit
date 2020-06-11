#' @section Options:
#'
#' downlit provides a number of options to control the details of the linking.
#' They are particularly important if you want to generate "local" links.
#'
#' * `downlit.package`: name of the current package. Determines when
#'   `topic_index` and `article_index`
#'
#' * `downlit.topic_index` and `downlit.article_index`: named character
#'   vector that maps from topic/article name to path.
#'
#' * `downlit.rdname`: name of current Rd file being documented (if any);
#'   used to avoid self-links.
#'
#' * `downlit.attached`: character vector of currently attached R packages.
#'
#' * `downlit.local_packages`: named character vector providing relative
#'   paths (value) to packages (name) that can be reached with relative links
#'   from the target HTML document.
#'
#' * `downlit.topic_path` and `downlit.article_path`: paths to reference
#'   topics and articles/vignettes relative to the "current" file.
#' @keywords internal
#' @import rlang
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
