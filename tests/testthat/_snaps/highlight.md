# custom infix operators are linked, but regular are not

    <span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>y</span>

---

    <span class='nv'>x</span> <span class='o'>+</span> <span class='nv'>y</span>

# ansi escapes are converted to html

    [1] "<span class='c'># <span style='color: #BB0000;'>hello</span></span>"

---

    [1] "<span class='c'># <span style='color: #BB0000;'>hello</span></span>"

# package loading is highlighted correctly if possible

    [1] "<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='s'>\"not.a.pkg\"</span><span class='o'>)</span>"

---

    [1] "<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'>not.a.pkg</span><span class='o'>)</span>"

---

    [1] "<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'>a_list</span><span class='o'>$</span><span class='nv'>pkg</span><span class='o'>)</span>"

