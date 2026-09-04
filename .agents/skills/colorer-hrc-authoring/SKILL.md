---
name: colorer-hrc-authoring
description: Create and maintain Colorer HRC syntax files. Use when adding or editing HRC types, prototypes, regions, or debugging coloring in the colorer base catalog.
---

# Colorer HRC Authoring

## Layout

Schemes in `./base/hrc` are of two kinds:

- **Static** — edit in place under `./base/hrc` (any path **except** `gen/`).
- **Dynamic** — generated from `./src`; always live under `**/gen/` inside `./base`. **Never edit these files directly** — change sources in `./src` instead.

If you must change generation logic or a generated scheme, follow **Workflow for Modifying Generated Schemes (Advanced)** in [README.md](../../../README.md) (`cd src && ./build.sh base`, then copy `src/build/` into `base/`, then test from the repo root).

| Path | Role |
|------|------|
| `./base/hrc/` (not `gen/`) | Static HRC — normal edits and new types. Learn from here. |
| `./base/hrc/**/gen/` | Generated HRC — read-only; rebuild from `./src`. |
| `./src/` | Generators/sources for dynamic schemes. |
| `./_build/base/` | Runnable catalog after `./build.sh base`. Always `-c ./_build/base/catalog.xml`. |

New types are almost always static: put them under `./base/hrc/` next to similar files (`base/`, `scripts/`, `rare/`, `inet/`, `db/`, `misc/`, `xml/`, …), never under `gen/`.


## Workflow

1. **Sample** — get a sample file; list keywords, strings, comments, numbers, blocks.
2. **Template** — copy a close match from `./base/hrc/` (see [examples.md](examples.md)).
3. **HRC** — `<type name>` = main `<scheme name>`; regions from `def:*`; `<regexp>` for line tokens, `<block>` for nesting.
4. **Prototype** — add to `base/hrc/proto.hrc` (`name` matches type; `<filename>` / `<firstline>` as needed; `<location link="…">` relative to `hrc/`).
5. **Author / license** — see below.
6. **Test** — `./build.sh base`, then the checks below.

## Authorship and license

Author from git only: `git config user.name` / `git config user.email` (current year for copyright).

- **New file:** `<annotation><contributors>` with that author; after `</hrc>`, MIT comment block (full text in [examples.md](examples.md)).
- **Edit existing:** do not change the trailing license; append the git author to `type` → `annotation` → `contributors` (create the block if missing). Skip if already listed.

## Tests

Always `./build.sh base` before colorer / load / parse (or use `validate.py`, which builds itself).

| Layer | Command | What it checks |
|-------|---------|----------------|
| Smoke | `python .agents/skills/colorer-hrc-authoring/scripts/validate.py <hrc> <type> [sample] [out.html]` | XML, prototype, type listed; optional `-ht` |
| HTML | `./bin/colorer -c ./_build/base/catalog.xml -ht FILE -o out.html -t TYPE` | Regions / CSS classes by eye |
| Load | `./build.sh test.load` | Catalog load; log vs `tests/test_load/ignored_error.txt` |
| Parse | `./build.sh test.parse` | HTML for `./tests/test` vs golden `./tests/test/_valid` → `./_test/test_*` |

- **Load:** success = `✅ Success: there are no unknown errors in the log.` Extend `ignored_error.txt` only for unavoidable pre-existing noise.
- **Parse:** no diffs ideally. If a scheme fix intentionally changes output, review then copy from `./_test/test_*` into `./tests/test/_valid`.
- **New scheme:** add ≥1 sample under `./tests/test/<lang>/` and matching golden `./tests/test/_valid/<lang>/…html`.

## Conventions

- Regions: `CapitalCase`. Schemes: lowercase with dashes/dots.
- Prefer parents: `def:Keyword`, `def:String`, `def:Number`, `def:Comment`, `def:Symbol`, `def:Error`, `def:PairStart`/`def:PairEnd`.
- Catch-alls: `priority="low"`.
- In `<block>`, `region00` = whole start match, `region01` = first capture — swap if a keyword is colored as a symbol.
- Type missing from `-lt` → prototype path, well-formed XML, and rebuild.

## Resources

- [examples.md](examples.md) — copy-paste HRC + MIT footer, snippets
- [reference.md](reference.md) — regions numbering, CLI, regexp tips
- [speed.md](speed.md) — write regexps/keywords so coloring does fewer `CRegExp::parse()`; do not change `priority="low"`
- [hrc-ref.md](hrc-ref.md) — full HRC / regexp reference
