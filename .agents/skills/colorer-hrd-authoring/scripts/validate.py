#!/usr/bin/env python3
"""Validate a Colorer HRD style and its catalog entry."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path
from xml.etree import ElementTree as ET

REPO_ROOT = Path(__file__).resolve().parents[4]
CATALOG = REPO_ROOT / "_build" / "base" / "catalog.xml"
COLORER = REPO_ROOT / "bin" / "colorer"
BUILD_SH = REPO_ROOT / "build.sh"
CATALOG_FILES = {
    "rgb": REPO_ROOT / "base" / "hrd" / "catalog-rgb.xml",
    "console": REPO_ROOT / "base" / "hrd" / "catalog-console.xml",
    "text": REPO_ROOT / "base" / "hrd" / "catalog-text.xml",
}


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


def xml_well_formed(hrd_path: Path) -> str | None:
    text = hrd_path.read_text(encoding="utf-8")
    stripped = re.sub(r"<!DOCTYPE[^>]*>", "", text, count=1)
    try:
        ET.fromstring(stripped)
        return None
    except ET.ParseError as e:
        return f"XML parse error: {e}"


def catalog_registered(hrd_class: str, name: str) -> tuple[bool, str | None]:
    path = CATALOG_FILES.get(hrd_class)
    if path is None:
        return False, f"unknown class {hrd_class!r} (rgb|console|text)"
    text = path.read_text(encoding="utf-8")
    ok = bool(
        re.search(
            rf'<hrd\s+class="{re.escape(hrd_class)}"\s+name="{re.escape(name)}"',
            text,
        )
    )
    return ok, None


def colorer_html(sample: Path, name: str, output: Path) -> str | None:
    result = subprocess.run(
        [
            str(COLORER),
            "-c",
            str(CATALOG),
            "-h",
            f"-i{name}",
            str(sample),
            "-o",
            str(output),
            "-db",
        ],
        capture_output=True,
        text=True,
        timeout=60,
    )
    if result.returncode != 0:
        return f"colorer -h failed: {result.stderr or result.stdout}"
    return None


def main() -> int:
    if len(sys.argv) < 4:
        print(
            f"Usage: {sys.argv[0]} <hrd-file> <class> <name> [sample-file] [output-html]",
            file=sys.stderr,
        )
        return 2

    hrd_path = Path(sys.argv[1])
    hrd_class = sys.argv[2]
    name = sys.argv[3]
    sample = Path(sys.argv[4]) if len(sys.argv) > 4 else None
    output = Path(sys.argv[5]) if len(sys.argv) > 5 else Path("/tmp") / f"hrd-{name}.html"

    errors: list[str] = []
    if not hrd_path.is_file():
        errors.append(f"missing file: {hrd_path}")
    else:
        err = xml_well_formed(hrd_path)
        if err:
            errors.append(err)

    ok, cat_err = catalog_registered(hrd_class, name)
    if cat_err:
        errors.append(cat_err)
    elif not ok:
        errors.append(f"{name!r} not in catalog-{hrd_class}.xml")

    if errors:
        print("FAIL")
        for e in errors:
            print(f"  {e}")
        return 1

    build_err = ensure_built_catalog()
    if build_err:
        print("FAIL")
        print(f"  {build_err}")
        return 1

    if sample is not None:
        if hrd_class != "rgb":
            print("WARN: -h uses rgb class; skip HTML for console/text")
        elif not sample.is_file():
            print("FAIL")
            print(f"  missing sample: {sample}")
            return 1
        else:
            html_err = colorer_html(sample, name, output)
            if html_err:
                print("FAIL")
                print(f"  {html_err}")
                return 1
            print(f"html {output}")

    print(f"OK {hrd_class}/{name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
