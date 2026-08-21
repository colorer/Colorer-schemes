#!/usr/bin/env python3
"""Validate a new Colorer HRC type."""

import subprocess
import sys
from pathlib import Path
from xml.etree import ElementTree as ET

REPO_ROOT = Path(__file__).resolve().parents[4]
CATALOG = REPO_ROOT / "_build" / "base" / "catalog.xml"
PROTO = REPO_ROOT / "base" / "hrc" / "proto.hrc"
COLORER = REPO_ROOT / "bin" / "colorer"
BUILD_SH = REPO_ROOT / "build.sh"


def ensure_built_catalog() -> str | None:
    result = subprocess.run(
        [str(BUILD_SH), "base"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        timeout=300,
    )
    if result.returncode != 0:
        return f"build.sh base failed: {result.stderr or result.stdout}"
    if not CATALOG.exists():
        return f"built catalog not found after build: {CATALOG}"
    return None


def xml_well_formed(hrc_path: Path) -> str | None:
    try:
        ET.parse(hrc_path)
        return None
    except ET.ParseError as e:
        return f"XML parse error: {e}"


def extract_type_name(hrc_path: Path) -> str | None:
    tree = ET.parse(hrc_path)
    ns = {"hrc": "http://colorer.sf.net/2003/hrc"}
    el = tree.find(".//hrc:type", ns)
    return el.get("name") if el is not None else None


def prototype_registered(type_name: str) -> bool:
    text = PROTO.read_text(encoding="utf-8")
    return f'name="{type_name}"' in text


def colorer_lists_type(type_name: str) -> bool:
    result = subprocess.run(
        [str(COLORER), "-c", str(CATALOG), "-lt"],
        capture_output=True,
        text=True,
        timeout=120,
    )
    return result.returncode == 0 and type_name in result.stdout.splitlines()


def colorer_highlights(sample_path: Path, type_name: str, output_path: Path) -> str | None:
    result = subprocess.run(
        [str(COLORER), "-c", str(CATALOG), "-ht", str(sample_path), "-o", str(output_path), "-t", type_name],
        capture_output=True,
        text=True,
        timeout=60,
    )
    if result.returncode != 0:
        return f"colorer failed: {result.stderr or result.stdout}"
    return None


def main() -> int:
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <hrc-file> <type-name> [sample-file] [output-html]", file=sys.stderr)
        return 2

    hrc_path = Path(sys.argv[1])
    type_name = sys.argv[2]
    sample_path = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    output_path = Path(sys.argv[4]) if len(sys.argv) > 4 else None

    errors = []

    if not hrc_path.exists():
        errors.append(f"HRC file not found: {hrc_path}")
    else:
        err = xml_well_formed(hrc_path)
        if err:
            errors.append(err)
        else:
            detected = extract_type_name(hrc_path)
            if detected != type_name:
                errors.append(f"type name mismatch: file has '{detected}', expected '{type_name}'")

    if not prototype_registered(type_name):
        errors.append(f"prototype for '{type_name}' not found in {PROTO}")

    if not COLORER.exists():
        errors.append(f"colorer binary not found: {COLORER}")
    else:
        build_err = ensure_built_catalog()
        if build_err:
            errors.append(build_err)
        elif not colorer_lists_type(type_name):
            errors.append(f"colorer does not list type '{type_name}'")

    if sample_path and output_path and not errors:
        if not sample_path.exists():
            errors.append(f"sample file not found: {sample_path}")
        else:
            err = colorer_highlights(sample_path, type_name, output_path)
            if err:
                errors.append(err)

    if errors:
        print("Validation FAILED:")
        for e in errors:
            print(f"  - {e}")
        return 1

    print("Validation OK.")
    if sample_path and output_path:
        print(f"HTML output: {output_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
