# pkgdown

<details>

* Version: 2.0.4
* GitHub: https://github.com/r-lib/pkgdown
* Source code: https://github.com/cran/pkgdown
* Date/Publication: 2022-06-10 12:30:02 UTC
* Number of recursive dependencies: 71

Run `cloud_details(, "pkgdown")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      
      `actual`:   "1 + 2"        
      `expected`: "1"     "+" "2"
      ── Failure (test-tweak-reference.R:99:3): fails cleanly ────────────────────────
      tweak_highlight_r(html) (`actual`) not equal to FALSE (`expected`).
      
      `actual`:   TRUE 
      `expected`: FALSE
      
      [ FAIL 4 | WARN 0 | SKIP 87 | PASS 536 ]
      Deleting unused snapshots:
      • build-search-docs/search-no-url.json
      • build-search-docs/search.json
      Error: Test failures
      Execution halted
    ```

## In both

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘usethis’
    ```

