# Compute topic index -----------------------------------------------------
# The topic index is a character vector that maps aliases to Rd file names
# (sans extension). Memoised for performance.

topic_index <- function(package) {
  if (is.null(package)) {
    context_get2("topic_index", NULL)
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

# A helper that can warn if the topic is not found
find_rdname <- function(package, topic, warn_if_not_found = FALSE) {
  index <- topic_index(package)

  if (has_name(index, topic)) {
    index[[topic]]
  } else {
    if (warn_if_not_found) {
      warn(paste0("Failed to find topic `", topic, "`"))
    }
    NULL
  }
}

find_rdname_attached <- function(topic) {
  # Deliberately ignore base packages here; as don't want to link every
  # single function invocation
  for (package in context_get("packages")) {
    rdname <- find_rdname(package, topic)
    if (!is.null(rdname)) {
      return(list(rdname = rdname, package = package))
    }
  }
  NULL
}
