"""Checksum-pinned native browser archives selected by the installed Playwright manifest."""

load("//playwright/private:playwright.bzl", _playwright = "playwright")

visibility("public")

playwright = _playwright
