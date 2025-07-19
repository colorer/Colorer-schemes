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

<xsl:template match="/bracket/block/query" mode="final">
 <xsl:variable name="i"><xsl:value-of select="position()"/></xsl:variable>
  <block 
   start="/\b\M(({../@start})({@start1}))/" 
   end="/({@end2})({../@end})/"
   scheme="{../@name}.block{$i}.core" 
   region="{../@region2}" 
   region11="{../@region-middle}"
   region12="{../@region-end}"
  /> <!-- region01="def:PairStart" region10="def:PairEnd"  -->
</xsl:template>

<xsl:template match="/bracket/block/query" mode="base">
 <xsl:variable name="i"><xsl:value-of select="position()"/></xsl:variable>
  <xsl:if test="@recursion1 = 'yes'">
   <scheme name="{../@name}.block{$i}.s1.{../@scheme1}">
    <inherit scheme="{../@scheme1}"/>
    <block start="/{@start1}/" end="/{@end1}/" 
     scheme="{../@name}.block{$i}.s1.{../@scheme1}"
     region00="def:PairStart" region10="def:PairEnd" 
    />
   </scheme>
  </xsl:if>
  <xsl:if test="@recursion2 = 'yes'">
   <scheme name="{../@name}.block{$i}.s2.{../@scheme2}">
    <inherit scheme="{../@scheme2}"/>
    <block start="/{@start2}/" end="/{@end2}/" 
     scheme="{../@name}.block{$i}.s2.{../@scheme2}"
     region00="def:PairStart" region10="def:PairEnd" 
    />
   </scheme>
  </xsl:if>
  
  <scheme name="{../@name}.block{$i}.middle">
   <block 
     start="/~({../@start})(({@start1}))/" 
     end="/({@end1})/"
     region="{../@region1}" region01="{../@region-start}" 
     region02="{../@region-middle}" region03="def:PairStart"
     region10="{../@region-middle}" region11="def:PairEnd"
    >
    <xsl:attribute name="scheme"><!--scheme="{../@scheme1}" -->
     <xsl:choose><xsl:when test="@recursion1 = 'yes'"><xsl:value-of 
       select="../@name"/>.block<xsl:value-of 
       select="$i"/>.s1.<xsl:value-of 
       select="../@scheme1"/>
     </xsl:when><xsl:otherwise>
      <xsl:value-of select="../@scheme1"/>
     </xsl:otherwise></xsl:choose>
    </xsl:attribute>
   </block>
   <xsl:if test="../@scheme-middle">
    <inherit scheme="{../@scheme-middle}"/>
   </xsl:if>
   <regexp match="/\S+?/" region0="def:Error" priority="low"/>
  </scheme>
  
  <scheme name="{../@name}.block{$i}.core">
   <block start="/~\M({../@start})({@start1})/" 
    end="/\M({@start2})/"
    scheme="{../@name}.block{$i}.middle"
   />
   <block start="/({@start2})/" end="/\M({@end2})({../@end})/" 
    region00="def:PairStart" region11="def:PairEnd" 
    region01="{../@region-middle}">
    <xsl:attribute name="scheme"><!--scheme="{../@scheme2}" -->
     <xsl:choose><xsl:when test="@recursion2 = 'yes'"><xsl:value-of 
       select="../@name"/>.block<xsl:value-of 
       select="$i"/>.s2.<xsl:value-of 
       select="../@scheme2"/>
     </xsl:when><xsl:otherwise>
      <xsl:value-of select="../@scheme2"/>
     </xsl:otherwise></xsl:choose>
    </xsl:attribute>    
   </block>
  </scheme>
  
  &separate; 
</xsl:template>
     
</xsl:stylesheet>
