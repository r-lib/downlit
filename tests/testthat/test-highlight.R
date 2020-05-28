test_that("can link to external topics that use ::", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("test")

  verify_output(test_path("test-highlight.txt"), {
    "explicit package"
    cat(highlight_text("MASS::addterm()"))
    cat(highlight_text("MASS::addterm"))
    cat(highlight_text("?MASS::addterm"))

    "implicit package"
    register_attached_packages("MASS")
    cat(highlight_text("addterm()"))
    cat(highlight_text("median()")) # base

    "local package"
    cat(highlight_text("test::foo()"))
  })
})

test_that("can parse code with carriage returns", {
  scoped_package_context("test")

  expect_equal(
    highlight_text("1\r\n2"),
    "<span class='fl'>1</span>\n<span class='fl'>2</span>"
  )
})

test_that("unparsed code is still escaped", {
  scoped_package_context("test")

  expect_equal(highlight_text("<"), "&lt;")
})
