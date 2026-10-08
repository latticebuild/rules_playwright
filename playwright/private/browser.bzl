"""Repository with one browser for one platform, at the build the installed Playwright manifest selects."""

load(":common.bzl", "BROWSERS", "PLATFORMS", "identifier")
load(":validation.bzl", "manifest_entry")

visibility("//...")

def _browser_impl(ctx):
    manifest = manifest_entry(json.decode(ctx.read(ctx.attr.manifest)), ctx.attr.browser)
    if manifest.error:
        fail(manifest.error)
    entry = manifest.entry

    # Playwright's registry derives the install directory and Chrome for Testing URL the same way.
    name = identifier(ctx.attr.browser)
    directory = ".playwright/{}-{}".format(name, entry["revision"])
    platform = PLATFORMS[ctx.attr.platform][2]
    url = "https://cdn.playwright.dev/builds/cft/{version}/{platform}/{prefix}-{platform}.zip".format(
        version = entry["browserVersion"],
        platform = platform,
        prefix = BROWSERS[ctx.attr.browser],
    )

    # The URL names the version, so a stale checksum cannot reuse an older cached archive.
    ctx.download_and_extract(url = url, sha256 = ctx.attr.sha256, canonical_id = url, output = directory)
    ctx.file(directory + "/INSTALLATION_COMPLETE", "", executable = False)
    ctx.file("BUILD.bazel", """
filegroup(
    name = "{name}",
    srcs = glob([".playwright/**"]),
    visibility = ["//visibility:public"],
)
""".format(name = name), executable = False)

browser = repository_rule(
    implementation = _browser_impl,
    doc = "One browser for one platform, at the build the installed Playwright manifest selects.",
    attrs = {
        "browser": attr.string(
            mandatory = True,
            values = sorted(BROWSERS),
            doc = "Manifest name of the browser.",
        ),
        "manifest": attr.label(mandatory = True),
        "platform": attr.string(
            mandatory = True,
            values = sorted(PLATFORMS),
            doc = "Bazel platform the archive runs on.",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = "Checksum of that platform's archive for the manifest's browser version.",
        ),
    },
)
