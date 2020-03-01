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


<xsl:key name="subst-group" match="xs:element[@substitutionGroup]" use="@substitutionGroup"/>

<xsl:template match="xs:element[@substitutionGroup]" mode="subst-group">
	<xsl:if test="generate-id(.) = generate-id(key('subst-group', @substitutionGroup))">
		<scheme>
			<xsl:attribute name="name">
				<xsl:call-template name="qname2hrcname">
					<xsl:with-param name="qname" select="@substitutionGroup"/>
				</xsl:call-template>
				<xsl:text>-substitutionGroup</xsl:text>
			</xsl:attribute>
			
			<xsl:apply-templates select="key('subst-group', @substitutionGroup)" mode='include-content'/>
		</scheme>
	</xsl:if>
</xsl:template>

<xsl:template match="text()" mode="subst-group"/>


<xsl:template match="xs:element" mode="subst-group-name">
	<xsl:choose>
		<xsl:when test="generate-id(xs:complexType|xs:simpleType)">
			<xsl:value-of select="concat($anonymous, generate-id(xs:complexType|xs:simpleType))"/>
		</xsl:when>
		
		<xsl:when test="@type">
			<xsl:value-of select="@type"/>
		</xsl:when>
		
		<xsl:when test="@substitutionGroup">
			<xsl:variable name="subst-name">
				<xsl:call-template name="qname2hrcname">
					<xsl:with-param name="qname" select="@substitutionGroup"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:apply-templates select="/xs:schema/xs:element[@name = $subst-name]" mode="subst-group-name"/>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:value-of select="name(namespace::*[. = 'http://www.w3.org/2001/XMLSchema'])"/>
			<xsl:text>:anyType</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
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
   - The Initial Developer of the Original Code is
   - Eugene Efremov <4mirror@mail.ru>
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
