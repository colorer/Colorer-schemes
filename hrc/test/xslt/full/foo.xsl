<?xml version = "1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

<xsl:template match="/">

<HTML>
<BODY>
<H1>Editor Contacts</H1>
<xsl:for-each select="editor_contacts/editor">
<H2>Name: <xsl:value-of select="first_name"/>
<xsl:value-of select="last_name"/></H2>
<P>Title: <xsl:value-of select="title"/></P>
<P>Publication: <xsl:value-of select="publication"/></P>
<P>Street Address: <xsl:value-of select="address/street"/></P>
<P>City: <xsl:value-of select="address/city"/></P>
<P>State: <xsl:value-of select="address/state"/></P>
<P>Zip: <xsl:value-of select="address/zip"/></P>
<P>E-Mail: <xsl:value-of select="e_mail"/></P>
</xsl:for-each>
</BODY>
</HTML>
</xsl:template>
</xsl:stylesheet>

