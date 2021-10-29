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

  # This call may warn if the URL doesn't have a final LF;
  # see pkgdown issue #1419
  suppressWarnings(yaml::read_yaml(path))
}

# Helpers -----------------------------------------------------------------

package_urls <- function(package, repos = getOption("repos")) {
  # Finding the package URL:
  #
  # 1. Check if the package is installed and use the DESCRIPTION
  # 2. Then look for the package in the 'repos' repos and find the DESCRIPTION
  # 2.5. Maybe try using a custom function here that we could register?
  # 3. Then look for the package on CRAN and look for the DESCRIPTION
  path <- system.file("DESCRIPTION", package = package)

  # If the package isn't installed, try repositories in 'repos', then CRAN
  if (path == "") {

    # Check the user's repos - the PACKAGE file will need to have the URL entry
    # otherwise we'd have to download the whole package just to get the DESCRIPTION

    # We try and remove CRAN from the list to check here but it's not the end of the world
    # if it stays because the CRAN PACKAGES files don't include the URL entry, so we won't get
    # anything back - it's just a bit of a waste of effort
    # What happens if the custom repo is called something like "mycran"?
    custom_repos <- repos[!grepl("(\\bcran\\b)|(\\bCRAN\\b)", repos)]

    # Check your custom repos for a URL entry, returning NA_character_ if nothing is found
    url <- url_from_custom_repo(package = package, repos = custom_repos)


    # If nothing is found, move to the next step (checking CRAN)
    if (length(url) == 0) {
        url <- url_from_cran(package)
      }
  } else {
    # If the package is installed, check the URL field from that
    url <- url_from_desc(path)
  }
  parse_urls(url)
}

parse_urls <- function(x) {
  # This allows parse_urls to deal with any return from checking a data.frame for a URL
  # If there's no package, you get an empty character(), if there's package but no URL,
  # you get an NA - this can deal with both
  if (length(x) == 0) {
    return(character())
  }
  urls <- trimws(strsplit(trimws(x), "[,\\s]+", perl = TRUE)[[1]])
  urls <- urls[grepl("^http", urls)]

  sub_special_cases(urls)
}

url_from_desc <- function(path) {
  read.dcf(path, fields = "URL")[[1]]
}

url_from_cran <- function(package) {
  pkgs <- memo_fetch_cran_packages()
  pkgs[pkgs[["Package"]] == package,"URL"]
}

url_from_custom_repo <- function(package, repos) {
  urls <- lapply(
    repos, check_repo_for_package_url, package = package
  )
  unlist(urls)
}

check_repo_for_package_url <- function(repo, package) {
  pkgs <- memo_fetch_repo_packages(repo)
  url <- pkgs[pkgs[["Package"]] == package,"URL"]
  fix_filtered_url_field(url)
}



#' When filtering a df with package information and trying to get the URL,
#' you'll get different return values:
#' If the package exists, but there's no URL, you'll get NA
#' If the package doesn't exist at all, you'll get character()
#' This function just levels things out so it's easier to check
fix_filtered_url_field <- function(x) {
  if (length(x) == 0) {
    return(character())
  }
  if (is.na(x)) {
    return(character())
  }
  x
}

fetch_repo_packages <- function(repo) {
  as.data.frame(utils::available.packages(utils::contrib.url(repo), fields = "URL"))
}

fetch_cran_packages <- function() {
  as.data.frame(tools::CRAN_package_db())
}

# All rOpenSci repositories have a known pkgdown URL.
# Todo: could generalise this concept for other orgs.
sub_special_cases <- function(urls){
  sub("^https?://github.com/ropensci/(\\w+).*$", "https://docs.ropensci.org/\\1", urls)
}
