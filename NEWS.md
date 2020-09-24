# downlit (development version)

* Autolinking guesses reference and article urls for pkgdown sites that haven't
  set url (@krlmlr, #44).

* R6 classes are autolinked when a new object is created i.e. in 
  `r6_object$new()`, `r6_object` will link to the docs of `r6_object` if found
  (#59, @maelle)

* R6 methods are no longer autolinked as if they were functions of the same name (#54, @maelle).

* `downlit_html_path()` has a more flexible XPath identifying R code blocks, and 
a `classes` argument (#53, @maelle, @cderv)

* `classes_pandoc()` and `classes_chroma()` have been tweaked to generate
  better class names.

* Trailing `/` are no longer stripped from URLs (#45, @krlmlr).

* Removed extra newline in `<pre>` output (#42, @krlmlr).

# downlit 0.1.0

* Added a `NEWS.md` file to track changes to the package.
