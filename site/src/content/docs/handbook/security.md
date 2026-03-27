---
title: Security
description: Trust model and security posture for the Star Freight Client.
sidebar:
  order: 4
---

## Trust Model

The Star Freight Client is a **local-only desktop application**. It has no network capabilities and no cloud dependencies.

### Data Touched

| Data | Access | Purpose |
|------|--------|---------|
| PNG sprite files | Read-only | Character rendering |
| JSON manifests | Read-only | Pack metadata and checksums |
| JSON-RPC messages | Local stdio | Communication with Python engine subprocess |

### Data NOT Touched

- No cloud services or remote APIs
- No user accounts or authentication
- No save files (the Python engine handles persistence)
- No user telemetry or analytics
- No credentials, tokens, or secrets

### Subprocess

The client spawns `python -m portlight.app.cli rpc` as a local child process. Communication happens exclusively over stdio (stdin/stdout) -- no network sockets are opened. The child process exits when the client exits. The `python_path` and `save_slot` are configurable exports on `EngineBridge`, but both default to safe local values (`"python"` and `"default"`).

## Reporting Vulnerabilities

Email: **64996768+mcp-tool-shop@users.noreply.github.com**

| Action | Timeline |
|--------|----------|
| Acknowledge report | 48 hours |
| Assess severity | 7 days |
| Release fix | 30 days |
