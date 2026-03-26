<p align="center">
  <img src="https://raw.githubusercontent.com/mcp-tool-shop-org/brand/main/logos/star-freight-client/readme.png" width="400" alt="Star Freight Client" />
</p>

<p align="center">
  <a href="https://github.com/mcp-tool-shop-org/star-freight-client/actions"><img src="https://github.com/mcp-tool-shop-org/star-freight-client/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" /></a>
  <a href="https://mcp-tool-shop-org.github.io/star-freight-client/"><img src="https://img.shields.io/badge/docs-landing%20page-brightgreen" alt="Landing Page" /></a>
</p>

Godot 4.6 graphical client for the [Star Freight](https://github.com/mcp-tool-shop-org/star-freight) space merchant RPG. Renders crew, creatures, and hostiles using pixel sprite packs from the [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry) pipeline.

The Python engine is the source of truth. This client is a rendering surface — it displays what the engine tells it via JSON-RPC over stdio.

> The Python engine package currently remains `portlight` for continuity.
> User-facing product name is **Star Freight**.
> Namespace migration, if desired, is a later dedicated refactor.

## Architecture

```
star-freight (Python)          star-freight-client (Godot 4.6)
┌──────────────────┐           ┌──────────────────────────┐
│ portlight.engine │──JSON-RPC─│ engine_bridge.gd         │
│ portlight.rpc    │  (stdio)  │ pack_loader.gd           │
│ portlight.content│           │ character_node.gd        │
└──────────────────┘           │ scenes/roster.tscn       │
                               │ assets/characters/       │
                               └──────────────────────────┘
```

- **Engine bridge**: JSON-RPC 2.0 over stdio. Godot spawns `starfreight rpc` as a subprocess.
- **Pack loader**: Reads manifest.json from imported sprite packs. Builds CanvasTextures (albedo + normal).
- **Character node**: Sprite2D wrapper with 8-direction switching and normal map lighting.

## Prerequisites

- [Godot 4.6.1](https://godotengine.org/download) (standard build, not .NET)
- Python 3.11+ with `star-freight` installed
- Windows 11 (primary development platform)

## Quick Start

1. Open this project in Godot 4.6
2. Press F5 to run — the roster scene loads 3 character packs
3. Controls:
   - **A/D** or arrow keys: rotate selected character facing
   - **Tab**: cycle through characters
   - **Space**: rotate all characters
   - **B**: connect to Python engine (must have `starfreight` installed)
   - **Esc**: quit

## Importing Sprite Packs

Packs are vendored into `assets/characters/`. To import from the foundry:

```bash
python scripts/import_packs.py                            # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## RPC Methods

| Method | Params | Returns |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | crew member dict |
| `get_campaign` | — | campaign summary |
| `shutdown` | — | `{status}` |

## Export Contract

Sprite packs follow the frozen foundry export contract (v1.0.0):

- 8 directions: front, front_left, left, back_left, back, back_right, right, front_right
- 3 layers: albedo, normal, depth (all 48x48 transparent PNG)
- Pivot: center_bottom
- Manifest: `manifest.json` with SHA-256 checksums per file

## Verify

```bash
bash verify.sh
```

Checks project structure, asset pack manifests (JSON + schema version), GDScript validity, and scene references.

## Security & Trust

This client operates **locally only**:

- **Data touched**: Local PNG sprite files (read-only), JSON manifests (read-only), JSON-RPC messages to local Python subprocess
- **Data NOT touched**: No cloud services, no user accounts, no network egress
- **No telemetry** is collected or sent
- **No secrets** are read, stored, or transmitted
- **Subprocess**: Spawns `starfreight rpc` as a local child process via stdio only

See [SECURITY.md](SECURITY.md) for the full security policy.

## License

MIT

Built by [MCP Tool Shop](https://mcp-tool-shop.github.io/)
