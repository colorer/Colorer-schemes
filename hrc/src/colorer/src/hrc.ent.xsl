<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
	exclude-result-prefixes="xsl"
	xmlns:hrc="http://colorer.sf.net/2003/hrc"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 >

<xsl:output indent="yes" method="xml" encoding="utf-8"/>

<xsl:key name="type" match="xs:element[@type]" use="@name"/>

<xsl:template match="/">
	<xs:schema targetNamespace="http://colorer.sf.net/2003/hrc-aliac">
		<xs:import namespace="http://colorer.sf.net/2003/hrc" schemaLocation="hrc.xsd"/>	
		<xsl:apply-templates/>
	</xs:schema>
</xsl:template>

<xsl:template match="xs:element[@type]">
	<xsl:if test="generate-id(.) = generate-id(key('type',@name))">
		<xs:element name="{@name}" type="hrc:{@type}"/>
	</xsl:if>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>