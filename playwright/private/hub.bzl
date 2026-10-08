"""The @playwright repository: a filegroup per browser selecting the target platform's browser repository."""

load(":common.bzl", "PLATFORMS", "identifier", "repository_name")

visibility("//...")

def _hub_impl(ctx):
    platforms = sorted({platform: None for platforms in ctx.attr.browsers.values() for platform in platforms})

    settings = "".join([
        """
config_setting(
    name = "{name}",
    constraint_values = [
        "@platforms//os:{os}",
        "@platforms//cpu:{cpu}",
    ],
)
""".format(name = platform, os = PLATFORMS[platform][0], cpu = PLATFORMS[platform][1])
        for platform in platforms
    ])
    filegroups = "".join([
        """
filegroup(
    name = "{name}",
    testonly = True,
    srcs = select(
        {{
{branches}        }},
        no_match_error = "{browser} is declared only for {declared}",
    ),
    visibility = ["//visibility:public"],
)
""".format(
            name = identifier(browser),
            browser = browser,
            declared = ", ".join(sorted(browser_platforms)),
            branches = "".join([
                '            ":{platform}": ["@{repository}//:{name}"],\n'.format(
                    platform = platform,
                    repository = repository_name(browser, platform),
                    name = identifier(browser),
                )
                for platform in sorted(browser_platforms)
            ]),
        )
        for browser, browser_platforms in sorted(ctx.attr.browsers.items())
    ])
    ctx.file("BUILD.bazel", 'package(default_visibility = ["//visibility:private"])\n' + settings + filegroups, executable = False)

hub = repository_rule(
    implementation = _hub_impl,
    doc = "A test-only filegroup for each browser, selecting the target platform's browser repository.",
    attrs = {
        "browsers": attr.string_list_dict(
            mandatory = True,
            doc = "Manifest browser name to the Bazel platforms it has a browser repository for.",
        ),
    },
)
