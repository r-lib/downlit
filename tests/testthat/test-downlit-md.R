# Sys.setenv("RSTUDIO_PANDOC" = "")
# rmarkdown::find_pandoc(cache = FALSE)

test_that("common across multiple versions", {
  verify_output(test_path("test-downlit-md.txt"), {
    "Bare code"
    cat(downlit_md_string("`base::t`"))
    cat(downlit_md_string("```\nbase::t(1)\n```"))

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
  skip_if_not(rmarkdown::pandoc_version() < "2.10")

  verify_output(test_path("test-downlit-md-v20.txt"), {
    cat(downlit_md_string("* `base::t`"))
    cat(downlit_md_string(brio::read_lines(test_path("markdown-table.md"))))
  })
})

test_that("pandoc AST v1.21", {
  skip_if_not(rmarkdown::pandoc_version() >= "2.10")

  verify_output(test_path("test-downlit-md-v21.txt"), {
    cat(downlit_md_string("* `base::t`"))
    cat(downlit_md_string(brio::read_lines(test_path("markdown-table.md"))))
  })
})
