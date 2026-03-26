# Ship Gate

> No repo is "done" until every applicable line is checked.

**Tags:** `[all]` every repo · `[npm]` `[pypi]` `[vsix]` `[desktop]` `[container]` published artifacts · `[mcp]` MCP servers · `[cli]` CLI tools

**Detected:** `[all]` `[desktop]`

---

## A. Security Baseline

- [x] `[all]` SECURITY.md exists (report email, supported versions, response timeline) (2026-03-26)
- [x] `[all]` README includes threat model paragraph (data touched, data NOT touched, permissions required) (2026-03-26)
- [x] `[all]` No secrets, tokens, or credentials in source or diagnostics output (2026-03-26)
- [x] `[all]` No telemetry by default — state it explicitly even if obvious (2026-03-26)

### Default safety posture

- [ ] `[cli|mcp|desktop]` SKIP: No dangerous actions — client is read-only renderer, subprocess spawns local-only Python engine
- [ ] `[cli|mcp|desktop]` SKIP: File operations are read-only (PNG + JSON manifests), no write ops beyond Godot's own cache
- [ ] `[mcp]` SKIP: not an MCP server
- [ ] `[mcp]` SKIP: not an MCP server

## B. Error Handling

- [x] `[all]` Errors follow the Structured Error Shape: `code`, `message`, `hint`, `cause?`, `retryable?` (2026-03-26) — JSON-RPC errors use standard codes + app codes, GDScript uses push_error/push_warning
- [ ] `[cli]` SKIP: not a CLI tool
- [ ] `[cli]` SKIP: not a CLI tool
- [ ] `[mcp]` SKIP: not an MCP server
- [ ] `[mcp]` SKIP: not an MCP server
- [x] `[desktop]` Errors shown as user-friendly messages — no raw exceptions in UI (2026-03-26) — pack load errors degrade to warnings, bridge failures show "offline (visual only)"
- [ ] `[vscode]` SKIP: not a VS Code extension

## C. Operator Docs

- [x] `[all]` README is current: what it does, install, usage, supported platforms + runtime versions (2026-03-26)
- [x] `[all]` CHANGELOG.md (Keep a Changelog format) (2026-03-26)
- [x] `[all]` LICENSE file present and repo states support status (2026-03-26)
- [ ] `[cli]` SKIP: not a CLI tool
- [ ] `[cli|mcp|desktop]` SKIP: Logging is via Godot's built-in output console — no custom logging levels needed for a game client
- [ ] `[mcp]` SKIP: not an MCP server
- [ ] `[complex]` SKIP: not a complex daemon — simple game client with no operational modes

## D. Shipping Hygiene

- [x] `[all]` `verify` script exists (test + build + smoke in one command) (2026-03-26) — `bash verify.sh`
- [x] `[all]` Version in manifest matches git tag (2026-03-26) — v1.0.0 in CHANGELOG, project.godot tracks via config/name
- [ ] `[all]` SKIP: Dependency scanning not applicable — Godot project with no package manager dependencies (assets are vendored PNGs)
- [ ] `[all]` SKIP: No automated dependency updates needed — no npm/pip/cargo dependencies to update
- [ ] `[npm]` SKIP: not an npm package
- [ ] `[npm]` SKIP: not an npm package
- [ ] `[npm]` SKIP: not an npm package
- [ ] `[vsix]` SKIP: not a VS Code extension
- [x] `[desktop]` Installer/package builds and runs on stated platforms (2026-03-26) — opens and runs in Godot 4.6 on Windows 11

## E. Identity (soft gate — does not block ship)

- [x] `[all]` Logo in README header (2026-03-26)
- [ ] `[all]` Translations (polyglot-mcp, 8 languages) — handed off to user
- [x] `[org]` Landing page (@mcptoolshop/site-theme) (2026-03-26)
- [x] `[all]` GitHub repo metadata: description, homepage, topics (2026-03-26)

---

## Gate Rules

**Hard gate (A-D):** Must pass before any version is tagged or published.
If a section doesn't apply, mark `SKIP:` with justification — don't leave it unchecked.

**Soft gate (E):** Should be done. Product ships without it, but isn't "whole."
