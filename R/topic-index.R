# Compute topic index -----------------------------------------------------
# The topic index is a character vector that maps aliases to Rd file names
# (sans extension). Memoised for performance.

topic_index <- function(package) {
  if (is.null(package)) {
    getOption("downlit.topic_index")
  } else if (devtools_loaded(package)) {
    # Use live docs for in-development packages
    topic_index_source(package)
  } else {
    topic_index_installed(package)
  }
}

topic_index_source <- function(package) {
  path <- file.path(find.package(package), "man")
  if (!file.exists(path)) {
    return(character())
  }

  rd <- package_rd(path)
  aliases <- lapply(rd, extract_alias)
  names(aliases) <- gsub("\\.Rd$", "", names(rd))

  unlist(invert_index(aliases))
}

topic_index_installed <- function(package) {
  path <- system.file("help", "aliases.rds", package = package)
  if (path == "")
    return(character())

  readRDS(path)
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
