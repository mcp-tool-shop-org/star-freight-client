# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

Email: **64996768+mcp-tool-shop@users.noreply.github.com**

Include:
- Description of the vulnerability
- Steps to reproduce
- Version affected
- Potential impact

### Response timeline

| Action | Target |
|--------|--------|
| Acknowledge report | 48 hours |
| Assess severity | 7 days |
| Release fix | 30 days |

## Scope

This is a **Godot 4.6 desktop game client** that renders sprites and communicates with a local Python engine.

- **Data touched:** Local sprite PNG files (read-only), JSON manifest files (read-only), JSON-RPC messages to/from local Python subprocess
- **Data NOT touched:** No cloud services, no user accounts, no save files (engine handles saves)
- **No network egress** — all communication is local subprocess stdio
- **No secrets handling** — does not read, store, or transmit credentials
- **No telemetry** is collected or sent
- **Subprocess:** Spawns `starfreight rpc` as a child process on localhost only
