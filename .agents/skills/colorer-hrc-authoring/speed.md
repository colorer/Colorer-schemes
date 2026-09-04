# HRC coloring speed

How to write schemes so `TextParser` does less `CRegExp::parse()`. Engine facts (Colorer-library): first-ASCII dispatch, keyword first-char probe, non-virtual inherit flattened at load. Virtual inherit is **not** flattened.

Do **not** change `priority="low"` — it decides inner match vs outer block `end`, not speed.

## Do

**Merge only adjacent `<regexp>` in one scheme.** Same first character, mutually exclusive tails, same (or named) regions. HRC order is priority; non-adjacent `|` changes “first match wins”.

Good (same region, exclusive tails):

```xml
<regexp match="/\b \d+\.\d* ([eE][\-+]?\d+)? \b/x" region0="NumberFloat"/>
<regexp match="/\b \d+ ([eE][\-+]?\d+) \b/x" region0="NumberFloat"/>
```

→ one `/\b \d+ ( \.\d* ([eE][\-+]?\d+)? | [eE][\-+]?\d+ ) \b/x`. Integers still miss both and hit `DecNumber`.

**Do not merge** Float with Dec, or different regions, without `(?{Region}…)`. `1.` and `1` must stay distinct. Do not put `DecNumber` before float (`1.5` would paint as `1` + `.5`).

**Hard first character.** `/foo/` not `/\s*foo/` or `/(bar)?foo/`. A nullable start (`*`, `?`, `\s*`, lone `^$ \b`) puts the regexp in **every** ASCII dispatch bucket.

**Prefer `[eE]` over `/i`** when only a few letters fold. `/x` is free (whitespace stripped at compile). Keywords `ignorecase="yes"` is cheaper than regexp `/i` for word lists.

**Negated class instead of `.*?`.** `(\\.|[^\\"])*` not `.*?"`.

**Word lists in `<keywords>`**, not `/if|else|while/`. Do not merge `/if\b/` with `/ifdef\b/` via `|` (shorter `if` wins).

## Do not

- Flatten or splice **virtual** inherit (`Script` → `phpScript`). Needed for embeddings.
- Touch `priority="low"` to “go faster”.
- Edit `**/gen/**` — rebuild from `./src`.
- Reorder general before specific.
- Put error/URL `.*?` regexps into a hot inherited scheme (`def:Number`) if they can live in a dedicated scheme.

## After a change

`./build.sh base`, then parse goldens for that language. Region splits (`NumberFloat` vs `NumberDec`) will show up in HTML.
