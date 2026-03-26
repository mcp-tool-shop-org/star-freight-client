---
title: Reference
description: Complete reference for scripts, scenes, and the export contract.
sidebar:
  order: 3
---

## Scripts

### pack_loader.gd

Static utility class for discovering and loading sprite packs.

| Method | Signature | Returns |
|--------|-----------|---------|
| `discover_packs` | `(root_path: String)` | `PackedStringArray` of pack directories |
| `load_pack` | `(pack_path: String)` | `CharacterPack` with textures and metadata |

**CharacterPack** fields:

| Field | Type | Description |
|-------|------|-------------|
| `slug` | `String` | Subject identifier (e.g. `sera_vale`) |
| `display_name` | `String` | Human-readable name |
| `body_family` | `String` | `bipedal`, `quadruped`, etc. |
| `width`, `height` | `int` | Sprite dimensions (48×48) |
| `direction_order` | `PackedStringArray` | 8 canonical direction names |
| `textures` | `Dictionary` | direction → { albedo, normal, depth } |
| `canvas_textures` | `Dictionary` | direction → CanvasTexture |
| `valid` | `bool` | Load succeeded |
| `error` | `String` | Error message if invalid |

### engine_bridge.gd

JSON-RPC client node. Spawns the Python engine subprocess.

| Method | Description |
|--------|-------------|
| `connect_to_engine()` | Spawn `starfreight rpc` subprocess |
| `call_blocking(method, params)` | Synchronous RPC call (blocks Godot) |
| `shutdown()` | Clean engine shutdown + process kill |

**Exports:**

| Property | Default | Description |
|----------|---------|-------------|
| `python_path` | `"python"` | Python executable path |
| `save_slot` | `"default"` | Game save slot |

### character_node.gd

Sprite2D wrapper with direction switching.

| Method | Description |
|--------|-------------|
| `load_character(pack)` | Load a CharacterPack and display front sprite |
| `set_direction(name)` | Set facing by direction name |
| `rotate_direction(offset)` | Rotate facing (+1 = clockwise) |
| `get_direction_name()` | Current direction name |

## Scenes

### main.tscn

Entry point. Instances `roster.tscn`.

### roster.tscn

Crew display scene with:
- Auto-discovery of all packs in `res://assets/characters/`
- Evenly spaced character nodes
- PointLight2D for normal map visualization
- Keyboard input handling
- Optional engine bridge connection

## Export Contract (v1.0.0)

The contract is frozen. Do not modify unless runtime pain proves it wrong.

| Property | Value |
|----------|-------|
| Schema version | `1.0.0` |
| Sprite size | 48×48 pixels |
| Transparency | Required (transparent PNG) |
| Pivot | `center_bottom` |
| Directions | 8: front, front_left, left, back_left, back, back_right, right, front_right |
| Layers | albedo (required), normal (required), depth (required) |
| Checksums | SHA-256 per file in manifest |
| Immutability | Packs are append-only after creation |

## Verify Script

```bash
bash verify.sh
```

Validates:
1. All required project files exist
2. Every asset pack has a valid manifest (JSON + schema v1.0.0)
3. GDScript files are valid UTF-8 and non-empty
4. Scene files are present
