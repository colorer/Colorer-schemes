<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns="http://colorer.sf.net/2003/hrc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 >

<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

<xsl:template match="php">
	<!--region name="php.keyword" parent="def:Keyword"/-->
	<region name="php.function" parent="def:FunctionKeyword"/>
	<region name="php.const" parent="def:Constant"/>
	<region name="php.class" parent="def:ClassKeyword"/>
	<region name="php.deprecated" parent="def:DeprecatedKeyword"/>

	<scheme name="base-keywords">
		<xsl:apply-templates select="lang"/>
		
		<regexp match="/(self|parent)\M::/" region1='php.keyword'/>
		
		<inherit scheme="keywords.const"/>
		<xsl:apply-templates select="packages" mode="inherit"/>
	</scheme>	
	
	<xsl:apply-templates select="consts"/>
	<xsl:apply-templates select="packages"/>
</xsl:template>


<xsl:template match="lang">
	<keywords region="php.keyword" ignorecase="yes">
		<xsl:apply-templates select="key"/>
	</keywords>
	<keywords region="php.function" ignorecase="yes">
		<xsl:apply-templates select="func"/>
	</keywords>
	<keywords region="php.const">
		<xsl:apply-templates select="const"/>
	</keywords>
</xsl:template>


<xsl:template match="consts">
	<scheme name="keywords.const" if="include-base-consts">
		<keywords region="php.const">
			<xsl:apply-templates/>
		</keywords>
	</scheme>
</xsl:template>


<xsl:template match="packages">
	<xsl:apply-templates/>
</xsl:template>



<xsl:key name="class" match="package/method" 
	use="concat(../@name, '-', @class)"
/>

<xsl:template match="package">
	<scheme name="{@name}" if="Include-{@name}">
		<keywords region='php.class' ignorecase="yes">
			<xsl:apply-templates select="method" mode="class"/>
		</keywords>
		<keywords region="php.function" ignorecase="yes">
			<xsl:apply-templates select="method|function"/>
		</keywords>
		<keywords region="php.const">
			<xsl:apply-templates select="const"/>
		</keywords>
	</scheme>
</xsl:template>

<xsl:template match="method" mode="class">
	<xsl:if 
		test="generate-id(.) = 
		      generate-id(key('class', concat(../@name, '-', @class)))"
	 >
		<word name="{@class}"/>
	</xsl:if>
</xsl:template>



<xsl:template match="*">
	<word name="{@name}">
		<xsl:if test="@depr">
			<xsl:attribute name="region">php.deprecated</xsl:attribute>
		</xsl:if>
	</word>
</xsl:template>

<xsl:template match="package" mode="inherit">
	<inherit scheme="{@name}"/>
</xsl:template>

</xsl:stylesheet>