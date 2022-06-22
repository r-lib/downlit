test_that("can link to external topics that use ::", {
  local_options(
    "downlit.package" = "test",
    "downlit.topic_index" = c(foo = "bar")
  )

  verify_output(test_path("test-highlight.txt"), {
    "explicit package"
    cat(highlight("MASS::addterm()"))
    cat(highlight("MASS::addterm"))
    cat(highlight("?MASS::addterm"))

    "implicit package"
    cat(highlight("library(MASS)"))
    cat(highlight("addterm()"))
    cat(highlight("median()")) # base

    "local package"
    cat(highlight("test::foo()"))

    "operators / special syntax"
    cat(highlight("1 + 2 * 3"))
    cat(highlight("x %in% y"))
    cat(highlight("if (FALSE) 1"))
    cat(highlight("f <- function(x = 'a') {}"))

    "ansi escapes + unicode"
    cat(highlight("# \033[34mblue\033[39m"))
  })
})

test_that("don't link to non-functions with matching topic name", {
  local_options("downlit.attached" = "MASS")

  expect_equal(
    highlight("abbey()"),
    "<span><span class='nf'>abbey</span><span class='o'>(</span><span class='o'>)</span></span>"
  )
})

test_that("unicode is not mangled", {
  skip_on_os("windows")

  expect_equal(highlight("# \u2714"), "<span><span class='c'># \u2714</span></span>")
})

test_that("custom infix operators are linked, but regular are not", {
  expect_snapshot_output(cat(highlight("x %in% y\n")))
  expect_snapshot_output(cat(highlight("x + y\n")))
})

test_that("distinguish logical and numeric",{
  expect_equal(highlight("TRUE"), "<span><span class='kc'>TRUE</span></span>")
  expect_equal(highlight("FALSE"), "<span><span class='kc'>FALSE</span></span>")
  expect_equal(highlight("1"), "<span><span class='m'>1</span></span>")
})
test_that("can parse code with carriage returns", {
  lines <- strsplit(highlight("1\r\n2"), "\n")[[1]]

  expect_equal(lines[[1]], "<span><span class='m'>1</span></span>")
  expect_equal(lines[[2]], "<span><span class='m'>2</span></span>")
})

test_that("can highlight code in Latin1", {
  x <- "'\xfc'"
  Encoding(x) <- "latin1"

  out <- highlight(x)
  expect_equal(Encoding(out), "UTF-8")
  expect_equal(out, "<span><span class='s'>'\u00fc'</span></span>")
})

test_that("syntax can span multiple lines", {
  expect_snapshot(cat(highlight("f(\n\n)")))
  expect_snapshot(cat(highlight("'\n\n'")))
})

test_that("code with tab is not mangled", {
  expect_equal(highlight("\tf()"), "<span>  <span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span></span>")
  expect_equal(highlight("'\t'"), "<span><span class='s'>'  '</span></span>")
})

test_that("unparsable code returns NULL", {
  expect_equal(highlight("<"), NA_character_)
  # but pure comments still highlighted
  expect_equal(
    highlight("#"),
    "<span><span class='c'>#</span></span>"
  )
})

test_that("R6 methods don't get linked", {
  expect_equal(
    highlight("x$get()"),
    "<span><span class='nv'>x</span><span class='o'>$</span><span class='nf'>get</span><span class='o'>(</span><span class='o'>)</span></span>"
  )

  expect_equal(
    highlight("x$library()"),
    "<span><span class='nv'>x</span><span class='o'>$</span><span class='kr'>library</span><span class='o'>(</span><span class='o'>)</span></span>"
  )

})

test_that("R6 instantiation gets linked", {
  expect_equal(
    highlight("mean$new()"),
    "<span><span class='nv'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>$</span><span class='nf'>new</span><span class='o'>(</span><span class='o'>)</span></span>"
  )
  # But not new itself
  expect_equal(
    highlight("new()"),
    "<span><span class='nf'>new</span><span class='o'>(</span><span class='o'>)</span></span>"
  )
})

test_that("ansi escapes are converted to html", {
  expect_snapshot_output(highlight("# \033[31mhello\033[m"))
  expect_snapshot_output(highlight("# \u2029[31mhello\u2029[m"))
})

test_that("can highlight vers long strings", {
  val <- paste0(rep('very', 200), collapse = " ")
  out <- downlit::highlight(sprintf("'%s'", val))
  expect_equal(out, paste0("<span><span class='s'>'", val, "'</span></span>"))
})

test_that("placeholder in R pipe gets highlighted and not linked", {
  skip_if_not(getRversion() >= 4.2, message = "Pipes are available from R 4.1")
  expect_snapshot(highlight("1:10 |> mean(x = _)", classes = classes_pandoc()))
})
