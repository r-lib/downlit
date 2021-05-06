# highlight all pre inside div.downlit

    <body>
      <div class="downlit">
        <pre class="downlit sourceCode r">
    <code class="sourceCode r"><span class="fl">1</span> <span class="op">+</span> <span class="fl">2</span></code></pre>
        <pre class="downlit sourceCode r">
    <code class="sourceCode r"><span class="fl">3</span> <span class="op">+</span> <span class="fl">4</span></code></pre>
      </div>
      <pre>No hightlight</pre>
    </body>

# preserves classes of .chunk <pre>s

    <body>
      <div class="r-chunk">
        <pre class="a">
    <code class="sourceCode r"><span class="fl">1</span> <span class="op">+</span> <span class="fl">2</span></code></pre>
        <pre class="b">
    <code class="sourceCode r"><span class="fl">3</span> <span class="op">+</span> <span class="fl">4</span></code></pre>
      </div>
    </body>

# special package string gets linked

    <p>before <a href="https://downlit.r-lib.org/">downlit</a> after</p>

---

    <p>before <code>{notapkg}</code> after</p>

