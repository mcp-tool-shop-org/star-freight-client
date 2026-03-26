# Star Freight Client

Godot 4.6 graphical client for the [Star Freight](https://github.com/mcp-tool-shop-org/star-freight) space merchant RPG.

The Python engine is the source of truth. This client renders game state using sprite packs from the [Sprite Foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry) pipeline.

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
- **Character node**: Sprite2D wrapper with 8-direction switching.

## Prerequisites

- [Godot 4.6.1](https://godotengine.org/download) (standard build, not .NET)
- Python 3.11+ with `star-freight` installed (`pip install -e F:/AI/star-freight`)

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
python scripts/import_packs.py                           # all 20 subjects
python scripts/import_packs.py --subjects sera_vale,thal  # specific subjects
```

## RPC Methods (Phase 7A)

| Method | Params | Returns |
|--------|--------|---------|
| `ping` | — | `{status, version}` |
| `get_roster` | — | `{crew: [...], count}` |
| `get_crew_member` | `{id}` | crew member dict |
| `get_campaign` | — | campaign summary |
| `shutdown` | — | `{status}` |

## Export Contract

Sprite packs follow the frozen foundry export contract (v1.0.0):

- 8 directions: front → front_right (clockwise)
- 3 layers: albedo, normal, depth (all 48×48 transparent PNG)
- Pivot: center_bottom
- Manifest: `manifest.json` with SHA-256 checksums

## License

MIT
