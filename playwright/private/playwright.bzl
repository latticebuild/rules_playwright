"""Module extension that declares the Playwright browser repositories and the @playwright hub."""

load(":browser.bzl", browser_repository = "browser")
load(":common.bzl", "BROWSERS", "repository_name")
load(":hub.bzl", "hub")
load(":validation.bzl", "declaration_error")

visibility("//...")

def _playwright(module_ctx):
    checksums = {}
    manifests = {}
    for module in module_ctx.modules:
        for tag in module.tags.browser:
            error = declaration_error(tag.name, tag.sha256, checksums.keys())
            if error:
                fail(error)
            checksums[tag.name] = tag.sha256
            manifests[tag.name] = tag.manifest

    for browser, platforms in checksums.items():
        for platform, sha256 in platforms.items():
            browser_repository(
                name = repository_name(browser, platform),
                browser = browser,
                manifest = manifests[browser],
                platform = platform,
                sha256 = sha256,
            )
    hub(
        name = "playwright",
        browsers = {browser: sorted(platforms) for browser, platforms in checksums.items()},
    )
    return module_ctx.extension_metadata(reproducible = True)

playwright = module_extension(
    implementation = _playwright,
    doc = """Creates `@playwright` with a test-only filegroup for each declared browser.

A browser's filegroup, such as `@playwright//:chromium`, selects the target
platform's archive. Only the selected platform's archive is fetched.""",
    tag_classes = {
        "browser": tag_class(
            doc = "A browser at the build the installed Playwright manifest selects.",
            attrs = {
                "name": attr.string(
                    mandatory = True,
                    values = sorted(BROWSERS),
                    doc = "Manifest name of the browser.",
                ),
                "manifest": attr.label(mandatory = True, allow_single_file = [".json"], doc = "Installed playwright-core browsers.json."),
                "sha256": attr.string_dict(
                    mandatory = True,
                    doc = "Bazel platform name, such as `darwin_arm64`, to the checksum of that platform's archive for the manifest's browser version.",
                ),
            },
        ),
    },
)
