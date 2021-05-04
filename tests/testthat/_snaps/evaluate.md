# custom infix operators are linked, but regular are not

    <span class='nv'>x</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>y</span>

---

    <span class='nv'>x</span> <span class='o'>+</span> <span class='nv'>y</span>

# ansi escapes are translated to html

    <div class='input'><span class='fu'>f</span><span class='op'>(</span><span class='op'>)</span></div>
    <div class='co'>#&gt; Output:  <span style='color: #0000BB;'>blue</span><span> </span></div><div class='co'>#&gt; Message: <span style='color: #0000BB;'>blue</span></div><div class='co'>#&gt; <span class='warning'>Warning: </span><span style='color: #0000BB;'>blue</span></div><div class='co'>#&gt; <span class='error'>Error: </span><span style='color: #0000BB;'>blue</span></div>

