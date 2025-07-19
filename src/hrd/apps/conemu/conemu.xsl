<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	exclude-result-prefixes="h xsl"
	xmlns:h="http://colorer.sf.net/2003/hrd"
	xmlns="http://colorer.sf.net/2003/hrd"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 >
  
<xsl:output method="xml" indent="yes" encoding="utf-8"
	doctype-public="-//Cail Lomecb//DTD Colorer HRD take5//EN"
	doctype-system="http://colorer.sf.net/2003/hrd.dtd"
/>

<xsl:param name='bold' select="'#c'"/>
<xsl:param name='italic' select="'#e'"/>


<xsl:template match="h:assign[@style][not(@back)]">
	<xsl:variable name='style'>
		<xsl:choose>
			<xsl:when test='(@style mod 2) &gt;= 1'>
				<xsl:value-of select='$bold'/>
			</xsl:when>
			<xsl:when test='((@style div 2) mod 2) &gt;= 1'>
				<xsl:value-of select='$italic'/>
			</xsl:when>
			<xsl:otherwise>not</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<assign>
		<xsl:apply-templates select='@*'/>
		<xsl:if test="not($style = 'not')">
			<xsl:attribute name='back'>
				<xsl:value-of select='$style'/>
			</xsl:attribute>
		</xsl:if>
	</assign>
</xsl:template>

<xsl:template match='@style'/>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
