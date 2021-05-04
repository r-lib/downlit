# handles parsing failures gracefully

    Code
      test_evaluate("1 + ")
    Output
      <div class='input'>NA</div><div class='co'>#&gt; <span class='error'>Error: </span>&lt;text&gt;:3:0: unexpected end of input#&gt; 1: 1 + #&gt; 2: #&gt;   ^</div>

# handles basic cases

    Code
      test_evaluate("# comment")
    Output
      <div class='input'><span class='co'># comment</span></div>
    Code
      test_evaluate("message('x')")
    Output
      <div class='input'><span class='fu'><a href='https://rdrr.io/r/base/message.html'>message</a></span><span class='op'>(</span><span class='st'>'x'</span><span class='op'>)</span></div>
      <div class='co'>#&gt; x</div>
    Code
      test_evaluate("warning('x')")
    Output
      <div class='input'><span class='kw'><a href='https://rdrr.io/r/base/warning.html'>warning</a></span><span class='op'>(</span><span class='st'>'x'</span><span class='op'>)</span></div>
      <div class='co'>#&gt; <span class='warning'>Warning: </span>x</div>
    Code
      test_evaluate("stop('x', call. = FALSE)")
    Output
      <div class='input'><span class='kw'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='op'>(</span><span class='st'>'x'</span>, call. <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></div>
      <div class='co'>#&gt; <span class='error'>Error: </span>x</div>

# combines plots as needed

    Code
      f1 <- (function() plot(1))
      f2 <- (function() lines(0:2, 0:2))
      test_evaluate("f1()\nf2()\n")
    Output
      <div class='input'><span class='fu'>f1</span><span class='op'>(</span><span class='op'>)</span></div>
      <div class='input'><span class='fu'>f2</span><span class='op'>(</span><span class='op'>)</span></div>
      <div class='img'><img src='1.png' alt='' width='10' height='10' /></div><div class='input'></div>

# handles other plots

    [1] "<div class='input'><span class='fu'>f3</span><span class='op'>(</span><span class='op'>)</span></div>\n<div class='input'><span class='fu'>f4</span><span class='op'>(</span><span class='op'>)</span></div>Text for plot  4"
    attr(,"dependencies")
    list()

# ansi escapes are translated to html

    <div class='input'><span class='fu'>f</span><span class='op'>(</span><span class='op'>)</span></div>
    <div class='co'>#&gt; Output:  <span style='color: #0000BB;'>blue</span><span> </span></div><div class='co'>#&gt; Message: <span style='color: #0000BB;'>blue</span></div><div class='co'>#&gt; <span class='warning'>Warning: </span><span style='color: #0000BB;'>blue</span></div><div class='co'>#&gt; <span class='error'>Error: </span><span style='color: #0000BB;'>blue</span></div><div class='input'></div>

