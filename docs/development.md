# Development

Install Mise, then run `mise trust` and `mise run bootstrap` in this checkout.
Use the owned MODULE configuration and frozen dependency locks.

```sh
hk check --all --slow
hk validate
hk test
bazel build //:artifacts
bazel test //:test
```

Native CI runs these gates on Ubuntu 24.04, macOS 27, and Windows 2025.
See [usage.md](usage.md) for setup and supported inputs.

On Windows, CI creates LOCALAPPDATA/Temp/latticebuild before Mise installs
tools. This uses a canonical long path on the installation drive and forwards
TMP/TEMP through Bazel tests. Private runtime trees remain inside that root.

CI uses a short Bazel output root on Windows (`D:/b`) so native linkers can
open deeply nested runfiles. Locally, select a short writable root with
`bazel --output_user_root=C:/b test //:test` when needed. Documentation and
example scripts accept the same root through BAZEL_OUTPUT_USER_ROOT.
