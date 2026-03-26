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

The bridge uses **JSON-RPC 2.0 over stdio**. Godot spawns `starfreight rpc` as a child process and exchanges newline-delimited JSON messages.

### Why stdio?

- No network stack required
- No port conflicts
- Clean process lifecycle (child exits when parent exits)
- Works everywhere Python runs

### RPC Methods

| Method | Purpose |
|--------|---------|
| `ping` | Liveness check, returns engine version |
| `get_roster` | List active crew members |
| `get_crew_member` | Detailed info for one crew member |
| `get_campaign` | Campaign summary (credits, day, station, fuel) |
| `shutdown` | Clean engine shutdown |

The RPC surface is intentionally minimal. Only methods the client actually needs are exposed. New methods are added when new scenes require them.

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

The node exposes `set_direction(name)`, `rotate_direction(offset)`, and `get_direction_name()` for scene scripts to control facing.
