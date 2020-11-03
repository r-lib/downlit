# ansi escapes are converted to html

    Code
      highlight("# \033[31mhello\033[m")
    Output
      [1] "<span class='c'># <span style='color: #BB0000;'>hello</span></span>"

---

    Code
      highlight("# \u2029[31mhello\u2029[m")
    Output
      [1] "<span class='c'># <span style='color: #BB0000;'>hello</span></span>"

