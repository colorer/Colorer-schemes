---
name: colorer-hrd-authoring
description: Create and maintain Colorer HRD style files (region-to-color maps). Use when adding or editing HRD themes, RGB/console palettes, catalog-rgb.xml, catalog-console.xml, or adapting editor themes (Monokai, Solarized, Dos Navigator).
---

# Colorer HRD Authoring

HRD maps HRC region names (`def:Keyword`, …) to colors/styles. It does **not** define syntax.

## Layout

| Path | Role |
|------|------|
| `./base/hrd/rgb/` | GUI / truecolor. Edit here. |
| `./base/hrd/console/` | 16-color VGA (`#0`–`#F`). Edit here. |
| `./base/hrd/text/` | HTML generator (`stext`/`etext` tags). Rare. |
| `./base/hrd/rgb/contrib/`, `./base/hrd/console/contrib/` | Third-party one-offs. |
| `./base/hrd/catalog-rgb.xml` (and `-console`, `-text`) | Catalog fragments (entity-included). |
| `./base/hrd/css/` | Generated from RGB at full `src` build. Newer RGB themes often have **no** committed CSS (`far2l`, popular palettes). Do not hand-edit. |
| `./_build/base/` | After `./build.sh base`. Always `-c ./_build/base/catalog.xml`. |

First-party palettes (Monokai, Solarized, FAR/DN, …) live in `rgb/` and `console/` roots, not `contrib/`. `./build.sh base` copies `base/hrd` as-is.

## Workflow

1. **Class** — `rgb` (hex `#rrggbb`), `console` (`#0`–`#F`), or both. `-h` HTML uses **rgb**; `-v` viewer uses **console**. Same `name` is allowed in both classes.
2. **Template** — complete style: `base/hrd/rgb/white.hrd` or `far2l.hrd` or a popular palette; minimal: `eclipse.hrd`. Console: `default.hrd` / `dnlike.hrd`. Full region list: [examples.md](examples.md).
3. **Assign** — `def:Text` (fg **and** bg). Then numbers, strings, comments, symbols, keywords, tags, errors, pairs. See [reference.md](reference.md#inheritance).
4. **Catalog** — add `<hrd>` to `catalog-rgb.xml` and/or `catalog-console.xml`. `name` is NMTOKEN (kebab-case, **no spaces**). Then **re-sort that file** by `description` (case-insensitive); 8-space indent on `<hrd>` / `</hrd>`.
5. **Changelog** — `CHANGELOG.md` → `[Unreleased]` Added/Changed, `[hrd] …`.
6. **Test** — `./build.sh base`, then the checks below.

Adapting an external palette (VS Code, Sublime, FAR, …): use **only** colors from that source. Map editor default → `def:Text`, selection/cursor → `HorzCross` / `PairStart`. Keywords, strings, comments, numbers must differ from Text fg **and** bg. If the source already names VGA indices (`F_YELLOW`, `B_CYAN`), use those for the console twin (see [reference.md](reference.md#vga)).

## Tests

Always `./build.sh base` first (or `validate.py`, which builds).

| Layer | Command | What it checks |
|-------|---------|----------------|
| Smoke | `python .agents/skills/colorer-hrd-authoring/scripts/validate.py <hrd> <class> <name> [sample]` | XML, catalog entry, optional `-h` |
| HTML (rgb) | `./bin/colorer -c ./_build/base/catalog.xml -h -iNAME FILE [-t TYPE] [-ln]` | Inline colors by eye |
| Viewer (console) | `./bin/colorer -c ./_build/base/catalog.xml -v -iNAME FILE` | 16-color |
| Load | `./build.sh test.load` | Catalog load; success = `✅ Success: there are no unknown errors in the log.` |

HRD changes do **not** require `test.parse` goldens (`-ht` is region classes, not this palette).

## Conventions

- `name="theme-id"` kebab-case; `description` is the UI label (sort key).
- `<?xml … UTF-8?>` + Colorer HRD take5 doctype + `xmlns="http://colorer.sf.net/2003/hrd"`.
- Optional `<documentation>…</documentation>` before assigns. Console twin: append `, 16-color console approximation.`
- `style`: `1` bold, `2` italic, `4` underline (bitmask; `3` = bold+italic). Modern dark themes: comments italic (`2`). Console may keep the same bits.
- **Inheritance trap:** undeclared region → parent HRD colors. Declared region **missing** `fore`/`back` → runtime fill (`def:Text`), **not** the parent. Either omit the child or set its colors.
- Children that share a parent color (all `Number*`) may repeat the same `fore`. `ParameterUnknown` must not equal Text fg on light themes (white-on-white).
- `HorzCross` = current line; `VertCross` = column. Distinct `back` from `def:Text`.
- Popular RGB → console: [reference.md](reference.md#rgb-to-console). Near-black bg → `#0`, near-white → `#F` (do not turn Solarized Dark into cyan). Then keep keyword/string/comment/number distinct from fg/bg; comments prefer `#8` over `#F`.
- Do not invent CSS under `base/hrd/css/` for new RGB themes unless the user asks.

## Resources

- [examples.md](examples.md) — RGB/console templates, catalog entry
- [reference.md](reference.md) — regions, inheritance, VGA, console mapping
- HRC regions live in `base/hrc/lib/def.hrc`; syntax skill: `colorer-hrc-authoring`
