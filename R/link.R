#' Automatically link inline code
#'
#' @param text String of code to highlight and link.
#' @return
#'   If `text` is linkable, an HTML link for `autolink()`, and or just
#'   the URL for `autolink_url()`. Both return `NA` if the text is not
#'   linkable.
#' @inheritSection highlight Options
#' @export
#' @examples
#' autolink("stats::median()")
#' autolink("vignette('grid', package = 'grid')")
#'
#' autolink_url("stats::median()")
autolink <- function(text) {
  href <- autolink_url(text)
  if (identical(href, NA_character_)) {
    return(NA_character_)
  }

  paste0("<a href='", href, "'>", escape_html(text), "</a>")
}


#' @export
#' @rdname autolink
autolink_url <- function(text) {
  expr <- safe_parse(text)
  if (length(expr) == 0) {
    return(NA_character_)
  }

  href_expr(expr[[1]])
}

# Helper for testing
href_expr_ <- function(expr, ...) {
  href_expr(substitute(expr), ...)
}

href_expr <- function(expr) {
  if (!is_call(expr)) {
    return(NA_character_)
  }

  fun <- expr[[1]]
  if (is_call(fun, "::", n = 2)) {
    pkg <- as.character(fun[[2]])
    fun <- fun[[3]]
  } else {
    pkg <- NULL
  }

  if (!is_symbol(fun))
    return(NA_character_)

  fun_name <- as.character(fun)
  n_args <- length(expr) - 1

  if (fun_name %in% c("library", "require", "requireNamespace")) {
    if (n_args == 1 && is.null(names(expr))) {
      pkg <- as.character(expr[[2]])
      topic <- href_package(pkg)
      if (is.na(topic)) {
        href_topic(fun_name)
      } else {
        topic
      }
    } else {
      href_topic(fun_name)
    }
  } else if (fun_name == "vignette") {
    if (length(expr) == 1) {
      return(href_topic(fun_name))
    }
    expr <- call_standardise(expr)
    topic_ok <- is.character(expr$topic)
    package_ok <- is.character(expr$package) || is.null(expr$package)
    if (topic_ok && package_ok) {
      href_article(expr$topic, expr$package)
    } else {
      NA_character_
    }
  } else if (fun_name == "?") {
    if (n_args == 1) {
      topic <- expr[[2]]
      if (is_call(topic, "::")) {
        # ?pkg::x
        href_topic(as.character(topic[[3]]), as.character(topic[[2]]))
      } else if (is_symbol(topic) || is_string(topic)) {
        # ?x
        href_topic(as.character(expr[[2]]))
      } else {
        NA_character_
      }
    } else if (n_args == 2) {
      # package?x
      href_topic(paste0(expr[[3]], "-", expr[[2]]))
    }
  } else if (fun_name == "help") {
    expr <- call_standardise(expr)
    if (is_help_literal(expr$topic) && is_help_literal(expr$package)) {
      href_topic(as.character(expr$topic), as.character(expr$package))
    } else if (is_help_literal(expr$topic) && is.null(expr$package)) {
      href_topic(as.character(expr$topic))
    } else if (is.null(expr$topic) && is_help_literal(expr$package)) {
      href_package_ref(as.character(expr$package))
    } else {
      NA_character_
    }
  } else if (fun_name == "::") {
    href_topic(as.character(expr[[3]]), as.character(expr[[2]]))
  } else if (n_args == 0) {
    href_topic(fun_name, pkg)
  } else {
    NA_character_
  }
}

is_help_literal <- function(x) is_string(x) || is_symbol(x)

# Topics ------------------------------------------------------------------

#' Generate url for topic/article
#'
#' @param topic,article Topic/article name
#' @param package Optional package name
#' @keywords internal
#' @export
#' @return URL topic or article; `NA` if can't find one.
#' @examples
#' href_topic("t")
#' href_topic("DOESN'T EXIST")
href_topic <- function(topic, package = NULL) {
  if (is_package_local(package)) {
    href_topic_local(topic)
  } else {
    href_topic_remote(topic, package)
  }
}

is_package_local <- function(package) {
  if (is.null(package)) {
    return(TRUE)
  }
  cur <- getOption("downlit.package")
  if (is.null(cur)) {
    return(FALSE)
  }

  package == cur
}

href_topic_local <- function(topic) {
  rdname <- find_rdname(NULL, topic)
  if (is.null(rdname)) {
    # Check attached packages
    loc <- find_rdname_attached(topic)
    if (is.null(loc)) {
      return(NA_character_)
    } else {
      return(href_topic_remote(topic, loc$package))
    }
  }

  if (rdname == "reexports") {
    return(href_topic_reexported(topic, getOption("downlit.package")))
  }

  cur_rdname <- getOption("downlit.rdname", "")
  if (rdname == cur_rdname) {
    return(NA_character_)
  }

  if (cur_rdname != "") {
    paste0(rdname, ".html")
  } else {
    paste0(getOption("downlit.topic_path"), rdname, ".html")
  }
}

href_topic_remote <- function(topic, package) {
  rdname <- find_rdname(package, topic)
  if (is.null(rdname)) {
    return(NA_character_)
  }

  if (rdname == "reexports") {
    return(href_topic_reexported(topic, package))
  }

  paste0(href_package_ref(package), "/", rdname, ".html")
}

# If it's a re-exported function, we need to work a little harder to
# find out its source so that we can link to it.
href_topic_reexported <- function(topic, package) {
  ns <- ns_env(package)
  exports <- .getNamespaceInfo(ns, "exports")

  if (!env_has(exports, topic)) {
    NA_character_
  } else {
    obj <- env_get(ns, topic, inherit = TRUE)
    package <- find_reexport_source(obj, ns, topic)
    href_topic_remote(topic, package)
  }
}

find_reexport_source <- function(obj, ns, topic) {
  if (is.primitive(obj)) {
    # primitive functions all live in base
    "base"
  } else if (is.function(obj)) {
    ## For functions, we can just take their environment.
    ns_env_name(get_env(obj))
  } else {
    ## For other objects, we need to check the import env of the package,
    ## to see where 'topic' is coming from. The import env has redundant
    ## information. It seems that we just need to find a named list
    ## entry that contains `topic`.
    imp <- getNamespaceImports(ns)
    imp <- imp[names(imp) != ""]
    wpkgs <- vapply(imp, `%in%`, x = topic, FUN.VALUE = logical(1))

    if (!any(wpkgs)) {
      return(NA_character_)
    }
    pkgs <- names(wpkgs)[wpkgs]
    # Take the last match, in case imports have name clashes.
    pkgs[[length(pkgs)]]
  }
}

# Articles ----------------------------------------------------------------

#' @export
#' @rdname href_topic
href_article <- function(article, package = NULL) {
  if (is_package_local(package)) {
    path <- find_article(NULL, article)
    if (!is.null(path)) {
      return(paste0(getOption("downlit.article_path"), path))
    }
  }

  if (is.null(package)) {
    package <- find_vignette_package(article)
    if (is.null(package)) {
      return(NA_character_)
    }
  }

  path <- find_article(package, article)
  if (is.null(path)) {
    return(NA_character_)
  }

  base_url <- remote_package_article_url(package)
  if (is.null(base_url)) {
    paste0("https://cran.rstudio.com/web/packages/", package, "/vignettes/", path)
  } else {
    paste0(base_url, "/", path)
  }
}

# Try to figure out package name from attached packages
find_vignette_package <- function(x) {
  for (pkg in getOption("downlit.attached")) {
    if (!is_installed(pkg)) {
      next
    }

    info <- tools::getVignetteInfo(pkg)

    if (x %in% info[, "Topic"]) {
      return(pkg)
    }
  }

  NULL
}

# Packages ----------------------------------------------------------------

href_package <- function(package) {
  urls <- package_urls(package)
  if (length(urls) == 0) {
    NA_character_
  } else {
    urls[[1]]
  }
}

href_package_ref <- function(package) {
  reference_url <- remote_package_reference_url(package)

  if (!is.null(reference_url)) {
    reference_url
  } else {
    # Fall back to rdrr.io
    package_link_function <- get_package_ref_function()
    package_link_function(package)
  }
}

rdrr_package_ref <- function(package) {
  if (is_base_package(package)) {
    paste0("https://rdrr.io/r/", package)
  } else {
    paste0("https://rdrr.io/pkg/", package, "/man")
  }
}

#' Get or register the default package reference function
#'
#' @describeIn register_package_ref_function Register the default package reference function
#' @description Register a function that will be used to generate the package reference URL if a remote URL for the package cannot be found.
#' By default, the `rdrr_package_ref()` function is used, relying the [https://rdrr.io](https://rdrr.io) website.
#' @param fn Function to be used to generate the package reference URL. The function should accept a single
#' parameter (preferably `package`) and return a character string of length one.
#' @examples
#' new_ref_function <- function(package) {
#'    paste0("https://rdocumentationsite/", package)
#' }
#' # Register a custom function
#' register_package_ref_function(new_ref_function)
#' get_package_ref_function()
#' autolink("stats::median()")
#'
#' # Reset the function back to the default
#' reset_package_ref_function()
#' get_package_ref_function()
#' autolink("stats::median()")
#' @export
#' @return `register_package_ref_function()` returns NULL invisibly.
register_package_ref_function <- function(fn) {
  assign(x = "package_ref_function", value = fn, envir = register)
  invisible(NULL)
}

#' @describeIn register_package_ref_function Get the currently registered default package reference function
#' @return `get_package_ref_function()` will return the currently registered function. By default, or if the registered function has been unset, this will return the
#' `rdrr_package_ref()` function which relies on the [https://rdrr.io](https://rdrr.io) site.
#' @export
get_package_ref_function <- function() {
  if (exists("package_ref_function", envir = register)) {
    get("package_ref_function", envir = register)
  } else {
    warn("Could not find a registered package reference function.\n
         Use the `register_package_ref_function() to register a function to be used when a package URL cannot be found.")
    rdrr_package_ref()
  }
}

#' @describeIn register_package_ref_function Resets the default package reference function to the `rdrr_package_ref()` function that
#' relies on the [https://rdrr.io](https://rdrr.io) site.
#' @return `reset_package_ref_function()` returns NULL invisibly.
#' @export
reset_package_ref_function <- function() {
  register_package_ref_function(rdrr_package_ref)
}

is_base_package <- function(x) {
  x %in% c(
    "base", "compiler", "datasets", "graphics", "grDevices", "grid",
    "methods", "parallel", "splines", "stats", "stats4", "tcltk",
    "tools", "utils"
  )
}
