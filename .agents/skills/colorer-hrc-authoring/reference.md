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
<block start="/^\s*(require)\s*\(\s*$/"
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
