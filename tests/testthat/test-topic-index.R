test_that("NULL package uses context", {
  local_options("downlit.topic_index" = c(foo = "bar"))
  expect_equal(topic_index(NULL), c(foo = "bar"))
})

test_that("can capture index from in-development package", {
  local_devtools_package(test_path("index"))
  expect_equal(topic_index("index"), c("a" = "a", "b" = "b", "c" = "b"))
})

test_that("can capture index from installed package", {
  skip_on_cran()

  grid_index <- topic_index("grid")
  expect_equal(grid_index[["unit"]], "unit")
})


# find_rdname -------------------------------------------------------------

test_that("can find topic in specified package", {
  skip_on_cran()

  grid_index <- topic_index("grid")
  expect_equal(find_rdname("grid", "unit"), "unit")
  expect_equal(find_rdname("grid", "DOESNOTEXIST"), NULL)
})

test_that("can find topic in attached packages", {
  local_options("downlit.attached" = "grid")
  expect_equal(find_rdname_attached("unit"), list(rdname = "unit", package = "grid"))
  expect_equal(find_rdname_attached("DOESNOTEXIST"), NULL)
})
