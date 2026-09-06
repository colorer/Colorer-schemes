# HRD examples

## Catalog entry

```xml
        <hrd class="rgb" name="my-theme" description="My Theme">
            <location link="&hrd;/rgb/my-theme.hrd"/>
        </hrd>
```

Console: `class="console"`, `link="&hrd;/console/my-theme.hrd"`. Same `name` in both catalogs is fine.

Then re-sort that catalog file by `description` (case-insensitive).

## Complete RGB (copy and recolor)

Structure used by popular palettes (`monokai.hrd`, `dn.hrd`, …). Replace hex values; keep region names.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hrd PUBLIC "-//Cail Lomecb//DTD Colorer HRD take5//EN"
  "http://colorer.sf.net/2003/hrd.dtd">
<hrd xmlns="http://colorer.sf.net/2003/hrd">
  <documentation>
    Short palette credit (editor / author).
  </documentation>

  <assign name="def:Text" fore="#c5c8c6" back="#1d1f21"/>
  <assign name="def:HorzCross" fore="#c5c8c6" back="#282a2e"/>
  <assign name="def:VertCross" fore="#c5c8c6" back="#282a2e"/>

  <assign name="def:Number" fore="#de935f"/>
  <assign name="def:String" fore="#b5bd68"/>
  <assign name="def:StringContent" fore="#8abeb7"/>
  <assign name="def:StringEdge" fore="#b5bd68"/>
  <assign name="def:Character" fore="#b5bd68"/>

  <assign name="def:Comment" fore="#969896" style='2'/>
  <assign name="def:LineComment" fore="#969896" style='2'/>
  <assign name="def:CommentDoc" fore="#a7aaa8" style='2'/>

  <assign name="def:Symbol" fore="#c5c8c6"/>
  <assign name="def:SymbolStrong" fore="#b294bb"/>
  <assign name="def:Operator" fore="#8abeb7"/>
  <assign name="def:Prefix" fore="#8abeb7"/>

  <assign name="def:Keyword" fore="#b294bb"/>
  <assign name="def:KeywordStrong" fore="#b294bb"/>
  <assign name="def:TypeKeyword" fore="#f0c674"/>
  <assign name="def:ClassKeyword" fore="#f0c674"/>
  <assign name="def:FunctionKeyword" fore="#81a2be"/>
  <assign name="def:DeprecatedKeyword" fore="#969896" style='4'/>

  <assign name="def:Function" fore="#81a2be"/>
  <assign name="def:Constant" fore="#de935f"/>
  <assign name="def:BooleanConstant" fore="#de935f"/>
  <assign name="def:Var" fore="#cc6666"/>
  <assign name="def:VarStrong" fore="#cc6666"/>
  <assign name="def:Identifier" fore="#c5c8c6"/>

  <assign name="def:Directive" fore="#b294bb"/>
  <assign name="def:Parameter" fore="#cc6666"/>
  <assign name="def:ParameterUnknown" fore="#cc6666"/>

  <assign name="def:Tag" fore="#cc6666"/>
  <assign name="def:OpenTag" fore="#cc6666"/>
  <assign name="def:CloseTag" fore="#cc6666"/>

  <assign name="def:Label" fore="#81a2be"/>
  <assign name="def:LabelStrong" fore="#1d1f21" back="#f0c674"/>

  <assign name="def:Insertion" fore="#c5c8c6" back="#161719"/>
  <assign name="def:InsertionStart" fore="#b294bb" back="#f0c674"/>
  <assign name="def:InsertionEnd" fore="#b294bb" back="#f0c674"/>

  <assign name="def:Error" fore="#c5c8c6" back="#cc6666" style='1'/>
  <assign name="def:ErrorText" fore="#cc6666"/>
  <assign name="def:TODO" fore="#1d1f21" back="#f0c674" style='1'/>
  <assign name="def:Debug" fore="#1d1f21" back="#8abeb7"/>

  <assign name="def:URI" fore="#81a2be" style='4'/>
  <assign name="def:URL" fore="#81a2be" style='4'/>
  <assign name="def:Path" fore="#b5bd68"/>
  <assign name="def:EMail" fore="#81a2be" style='4'/>

  <assign name="def:Date" fore="#de935f"/>
  <assign name="def:Time" fore="#de935f"/>

  <assign name="def:PairStart" fore="#c5c8c6" back="#373b41"/>
  <assign name="def:PairEnd" fore="#c5c8c6" back="#373b41"/>
  <assign name="def:PairStrongStart" fore="#1d1f21" back="#81a2be"/>
  <assign name="def:PairStrongEnd" fore="#1d1f21" back="#81a2be"/>
</hrd>
```

Expand `Number*` / `Comment*` siblings when the palette distinguishes them; otherwise Colorer inherits from the parent **if the child is not listed**.

## Console twin of a gray FAR / DN editor

Editor default is LIGHTGRAY on DARKGRAY. Map with the VGA table in [reference.md](reference.md#vga), not Euclidean RGB:

```xml
  <assign name="def:Text" fore="#7" back="#8"/>
  <assign name="def:HorzCross" fore="#F" back="#3"/>
  <assign name="def:VertCross" fore="#E" back="#1"/>
  <assign name="def:Keyword" fore="#E" style='1'/>
  <assign name="def:String" fore="#4"/>
  <assign name="def:Number" fore="#B"/>
  <assign name="def:Comment" fore="#3"/>
```

See `base/hrd/rgb/dn.hrd` and `base/hrd/console/dn.hrd` for a full pair.

## Minimal RGB

`eclipse.hrd` only overrides what must differ from Text; everything else inherits. Use when matching a sparse IDE theme, not a full editor palette.
