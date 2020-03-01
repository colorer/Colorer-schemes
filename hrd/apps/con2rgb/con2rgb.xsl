<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns="http://colorer.sf.net/2003/hrd"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 >
  
<xsl:output method="xml" indent="yes" encoding="utf-8"
	doctype-public="-//Cail Lomecb//DTD Colorer HRD take5//EN"
	doctype-system="http://colorer.sf.net/2003/hrd.dtd"
/>

<xsl:param name="hcd" select="'hcd/ansi.xml'"/>
<xsl:variable name="conv" select="document($hcd)/hcd"/>

<xsl:template match="/">
	<xsl:text>&#10;</xsl:text>
	<xsl:comment>
		<xsl:text>
	This HRD file was generated automaticaly via con2rgb
	Use highlighting console defines: </xsl:text>
		<xsl:value-of select="$hcd"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:comment>
	<xsl:text>&#10;&#10;</xsl:text>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="@fore | @back">
	<xsl:variable name="val" select="translate(.,'abcdef','ABCDEF')"/>
	<xsl:attribute name="{name()}">
		<xsl:value-of select="$conv/color[@con = $val]/@rgb"/>
	</xsl:attribute>
</xsl:template>

<xsl:template match="text()|comment()" priority="1"/>

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
   - Eugene Efremov <4mirror@mail.ru>.
   - Portions created by the Initial Developer are Copyright (C) 2005
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