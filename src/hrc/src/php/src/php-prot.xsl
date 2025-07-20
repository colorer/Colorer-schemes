<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns="http://colorer.sf.net/2003/hrc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 >

<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

<xsl:template match="php">
    <xsl:apply-templates select="packages"/>
</xsl:template>

<xsl:template match="package">
    <param name="Include-{@name}" description='{@number}. {@desc}'>
        <xsl:attribute name="value">
            <xsl:choose>
                <xsl:when test="@depr">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </param>
</xsl:template>

</xsl:stylesheet>