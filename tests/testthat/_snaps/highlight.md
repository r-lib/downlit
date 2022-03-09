# custom infix operators are linked, but regular are not

    <span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>y</span>

---

    <span class='nv'>x</span> <span class='o'>+</span> <span class='nv'>y</span>

# ansi escapes are converted to html

    [1] "<span class='c'># <span style='color: #BB0000;'>hello</span></span>"

---

    [1] "<span class='c'># <span style='color: #BB0000;'>hello</span></span>"

# New R pipes get highlighted and not linked

    Code
      highlight("1 |> x => fun(2, x)")
    Output
      [1] "<span class='m'>1</span> <span class='o'>|&gt;</span> <span class='nv'>x</span> <span class='o'>=&gt;</span> <span class='nf'>fun</span><span class='o'>(</span><span class='m'>2</span>, <span class='nv'>x</span><span class='o'>)</span>"

# placeholder in R pipe gets highlighted and not linked

    Code
      highlight("1:10 |> mean(x = _)")
    Output
      [1] "<span class='m'>1</span><span class='o'>:</span><span class='m'>10</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='o'>_</span><span class='o'>)</span>"

