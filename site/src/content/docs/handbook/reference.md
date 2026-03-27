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
| `connect_to_engine()` | Spawn Python RPC subprocess (`python -m portlight.app.cli rpc`), returns `bool` |
| `send_request(method, params)` | Async JSON-RPC request, returns request `int` id |
| `call_blocking(method, params)` | Synchronous RPC call (blocks Godot), returns result or `null` |
| `shutdown()` | Clean engine shutdown + process kill |

**Signals:**

| Signal | Params | Description |
|--------|--------|-------------|
| `connected` | — | Emitted when engine subprocess launches |
| `disconnected` | — | Emitted after shutdown |
| `response_received` | `id: int, result: Variant` | Async RPC response arrived |
| `error_received` | `id: int, error: Dictionary` | RPC error received |

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

**Exports:**

| Property | Default | Description |
|----------|---------|-------------|
| `sprite_scale` | `4.0` | Display scale for 48px sprites (48 x 4 = 192px on screen) |

### roster_scene.gd

Main scene script. Discovers packs, creates `CharacterNode` instances, handles input.

| Constant | Value | Description |
|----------|-------|-------------|
| `ASSETS_ROOT` | `"res://assets/characters"` | Root directory for pack discovery |

The scene builds its UI entirely in code during `_ready()`: background `ColorRect`, title `Label`, direction indicator `Label`, controls hint `Label`, ground plane, and a `PointLight2D` for normal-map lighting. Characters are evenly spaced across the 960px viewport width.

**Keyboard bindings** (handled in `_input`):

| Key | Action |
|-----|--------|
| A / Left | Rotate selected character counter-clockwise |
| D / Right | Rotate selected character clockwise |
| Tab | Cycle selection to next character |
| Space | Rotate all characters clockwise |
| B | Attempt engine bridge connection |
| Escape | Quit |

### import_packs.py

Python utility for importing sprite packs from the foundry exports directory.

```bash
python scripts/import_packs.py [--source PATH] [--subjects slug1,slug2]
```

| Flag | Default | Description |
|------|---------|-------------|
| `--source` | `F:/AI/star-freight-foundry/exports` | Foundry exports directory |
| `--subjects` | all subjects | Comma-separated subject slugs to import |

The script finds the latest run directory (by modification time) for each subject, copies it unchanged into `assets/characters/{slug}/`, and validates the manifest. Re-running replaces existing packs.

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
| Layers | albedo (required), normal (optional, used for lighting), depth (optional, reserved) |
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
