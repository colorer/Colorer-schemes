<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     exclude-result-prefixes="c hrc xsl"
     xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:c="uri:colorer:custom"
     xmlns:hrc="http://colorer.sf.net/2003/hrc"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <!-- Mode 'include-attr' searches and creates call statements
  for all attributes and attributeGroups in called parent type
  -->


  <xsl:template match="text()" mode="include-attr"/>

  <xsl:template match="xs:element" mode="include-attr"/>

  <xsl:template match="*" mode="include-attr">
    <xsl:apply-templates mode="include-attr"/>
  </xsl:template>

  <xsl:template match="xs:anyAttribute" mode="include-attr">
    <!-- EE: must disabled for recursion -->  
    <xsl:param name="any" select="'yes'"/>
  
    <!-- TODO: use @namespace attribute -
    <xsl:choose>
      <xsl:when test="@namespace = '##other'">
        <regexp match="/(\s?#1|^)(%nsprefix;)?!%xml:NCName;/" region="dInsert"/>
      </xsl:when>
    </xsl:choose>-->
    <xsl:if test="$any = 'yes'">
      <inherit scheme="xml:Attribute.any"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xs:attributeGroup" mode="include-attr">
    <inherit>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="@ref"/>
        </xsl:call-template><xsl:text>-attributeGroup</xsl:text>
      </xsl:attribute>
    </inherit>
  </xsl:template>

  <xsl:template match="xs:complexContent/xs:extension | xs:complexContent/xs:restriction" mode="include-attr">
    <xsl:apply-templates mode="include-attr">
      <xsl:with-param name="any" select="'no'"/>
    </xsl:apply-templates>
    <inherit>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="@base"/>
        </xsl:call-template><xsl:text>-Attributes</xsl:text>
      </xsl:attribute>
    </inherit>
  </xsl:template>

  <xsl:template match="xs:attribute" mode="include-attr">
    <xsl:choose>
      <xsl:when test="@ref">
        <inherit>
          <xsl:attribute name="scheme">
            <xsl:call-template name="qname2hrcname">
              <xsl:with-param name="qname" select="@ref"/>
            </xsl:call-template><xsl:text>-attribute</xsl:text>
          </xsl:attribute>
        </inherit>
      </xsl:when>

      <xsl:when test="@use = 'prohibited'">
        <!-- FIX: possible unwanted escape sequences?? -->
        <regexp match="/{@name}/x" region="xml:badChar"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="attribute-call">
          <xsl:with-param name="name" select="@name"/>
          <xsl:with-param name="qualified">
            <xsl:if test="../self::xs:schema or
            @form = 'qualified' or
            (not(@form) and /xs:schema/@attributeFormDefault = 'qualified')">yes</xsl:if>
          </xsl:with-param>
          <xsl:with-param name="type">
            <xsl:choose>
              <xsl:when test="generate-id(xs:simpleType)">
                <xsl:value-of select="concat($anonymous, generate-id(xs:simpleType))"/>
              </xsl:when>
              <xsl:when test="@type">
                <xsl:value-of select="@type"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="name(namespace::*[. = 'http://www.w3.org/2001/XMLSchema'])"/>
                <xsl:text>:anySimpleType</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
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
   - Cail Lomecb <cail@nm.ru>.
   - Portions created by the Initial Developer are Copyright (C) 1999-2003
   - the Initial Developer. All Rights Reserved.
   -
   - Contributor(s):
   - Eugene Efremov <4mirror@mail.ru>
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