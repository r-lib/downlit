# Compute topic index -----------------------------------------------------
# The topic index is a character vector that maps aliases to Rd file names
# (sans extension). rdtools handles caching and the differences between
# installed, source, and in-development packages.

topic_index <- function(package) {
  if (is.null(package)) {
    getOption("downlit.topic_index")
  } else if (!is_installed(package) && !devtools_loaded(package)) {
    character()
  } else {
    rdtools::pkg_topics(package)
  }
}

find_rdname <- function(package, topic) {
  index <- topic_index(package)

  if (has_name(index, topic)) {
    index[[topic]]
  } else {
    NULL
  }
}

find_rdname_attached <- function(topic, is_fun = FALSE) {
  packages <- c(
    getOption("downlit.attached"),
    rdtools::pkg_search_base()
  )

  matches <- rdtools::topic_find_all(topic, packages)
  for (i in seq_len(nrow(matches))) {
    package <- matches$package[[i]]
    # When linking a bare call, only link to exported symbols
    if (is_fun && !is_exported(topic, package)) {
      next
    }
    return(list(rdname = matches$file[[i]], package = package))
  }
  NULL
}
