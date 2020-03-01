<?xml version="1.0"?>
<xsl:stylesheet
     version="1.0"
     xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:hrc="http://colorer.sf.net/2003/hrc"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="yes" method="html" encoding="UTF-8"/>

<xsl:template match="/">
 <html>
  <head>
   <title>HRC Script Description</title>
   <style>
html, body{
  background: white;
  font-family: Verdana, Tahoma, sanserif;
  font-size: 12pt;
}
h1, h2, h3{
  margin: 0 0 0 0;
}
h1{
  font-size:14pt;
}
h2{
  font-size:12pt;
  text-decoration:bold;
}
h3{
  font-size:12pt;
}
.hidden{
  display: none;
}
.shown{
  display: block;
}
.ptr{
  cursor: hand;
}
.header{
  text-align:center;
  font-size:30pt;
}
   </style>
  </head>
  <body>
    <div class="header">HRC Type definitions</div>
    <xsl:apply-templates/>
  </body>
 </html>
</xsl:template>

<xsl:template match="hrc:prototype">
<a name="{@name}"/>
 <h1 class="ptr" onclick="document.all.proto{@name}.className=(document.all.proto{@name}.className=='hidden')?'shown':'hidden';">
  <xsl:number format="1. "/> <xsl:value-of select="@description"/>
 </h1>
 <div class="hidden" id="proto{@name}">
  type: <xsl:value-of select="@name"/><br/>
  group:<xsl:value-of select="@group"/><br/>
  filename: <b><xsl:value-of select="hrc:filename"/></b><br/>
  <blockquote>
   <xsl:apply-templates select="hrc:location"/>
   <xsl:if test="count(hrc:switch) != 0">
     used language switches:
     <ul>
      <xsl:apply-templates select="hrc:switch"/>
     </ul>
   </xsl:if>
  </blockquote>
 </div>
 <xsl:if test="following-sibling::hrc:prototype[1]/@group != @group"><hr/></xsl:if>
</xsl:template>

<xsl:template match="hrc:location">
  needs
  <b><u><a class="ptr" onclick="document.all.type{../@name}.className=(document.all.type{../@name}.className=='hidden')?'shown':'hidden';">
   <xsl:value-of select="@link"/>
  </a></u></b> file to load<br/>
  <div class="hidden" id="type{../@name}">
    <xsl:apply-templates select="document(@link)/hrc:hrc/hrc:type"/>
  </div>
</xsl:template>

<xsl:template match="hrc:switch">
  <a>
   <xsl:attribute name="href">#<xsl:value-of select="@type"/></xsl:attribute>
   <xsl:value-of select="@type"/>
  </a>
  on match <b><xsl:value-of select="."/></b><br/>
</xsl:template>




<xsl:template match="hrc:define">
region <b><xsl:value-of select="@region"/></b> has value of <b><xsl:value-of select="@value"/></b><br/>
</xsl:template>

<xsl:template match="hrc:entity">
entity <b><xsl:value-of select="@name"/></b> has value of <b><xsl:value-of select="@value"/></b><br/>
</xsl:template>


<xsl:template match="text()|@*"/>

<!-- type defines -->
<xsl:template match="hrc:type">
  <h2>
   <span class="ptr" onclick="document.all.typecont{@name}.className=(document.all.typecont{@name}.className=='hidden')?'shown':'hidden';">
    type
    <xsl:value-of select="@name"/>
   </span>
  </h2>
  <div class="hidden" id="typecont{@name}">
    <xsl:apply-templates/>
  </div>
</xsl:template>


<xsl:template match="hrc:scheme">
 <h3 class="ptr" onclick="document.all.scheme{generate-id()}.className=(document.all.scheme{generate-id()}.className=='hidden')?'shown':'hidden';">
  scheme <xsl:value-of select="@name"/>
 </h3>
 <blockquote>
   <div class="hidden" id="scheme{generate-id()}">
     <xsl:apply-templates/>
   </div>
 </blockquote>
</xsl:template>

<xsl:template match="hrc:inherit">
inherits <b><xsl:value-of select="@scheme"/></b> scheme<br/>
</xsl:template>

<xsl:template match="hrc:regexp">
regexp <b><xsl:value-of select="@match"/></b><br/>
</xsl:template>

<xsl:template match="hrc:block">
switches into scheme <b><xsl:value-of select="@scheme"/></b><br/>
</xsl:template>

<xsl:template match="hrc:keywords">
uses keywords <b><xsl:value-of select="@region"/></b><br/>
</xsl:template>

</xsl:stylesheet>
<!-- ***** BEGIN LICENSE BLOCK *****
   - Version: MPL 1.1/GPL 2.0/LGPL 2.1
   -
   - The contents of this file are subject to the Mozilla Public License Version
   - 1.1 (the "License"); you may not use this file except in compliance with
   - the License. You may obtain a copy of the License at
   - http://www.mozilla.org/MPL/
   -
   - Software distributed under the License is distributed on an "AS IS" basis,
   - WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
   - for the specific language governing rights and limitations under the
   - License.
   -
   - The Original Code is the Colorer Library.
   -
   - The Initial Developer of the Original Code is
   - Cail Lomecb <cail@nm.ru>.
   - Portions created by the Initial Developer are Copyright (C) 1999-2005
   - the Initial Developer. All Rights Reserved.
   -
   - Contributor(s):
   -
   - Alternatively, the contents of this file may be used under the terms of
   - either the GNU General Public License Version 2 or later (the "GPL"), or
   - the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
   - in which case the provisions of the GPL or the LGPL are applicable instead
   - of those above. If you wish to allow use of your version of this file only
   - under the terms of either the GPL or the LGPL, and not to allow others to
   - use your version of this file under the terms of the MPL, indicate your
   - decision by deleting the provisions above and replace them with the notice
   - and other provisions required by the LGPL or the GPL. If you do not delete
   - the provisions above, a recipient may use your version of this file under
   - the terms of any one of the MPL, the GPL or the LGPL.
   -
   - ***** END LICENSE BLOCK ***** -->
