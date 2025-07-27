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

<!-- 
 script&style support in custom.*.xml 
 XSL-based version of xmlss.hrc package
 
 Written by Eugene Efremov <4mirror@mail.ru>
--> 


<!--
 Mode 'scriptdef':
-->

<!-- custom/custom-type/script-n-style/element: -->

<xsl:template match="c:script-n-style/c:element" mode="scriptdef">
	<xsl:variable name="script-elem" select="@name"/>
	
	<xsl:variable name="script-type-named">
		<xsl:for-each select="$root">
			<xsl:choose>
				<xsl:when test="generate-id(key('script',$script-elem)/xs:complexType)">
					<xsl:value-of select="concat($anonymous, generate-id(key('script',$script-elem)/xs:complexType))"/>
				</xsl:when>
				<xsl:when test="key('script',$script-elem)/@type">
					<xsl:value-of select="key('script',$script-elem)/@type"/>
				</xsl:when>
				<!--<xsl:otherwise>
					<xsl:text>-shit-</xsl:text>
				</xsl:otherwise>-->
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- Note!! Namespace must be defined in custom.*.xml -->
	<xsl:variable name="script-type">
		<xsl:call-template name="qname2hrcname">
			<xsl:with-param name="qname" select="$script-type-named"/>
		</xsl:call-template>
	</xsl:variable>
	
	
	<xsl:call-template name='crlf'/>
		<xsl:comment>
			xmlss: support &apos;<xsl:value-of select="$script-elem"/>&apos; element
		</xsl:comment>
	<xsl:call-template name='crlf'/>
	
	<xsl:apply-templates select="c:language" mode="scriptdefscheme"/>
	
	<scheme name="xmlss-{$script-elem}">
		<xsl:apply-templates mode="scriptdef"><!--  select="./language"-->
			<xsl:with-param name="tag" select="$script-elem"/>
		</xsl:apply-templates>
	</scheme>
	
	<scheme name="{$script-elem}-element">
		<inherit scheme="xmlss-{$script-elem}">
			<virtual scheme="xml:Attribute.any" 
				subst-scheme="{$script-type}-Attributes"/>
		</inherit>    
	</scheme>
	
</xsl:template>


<!-- custom/custom-type/script-n-style/element/language - part I: -->

<xsl:template match="c:language[@first]" mode="scriptdefscheme">
	<xsl:variable name="scheme">
		<xsl:choose>
			<xsl:when test="@scheme">
				<xsl:value-of select="@scheme"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<scheme name="xmlss-{@name}-elementContent">
		<inherit scheme="{$anonymous}elementContent">
			<virtual scheme="xml:element" subst-scheme="def:empty"/>
			<virtual scheme="xml:content.cdata.stream" subst-scheme="{@name}:{$scheme}"/>
			<virtual scheme="xml:CDSect.content.stream" subst-scheme="{@name}:{$scheme}"/>
		</inherit>
	</scheme>
</xsl:template>


<!-- custom/custom-type/script-n-style/element/language - part II: -->
<!-- 08-03-2006 - now support language without expr: -->

<xsl:template match="c:element/c:language[@expr]" mode="scriptdef" priority='1'>
	<xsl:param name="tag" select="'script'"/>
	
	<xsl:variable name='prefix'>
		<xsl:call-template name='nsprefix'>
			<xsl:with-param name='tag' select='$tag'/>
		</xsl:call-template>
	</xsl:variable>
	
	<!-- [\d\.]* ?? -->
	<block start="/\M &lt;%{$prefix};{$tag}\b [^&gt;]+ {@expr} [^&gt;]* (&gt;|$) /six" 
		end="/&gt;/" scheme="xmlss-{@name}-elementContent"
	/> 
</xsl:template>


<!-- custom/custom-type/script-n-style/element/default: -->

<xsl:template match="c:element/c:default | c:element/c:language[not(@expr)]" mode="scriptdef">
	<xsl:param name="tag" select="'script'"/>
	<xsl:variable name='prefix'>
		<xsl:call-template name='nsprefix'>
			<xsl:with-param name='tag' select='$tag'/>
		</xsl:call-template>
	</xsl:variable>
	
	<block start="/\M &lt;%{$prefix};{$tag}\b [^&gt;]* (&gt;|$)/{$ric}x" 
		end="/&gt;/" scheme="xmlss-{@name}-elementContent"
	/> 
</xsl:template>


<!-- custom/custom-type/script-n-style/attribute: -->
<!--  
Note!! We need include to custom/custom-type/type:

   <scheme name="[sipleType/@name]-content">
    <inherit scheme="xmlss-[language]-[scheme-suffix]-attr"/>
   </scheme>

-->

<xsl:template match="c:script-n-style/c:attribute" mode="scriptdef">
	<xsl:call-template name='crlf'/>
		<xsl:comment>
			xmlss: support attributes for language &apos;<xsl:value-of select="@language"/>&apos;, schemes &apos;(Quot|Apos)<xsl:value-of select="@scheme-suffix"/>&apos;
		</xsl:comment>
	<xsl:call-template name='crlf'/>
	
	<!-- 31-03-2005 - bugfix: -->
	<scheme name="xmlss-{@language}-{@scheme-suffix}-attr">
		<block start="/~'?#1\M([^']|$)/"
			end="/\M'/" scheme="{@language}:Quot{@scheme-suffix}"
		 >
			<xsl:if test="@region">
				<xsl:attribute name="region">
					<xsl:value-of select="@region"/>
				</xsl:attribute>
			</xsl:if>
		</block>
		<block start='/~"?#1\M([^"]|$)/'
			end='/\M"/' scheme="{@language}:Apos{@scheme-suffix}"
		 >
			<xsl:if test="@region">
				<xsl:attribute name="region">
					<xsl:value-of select="@region"/>
				</xsl:attribute>
			</xsl:if>
		</block>
	</scheme>
</xsl:template>



<!-- 17-05-2005
 -
 - embedded xsd:simpleType (for c:processing-instruction, c:*-attribute)
 -
-->

<xsl:template match="c:xsd-typedefs" mode="scriptdef">
	<xsl:apply-templates select="xs:*" mode="typedefs"/>
</xsl:template>


<!-- 9-05-2005
 -
 - processing-instruction support
 -
-->

<xsl:template match="c:processing-instruction" mode="scriptdef">
	<!-- 1: his name -->
	<xsl:variable name="scheme">
		<xsl:choose>
			<xsl:when test="@scheme">
				<xsl:value-of select="@scheme"/>
			</xsl:when>
			<xsl:when test="xs:complexType">
				<xsl:value-of select="concat(@name, '-piContent')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>xml:badChar</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- 2: his content -->
	<xsl:apply-templates select="xs:*" mode="typedefs"/>
	<xsl:if test="xs:complexType">
		<xsl:call-template name="createScheme">
			<xsl:with-param name="name" select="concat(@name, '-piContent')"/>
			<xsl:with-param name="content">
				<inherit scheme="{$anonymous}{generate-id(xs:complexType)}-Attributes"/>
				<inherit scheme="xml:badChar"/>
			</xsl:with-param>
		</xsl:call-template>    
	</xsl:if>
	
	<!-- 3: his interface -->
	<xsl:call-template name="createScheme">
		<xsl:with-param name="name" select="concat(@name, '-processing-instruction')"/>
		<xsl:with-param name="content">
			<block start="/(&lt;\?)(?{{xml:PI.name.defined}}{@name})\M(\s|$)/"
				end="/(\?&gt;)/" scheme="{$scheme}"
				region="xml:PI.content"
				region00="def:PairStart" region01="xml:PI.start.defined"
				region10="def:PairEnd" region11="xml:PI.end.defined"
			/>
		</xsl:with-param>
	</xsl:call-template>    
</xsl:template>

<xsl:template match="text()" mode="scriptdef"/>


<!--
 Mode 'scriptdef-attr':
 uses for type-attribute, element-attribute
-->

<xsl:template mode="scriptdef-attr" match="c:script-n-style/*">
	<xsl:apply-templates select="xs:*" mode="include-attr"/>
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
   - The Original Code is the xmlss package.
   -
   - The Initial Developer of the Original Code is
   - Eugene Efremov <4mirror@mail.ru>
   - Portions created by the Initial Developer are Copyright (C) 2003-2006
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
