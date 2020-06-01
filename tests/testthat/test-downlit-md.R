test_that("test basic recursion", {
  verify_output(test_path("test-downlit-md.txt"), {
    "Bare code"
    cat(downlit_md_string("`base::t`"))
    cat(downlit_md_string("```\nbase::t(1)\n```"))

    "Nested in inline"
    cat(downlit_md_string("*`base::t`*"))
    cat(downlit_md_string("<span class='x'>`base::t`</span>"))

    "Nested in block"
    cat(downlit_md_string("* `base::t`"))
    cat(downlit_md_string("| `base::t`"))
    cat(downlit_md_string("1. `base::t`"))

    "Complex blocks"
    cat(downlit_md_string(brio::read_lines(test_path("markdown-table.md"))))
    cat(downlit_md_string(brio::read_lines(test_path("markdown-definition.md"))))

    "No transforms"
    cat(downlit_md_string("## `base::t`"))
    cat(downlit_md_string("[`base::t`](http://google.com)"))

  })
})
