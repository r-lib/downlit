article_index <- function(package) {
  if (is.null(package)) {
    getOption("downlit.article_index")
  } else if (devtools_loaded(package)) {
    # Use live docs for in-development packages
    article_index_source(package)
  } else {
    article_index_remote(package)
  }
}

article_index_source <- function(package) {
  path <- file.path(find.package(package), "vignettes")
  if (!file.exists(path)) {
    return(character())
  }

  vig_path <- dir(path, pattern = "\\.[rR]md$", recursive = TRUE)
  out_path <- gsub("\\.[rR]md$", ".html", vig_path)
  vig_name <- gsub("\\.[rR]md$", "", basename(vig_path))

  set_names(out_path, vig_name)
}

article_index_remote <- function(package) {
  # Ideally will use published metadata because that includes all articles
  # not just vignettes
  metadata <- remote_metadata(package)
  if (!is.null(metadata)) {
    return(metadata$articles)
  }

  # Otherwise, fallback to vignette index
  path <- system.file("Meta", "vignette.rds", package = package)
  if (path == "") {
    return(character())
  }

  meta <- readRDS(path)

  name <- tools::file_path_sans_ext(meta$File)
  set_names(meta$PDF, name)
}

find_article <- function(package, name) {
  index <- article_index(package)
  if (has_name(index, name)) {
    index[[name]]
  } else {
    NULL
  }
}
