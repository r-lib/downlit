# custom infix operators are linked, but regular are not

    <span><span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>y</span></span>

---

    <span><span class='nv'>x</span> <span class='o'>+</span> <span class='nv'>y</span></span>

# syntax can span multiple lines

    Code
      cat(highlight("f(\n\n)"))
    Output
      <span><span class='nf'>f</span><span class='o'>(</span></span>
      <span></span>
      <span><span class='o'>)</span></span>

---

    Code
      cat(highlight("'\n\n'"))
    Output
      <span><span class='s'>'</span></span>
      <span><span class='s'></span></span>
      <span><span class='s'>'</span></span>

# ansi escapes are converted to html

    [1] "<span><span class='c'># <span style='color: #BB0000;'>hello</span></span></span>"

---

    [1] "<span><span class='c'># <span style='color: #BB0000;'>hello</span></span></span>"

# placeholder in R pipe gets highlighted and not linked

    Code
      highlight("1:10 |> mean(x = _)", classes = classes_pandoc())
    Output
      [1] "<span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>10</span> <span class='op'>|&gt;</span> <span class='fu'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='op'>(</span>x <span class='op'>=</span> <span class='va'>_</span><span class='op'>)</span></span>"

