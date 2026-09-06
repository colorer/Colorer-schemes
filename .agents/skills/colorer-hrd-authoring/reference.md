# HRD reference

## Inheritance

Colorer looks up HRD in this order:

1. Exact `assign name="type:Region"` in the loaded HRD set (later assign wins).
2. If the region is **not** in HRD at all → walk the HRC **parent** chain (`NumberHex` → `Number` → …).
3. If the region **is** in HRD but `fore` or `back` is omitted → transparent; fill comes from the **runtime scheme background** (`def:Text` at top level), not from the HRC parent.

Practical rule: omit unused children, **or** give them `fore`. Never declare `<assign name="def:Keyword"/>` with no colors.

`def:Text` must set both `fore` and `back` (editor default).

## `style` bits

| Bit | Value | CSS |
|-----|-------|-----|
| bold | 1 | `font-weight: bold` |
| italic | 2 | `font-style: italic` |
| underline | 4 | `text-decoration: underline` |

Combine: `3` = bold+italic. Attribute is a single digit in the XSD.

## `def:*` regions

From `base/hrc/lib/def.hrc`. Assign at least the **bold** parents; children inherit if omitted.

| Region | Role in a palette |
|--------|-------------------|
| `Text` | Default fg/bg |
| `HorzCross` / `VertCross` | Current line / column (`back` ≠ Text `back`) |
| `Number` (+ Dec/Hex/Bin/Oct/Float/Suffix/Prefix) | Numbers |
| `String` / `StringContent` / `StringEdge` | String, escapes, quotes |
| `Character` / `CharacterContent` | `'x'` |
| `Comment` / `LineComment` / `CommentContent` / `CommentEdge` | Comments |
| `CommentDoc*` | Doc comments (`/**`, `///`) |
| `Symbol` / `SymbolStrong` / `Operator` | Punctuation / operators |
| `Prefix` / `PrefixStrong` | `++`, `*`, language prefixes |
| `Keyword` / `KeywordStrong` | Keywords |
| `TypeKeyword` / `ClassKeyword` / `StructKeyword` / `FunctionKeyword` / `InterfaceKeyword` | Types / class / fn-as-keyword |
| `DeprecatedKeyword` | Often underline (`style='4'`) |
| `Constant` / `BooleanConstant` | `true` / `NULL` |
| `Function` | Function **definition** (outlined; many schemes never hit this) |
| `Var` / `VarStrong` / `Identifier` | Variables / names |
| `Register` | ASM registers |
| `Directive*` | Preprocessor |
| `Parameter*` | XML attrs, params; `ParameterUnknown` = error-ish, not Text fg |
| `Tag` / `OpenTag` / `CloseTag` / `EmbeddedTag` | Markup |
| `Label` / `LabelStrong` | Labels; Strong often inverted bg |
| `Insertion*` | Embedded language (PHP in HTML): slightly different `back` |
| `Error` / `ErrorText` / `TODO` / `Debug` | Diagnostics (`Error` usually fg+bg) |
| `URI` / `URL` / `Path` / `EMail` | Links (often `style='4'`) |
| `Date` / `Time` | Dates |
| `PairStart` / `PairEnd` | Matching brackets |
| `PairStrongStart` / `PairStrongEnd` | Blocked / nested pair |

Do not assign `def:default` (transparent). `def:Syntax` / `def:Special` / `def:Outlined` are usually omitted.

Typical TextMate/VS Code → Colorer:

| Scope | Region |
|-------|--------|
| comment | `Comment` (doc → `CommentDoc`) |
| string | `String` (escape → `StringContent`) |
| constant.numeric | `Number` |
| keyword | `Keyword` |
| storage.type / entity.name.class | `TypeKeyword` / `ClassKeyword` |
| entity.name.function | `Function` / `FunctionKeyword` |
| variable | `Var` |
| keyword.operator | `Operator` |
| entity.name.tag | `Tag` |
| entity.other.attribute-name | `Parameter` |
| invalid | `Error` |

## VGA {#vga}

Console HRD uses one hex digit. FAR / VGA `B_*` / `F_*` names:

| Index | Name | RGB |
|-------|------|-----|
| `#0` | BLACK | `#000000` |
| `#1` | BLUE | `#0000AA` |
| `#2` | GREEN | `#00AA00` |
| `#3` | CYAN | `#00AAAA` |
| `#4` | RED | `#AA0000` |
| `#5` | MAGENTA | `#AA00AA` |
| `#6` | BROWN | `#AA5500` |
| `#7` | LIGHTGRAY | `#AAAAAA` |
| `#8` | DARKGRAY | `#555555` |
| `#9` | LIGHTBLUE | `#5555FF` |
| `#A` | LIGHTGREEN | `#55FF55` |
| `#B` | LIGHTCYAN | `#55FFFF` |
| `#C` | LIGHTRED | `#FF5555` |
| `#D` | LIGHTMAGENTA | `#FF55FF` |
| `#E` | YELLOW | `#FFFF55` |
| `#F` | WHITE | `#FFFFFF` |

When the source already uses those names, copy them (`F_RED` → `#4`, not `#C`; `F_YELLOW` → `#E`; `B_CYAN` → `#3`; LIGHTGRAY on DARKGRAY → `#7` / `#8`).

## RGB → console {#rgb-to-console}

Do **not** use raw Euclidean RGB on backgrounds: `#002b36` (Solarized Dark) is a dark teal and snaps to cyan `#3`. Use luminance first.

1. Parse `#rrggbb` → HLS.
2. If `L < 0.16` → `#0`. If `L > 0.82` → `#F`.
3. If saturation `< 0.22` → gray ramp `#8` / `#7` / `#F`.
4. Else hue buckets: red `#4`, orange/yellow `#6` (bright yellow `#E` or `#C`), green `#2`, cyan `#3`, blue `#1`, magenta `#5`; add 8 if light.
5. Force `def:Text` fg ≠ bg. `HorzCross`/`VertCross` `back` ≠ Text `back`.
6. Uniquify in order: Keyword, String, Comment, Number — each `fore` must not equal Text fg/bg or a previous role. If the original was gray, prefer `#8` before `#F` (white comments on black are unreadable).
7. After uniquifying a parent (`Number`), copy that index to siblings that shared the old color (`NumberDec`, …).

`def:Text` fg/bg define the theme (black `#0`, gray editor `#7`/`#8`, cyan DN `#0`/`#3`, light `#8`/`#F` or `#0`/`#F`).

## Catalog

Fragments have **no** XML root; they are `&catalog-rgb;` inside `base/catalog.base.xml`.

```xml
        <hrd class="rgb" name="my-theme" description="My Theme">
            <location link="&hrd;/rgb/my-theme.hrd"/>
        </hrd>
```

`class` matches the folder. `name` = filename without `.hrd` when possible. After insert or description edit, sort **all** `<hrd>…</hrd>` in that file by `description.casefold()`, keep eight spaces on the wrapper tags. Multiple `<location>` on one entry are allowed (`gray` stacks two files).

`stext` / `etext` / `sback` / `eback` are for `text` class (HTML wrappers), not rgb/console colors.

## Colorer CLI

```
./bin/colorer -c ./_build/base/catalog.xml -h -imonokai -t python FILE
./bin/colorer -c ./_build/base/catalog.xml -v -idn FILE
```

`-i` is the catalog `name`. `-h` always loads class `rgb`.
