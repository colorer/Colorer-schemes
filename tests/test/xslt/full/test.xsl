<?xml version="1.0" encoding="Windows-1251"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="0.1">
  <xsl:output encoding="Windows-1251"/>
  <xsl:template match="/root">
    <root>
      <new-text>Проверка</new-text>
      <old-text>
        <xsl:apply-templates select="text"/>
      </old-text>
    </root>
  </xsl:template>
</xsl:transform>





























