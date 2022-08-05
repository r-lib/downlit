# highlight all pre inside div.downlit

    <body>
      <div class="downlit">
        <pre class="downlit sourceCode r">
    <code class="sourceCode R"><span><span class="fl">1</span> <span class="op">+</span> <span class="fl">2</span></span></code></pre>
        <pre class="downlit sourceCode r">
    <code class="sourceCode R"><span><span class="fl">3</span> <span class="op">+</span> <span class="fl">4</span></span></code></pre>
      </div>
      <pre>No hightlight</pre>
    </body>

# special package string gets linked

    <p>before <a href="https://downlit.r-lib.org/">downlit</a> after</p>

---

    <p>before <code>{notapkg}</code> after</p>

# keeps all pre classes

    <div class="sourceCode">
      <pre class="downlit sourceCode r my-class">
    <code class="sourceCode R"><span><span class="va">Hello</span></span></code></pre>
    </div>

