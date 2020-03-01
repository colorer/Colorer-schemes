<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     exclude-result-prefixes="c hrc xsl"
     xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:c="uri:colorer:custom"
     xmlns:hrc="http://colorer.sf.net/2003/hrc"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Mode 'include-content' searches and creates call statements
  for all elements and groups in called parent type
  -->

  <xsl:template match="text()" mode="include-content">
  </xsl:template>

  <xsl:template match="*" mode="include-content">
    <xsl:apply-templates mode="include-content"/>
  </xsl:template>

  <xsl:template match="xs:any" mode="include-content">
    <xsl:choose>
      <xsl:when test="starts-with(@namespace, '##other')">
        <regexp match="/ &lt; (%ns-real-prefix;%xml:NCName; ([\s\/&gt;]|$) )/x"
                region="def:Error"/>
        <inherit scheme="xml:element"/>
      </xsl:when>
      <xsl:otherwise>
        <inherit scheme="xml:element"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xs:attribute" mode="include-content"/>

  <xsl:template match="xs:group" mode="include-content">
    <inherit>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="@ref"/>
        </xsl:call-template><xsl:text>-group</xsl:text>
      </xsl:attribute>
    </inherit>
  </xsl:template>

  <xsl:template match="xs:enumeration" mode="include-content">
    <!-- FIX: need \b..\b  here?? -->
    <regexp region="Enumeration">
      <xsl:attribute name="match">
        <xsl:text>/</xsl:text>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="string" select="@value"/>
          <xsl:with-param name="match-list" select="$replace-patterns/patterns/enum-patterns"/>
        </xsl:call-template>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$ric"/>
      </xsl:attribute>
    </regexp>
  </xsl:template>

  <xsl:template match="xs:pattern" mode="include-content">
    <xsl:comment>
    Warning: RE pattern used. Possible compatibility faults
    Original RE: <xsl:value-of select="@value"/>
    </xsl:comment>
    <regexp region="Enumeration" priority="low">
      <xsl:attribute name="match">
        <xsl:text>/</xsl:text>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="string" select="@value"/>
          <xsl:with-param name="match-list" select="$replace-patterns/patterns/re-patterns"/>
        </xsl:call-template>
        <xsl:text>/</xsl:text>
      </xsl:attribute>
    </regexp>
  </xsl:template>

  <xsl:template match="xs:simpleType/xs:restriction | xs:simpleContent/xs:restriction" mode="include-content">
    <xsl:apply-templates mode="include-content"/>
    <xsl:if test="not(xs:enumeration | xs:pattern)">
      <inherit>
        <xsl:attribute name="scheme">
          <xsl:call-template name="qname2hrcname">
            <xsl:with-param name="qname">
              <xsl:choose>
                <xsl:when test="@base">
                  <xsl:value-of select="@base"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($anonymous, generate-id(xs:simpleType))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template><xsl:text>-content</xsl:text>
        </xsl:attribute>
      </inherit>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xs:list" mode="include-content">
    <xsl:comment>list:</xsl:comment>
    <inherit>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname">
            <xsl:choose>
              <xsl:when test="@itemType">
                <xsl:value-of select="@itemType"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($anonymous, generate-id(xs:simpleType))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template><xsl:text>-content</xsl:text>
      </xsl:attribute>
    </inherit>
  </xsl:template>

  <xsl:template match="xs:simpleType" mode="include-content-union">
    <inherit>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="concat($anonymous, generate-id(.))"/>
        </xsl:call-template><xsl:text>-content</xsl:text>
      </xsl:attribute>
    </inherit>
  </xsl:template>

  <!-- This template tokenize given string
  and returns a list of inheritances of appropriate types -->
  <xsl:template name="include-content-tokenize">
    <xsl:param name="tokens" select="''"/>
    <xsl:param name="position" select="1"/>

    <xsl:choose>
      <xsl:when test="substring($tokens, $position, 1) = ' '">
        <xsl:call-template name="include-content-tokenize">
          <xsl:with-param name="tokens" select="$tokens"/>
          <xsl:with-param name="position" select="$position+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$position &lt;= string-length($tokens)">
        <xsl:variable name="tokenend">
          <xsl:choose>
            <xsl:when test="substring-before( substring($tokens,$position),' ')">
              <xsl:value-of select="substring-before( substring($tokens,$position),' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring($tokens,$position)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <inherit>
          <xsl:attribute name="scheme">
            <xsl:call-template name="qname2hrcname">
              <xsl:with-param name="qname" select="$tokenend"/>
            </xsl:call-template><xsl:text>-content</xsl:text>
          </xsl:attribute>
        </inherit>
        <xsl:call-template name="include-content-tokenize">
          <xsl:with-param name="tokens" select="$tokens"/>
          <xsl:with-param name="position" select="$position+string-length($tokenend)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="xs:union" mode="include-content">
    <xsl:comment>union:</xsl:comment>
    <xsl:call-template name="include-content-tokenize">
      <xsl:with-param name="tokens" select="@memberTypes"/>
    </xsl:call-template>
    <xsl:apply-templates mode="include-content-union"/>
  </xsl:template>

  <xsl:template match="xs:complexContent/xs:extension | xs:simpleContent/xs:extension" mode="include-content">
    <xsl:apply-templates mode="include-content"/>
    <inherit>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="@base"/>
        </xsl:call-template><xsl:text>-content</xsl:text>
      </xsl:attribute>
    </inherit>
  </xsl:template>

  <xsl:template match="xs:element" mode="include-content">
    <xsl:choose>
      <xsl:when test="@ref"><!--!!  substitutionGroup chek need -->
        <inherit>
          <xsl:attribute name="scheme">
            <xsl:call-template name="qname2hrcname">
              <xsl:with-param name="qname" select="@ref"/>
            </xsl:call-template><xsl:text>-element</xsl:text>
          </xsl:attribute>
        </inherit>
      </xsl:when>

      <xsl:when test="@minOccurs = '0' and @maxOccurs = '0'">
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name='custom-type-outline' select='$custom-type/c:outline/c:element[@name = current()/@name]'/>
        
        <xsl:variable name='prefix'>
        	<xsl:call-template name='nsprefix'>
        		<xsl:with-param name='tag' select='@name'/>
        	</xsl:call-template>
        </xsl:variable>
        
        
        <xsl:if test='$custom-type-outline'>
          <xsl:if test='$custom-type-outline/@extract = "attributeValue"'>
            <regexp match="/\M (&lt; %{$prefix};{@name} \b.*? (([\x22\x27])(.*?)(\3)) )/{$ric}x" region4="{@name}Outlined"/>
          </xsl:if>
          <xsl:if test='$custom-type-outline/@extract = "withAttribute"'>
            <regexp match="/\M (&lt; %{$prefix};{@name} \b\s*.*? (([\x22\x27])(.*?)(\3))? )([\/>\s]|$)/{$ric}x" region1="{@name}Outlined"/>
          </xsl:if>
          <xsl:if test='$custom-type-outline/@extract = "fullElement"'>
            <regexp match="/\M (&lt; %{$prefix};{@name} \b.*? (>|$) )/{$ric}x" region1="{@name}Outlined"/>
          </xsl:if>
          <xsl:if test='$custom-type-outline/@extract = "tillNext"'>
            <regexp match="/\M &lt; %{$prefix};{@name} \b.*? &gt; (.{{2,}}?) (&lt;|$) /{$ric}x" region1="{@name}Outlined"/>
          </xsl:if>
        </xsl:if>

        <!-- EE: support @substitutionGroup -->
        <xsl:choose>
          <xsl:when test="@abstract = 'true'">
            <xsl:comment>
             <xsl:text>
    Warning! One or more other elements must have "substitutionGroup"
     attribute, referenced to this element.
    If no these elements, you need manually define scheme
     "</xsl:text>
              <xsl:value-of select="@name"/>
              <xsl:text>-substitutionGroup" in your "</xsl:text>
              <xsl:value-of select="$hrctype"/>
              <xsl:text>" custom-defines file</xsl:text>
            </xsl:comment>
            <inherit scheme="{@name}-substitutionGroup"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:call-template name="element-call">
              <xsl:with-param name="name" select="@name"/>
              <xsl:with-param name="type">
                <xsl:apply-templates select="." mode="subst-group-name"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

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