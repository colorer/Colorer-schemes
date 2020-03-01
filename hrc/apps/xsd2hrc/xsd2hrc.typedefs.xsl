<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     exclude-result-prefixes="c hrc xsl"
     xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:c="uri:colorer:custom"
     xmlns:hrc="http://colorer.sf.net/2003/hrc"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Mode 'typedefs' searches and defines all possible
  complex and simple types: named and anonymous.
  -->

  <xsl:template match="text()" mode="typedefs">
  </xsl:template>


  <!-- Basic template, defines schema datatypes.
  We have three kinds of datatypes to compose in HRC:
    1. complexType with complexContent
       basic scheme '{$typename}-content' have to be used only
       within element's content and can contain just elements,
       possibly mixed with _untyped_ cdata
    2. complexType with simpleContent
       basic scheme '{$typename}-content' could be used within
       element's content - here we have to allow xml:content.cdata
       and xml:content.other (for PI!?). Simultaneously we must
       check and parse here simpleType definition.
    3. simpleType
       basic scheme '{$typename}-content' could be used within
        a. attribute's content - include just Entities, badChars
           and simpleType definitions.
        b. element's content - as with 2nd variant
  -->
  <xsl:template match="xs:complexType | xs:simpleType" mode="typedefs">

    <xsl:variable name="typename">
      <xsl:choose>
        <xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat($anonymous, generate-id(.))"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="@name and preceding-sibling::*[position()=1 and local-name() = 'annotation']">
      <xsl:call-template name='crlf'/>
      <xsl:comment>
      <xsl:value-of select="preceding-sibling::*[position()=1 and local-name()='annotation']"/><xsl:call-template name='crlf'/>
      </xsl:comment>
    </xsl:if>
    <xsl:call-template name='crlf'/>
    <xsl:if test="../@name">
      <xsl:comment>
        parent: <xsl:value-of select="../@name"/><xsl:call-template name='crlf'/>
      </xsl:comment><xsl:call-template name='crlf'/>
    </xsl:if>
    <!-- Base scheme - creates real type content
    Could be customized in separate file, and included separately.
    This is done mostly for basic xmlscheme types, but you can use it
    to extend your schema abilities.
    Customization is made also for groups definitions
    -->
    <xsl:call-template name="createScheme">
      <xsl:with-param name="name" select="concat($typename, '-content')"/>
      <xsl:with-param name="content">
        <xsl:if test="xs:annotation/xs:documentation and $drop-annotations = 'no'">
          <annotation><documentation>
            <xsl:value-of select="xs:annotation"/>
          </documentation></annotation>
        </xsl:if>
        <xsl:apply-templates mode="include-content" select="."/>
        <xsl:if test="self::xs:complexType and not(xs:simpleContent) and $allow-unknown-elements = 'yes'">
          <inherit scheme="xml:element"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>

    <!-- This scheme adds errors highlighting into simple type -->
    <xsl:call-template name="createScheme">
      <xsl:with-param name="name" select="concat($typename, '-content-error')"/>
      <xsl:with-param name="content">
        <inherit scheme="{$typename}-content"/>
        <inherit scheme="xml:badChar"/>
      </xsl:with-param>
    </xsl:call-template>
    
    
    <!-- EE: This scheme used for CDATA sections -->
    <xsl:if test="(self::xs:complexType or (self::xs:simpleType and @name)) and not(parent::c:*)">
     <xsl:call-template name="createScheme">
      <xsl:with-param name="name" select="concat($typename, '-content-cdsect')"/>
      <xsl:with-param name="content">
        <inherit scheme="{$typename}-content-error">
          <virtual scheme="xml:badLiter" subst-scheme="xml:badCDLiter"/>
          <virtual scheme="xml:Reference" subst-scheme="def:empty"/>
        </inherit>
      </xsl:with-param>
     </xsl:call-template>    
    </xsl:if>

    <!-- complexType attributes -->

<!--    <xsl:if test="self::xs:complexType">-->
      <scheme name="{$typename}-Attributes">
        <!-- EE: Trap redefines in s&s attribs: -->  
        <xsl:if test="self::xs:complexType and @name">
          <xsl:apply-templates mode="scriptdef-attr"
            select="$custom-type/c:script-n-style/c:type-attributes[@name = current()/@name]" 
          />
        </xsl:if>
        <xsl:if test="parent::xs:element and ../@name">
          <xsl:variable name="pn" select="../@name"/>
          <!--xsl:comment>scriptdef-attr for <xsl:value-of select="$pn"/></xsl:comment-->
          <xsl:apply-templates mode="scriptdef-attr"
            select="$custom-type/c:script-n-style/c:element-attributes[@name = $pn]" 
          />
        </xsl:if>
      
        <xsl:apply-templates mode="include-attr"/>
        <xsl:if test="$allow-any-attr != 'no'">
          <inherit scheme="xml:Attribute.any"/>
        </xsl:if>
      </scheme>
<!--    </xsl:if>
    <xsl:if test="self::xs:simpleType">
      <scheme name="{$typename}-Attributes"/>
    </xsl:if> -->

    <!-- We need this scheme to call from attribute definitions.
    So, we create it only for simpleType's
    -->

    <xsl:if test="self::xs:simpleType">
      <scheme name="{$typename}-AttributeContent">
        <inherit scheme="AttributeContent">
          <virtual scheme="xml:AttValue.content.stream" subst-scheme="{$typename}-content-error"/>
        </inherit>
      </scheme>
    </xsl:if>

    <!--
    Scheme to support calls from element's creation.
    Active for any kind of type
    -->
    <xsl:if test="(self::xs:complexType or (self::xs:simpleType and @name)) and not(parent::c:*)">
      <scheme name="{$typename}-elementContent">
        <inherit scheme="{$anonymous}elementContent">
          <xsl:if test="self::xs:complexType and not(xs:simpleContent)">
            <virtual scheme="xml:element"  subst-scheme="{$typename}-content"/>
            <!-- broken in hrc.xsd -->
            <xsl:choose>  
               <!--
              <xsl:when test="not( xs:complexContent/@mixed and (
                                   string(xs:complexContent/@mixed) = 'true'
                                   or string(xs:complexContent/@mixed) = '1')
                                  or
                                   not(xs:complexContent/@mixed) and
                                   (string(@mixed) = 'true' or string(@mixed) = '1')
                              )">
                              -->
                              <!-- TODO: must be completly re-writen: we cannot detect error in 'xs:complexContent' -->
              <xsl:when test="not(xs:complexContent or (string(@mixed) = 'true' or string(@mixed) = '1'))">
                <virtual scheme="xml:content.cdata" subst-scheme="xml:badChar"/>
              </xsl:when>
            </xsl:choose>
          </xsl:if>
          
          <!-- Allows to parse simpleType content in CDATA sections content -->
          <xsl:if test="self::xs:simpleType or xs:simpleContent or xs:complexContent">
            <virtual scheme="xml:CDSect.content.stream" subst-scheme="{$typename}-content-cdsect"/>
          </xsl:if>
          <xsl:if test="self::xs:simpleType or xs:simpleContent"><!--  or xs:complexContent" -->
            <virtual scheme="xml:content.cdata.stream"  subst-scheme="{$typename}-content-error"/><!-- changed !! -->
            <virtual scheme="xml:element" subst-scheme="def:empty"/>
          </xsl:if>

          <virtual scheme="xml:Attribute.any" subst-scheme="{$typename}-Attributes"/>
          <xsl:if test="self::xs:complexType and $allow-common-attr != 'yes'">
            <virtual scheme="xml:Attribute.common" subst-scheme="def:empty"/>
          </xsl:if>
        </inherit>
      </scheme>
    </xsl:if>
    <!--
    Recursively searches any other types (named or unnamed)
    -->
    <xsl:apply-templates mode="typedefs"/>

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