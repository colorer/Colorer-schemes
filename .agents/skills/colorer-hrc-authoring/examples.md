# HRC Examples

Canonical copy-paste pieces. Author lines: `git config user.name` / `user.email`.

## Minimal language + MIT footer

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hrc PUBLIC "-//Cail Lomecb//DTD Colorer HRC take5//EN"
  "http://colorer.sf.net/2003/hrc.dtd">
<hrc version="take5" xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://colorer.sf.net/2003/hrc http://colorer.sf.net/2003/hrc.xsd">
  <type name="tiny">
    <annotation>
      <documentation>Tiny language syntax</documentation>
      <contributors><![CDATA[
        Your Name <you@example.com>
      ]]></contributors>
    </annotation>
    <import type="def"/>
    <region name="Keyword" parent="def:Keyword"/>
    <region name="String" parent="def:String"/>
    <region name="Comment" parent="def:Comment"/>
    <scheme name="tiny">
      <keywords region="Keyword">
        <word name="if"/>
        <word name="else"/>
        <word name="return"/>
      </keywords>
      <block start="/&#34;/" end="/&#34;/" scheme="def:empty" region="String"/>
      <block start="/\/\//" end="/$/" scheme="def:Comment" region="Comment"/>
    </scheme>
  </type>
</hrc>
<!--
Copyright (C) YEAR Your Name <you@example.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-->
```

## Block with keyword + parentheses

```xml
<scheme name="requireBlock">
  <inherit scheme="common"/>
  <regexp match="/^\s*([\w\.\-\/]+)\s+(v\d+\.\d+\.\d+)/"
          region1="ModulePath" region2="Version"/>
</scheme>

<scheme name="go-mod">
  <block start="/^\s*(require)\s*\(\s*$/"
         end="/^\s*\)\s*$/"
         scheme="requireBlock"
         region00="Symbol" region01="Keyword" region10="Symbol"/>
</scheme>
```

## Entity reuse

```xml
<entity name="modulePath" value="[a-zA-Z][a-zA-Z0-9_.\-]*(?:\/[a-zA-Z0-9_.\-]+)*"/>
<entity name="version" value="v\d+(?:\.\d+){0,2}"/>
<regexp match="/^\s*(%modulePath;)\s+(%version;)/"
        region1="ModulePath" region2="Version"/>
```

## Prototype

```xml
<prototype name="tiny" group="main" description="Tiny language">
    <location link="base/tiny.hrc" />
    <filename>/\.tiny$/i</filename>
</prototype>
```
