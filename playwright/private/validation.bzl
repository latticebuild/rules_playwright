"""Browser declaration and manifest validation shared with repository tests."""

load(":common.bzl", "BROWSERS", "PLATFORMS")

visibility("//...")

def declaration_error(name, checksums, seen = []):
    """Checks supported browser names and exact platform checksum declarations.

    Args:
      name: Manifest browser name.
      checksums: Platform names mapped to SHA-256 strings.
      seen: Names declared by earlier tags.

    Returns:
      A refusal string, or None for a valid declaration.
    """
    if name not in BROWSERS:
        return "unsupported browser %s; supported browsers are %s" % (name, ", ".join(sorted(BROWSERS)))
    if name in seen:
        return "browser %s is declared more than once" % name
    if not checksums:
        return "browser %s declares no platforms" % name
    for platform, checksum in checksums.items():
        if platform not in PLATFORMS:
            return "unsupported platform %s for %s; supported platforms are %s" % (platform, name, ", ".join(sorted(PLATFORMS)))
        if len(checksum) != 64 or any([char not in "0123456789abcdef" for char in checksum.elems()]):
            return "browser %s requires a SHA-256 checksum for %s" % (name, platform)
    return None

def manifest_entry(value, browser):
    """Selects one complete browser record from a decoded manifest.

    Args:
      value: Decoded browsers.json value.
      browser: The declared browser name.

    Returns:
      A struct containing either the entry or a refusal string.
    """
    entries = [entry for entry in value.get("browsers", []) if type(entry) == "dict" and entry.get("name") == browser] if type(value) == "dict" and type(value.get("browsers", [])) == "list" else []
    if len(entries) != 1 or not entries[0].get("revision") or not entries[0].get("browserVersion"):
        return struct(error = "playwright-core/browsers.json must list one %s with a revision and browserVersion" % browser, entry = None)
    return struct(error = None, entry = entries[0])
