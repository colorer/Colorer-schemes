<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	exclude-result-prefixes="c hrc xsl"
	xmlns="http://colorer.sf.net/2003/hrc"
	xmlns:c="uri:colorer:custom"
	xmlns:hrc="http://colorer.sf.net/2003/hrc"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 >
 

<xsl:template match='c:*[c:any-prefix or c:prefix]' mode='nsprefix-real'>
	<xsl:param name="nscolon"/>
	  
	<xsl:text>(?{}</xsl:text>
	<xsl:choose>
		<xsl:when test="c:any-prefix">
			<xsl:text>%xml:NCName;</xsl:text>
		</xsl:when>
		<xsl:when test="c:prefix">
			<xsl:text>(?{}</xsl:text>
			<xsl:for-each select="c:prefix">
				<xsl:value-of select="."/>
				<xsl:if test="position() != last()">|</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:when>
	</xsl:choose>
	
	<xsl:text>(?{</xsl:text>
	<xsl:value-of select="$nscolon"/>
	<xsl:text>}:))</xsl:text>
</xsl:template>

<xsl:template match='c:*' mode='nsprefix-real'/>


<xsl:template match='c:*[c:any-prefix or c:prefix or c:empty-prefix]' mode='nsprefix'>
	<xsl:variable name='prefix'>
		<xsl:apply-templates mode='nsprefix-real' select='.'/>
	</xsl:variable>
	
	<xsl:if test="$prefix != ''">
		<xsl:value-of select="$prefix"/>
		<xsl:if test="c:empty-prefix">?</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match='c:*' mode='nsprefix'/>



<!--xsl:apply-templates select='$custom-type/c:force-prefix' mode='nsprefix-strict'/-->

<xsl:template match='c:force-prefix' mode='nsprefix-strict'>
	<xsl:apply-templates select='c:element' mode='nsprefix-strict'/>
</xsl:template>

<xsl:template match='c:element' mode='nsprefix-strict'>
	<xsl:variable name='prefix'>
		<xsl:apply-templates select='..' mode='nsprefix'/>
	</xsl:variable>
	<entity name="nsprefix-{@name}" value="{$prefix}"/>
</xsl:template>


<!--xsl:call-template name='nsprefix'-->

<xsl:template name='nsprefix'>
	<xsl:param name="tag"/>
	
	<xsl:text>nsprefix</xsl:text>
	<xsl:if test='$custom-type/c:force-prefix/c:element[@name = $tag]'>
		<xsl:text>-</xsl:text>
		<xsl:value-of select='$tag'/>
	</xsl:if>
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
   - The Original Code is the Colorer Library xsd2hrc module.
   -
   - The Initial Developers of the Original Code is
   - Cail Lomecb <cail@nm.ru> & Eugene Efremov <4mirror@mail.ru>.
   - Portions created by the Initial Developer are Copyright (C) 1999-2009
   - the Initial Developers. All Rights Reserved.
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
