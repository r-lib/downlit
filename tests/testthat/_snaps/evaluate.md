# handles parsing failures gracefully

    Code
      test_evaluate("1 + ")
    Output
      <span class='input'>NA</span><span class='co'>#&gt; <span class='error'>Error: </span>&lt;text&gt;:3:0: unexpected end of input
      #&gt; 1: 1 + 
      #&gt; 2: 
      #&gt;   ^</span>

# handles basic cases

    Code
      test_evaluate("# comment")
    Output
      <span class='input'><span class='co'># comment</span></span>
    Code
      test_evaluate("message('x')")
    Output
      <span class='input'><span class='fu'><a href='https://rdrr.io/r/base/message.html'>message</a></span><span class='op'>(</span><span class='st'>'x'</span><span class='op'>)</span></span>
      <span class='co'>#&gt; x</span>
    Code
      test_evaluate("warning('x')")
    Output
      <span class='input'><span class='kw'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span><span class='op'>(</span><span class='st'>'x'</span><span class='op'>)</span></span>
      <span class='co'>#&gt; <span class='warning'>Warning: </span>x</span>
    Code
      test_evaluate("stop('x', call. = FALSE)")
    Output
      <span class='input'><span class='kw'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='op'>(</span><span class='st'>'x'</span>, call. <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span>
      <span class='co'>#&gt; <span class='error'>Error: </span>x</span>

# combines plots as needed

    Code
      f1 <- (function() plot(1))
      f2 <- (function() lines(0:2, 0:2))
      test_evaluate("f1()\nf2()\n")
    Output
      <span class='input'><span class='fu'>f1</span><span class='op'>(</span><span class='op'>)</span></span>
      <span class='input'><span class='fu'>f2</span><span class='op'>(</span><span class='op'>)</span></span>
      <span class='img'><img src='1.png' alt='' width='10' height='10' /></span><span class='input'></span>

# handles other plots

    [1] "<span class='input'><span class='fu'>f3</span><span class='op'>(</span><span class='op'>)</span></span>\n<span class='input'><span class='fu'>f4</span><span class='op'>(</span><span class='op'>)</span></span>Text for plot  4"
    attr(,"dependencies")
    list()

# ansi escapes are translated to html

    <span class='input'><span class='fu'>f</span><span class='op'>(</span><span class='op'>)</span></span>
    <span class='co'>#&gt; Output:  <span style='color: #0000BB;'>blue</span><span> </span></span>
    <span class='co'>#&gt; Message: <span style='color: #0000BB;'>blue</span></span>
    <span class='co'>#&gt; <span class='warning'>Warning: </span><span style='color: #0000BB;'>blue</span></span>
    <span class='co'>#&gt; <span class='error'>Error: </span><span style='color: #0000BB;'>blue</span></span>
    <span class='input'></span>

