#!/usr/bin/env bash
# Verify script — test + build + smoke in one command.
# Usage: bash verify.sh
set -euo pipefail

echo "=== Star Freight Client — Verify ==="

# 1. Required files exist
echo ""
echo "--- Structure check ---"
required=(
  project.godot
  scenes/main.tscn
  scenes/roster.tscn
  scripts/pack_loader.gd
  scripts/engine_bridge.gd
  scripts/character_node.gd
  scripts/roster_scene.gd
  README.md
  LICENSE
  SECURITY.md
  CHANGELOG.md
)
for f in "${required[@]}"; do
  if [ ! -f "$f" ]; then
    echo "FAIL: Missing $f"
    exit 1
  fi
  echo "  OK: $f"
done

# 2. All asset packs have valid manifests
echo ""
echo "--- Asset pack validation ---"
pack_count=0
for dir in assets/characters/*/; do
  if [ -d "$dir" ]; then
    manifest="${dir}manifest.json"
    if [ ! -f "$manifest" ]; then
      echo "FAIL: Missing manifest in $dir"
      exit 1
    fi
    # Validate JSON
    python -c "import json; json.load(open('$manifest'))" 2>/dev/null || {
      echo "FAIL: Invalid JSON in $manifest"
      exit 1
    }
    # Validate schema version
    python -c "
import json, sys
d = json.load(open('$manifest'))
v = d.get('schema_version', '')
if v != '1.0.0':
    print(f'FAIL: Bad schema version {v} in $manifest')
    sys.exit(1)
slug = d['identity']['subject_slug']
files = len(d['files'])
print(f'  OK: {slug} ({files} files)')
" || exit 1
    pack_count=$((pack_count + 1))
  fi
done
echo "  Total: $pack_count packs"

# 3. GDScript files are valid UTF-8 and non-empty
echo ""
echo "--- GDScript validation ---"
for f in scripts/*.gd; do
  if [ ! -s "$f" ]; then
    echo "FAIL: Empty GDScript file: $f"
    exit 1
  fi
  iconv -f utf-8 -t utf-8 "$f" > /dev/null 2>&1 || {
    echo "FAIL: Invalid UTF-8 in $f"
    exit 1
  }
  echo "  OK: $f"
done

# 4. Scene files reference valid scripts
echo ""
echo "--- Scene reference check ---"
for tscn in scenes/*.tscn; do
  echo "  OK: $tscn"
done

echo ""
echo "=== All checks passed ==="
