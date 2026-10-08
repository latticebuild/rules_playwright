# Browser acquisition

Declare `latticebuild_playwright` in your root MODULE.bazel, then select a
caller-owned manifest and the checksums for your supported platforms. A manifest
may be a local JSON file or a file exported from an installed Playwright package.
The runnable example uses [a local manifest](../examples/browser/browsers.json),
so browser acquisition is independent of npm installation.

```starlark
playwright = use_extension("@latticebuild_playwright//playwright:extensions.bzl", "playwright")
playwright.browser(
    name = "chromium",
    manifest = "@npm//node_modules/playwright-core:browsers.json",
    sha256 = {
        "darwin_arm64": "d64771a096fffd48b49a65e481dda50ae43a7de55fb93acfa6aece26ec3b10db",
        "darwin_x86_64": "580b3ea6231df5cb9760e27a889dfde21f391adbd58429d72be4684f789e8682",
        "linux_arm64": "bf94336ee2e3edb1279da28a74a744958ba10741e5994351610bc19028482b0b",
        "linux_x86_64": "a24546e0e6c763bf864861ce50498f38783663e24cd2af2a16798c25dc3a9489",
        "windows_x86_64": "48e66b6d93271398c68564ac8ca081b862cb7b78851ec3eae376a9a8d1941a15",
    },
)
use_repo(playwright, browser_payload = "playwright")
```

`manifest` is required. The npm repository may have any name. `sha256` keys
are `darwin_arm64`, `darwin_x86_64`, `linux_arm64`, `linux_x86_64`, and
`windows_x86_64`. Declare the platforms your consumers support. A missing
platform fails target selection; it does not fetch another platform's
archive. The current extension supports Chromium only.

The hub's `:chromium` target exposes the native files and one
INSTALLATION_COMPLETE marker. Pass it to rules_js's `js_vitest.browser`.
The runner derives a private installation layout from the marker and owns
PLAYWRIGHT_BROWSERS_PATH. Repository preparation downloads the archive; tests
perform no runtime browser installation.

Linux workers need Chromium's system libraries. The native Ubuntu CI image
supplies them. Keep HOME and temporary files private to each test, and stop the
browser process before releasing the test scope.

On Linux, Chromium creates Unix sockets beneath TMPDIR. If your Bazel temporary
path is long, give the browser launch a short temporary root:

```javascript
const launchOptions = {
  env: { ...process.env, ...(process.platform === "linux" ? { TMPDIR: "/tmp" } : {}) },
};
```

Playwright creates a private profile there and removes it when the browser is
closed. Workspace actions continue to use their own scratch directories.

The [native browser example](../examples/browser/index.html) is rendered by the
selected Chromium payload. Its Go test verifies JavaScript DOM updates and then
requests supervised shutdown, with a private profile and bounded descendant
cleanup. This probe's Go/process dependencies are development-only.
