# Sys.setenv("RSTUDIO_PANDOC" = "")
# rmarkdown::find_pandoc(cache = FALSE)

test_that("common across multiple versions", {
  skip_if_not(rmarkdown::pandoc_version() > "2.0.0")

  verify_output(test_path("test-downlit-md.txt"), {
    "Bare code"
    cat(downlit_md_string("`base::t`"))

    "No transforms"
    cat(downlit_md_string("## `base::t`"))
    cat(downlit_md_string("[`base::t`](http://google.com)"))

    "Nested"
    cat(downlit_md_string("*`base::t`*"))
    cat(downlit_md_string("<span class='x'>`base::t`</span>"))
    cat(downlit_md_string("1. `base::t`"))

    "Markdown extensions not in GFM"
    cat(downlit_md_string("| `base::t`", format = "markdown"))

    md <- brio::read_lines(test_path("markdown-definition.md"))
    cat(downlit_md_string(md, "markdown"))
  })
})

test_that("pandoc AST v1.20", {
  skip_if_not(rmarkdown::pandoc_version() > "2.0.0")
  skip_if_not(rmarkdown::pandoc_version() < "2.10")

  verify_output(test_path("test-downlit-md-v20.txt"), {
    cat(downlit_md_string("* `base::t`"))
    cat(downlit_md_string("```\nbase::t(1)\n```"))
    cat(downlit_md_string(brio::read_lines(test_path("markdown-table.md"))))
  })
})

test_that("pandoc AST v1.21", {
  skip_if_not(rmarkdown::pandoc_version() >= "2.10")

  verify_output(test_path("test-downlit-md-v21.txt"), {
    cat(downlit_md_string("* `base::t`"))
    cat(downlit_md_string("```\nbase::t(1)\n```"))
    cat(downlit_md_string(brio::read_lines(test_path("markdown-table.md"))))
  })
})

test_that("Special package string gets linked", {
  # needed for eof setting on windows
  skip_if_not(rmarkdown::pandoc_version() > "2.0.0")

  expect_equal(
    downlit_md_string("`{downlit}`"),
    "[downlit](https://downlit.r-lib.org/)\n"
  )
  expect_equal(
    downlit_md_string("`{thisisrealltnotapackagename}`"),
    "`{thisisrealltnotapackagename}`\n"
  )
})

test_that("relative paths", {
  path <- tempfile("downlit")
  dir.create(path)
  withr::local_dir(path)

  writeLines("Test", "in.md")

  # Relative paths
  downlit_md_path("in.md", "out1.md")
  expect_equal(readLines("out1.md", "Test"))

  # Directory must exist
  expect_error(downlit_md_path("in.md", "bogus/out.md"))

  # Subdirectory
  dir.create("out3")
  downlit_md_path("in.md", "out3/out3.md")
  expect_equal(readLines("out3/out3.md", "Test"))

  in_path <- normalizePath("in.md", mustWork = TRUE)

  dir.create("out4")
  withr::local_dir("out4")

  # Paths are relative to current directory
  downlit_md_path(in_path, "out5.md")
  expect_equal(readLines("out5.md", "Test"))

  # Absolute paths
  out_path <- file.path(getwd(), "out6.md")
  downlit_md_path(in_path, out_path)
  expect_equal(readLines(out_path, "Test"))
})

test_that("path_abs", {
  expect_equal(path_abs("."), file.path(getwd(), "."))
  expect_equal(path_abs(".."), file.path(getwd(), ".."))
  expect_equal(path_abs("../bogus"), file.path(dirname(getwd()), "bogus"))
  expect_equal(path_abs("bogus"), file.path(getwd(), "bogus"))
  expect_equal(path_abs(getwd()), getwd())
  expect_equal(path_abs(file.path(getwd(), "bogus"), file.path(getwd(), "bogus")))
})
