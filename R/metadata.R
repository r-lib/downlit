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
    custom_repos <- repos[names(repos) != "CRAN"]

    # Check your custom repos for a URL entry, returning NA_character_ if nothing is found
    desc_url <- repo_packages_urls(package = package, repos = custom_repos)


    # If nothing is found, move to the next step (checking CRAN)
    if (is.na(desc_url)) {
      # Check CRAN for the URL
      desc_url <- cran_description_urls(package)
      # If there's no URL in the CRAN package, return an empty character
      if (is.na(desc_url)) {
        return(character())
      }
    }
    # If the package is installed, check the URL field from that
  } else {
    desc_url <- read.dcf(path, fields = "URL")[[1]]
    # If there's no URL field, return an empty character
    if (is.na(desc_url)) {
      return(character())
    }
  }
  parse_urls(desc_url)
}

parse_urls <- function(x) {
  urls <- trimws(strsplit(trimws(x), "[,\\s]+", perl = TRUE)[[1]])
  urls <- urls[grepl("^http", urls)]

  sub_special_cases(urls)
}

cran_description_urls <- function(package) {
  pkgs <- as.data.frame(tools::CRAN_package_db())

  pkg_url <- unlist(strsplit(pkgs[pkgs[["Package"]] == package,"URL"], ", "))

  if (is.null(pkg_url)){
    return(NA_character_)
  } else {
    pkg_url
  }
}

repo_packages_urls <- function(package, repos) {
  urls <- purrr::map(
    repos, ~check_repo_for_package_url(repo = .x, package = package)
  )
  urls <- purrr::compact(urls)
  if (length(urls) == 0) {
    return(NA_character_)
  }
  urls
}

check_repo_for_package_url <- function(repo, package) {
  pkgs <- fetch_repo_packages_file(repo)
  pkg <- pkgs[pkgs[["Package"]] == package,"URL"]
  if (is.null(pkg)) {
    return(NULL)
  }
  unlist(strsplit(pkg, ", "))
}

fetch_repo_packages_file <- function(repo) {

  available.packages(contrib.url(repo), fields = "URL")

  as.data.frame(readRDS(tmp_packages))
}

# All rOpenSci repositories have a known pkgdown URL.
# Todo: could generalise this concept for other orgs.
sub_special_cases <- function(urls){
  sub("^https?://github.com/ropensci/(\\w+).*$", "https://docs.ropensci.org/\\1", urls)
}
