# Colorer HRC Reference

Read when you need detail beyond [SKILL.md](SKILL.md). For a full file template and MIT footer, use [examples.md](examples.md).

## Prototype

In `base/hrc/proto.hrc`, near related entries. `link` is relative to `hrc/`:

```xml
<prototype name="mytype" group="main" description="My Language">
    <location link="base/mytype.hrc" />
    <filename>/\.ext$/i</filename>
    <firstline>/^#!/</firstline>
</prototype>
```

Prefer one `<filename>` regexp that lists all extensions for the type (`/\.(kt|kts)$/i`). A second `<filename>` is fine when the pattern is a full name (`/^meson\.build$/i`), not as a way to attach a fake `weight`.

## Prototype weights

Autodetect (`chooseFileType`) sums every matching `<filename>` and `<firstline>` on the prototype. Highest sum wins; **ties keep the first prototype in `proto.hrc`**.

| Element | Default `weight` |
|---------|------------------|
| `<filename>` | **2** |
| `<firstline>` | **1** |

- **Firstline always scores**, even when the filename did not match. (A comment in the engine about “content only after filename > 0” is stale.)
- The CLI concatenates about the first 4 lines / 500 bytes (`default` type’s `firstlines` / `firstlinebytes`) and runs each firstline RE on that blob. A firstline **without `^`** can match anywhere in the blob; several firstline rules on the same type **add up**.
- Type `default` has `<filename weight='1'>//</filename>` and matches every name. A unique extension at default 2 already beats it.

**Do not set `weight` on a unique extension.** `weight="5"` / `"10"` does not “make autodetection more reliable” if nothing else claims that name.

Raise `weight` only when you have counted a real competitor:

1. Another type’s **filename** matches the same path (shared extension, `\.txt$`, …), or
2. Another type’s **firstline** sum is ≥ 2 **and** that type is listed **earlier** in `proto.hrc` (ties go to the earlier entry).

Existing justified examples: `.ss` / `.twig` (10 vs a shared suffix), `CMakeLists.txt` (3 vs `text`’s `.txt`), yaml (10), json (3). Unjustified: extra weight on `.pyi`, `.scss`, `.prisma`, `.vue` — default filename 2 already beat qml/cpp/pascal `firstline` (1).

When a firstline steals a file that has **no** filename rule (`.pyi` → qml `import`, `.scss` → cpp `//`, `.ipynb` → pascal `{`), the fix is to **add `<filename>`**, not to inflate `weight`.

## `<block>` region numbering

For start `/(keyword)(\()/`, end `/(\))/`:

| Attr | Meaning |
|------|---------|
| `region00` | whole `start` match |
| `region01` | 1st capture in `start` |
| `region02` | 2nd capture in `start` |
| `region10` | whole `end` match |
| `region11` | 1st capture in `end` |

First digit: `0` = start, `1` = end. Second digit: capture index (`0` = entire match).

```xml
<block start="/(require)\s*\(\s*$/"
       end="/^\s*\)\s*$/"
       scheme="requireBlock"
       region00="Symbol" region01="Keyword" region10="Symbol"/>
```

## Colorer CLI

After `./build.sh base`:

| Command | Purpose |
|---------|---------|
| `./bin/colorer -c ./_build/base/catalog.xml -lt` | List types |
| `./bin/colorer -c ./_build/base/catalog.xml -ht FILE [-t TYPE] [-o out.html]` | Tokenized HTML |

## Default regions

`def:Keyword`, `def:String`, `def:Number`, `def:Comment` / `def:LineComment`, `def:Symbol`, `def:Error`, `def:PairStart` / `def:PairEnd`.

## Regexp notes

- Line-bound except `<firstline>`.
- `/.../ix` — case-insensitive + extended whitespace.
- Escape in attributes: `&quot;`, `&lt;`, `&gt;`, `&amp;`.
- `<entity name="foo" value="…"/>` → `%foo;`.
- Full syntax: [hrc-ref.md](hrc-ref.md) (Appendix A).
