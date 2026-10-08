"""Manifest and declaration refusals before archive acquisition."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//playwright/private:validation.bzl", "declaration_error", "manifest_entry")

def _validation_impl(ctx):
    env = unittest.begin(ctx)
    checksums = {"darwin_arm64": "a" * 64}
    asserts.equals(env, None, declaration_error("chromium", checksums))
    for name, hashes, seen, fragment in [
        ("firefox", checksums, [], "unsupported browser"),
        ("chromium", checksums, ["chromium"], "declared more than once"),
        ("chromium", {}, [], "declares no platforms"),
        ("chromium", {"unsupported": "a" * 64}, [], "unsupported platform"),
        ("chromium", {"darwin_arm64": "wrong"}, [], "SHA-256 checksum"),
    ]:
        asserts.true(env, fragment in declaration_error(name, hashes, seen))
    entry = {"name": "chromium", "revision": "1247", "browserVersion": "155.0.8059.12"}
    asserts.equals(env, entry, manifest_entry({"browsers": [entry]}, "chromium").entry)
    for value in [None, {}, {"browsers": []}, {"browsers": "wrong"}, {"browsers": [entry, entry]}, {"browsers": [{"name": "chromium"}]}]:
        asserts.true(env, "must list one chromium" in manifest_entry(value, "chromium").error)
    return unittest.end(env)

validation_test = unittest.make(_validation_impl)
