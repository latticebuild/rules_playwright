"""The browsers and platforms Playwright archives are declared for, and their repository names."""

visibility("//...")

# Bazel platform name: (@platforms os, @platforms cpu, Chrome for Testing platform).
PLATFORMS = {
    "darwin_arm64": ("macos", "arm64", "mac-arm64"),
    "darwin_x86_64": ("macos", "x86_64", "mac-x64"),
    "linux_arm64": ("linux", "arm64", "linux-arm64"),
    "linux_x86_64": ("linux", "x86_64", "linux64"),
    "windows_x86_64": ("windows", "x86_64", "win64"),
}

# Manifest browser name: Chrome for Testing archive prefix. Playwright downloads it from the CfT mirror.
BROWSERS = {
    "chromium": "chrome",
}

def identifier(browser):
    # Playwright's registry names install directories this way; the repositories reuse it.
    return browser.replace("-", "_")

def repository_name(browser, platform):
    return identifier(browser) + "_" + platform
