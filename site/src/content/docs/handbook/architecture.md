---
title: Architecture
description: How the client, engine, and foundry fit together.
sidebar:
  order: 2
---

## Two-Repo Split

Star Freight separates simulation from presentation:

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

The Python engine owns all game logic, save files, and state. The Godot client is a rendering surface that displays what the engine tells it. This split means:

- Engine tests (2168) cover all game logic
- Client can be replaced without touching the simulation
- Turn-based gameplay makes RPC latency invisible

## Engine Bridge

The bridge uses **JSON-RPC 2.0 over stdio**. Godot spawns `python -m portlight.app.cli rpc` as a child process and exchanges newline-delimited JSON messages. (The Python package is still called `portlight`; the user-facing product name is Star Freight. A namespace migration may happen later.)

`engine_bridge.gd` exposes a configurable `python_path` export (default `"python"`) and a `save_slot` export (default `"default"`). When a non-default save slot is used, the bridge passes `--save <slot>` before the module path.

### Why stdio?

- No network stack required
- No port conflicts
- Clean process lifecycle (child exits when parent exits)
- Works everywhere Python runs
- No firewall prompts on Windows

### RPC Methods

| Method | Purpose |
|--------|---------|
| `ping` | Liveness check, returns engine version |
| `get_roster` | List active crew members |
| `get_crew_member` | Detailed info for one crew member |
| `get_campaign` | Campaign summary (credits, day, station, fuel) |
| `shutdown` | Clean engine shutdown |

The RPC surface is intentionally minimal. Only methods the client actually needs are exposed. New methods are added when new scenes require them.

### Connection modes

The bridge supports two calling styles:

- **`call_blocking(method, params)`** -- Synchronous. Launches a one-shot Python process, waits for the result, and returns. Used during init (e.g., the `ping` and `get_roster` calls when the user presses B).
- **`send_request(method, params)`** -- Asynchronous. Writes to the persistent subprocess's stdin pipe. Responses arrive via the `response_received` signal. Suitable for in-game polling.

## Pack Loader

Sprite packs follow the frozen foundry export contract (v1.0.0):

```
assets/characters/{slug}/
├── manifest.json       # Schema, identity, checksums
├── albedo/             # 8 × RGB diffuse PNGs
├── normal/             # 8 × normal map PNGs
├── depth/              # 8 × depth map PNGs
└── preview/            # Contact sheet (optional)
```

The pack loader reads `manifest.json`, validates the schema version, and builds a `CanvasTexture` per direction combining albedo (diffuse) and normal (lighting) layers. Depth maps are available but not yet used in rendering.

## Character Node

`CharacterNode` wraps a Godot `Sprite2D` with:

- 8-direction switching (front through front_right, clockwise)
- CanvasTexture with normal maps for dynamic lighting
- 4x pixel scaling (48px → 192px display)
- Name label below the sprite

The node exposes `set_direction(name)`, `rotate_direction(offset)`, and `get_direction_name()` for scene scripts to control facing. Direction wraps around: rotating past `front_right` returns to `front`.

## Roster Scene

`roster_scene.gd` ties everything together. On `_ready()` it:

1. Auto-discovers all packs in `res://assets/characters/` via `PackLoader.discover_packs()`
2. Creates a `CharacterNode` for each valid pack, spaced evenly across the 960px viewport
3. Adds a `PointLight2D` above the characters so normal maps produce visible lighting
4. Listens for keyboard input (A/D rotate, Tab select, Space rotate all, B bridge, Esc quit)

The bridge connection is optional. Without the Python engine, the roster works in **visual-only mode** -- useful for testing sprite packs without a running game session.
