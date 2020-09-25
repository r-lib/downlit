remote_urls <- function(package) {
  local <- getOption("downlit.local_packages")
  if (has_name(local, package)) {
    base_url <- local[[package]]
    list(
      reference = file.path(base_url, "reference"),
      article = file.path(base_url, "articles")
    )
  } else {
    remote_metadata(package)$urls
  }
}

remote_package_reference_url <- function(package) {
  remote_urls(package)$reference
}
remote_package_article_url <- function(package) {
  remote_urls(package)$article
}

# Retrieve remote metadata ------------------------------------------------

remote_metadata <- function(package) {
  # Is the metadata installed with the package?
  meta <- local_metadata(package)
  if (!is.null(meta)) {
    return(meta)
  }

  # Otherwise, look in package websites, caching since this is a slow operation
  tempdir <- Sys.getenv("RMARKDOWN_PREVIEW_DIR", unset = tempdir())
  dir.create(file.path(tempdir, "downlit"), showWarnings = FALSE)
  cache_path <- file.path(tempdir, "downlit", package)

  if (file.exists(cache_path)) {
    readRDS(cache_path)
  } else {
    meta <- remote_metadata_slow(package)
    saveRDS(meta, cache_path)
    meta
  }
}

local_metadata <- function(package) {
  local_path <- system.file("pkgdown.yml", package = package)
  if (local_path == "") {
    NULL
  } else {
    yaml::read_yaml(local_path)
  }
}

remote_metadata_slow <- function(package) {
  urls <- package_urls(package)

  for (url in urls) {
    url <- paste0(url, "/pkgdown.yml")
    yaml <- tryCatch(fetch_yaml(url), error = function(e) NULL)
    if (is.list(yaml)) {
      if (has_name(yaml, "articles")) {
        yaml$articles <- unlist(yaml$articles)
      }
      if (!has_name(yaml, "urls")) {
        base_url <- dirname(url)
        yaml$urls <- list(
          reference = paste0(base_url, "/reference"),
          article = paste0(base_url, "/articles")
        )
      }
      return(yaml)
    }
  }

  NULL
}

fetch_yaml <- function(url) {
  path <- tempfile()
  if (suppressWarnings(utils::download.file(url, path, quiet = TRUE) != 0)) {
    abort("Failed to download")
  }

  yaml::read_yaml(path)
}

# Helpers -----------------------------------------------------------------

package_urls <- function(package) {
  path <- system.file("DESCRIPTION", package = package)
  if (path == "") {
    return(character())
  }

  desc_url <- read.dcf(path, fields = "URL")[[1]]
  if (is.na(desc_url)) {
    return(character())
  }
  parse_urls(desc_url)
}

parse_urls <- function(x) {
  urls <- trimws(strsplit(trimws(x), "[,\\s]+", perl = TRUE)[[1]])
  urls <- urls[grepl("^http", urls)]

  sub_special_cases(urls)
}

# All rOpenSci repositories have a known pkgdown URL.
# Todo: could generalise this concept for other orgs.
sub_special_cases <- function(urls){
  sub("^https?://github.com/ropensci/(\\w+).*$", "https://docs.ropensci.org/\\1", urls)
}
