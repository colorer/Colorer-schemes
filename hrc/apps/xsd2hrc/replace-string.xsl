<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     exclude-result-prefixes="xsl"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--
       This template searches and replaces all occurences of
       $match-list/match/@token  to
       $match-list/match/@subst  in  $string
  -->
  <xsl:template name="replace-string">
    <xsl:param name="string" select="'-1'"/>
    <xsl:param name="match-list" select="'-1'"/>
    <xsl:param name="position" select="1"/>
    <xsl:if test="$string = '-1' or $match-list = '-1'">
      <xsl:message>'replace-string' template called without parameters!</xsl:message>
    </xsl:if>

    <xsl:variable name="subst" select="$match-list/match[starts-with(substring($string, $position), @token)]"/>

    <xsl:if test="$position &lt;= string-length($string)">
      <xsl:choose>
        <xsl:when test="$subst">
          <xsl:value-of select="$subst/@subst"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($string, $position, 1)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="replace-string">
        <xsl:with-param name="string" select="$string"/>
        <xsl:with-param name="match-list" select="$match-list"/>
        <xsl:with-param name="position">
          <xsl:choose>
            <xsl:when test="$subst">
              <xsl:value-of select="$position + string-length($subst/@token)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$position + 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

<!-- test call
  <xsl:template match="/">
    <xsl:call-template name="replace-string">
      <xsl:with-param name="string" select="'test \isss\\\csss\I - - \C - - -[\p{L}]'"/>
      <xsl:with-param name="match-list" select="document('schema2hrc.custom.xml')/custom/patterns"/>
    </xsl:call-template>
  </xsl:template>
-->

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