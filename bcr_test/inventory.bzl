"""Resolve the selected native browser marker without a large environment value."""

def _inventory_impl(ctx):
    files = ctx.attr.browser[DefaultInfo].files.to_list()
    markers = [file for file in files if file.basename == "INSTALLATION_COMPLETE"]
    if len(markers) != 1:
        fail("browser must declare one installation marker")
    marker = markers[0].short_path
    if not marker.startswith("../"):
        fail("browser must come from its declared external repository")
    executables = [file for file in files if file.basename in ["chrome", "chrome.exe", "Google Chrome for Testing"]]
    if len(executables) != 1:
        fail("browser must declare one Chromium executable")
    executable = executables[0].short_path
    if not executable.startswith(marker.removesuffix("INSTALLATION_COMPLETE")):
        fail("browser executable must belong to its declared installation")
    output = ctx.actions.declare_file(ctx.label.name + ".json")
    ctx.actions.write(output, json.encode({"marker": marker[3:], "executable": executable[3:]}))
    return [DefaultInfo(files = depset([output]))]

browser_inventory = rule(implementation = _inventory_impl, attrs = {"browser": attr.label(mandatory = True)})
