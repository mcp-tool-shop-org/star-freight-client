#!/usr/bin/env python3
"""Import sprite packs from the foundry exports into the client repo.

Usage:
    python scripts/import_packs.py [--source F:/AI/star-freight-foundry/exports]
    python scripts/import_packs.py --subjects sera_vale,drift_maw,scav_raider

Copies packs unchanged into assets/characters/{slug}/ with manifest intact.
Only copies the latest run for each subject.
"""

import argparse
import json
import shutil
from pathlib import Path

DEFAULT_SOURCE = Path("F:/AI/star-freight-foundry/exports")
TARGET = Path(__file__).parent.parent / "assets" / "characters"


def find_latest_run(subject_dir: Path) -> Path | None:
    """Find the latest run directory for a subject (by mtime)."""
    runs = [d for d in subject_dir.iterdir() if d.is_dir() and (d / "manifest.json").exists()]
    if not runs:
        return None
    return max(runs, key=lambda d: d.stat().st_mtime)


def import_pack(subject_slug: str, source_root: Path) -> bool:
    """Import a single subject's latest pack."""
    subject_dir = source_root / subject_slug
    if not subject_dir.exists():
        print(f"  SKIP {subject_slug}: not found in {source_root}")
        return False

    run_dir = find_latest_run(subject_dir)
    if run_dir is None:
        print(f"  SKIP {subject_slug}: no valid runs")
        return False

    target_dir = TARGET / subject_slug
    if target_dir.exists():
        shutil.rmtree(target_dir)

    shutil.copytree(run_dir, target_dir)

    manifest = json.loads((target_dir / "manifest.json").read_text())
    name = manifest.get("identity", {}).get("display_name", subject_slug)
    file_count = len(manifest.get("files", {}))
    print(f"  OK   {name} ({subject_slug}) — {file_count} files")
    return True


def main():
    parser = argparse.ArgumentParser(description="Import foundry sprite packs")
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE,
                        help="Foundry exports directory")
    parser.add_argument("--subjects", type=str, default=None,
                        help="Comma-separated subject slugs (default: all)")
    args = parser.parse_args()

    if not args.source.exists():
        print(f"Source not found: {args.source}")
        return

    TARGET.mkdir(parents=True, exist_ok=True)

    if args.subjects:
        slugs = [s.strip() for s in args.subjects.split(",")]
    else:
        slugs = [d.name for d in sorted(args.source.iterdir()) if d.is_dir()]

    print(f"Importing {len(slugs)} packs from {args.source}")
    imported = sum(1 for s in slugs if import_pack(s, args.source))
    print(f"\nDone: {imported}/{len(slugs)} imported to {TARGET}")


if __name__ == "__main__":
    main()
