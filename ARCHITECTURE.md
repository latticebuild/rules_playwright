# Pinned native browser payloads

Browser tests need an archive that matches the installed Playwright runtime.
The public extension reads the caller's declared browsers.json and selects
archive versions from that manifest. Each platform has a caller-owned SHA-256
checksum; repository preparation verifies the download before exposing files.

The extension declares separate repositories for each platform and a hub with
platform-selected edges. This keeps unrelated browser archives out of a build.
An unsupported browser, duplicate declaration, missing platform set, or malformed
manifest fails during preparation. A requested platform without a declaration
has no compatible payload.

Payload files remain native runfiles under one Chromium installation directory.
An INSTALLATION_COMPLETE marker names that installation. Runners own writable
validation state and temporary directories; they do not mutate the archive or
use a developer's browser cache. The native test resolves the selected executable
from the declared payload and checks JavaScript-rendered DOM from the HTML fixture.

Only Chromium is supported. Linux hosts supply Chromium's operating-system
libraries; those belong to the runner image rather than the browser archive.

Native verification invokes the declared Chromium executable against the HTML
example, observes complete JavaScript-updated DOM, and deliberately requests
bounded shutdown through the development-only graceproc dependency. The selected
browser payload stays immutable; profile state belongs to each probe. This keeps
browser acquisition independent of JavaScript build execution.
