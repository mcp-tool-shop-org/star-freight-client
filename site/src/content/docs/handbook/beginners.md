---
title: Beginner's Guide
description: New to the Star Freight Client? Start here for a plain-language walkthrough.
sidebar:
  order: 99
---

## What is Star Freight Client?

Star Freight Client is a Godot 4.6 desktop application that renders the visual side of the Star Freight space merchant RPG. It displays crew members, creatures, and hostiles as pixel-art sprites with normal-map lighting -- but it never runs game logic itself. All simulation, saves, and state live in the Python engine (`portlight`). The two communicate over JSON-RPC on stdio, so there is no network traffic and no cloud dependency.

The client can also run standalone in visual-only mode, which loads and displays sprite packs without any engine connection. This is useful for inspecting art assets or testing the rendering pipeline.

## Who is it for?

- **Star Freight players** who want a graphical interface instead of the terminal UI
- **Sprite artists** checking how their foundry-generated packs look with lighting and rotation
- **Developers** extending the client with new scenes (combat, starmap, trade) that consume engine data
- **Modders** who want to add custom character packs following the export contract

No Godot scripting experience is required to run the client. You only need Godot installed to open and play. The viewport is 960x640 pixels with nearest-neighbor texture filtering, giving sprites a crisp pixel-art look at any window size.

## Prerequisites

- **Godot 4.6.1** (standard build, not .NET) -- [download here](https://godotengine.org/download). This is the game engine that runs the client.
- **Git** -- to clone the repository.
- **Python 3.11+** (optional) -- only needed if you want the engine bridge to connect to the Star Freight game engine. Without Python, the client works in visual-only mode.
- **Basic terminal skills** -- you will run a few commands to clone and import packs, but no scripting knowledge is required.

## Key concepts

### Sprite packs

Each character is a self-contained folder under `assets/characters/` containing:

- **Albedo**: the base color sprite (48x48 transparent PNG, 8 directions)
- **Normal map**: per-pixel lighting information so a `PointLight2D` produces visible shading
- **Depth map**: reserved for future parallax or layering (loaded but not yet rendered)
- **manifest.json**: identity, render contract, and SHA-256 checksums for every file

The pack loader reads the manifest, validates the schema version (`1.0.0`), and builds a `CanvasTexture` per direction that combines albedo and normal layers.

### Engine bridge

When you press **B** in the roster scene, the client spawns `python -m portlight.app.cli rpc` as a child process. (The Python package is still called `portlight`; the user-facing product name is Star Freight.) Godot writes JSON-RPC 2.0 requests to the process's stdin and reads responses from stdout. The bridge exposes five methods: `ping`, `get_roster`, `get_crew_member`, `get_campaign`, and `shutdown`. If the Python engine is not installed, the client stays in visual-only mode and nothing breaks.

### Character node

`CharacterNode` is a `Node2D` subclass that wraps a `Sprite2D`. It holds a loaded pack, tracks a direction index (0--7), and applies the matching `CanvasTexture` whenever the direction changes. The default display scale is 4x, so a 48px sprite appears at 192px on screen.

### Scenes

The project has two scenes:

| Scene | Purpose |
|-------|---------|
| `main.tscn` | Entry point -- instances the roster scene |
| `roster.tscn` | Discovers packs, creates character nodes, handles keyboard input |

## Installation

1. Install [Godot 4.6.1](https://godotengine.org/download) (standard build, not the .NET variant).
2. Clone the repository:
   ```bash
   git clone https://github.com/mcp-tool-shop-org/star-freight-client.git
   ```
3. (Optional) Install the Python engine if you want the engine bridge:
   ```bash
   pip install -e /path/to/star-freight
   ```

No additional dependencies are needed. Godot reads the `project.godot` file and is ready to run.

## First steps

1. Open Godot 4.6, click **Import**, and select the `project.godot` file in the cloned folder.
2. Press **F5** (or the Play button) to launch. The roster scene discovers all packs in `assets/characters/` and displays them with a top-down point light.
3. Use **A/D** (or arrow keys) to rotate the selected character through all 8 directions. Watch how the normal map reacts to the light position.
4. Press **Tab** to cycle selection between characters. The direction label at the bottom updates to show the current character name and facing.
5. Press **Space** to rotate every character at once -- useful for verifying that all packs produce consistent results.
6. Press **B** to attempt an engine bridge connection. If the Python engine is installed and a save exists, the title bar shows the crew count.

## Common tasks

### Importing more sprite packs

The client ships with a few packs, but the foundry can produce 20. To import all available packs:

```bash
python scripts/import_packs.py
```

To import only specific characters:

```bash
python scripts/import_packs.py --subjects sera_vale,drift_maw
```

The script copies the latest foundry run for each subject into `assets/characters/`. Re-run the client afterward and the new characters appear automatically.

### Running the verify script

```bash
bash verify.sh
```

This checks that all required project files exist, every asset pack has a valid JSON manifest with schema version `1.0.0`, all GDScript files are valid UTF-8, and scene files are present. Run it after importing packs or editing scripts.

### Adjusting sprite scale

Open `character_node.gd` and change the `sprite_scale` export variable (default `4.0`). A value of `2.0` halves the display size; `6.0` makes sprites larger. You can also override the scale per-instance in the Godot inspector.

### Troubleshooting

**No characters appear** -- The `assets/characters/` folder is empty. Import packs with `python scripts/import_packs.py` and relaunch.

**Engine bridge says "offline"** -- Verify the Python `portlight` package is installed and that `python` is on your system PATH. The bridge calls `python -m portlight.app.cli rpc` internally. You also need at least one save file for the engine to return data.

**Pack loader warnings** -- If a pack fails to load, the roster skips it and logs a warning to the Godot console. Check that the pack directory contains a `manifest.json` with `schema_version: "1.0.0"` and that all eight albedo PNGs exist.

**verify.sh fails** -- The script requires `python` on PATH (for manifest JSON validation). On Windows, run it via Git Bash or WSL. It checks file structure, manifest schema, GDScript validity, and scene existence.

## Next steps

- Read the [Architecture](/star-freight-client/handbook/architecture/) page to understand the two-repo split and how the engine bridge works under the hood.
- Check the [Reference](/star-freight-client/handbook/reference/) for the full API of every script and the frozen export contract.
- Explore the [Security](/star-freight-client/handbook/security/) page to understand the trust model and data access scope.
- Look at the [star-freight](https://github.com/mcp-tool-shop-org/star-freight) repo for the Python engine that drives game logic.
- Look at the [star-freight-foundry](https://github.com/mcp-tool-shop-org/star-freight-foundry) repo if you want to generate new sprite packs.

## Glossary

| Term | Meaning |
|------|---------|
| **Albedo** | The base color texture of a sprite -- what you see without lighting effects. |
| **Normal map** | A texture that encodes surface direction per pixel, allowing a 2D sprite to react to lights as if it had 3D depth. |
| **Depth map** | A grayscale texture encoding distance from the viewer. Reserved for future parallax effects; loaded but not yet rendered. |
| **CanvasTexture** | A Godot resource that combines a diffuse (albedo) texture with a normal texture so 2D lights affect the sprite. |
| **Sprite pack** | A self-contained folder with albedo, normal, and depth PNGs for all 8 directions, plus a `manifest.json`. |
| **JSON-RPC** | A lightweight protocol for sending method calls as JSON objects. The client uses JSON-RPC 2.0 over stdio to talk to the Python engine. |
| **stdio** | Standard input/output -- the text streams every process has. The engine bridge writes requests to the Python process's stdin and reads responses from its stdout. |
| **Foundry** | The Sprite Foundry pipeline that generates character sprite packs using ComfyUI and post-processing. |
| **Visual-only mode** | The client's default state when no Python engine is connected. Packs load and render, but no game data is available. |
| **Export contract** | The frozen specification (v1.0.0) that defines sprite pack structure: 48x48 pixels, 8 directions, 3 layers, SHA-256 checksums. |
