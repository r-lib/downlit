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
    c("datasets", "utils", "grDevices", "graphics", "stats", "base")
  )

  for (package in packages) {
    if (!is_installed(package)) {
      next
    }

    if (is_fun && !is_exported(topic, package)) {
      next
    }

    rdname <- find_rdname(package, topic)
    if (!is.null(rdname)) {
      return(list(rdname = rdname, package = package))
    }
  }
  NULL
}
