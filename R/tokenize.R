#' Perform tokenization of R code
#'
#' This function performs the initial step of the highlighting, turning R code
#' into a number of tokens identified by their type and attached a class based
#' on the `classes` argument.
#'
#' @inheritParams highlight
#'
#' @return A list containing the input code as a string and as an expression
#' along with a data frame containing the tokenized code.
#'
#' @keywords internal
#' @export
#'
#' @examples
#' tokenize_code("sum(sample(10) * 10)")
#'
tokenize_code <- function(text, classes = classes_chroma()) {
  parsed <- parse_data(text)

  if (is.null(parsed)) {
    return(NULL)
  }

  # Highlight, link, and escape
  parsed$data$class <- token_class(parsed$data$token, parsed$data$text, classes)
  parsed$data$href <- token_href(parsed$data$token, parsed$data$text)
  parsed$data$escaped <- token_escape(parsed$data$token, parsed$data$text)

  parsed
}
