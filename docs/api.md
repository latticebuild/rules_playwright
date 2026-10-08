<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Checksum-pinned native browser archives selected by the installed Playwright manifest.

<a id="playwright"></a>

## playwright

<pre>
playwright = use_extension("@latticebuild_playwright//playwright:extensions.bzl", "playwright")
playwright.browser(<a href="#playwright.browser-name">name</a>, <a href="#playwright.browser-manifest">manifest</a>, <a href="#playwright.browser-sha256">sha256</a>)
</pre>

Creates `@playwright` with a test-only filegroup for each declared browser.

A browser's filegroup, such as `@playwright//:chromium`, selects the target
platform's archive. Only the selected platform's archive is fetched.


**TAG CLASSES**

<a id="playwright.browser"></a>

### browser

A browser at the build the installed Playwright manifest selects.

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="playwright.browser-name"></a>name |  Manifest name of the browser.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="playwright.browser-manifest"></a>manifest |  Installed playwright-core browsers.json.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="playwright.browser-sha256"></a>sha256 |  Bazel platform name, such as `darwin_arm64`, to the checksum of that platform's archive for the manifest's browser version.   | <a href="https://bazel.build/rules/lib/core/dict">Dictionary: String -> String</a> | required |  |
