# handles parsing failures gracefully

    Code
      test_evaluate("1 + ", highlight = TRUE)
    Output
      <pre class='r-in'>1 + </pre>
      <pre class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error:</span> &lt;text&gt;:2:0: unexpected end of input
      <span class='r-pr'>#&gt;</span> 1: 1 + 
      <span class='r-pr'>#&gt;</span>    ^</pre>

# highlights when requested

    Code
      test_evaluate("1 + \n 2 + 3", highlight = TRUE)
    Output
      <pre class='r-in'><span class='fl'>1</span> <span class='op'>+</span> 
       <span class='fl'>2</span> <span class='op'>+</span> <span class='fl'>3</span></pre>
      <pre class='r-out co'><span class='r-pr'>#&gt;</span> [1] 6</pre>

# handles basic cases

    Code
      test_evaluate("# comment")
    Output
      <pre class='r-in'># comment</pre>
    Code
      test_evaluate("message('x')")
    Output
      <pre class='r-in'>message('x')</pre>
      <pre class='r-msg co'><span class='r-pr'>#&gt;</span> x</pre>
    Code
      test_evaluate("warning('x')")
    Output
      <pre class='r-in'>warning('x')</pre>
      <pre class='r-wrn co'><span class='r-pr'>#&gt;</span> <span class='warning'>Warning: </span>x</pre>
    Code
      test_evaluate("stop('x', call. = FALSE)")
    Output
      <pre class='r-in'>stop('x', call. = FALSE)</pre>
      <pre class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error:</span> x</pre>
    Code
      test_evaluate("f <- function() stop('x'); f()")
    Output
      <pre class='r-in'>f &lt;- function() stop('x'); f()</pre>
      <pre class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error in f()</span> x</pre>

# each line of input gets span

    Code
      test_evaluate("1 +\n 2 +\n 3 +\n 4 +\n 5")
    Output
      <pre class='r-in'>1 +
       2 +
       3 +
       4 +
       5</pre>
      <pre class='r-out co'><span class='r-pr'>#&gt;</span> [1] 15</pre>

# multiple code blocks are combined

    Code
      test_evaluate("x <- 1\nx <- 2\nx <- 3")
    Output
      <pre class='r-in'>x &lt;- 1
      x &lt;- 2
      x &lt;- 3</pre>

# output always gets trailing nl

    Code
      test_evaluate("cat(\"a\")\ncat(\"a\\n\")")
    Output
      <pre class='r-in'>cat("a")</pre>
      <pre class='r-out co'><span class='r-pr'>#&gt;</span> a</pre>
      <pre class='r-in'>cat("a\n")</pre>
      <pre class='r-out co'><span class='r-pr'>#&gt;</span> a</pre>

# combines plots as needed

    Code
      f1 <- (function() plot(1))
      f2 <- (function() lines(0:2, 0:2))
      test_evaluate("f1()\nf2()\n")
    Output
      <pre class='r-in'>f1()
      f2()</pre>
      <pre class='r-plt'><img src='1.png' alt='' width='10' height='10' /></pre>

---

    Code
      f3 <- (function() {
        plot(1)
        plot(2)
      })
      test_evaluate("f3()")
    Output
      <pre class='r-in'>f3()</pre>
      <pre class='r-plt'><img src='1.png' alt='' width='10' height='10' /></pre>
      <pre class='r-plt'><img src='2.png' alt='' width='10' height='10' /></pre>

# handles other plots

    <pre class='r-in'>f3()
    f4()</pre>
    <HTML for plot 4>

# ansi escapes are translated to html

    Code
      blue <- (function(x) paste0("\033[34m", x, "\033[39m"))
      f <- (function(x) {
        cat("Output: ", blue("blue"), "\n", sep = "")
        inform(paste0("Message: ", blue("blue")))
        warn(blue("blue"))
        abort(blue("blue"))
      })
      test_evaluate("f()\n")
    Output
      <pre class='r-in'>f()</pre>
      <pre class='r-out co'><span class='r-pr'>#&gt;</span> Output: <span style='color: #0000BB;'>blue</span></pre>
      <pre class='r-msg co'><span class='r-pr'>#&gt;</span> Message: <span style='color: #0000BB;'>blue</span></pre>
      <pre class='r-wrn co'><span class='r-pr'>#&gt;</span> <span class='warning'>Warning: </span><span style='color: #0000BB;'>blue</span></pre>
      <pre class='r-err co'><span class='r-pr'>#&gt;</span> <span class='error'>Error:</span> <span style='color: #0000BB;'>blue</span></pre>

