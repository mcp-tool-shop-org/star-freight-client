# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-03-26

### Added

- Godot 4.6 project scaffold with 960x640 viewport
- Pack loader (`pack_loader.gd`): manifest-driven sprite pack discovery and loading with CanvasTexture (albedo + normal)
- Engine bridge (`engine_bridge.gd`): JSON-RPC 2.0 client over stdio, spawns `starfreight rpc` subprocess
- Character node (`character_node.gd`): Sprite2D wrapper with 8-direction switching and normal map support
- Roster scene (`roster_scene.gd`): crew display with keyboard controls (A/D rotate, Tab select, Space all, B bridge)
- Import script (`import_packs.py`): copies foundry export packs into client repo
- 3 imported sprite packs: Sera Vale (crew), Drift Maw (creature), Scav Raider (hostile)
- CI workflow: structure validation and GDScript syntax checks
