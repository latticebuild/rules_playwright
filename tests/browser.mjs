import assert from "node:assert/strict";
import { call, ensure, run } from "effection";
import { chromium } from "playwright-core";

run(function* () {
  const server = yield* call(() => chromium.launchServer({
      channel: "chromium",
      headless: true,
      // Linux Unix sockets must fit inside Chromium's 108-byte path limit.
      env: { ...process.env, ...(process.platform === "linux" ? { TMPDIR: "/tmp" } : {}) },
    }));
  yield* ensure(function* () { yield* call(() => server.kill()); });
  const browser = yield* call(() => chromium.connect(server.wsEndpoint()));
  yield* ensure(function* () { yield* call(() => browser.close()); });
  const page = yield* call(() => browser.newPage());
  yield* call(() => page.setContent('<button aria-label="browser works">ready</button>'));
  assert.equal(yield* call(() => page.getByRole("button", { name: "browser works" }).textContent()), "ready");
  assert.equal(yield* call(() => page.evaluate(() => navigator.platform.length > 0)), true);
}).catch((error) => { console.error(error); process.exitCode = 1; });
