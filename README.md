# rules_playwright

A Bazel module extension for checksum-pinned Playwright browser archives. The caller supplies the browser manifest and supported platform checksums; the generated hub selects the matching native payload.

## Setup

Use Bazel 9.2 with Bzlmod. These source repositories have no registry release yet.
Pin your chosen revision in your root MODULE.bazel:

```starlark
bazel_dep(name = "latticebuild_playwright", version = "0.0.0")
git_override(
    module_name = "latticebuild_playwright",
    remote = "https://github.com/latticebuild/rules_playwright.git",
    commit = "FULL_COMMIT_SHA",
)
```

Replace FULL_COMMIT_SHA with the full commit hash of that revision. Copy the
Latticebuild dependency overrides from [MODULE.bazel](MODULE.bazel) into the
consuming root too; overrides declared by a dependency do not propagate.

## Usage

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

See [docs/usage.md](docs/usage.md) for attributes, required tool inputs and
consumer setup. The public API lives in [playwright/](playwright/);
implementation files under its private/ directory are repository-local.

Chromium is currently supported. A platform missing from sha256 fails target
selection; it never fetches a different platform’s archive. The browser-only
module closure needs no Node or Go toolchain. Linux execution needs Chromium’s
system libraries; the native Ubuntu CI image supplies them.

## Development

Install [Mise](https://mise.jdx.dev/), then prepare this checkout:

```sh
mise trust
mise run bootstrap
hk validate
hk test
hk check --all --slow
bazel build //:artifacts
bazel test //:test
```

Tools and dependency versions are pinned in [mise.toml](mise.toml) and
[MODULE.bazel](MODULE.bazel). CI runs these gates on native Linux, macOS and
Windows runners. Repositories with a race suite also run it on Linux and macOS.
See [docs/development.md](docs/development.md) for owning checks and platform
constraints, and [ARCHITECTURE.md](ARCHITECTURE.md) for implementation decisions.

## License

[Apache License 2.0](LICENSE).
