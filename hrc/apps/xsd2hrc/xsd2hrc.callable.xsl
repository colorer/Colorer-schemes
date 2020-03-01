<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     exclude-result-prefixes="c hrc xsl"
     xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:c="uri:colorer:custom"
     xmlns:hrc="http://colorer.sf.net/2003/hrc"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Transforms qualified type names into qualified hrc type names
  Takes into account assigns between hrc types and
  namespaces (reads hrc catalog), handles default and empty namespaces.
  -->

  <xsl:template name="qname2hrcname">
    <xsl:param name="qname"/>
    <xsl:variable name="prefix" select="substring-before($qname,':')"/>
    <xsl:variable name="localname">
      <xsl:choose>
        <xsl:when test="substring-after($qname,':')">
          <xsl:value-of select="substring-after($qname,':')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$qname"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="nsURI" select="namespace::*[name() = $prefix]"/>
    <xsl:if test="not(namespace::*[name() = $prefix]) and
                  ($prefix != '' or $targetNamespace != '' and not(starts-with($localname, $anonymous)) )">
      <xsl:message>
 Warning: XML Schema validity error!
 No namespace with prefix '<xsl:value-of select="$prefix"/>' was defined for name '<xsl:value-of select="$qname"/>'
      </xsl:message>
    </xsl:if>

    <xsl:variable name="nsMap" select="($catalog/hrc:hrc/hrc:prototype | $catalog/hrc:hrc/hrc:package)[@targetNamespace = $nsURI]"/>

    <xsl:choose>
      <xsl:when test="$targetNamespace = $nsURI or starts-with($qname, $anonymous)">
      </xsl:when>
      <xsl:when test="$nsMap">
        <xsl:value-of select="$nsMap/@name"/>
        <xsl:text>:</xsl:text>
      </xsl:when>
      <xsl:when test="$prefix">
        <xsl:message>
 Warning: XML Schema namespace '<xsl:value-of select="$prefix"/>'='<xsl:value-of select="namespace::*[name()=$prefix]"/>'
 can't be bounded to any HRC type. It is defaulted, that corresponding
 HRC type would have name equals to this namespace prefix.
        </xsl:message>
        <xsl:value-of select="$prefix"/>
        <xsl:text>:</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="$localname"/>

  </xsl:template>

  <!-- Creates scheme instance and optionally renames it
  into $name-old to supply scheme customization
  -->
  <xsl:template name="createScheme">
    <xsl:param name="name"/>
    <xsl:param name="content"/>
    <scheme>
      <xsl:attribute name="name">
        <xsl:value-of select="$name"/>
        <xsl:if test="$custom-type-schemes/self::hrc:scheme[@name = $name]">-old</xsl:if>

        <!-- EE: support xmlss. Eliminate redefined elements -->
        <xsl:for-each select="$custom-type/c:script-n-style/c:element">
         <xsl:if test="$name = concat(@name, '-element')">-old-xmlss</xsl:if>
        </xsl:for-each>

      </xsl:attribute>
      <xsl:copy-of select="$content"/>

    </scheme>
  </xsl:template>


  <!-- Callable templates to create
  element and attribute call statements
  -->

  <xsl:template name="element-call">
    <xsl:param name="name"/>
    <xsl:param name="type"/>
    <xsl:variable name='prefix'>
    	<xsl:call-template name='nsprefix'>
    		<xsl:with-param name='tag' select='$name'/>
    	</xsl:call-template>
    </xsl:variable>

    <block start="/\M &lt; (%{$prefix};{$name} ([\s\/&gt;]|$) )/{$ric}x" end="/ &gt; /x">
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="$type"/>
        </xsl:call-template>
        <xsl:text>-elementContent</xsl:text>
      </xsl:attribute>
    </block>
  </xsl:template>

  <xsl:template name="attribute-call">
    <xsl:param name="name"/>
    <xsl:param name="type"/>
    <xsl:param name="qualified" select="'no'"/>

    <!-- TODO: \b bounds !!! -->
    <!-- TODO: namespace highlight?? -->
    <block end="/[&quot;&apos;]?#1/"
           region02="Attribute.name">
      <xsl:attribute name="start">
        <xsl:choose>
          <xsl:when test="$qualified = 'yes'">
            <xsl:value-of select="concat('/(\s?#1|^)(?{Attribute.nsprefix}%attr-nsprefix;)(',$name,')\M([\s\=]|$)/',$ric,'x')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('/(\s?#1|^)(',$name,')\M([\s\=]|$)/',$ric,'x')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="scheme">
        <xsl:call-template name="qname2hrcname">
          <xsl:with-param name="qname" select="$type"/>
        </xsl:call-template><xsl:text>-AttributeContent</xsl:text>
      </xsl:attribute>
    </block>
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