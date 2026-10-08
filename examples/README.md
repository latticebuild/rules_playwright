# Runnable examples

Prepare the repository with `mise run bootstrap`, then run:

```sh
bazel build //examples:artifacts
bazel test //examples:test
```

| Feature | Source | Command | Expected result |
| --- | --- | --- | --- |
| Caller-owned browser manifest and platform selection | [browser/browsers.json](browser/browsers.json) | `bazel build //examples/browser:chromium` | Selects the checksum-pinned target-platform Chromium payload. |
| Renamed extension hub and per-platform checksums | [../MODULE.bazel](../MODULE.bazel) | `bazel test //tests:browser_test` | The browser_payload alias is caller-owned; Chromium opens a page and executes native assertions. |
| Malformed manifests and unsupported declarations | [../tests/BUILD.bazel](../tests/BUILD.bazel) | `bazel test //tests:validation_test` | Rejects malformed declarations; the consumer guide documents real checksum and platform refusals. |

The root artifact/test gates include these examples. Deliberately invalid subjects
remain in test fixtures; their owner tests require the expected refusals. Fix and
editor-write commands modify the invoking checkout only when run explicitly.
Automated mutation cases use disposable invoking workspaces.
