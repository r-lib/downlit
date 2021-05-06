# handles parsing failures gracefully

    Code
      test_evaluate("1 + ", highlight = TRUE)
    Output
      <pre class='r-in'><code class='sourceCode r'>1 + </code></pre>
      <pre class='r-err co'><code class='sourceCode r'>#&gt; <span class='error'>Error:</span> &lt;text&gt;:2:0: unexpected end of input
      #&gt; 1: 1 + 
      #&gt;    ^</code></pre>

# highlights when requested

    Code
      test_evaluate("1 + \n 2 + 3", highlight = TRUE)
    Output
      <pre class='r-in'><code class='sourceCode r'><span class='fl'>1</span> <span class='op'>+</span> 
       <span class='fl'>2</span> <span class='op'>+</span> <span class='fl'>3</span></code></pre>
      <pre class='r-out co'><code class='sourceCode r'>#&gt; [1] 6</code></pre>

# handles basic cases

    Code
      test_evaluate("# comment")
    Output
      <pre class='r-in'><code class='sourceCode r'># comment</code></pre>
    Code
      test_evaluate("message('x')")
    Output
      <pre class='r-in'><code class='sourceCode r'>message('x')</code></pre>
      <pre class='r-msg co'><code class='sourceCode r'>#&gt; x</code></pre>
    Code
      test_evaluate("warning('x')")
    Output
      <pre class='r-in'><code class='sourceCode r'>warning('x')</code></pre>
      <pre class='r-wrn co'><code class='sourceCode r'>#&gt; <span class='warning'>Warning: </span>x</code></pre>
    Code
      test_evaluate("stop('x', call. = FALSE)")
    Output
      <pre class='r-in'><code class='sourceCode r'>stop('x', call. = FALSE)</code></pre>
      <pre class='r-err co'><code class='sourceCode r'>#&gt; <span class='error'>Error:</span> x</code></pre>
    Code
      test_evaluate("f <- function() stop('x'); f()")
    Output
      <pre class='r-in'><code class='sourceCode r'>f &lt;- function() stop('x'); f()</code></pre>
      <pre class='r-err co'><code class='sourceCode r'>#&gt; <span class='error'>Error in f()</span> x</code></pre>

# each line of input gets span

    Code
      test_evaluate("1 +\n 2 +\n 3 +\n 4 +\n 5")
    Output
      <pre class='r-in'><code class='sourceCode r'>1 +
       2 +
       3 +
       4 +
       5</code></pre>
      <pre class='r-out co'><code class='sourceCode r'>#&gt; [1] 15</code></pre>

# multiple code blocks are combined

    Code
      test_evaluate("x <- 1\nx <- 2\nx <- 3")
    Output
      <pre class='r-in'><code class='sourceCode r'>x &lt;- 1
      x &lt;- 2
      x &lt;- 3</code></pre>

# output always gets trailing nl

    Code
      test_evaluate("cat(\"a\")\ncat(\"a\\n\")")
    Output
      <pre class='r-in'><code class='sourceCode r'>cat("a")</code></pre>
      <pre class='r-out co'><code class='sourceCode r'>#&gt; a</code></pre>
      <pre class='r-in'><code class='sourceCode r'>cat("a\n")</code></pre>
      <pre class='r-out co'><code class='sourceCode r'>#&gt; a</code></pre>

# combines plots as needed

    Code
      f1 <- (function() plot(1))
      f2 <- (function() lines(0:2, 0:2))
      test_evaluate("f1()\nf2()\n")
    Output
      <pre class='r-in'><code class='sourceCode r'>f1()
      f2()</code></pre>
      <pre class='r-plt'><code class='sourceCode r'><img src='1.png' alt='' width='10' height='10' /></code></pre>

---

    Code
      f3 <- (function() {
        plot(1)
        plot(2)
      })
      test_evaluate("f3()")
    Output
      <pre class='r-in'><code class='sourceCode r'>f3()</code></pre>
      <pre class='r-plt'><code class='sourceCode r'><img src='1.png' alt='' width='10' height='10' /></code></pre>
      <pre class='r-plt'><code class='sourceCode r'><img src='2.png' alt='' width='10' height='10' /></code></pre>

# handles other plots

    <pre class='r-in'><code class='sourceCode r'>f3()
    f4()</code></pre>
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
      <pre class='r-in'><code class='sourceCode r'>f()</code></pre>
      <pre class='r-out co'><code class='sourceCode r'>#&gt; Output: <span style='color: #0000BB;'>blue</span></code></pre>
      <pre class='r-msg co'><code class='sourceCode r'>#&gt; Message: <span style='color: #0000BB;'>blue</span></code></pre>
      <pre class='r-wrn co'><code class='sourceCode r'>#&gt; <span class='warning'>Warning: </span><span style='color: #0000BB;'>blue</span></code></pre>
      <pre class='r-err co'><code class='sourceCode r'>#&gt; <span class='error'>Error:</span> <span style='color: #0000BB;'>blue</span></code></pre>

