---
title: Getting Started
description: Set up and run the Star Freight graphical client.
sidebar:
  order: 1
---

## Prerequisites

- **Godot 4.6.1** (standard build, not .NET) — [download](https://godotengine.org/download)
- **Python 3.11+** with the `star-freight` package installed
- **Windows 11** (primary development platform)

## Installation

Clone the repository:

```bash
git clone https://github.com/mcp-tool-shop-org/star-freight-client.git
```

Install the Python engine (required for the engine bridge):

```bash
pip install -e /path/to/star-freight
```

## Running

1. Open the project folder in Godot 4.6
2. Press **F5** to run the main scene
3. The roster scene loads all available character packs automatically

## Controls

| Key | Action |
|-----|--------|
| **A/D** or arrows | Rotate selected character facing |
| **Tab** | Cycle through characters |
| **Space** | Rotate all characters at once |
| **B** | Connect to Python engine bridge |
| **Esc** | Quit |

## First Run (Visual Only)

On first launch, the client works in **visual-only mode** — it loads sprite packs and displays characters without the engine. This proves the pack loader and character rendering pipeline.

Press **B** to attempt an engine bridge connection. If `starfreight` is installed and a save file exists, the title bar updates to show crew count from the engine.

## Importing More Packs

The foundry has 20 character packs. To import all of them:

```bash
python scripts/import_packs.py
```

To import specific characters:

```bash
python scripts/import_packs.py --subjects sera_vale,thal,varek
```

Packs are copied unchanged into `assets/characters/` with their manifests intact.
