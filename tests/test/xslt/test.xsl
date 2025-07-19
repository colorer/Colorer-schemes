<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:template match="root">
  <xsl:variable name="apos" select="&quot;'&quot;" />
  <xsl:variable name="quot" select='&apos;"&apos;' />
  <xsl:value-of select="translate(.,'&quot;',$apos)"/>
</xsl:template>

</xsl:stylesheet>