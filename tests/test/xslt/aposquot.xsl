<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 >
	
<xsl:template match="/">

	<xsl:value-of select="concat(&quot;'&quot;, '&quot;')"/>
	<xsl:value-of select="concat(&quot;'&quot;, '&quot;')"/>
	
	<xsl:value-of select='concat(&apos;"&apos;, "&apos;")'/>
	<xsl:value-of select='concat(&apos;"&apos;, "&apos;")'/>
	
</xsl:template>
</xsl:stylesheet>