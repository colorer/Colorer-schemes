# HRC coloring speed

How to write schemes so `TextParser` does less `CRegExp::parse()`, and so each parse does less NFA work. Matcher internals: Colorer-library skill `colorer-hrc` (`core-parse.md`) if that repo is available (example sibling path `../Colorer-library`). Virtual inherit is **not** flattened at load.

Do **not** change `priority="low"` — it decides inner match vs outer block `end`, not speed.

## What the engine already skips

Authors still control the expensive cases. Cheap rejects (no NFA):

| Filter | HRC meaning |
|--------|-------------|
| Scheme first-ASCII list | Node is not tried unless `canStartWith` the current char. Nullable prefix (`\s*`, `[+-]?`, leading `\b`) → **every** ASCII bucket. |
| `^` / `~` at the start | `mayMatch` fails when the column is not 0 / not scheme start. `/^#/` is the `#` bucket (leading `^` is skipped in first-char analysis), **not** every bucket. Mid-line `#` no longer enters the NFA. |
| `$` + bounded length | `/[^\\"]$/` only at `end-1`; a short end-RE with `$` is skipped while more than `maxLen` characters remain. `.*$` / `{n,}` / `\N` / `\y` are unbounded — no skip. `/m` disables the `$` skip. |
| Required ASCII on the **line** | If the pattern must contain `(` / `{` / a literal, lines without that character never call `parse()`. Optional `[+-]?` and `/i` letters do not count. |
| `\|` first char | `(about\|ftp\|http)` does not try the `about` branch on `f…`. A branch that starts with `\b` / `\m` / lookaround / `^` is not skipped (side effects). Prefer `<keywords>` anyway. |

`parse()` also caps NFA steps (default 1e6). Over that, the match **fails** (wrong coloring), it does not hang. Do not “fix” slowness by raising the limit in the library — fix the pattern.

Editors color at most one `maxBlockSize` window per line (default 1000) unless the host sets `chunkLongLines`. Outline / end-of-line regexps on minified lines may never see the tail in an editor; CLI goldens often chunk.

## Do

**Merge only adjacent `<regexp>` in one scheme.** Same first character, mutually exclusive tails, same (or named) regions. HRC order is priority; non-adjacent `|` changes “first match wins”.

Good (same region, exclusive tails):

```xml
<regexp match="/\b \d+\.\d* ([eE][\-+]?\d+)? \b/x" region0="NumberFloat"/>
<regexp match="/\b \d+ ([eE][\-+]?\d+) \b/x" region0="NumberFloat"/>
```

→ one `/\b \d+ ( \.\d* ([eE][\-+]?\d+)? | [eE][\-+]?\d+ ) \b/x`. Integers still miss both and hit `DecNumber`.

**Do not merge** Float with Dec, or different regions, without `(?{Region}…)`. `1.` and `1` must stay distinct. Do not put `DecNumber` before float (`1.5` would paint as `1` + `.5`).

**Hard first character.** `/foo/` not `/\s*foo/` or `/(bar)?foo/`. A nullable start (`*`, `?`, `\s*`, a leading `\b` with no literal after it) puts the regexp in **every** ASCII dispatch bucket.

Unmatched whitespace is skipped one character at a time. `/import\b/` after leading spaces equals `/^\s*import\b/` except the spaces are not part of the match. Use `^\s*` only when the start token must include that whitespace (or when `^` is required so a later `)` / `#` on the same line cannot match).

**Keep `$` on short end-REs** (`/#1 $/x`, `/[^\\"]$/`). The engine jumps to `eol - maxLen` instead of scanning the whole line. Do not write `.*$` “for speed”.

**Put a rare mandatory literal in outline / structure patterns** (`\(`, `\{`). The line mask then skips every line that cannot match. Optional prefixes do not help that filter.

**Prefer `[eE]` over `/i`** when only a few letters fold. `/i` also drops those letters from the required-char filter (non-ASCII case folds). `/x` is free (whitespace stripped at compile). Keywords `ignorecase="yes"` is cheaper than regexp `/i` for word lists.

**Negated class instead of `.*?`.** `(\\.|[^\\"])*` not `.*?"`. Doubled-quote languages: `"(?:[^"]|"")*"`, not `".*?"` (faster **and** `"a""b"` stays one string).

**No overlapping lazy prefixes.** Two `*?`/`+?` with intersecting classes, then a long absorbing tail (`[^;]* ($|\{)`), explode on a miss (`foo(a, b);`). Bound the tail so `{` cannot be skipped (`[^;\{]* (\{|$)`), and make the name/type prefix greedy. `c:FuncOutline` / `cpp` outlines are the example; a failed attempt still costs up to the step cap.

**Word lists in `<keywords>`**, not `/if|else|while/` or `/\bQtQuick\b/`. Do not merge `/if\b/` with `/ifdef\b/` via `|` (shorter `if` wins). When merging `#if|#else|#elseif`, put **longer** names first; `\b` often saves you, longer-first still should.

**Named regions to merge different paints with one first char:**

```xml
<regexp match="/(?:(?{def:NumberBin}0[bB][01_]+)|(?{def:NumberOct}0[oO][0-7_]+)|(?{def:NumberHex}0[xX][\da-fA-F_]+))/"/>
```

Put the `0` **inside** each `(?{Region}…)` or the prefix is uncolored. Prefer two regexps over `(group)?` if an optional capture blanks or shifts regions (go.sum `/go.mod`).

## `\b` and identifiers

Leading `\b` is nullable (every bucket). Drop it only when a **hard first character** is enough:

- Numbers `/0x…/` `/ \d+/` are only tried when the current char is `0` / a digit.
- If the scheme has **no** identifier token, the parser then steps into `foo2` / `a0x1` and the number regexp fires on the trailing digits. Keep `\b`, or add `/[A-Za-z_][\w]*/` (often `priority="low"`) so the whole identifier is consumed first.

`[\d_]+` matches a lone `_` (Swift wildcard). Use `\d[\d_]*`.

## Numbers: do not stack `def:Number` under language literals

`def:Number` has no underscores, no `0o`, no hex-float, and paints `0b` as `0` + suffix `b`. If it is inherited **before** language regexps, it steals `0xC` from `0xC.3p0` and `\B \.\d+` can eat the third dot of `1...10` as float `.10`.

Either inherit `def:Number` and **do not** add overlapping `0x`/`\d+` after it, or drop the inherit and write language numbers only (bin/oct/hex first, then float, then dec).

Split a nullable sign: `/[+-]…/` (first char `+`/`-`) and `/…/` (first char digit), not `/[+-]?…/`.

Do not copy C suffixes (`ul`, `i64`, `/i`) into JSON-like languages.

## Line-start `#` / `!`

`/^#/` is the `#` bucket plus a start-anchor skip at other columns. If the catch-all token **includes** `#` (gitignore Pattern), `foo#bar` is one token and `/#.*$/` (hard `#`) runs only when the cursor is already on `#` (BOL after skipped spaces, or after space/`*`). Same for `!`.

Trade-off: `foo #bar` and `dir/!x` then hit the special regexp. Keep `/^/` when that is wrong.

Block **end** `/^\s*\)\s*$/` — keep `^` if a `)` mid-line must not close the block (go.mod). Leading `\s*` still widens the first-char set to whitespace ∪ `)`.

## Do not

- Flatten or splice **virtual** inherit (`Script` → `phpScript`). Needed for embeddings.
- Touch `priority="low"` to “go faster”.
- Edit `**/gen/**` — rebuild from `./src`.
- Reorder general before specific.
- Put error/URL `.*?` regexps into a hot inherited scheme (`def:Number`) if they can live in a dedicated scheme.
- Rely on `.*?` / two lazy quantifiers with a shared class to “find the `{`”. The step cap will fail the match on long lines.

## After a change

`./build.sh base`, then parse goldens for that language. Region splits (`NumberFloat` vs `NumberDec`) show up in HTML.

Large-file cost: Colorer-library `tests/perftest` against `tests/performance/samples/` (sqlite3.c, PHP, …) with this catalog. Example: this repo and Colorer-library cloned under the same parent (`../Colorer-library`). A scheme-only change should not move goldens; if it does, show the token that changed.

No sample for this type: add `tests/test/<lang>/…` and golden `tests/test/_valid/<lang>/…html` (`./bin/colorer -c ./_build/base/catalog.xml -ht FILE -t TYPE -dc -dh -ln -o …`). Shared extensions (`.prg` clipper/foxpro): use one unique to the prototype (`.spr`).

`CHANGELOG.md` `[Unreleased]`: if valid-file coloring is unchanged, one line “speed up … matching”. If tokens/regions change, say what.

Contributors: `Aleksey <email>` inside non-CDATA XML is a tag and **the type fails to load** (empty highlighting). Use `<![CDATA[…]]>` or omit `<>`.
