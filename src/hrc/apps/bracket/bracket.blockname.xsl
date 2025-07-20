<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY separate "<xsl:text>&#10;</xsl:text>">
  <!ENTITY tab "<xsl:text>&#09;</xsl:text>">
]>

<!-- 
bracket: support custom blocks in hrc.
Written by Eugene Efremov <4mirror@mail.ru>
-->

<xsl:stylesheet
     version="1.0"
     exclude-result-prefixes="xsl"
     xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="scheme-check">
 <xsl:choose>
  <xsl:when test="@scheme"><xsl:value-of select="@scheme"/></xsl:when>
  <xsl:otherwise><xsl:value-of select="../@scheme"/></xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="/bracket/name-block/case" mode="final">
 <xsl:variable name="i"><xsl:value-of select="position()"/></xsl:variable>
 
 <xsl:choose><xsl:when test="@type = 'monoblock'">
  <block 
   start="/\M{../@start}{../name/@match}{@start}/" 
   end="/({@end})({../@end})/"
   scheme="{../@name}.block{$i}.core" 
   region="{../@region}" region10="def:PairEnd" 
   region11="{../@region-middle}"
   region12="{../@region-end}"
  />
  
 </xsl:when><xsl:when test="@type = 'halfblock'">
  <block 
   start="/\M{../@start}{../name/@match}({@all})/" 
   end="/(\y1)({../@end})/"
   scheme="{../@name}.block{$i}.core" 
   region="{../@region}" region10="def:PairEnd" 
   region11="{../@region-middle}"
   region12="{../@region-end}"
  />
 </xsl:when><xsl:when test="@type = 'noblock'">
  <block  
    start="/{../@start}\M{../name/@match}{@all}/" 
    end="/~{../name/@match}\m({@all}){../@end}/"
    region="{../name/@region}" scheme="{../name/@scheme}"
    region00="{../@region-start}" region10="{../@region-end}"
    region11="{../@region-middle}"
   />
 </xsl:when></xsl:choose>
  
</xsl:template>

<xsl:template match="/bracket/name-block/case" mode="base">
 <xsl:variable name="i"><xsl:value-of select="position()"/></xsl:variable>
 <xsl:variable name="sh"><xsl:call-template name="scheme-check"/></xsl:variable>

 <xsl:choose><xsl:when test="@type = 'monoblock'">
  <scheme name="{../@name}.block{$i}.core">
   <block 
    start="/~{../@start}\M{../name/@match}{@start}/" 
    end="/~{../name/@match}\m\M{@start}/"
    region="{../name/@region}" scheme="{../name/@scheme}"    
    region00="{../@region-start}"
   />
   <block start="/({@start})/" end="/\M{@end}/" scheme="{$sh}" 
    region00="{../@region-middle}" region01="def:PairStart"
   />
  </scheme>
  
 </xsl:when><xsl:when test="@type = 'halfblock'">
  <scheme name="{../@name}.block{$i}.core">
   <block 
    start="/~{../@start}\M{../name/@match}({@all})/" 
    end="/~{../name/@match}\m\M\y1/"
    region="{../name/@region}" scheme="{../name/@scheme}"    
    region00="{../@region-start}"
   />
   <block start="/({@all})/" end="/\M\y1/" scheme="{$sh}" 
    region00="{../@region-middle}" region01="def:PairStart"
   />
  </scheme>
 </xsl:when></xsl:choose>
  
</xsl:template>

     
</xsl:stylesheet>
