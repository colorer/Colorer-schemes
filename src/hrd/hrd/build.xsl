<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" encoding="utf-8"/>
<xsl:strip-space elements="*"/>

<xsl:template match='target-list'>
	<project name="con2rgb.lst" default="all" basedir=".">
		
		<property name="target" value="all" description="default subproject target"/>
		
		<xsl:apply-templates/>
		
		<target name="all">
			<xsl:apply-templates mode='all'/>
		</target>
		
	</project>
</xsl:template>

<xsl:template match='group'>
		<target name="{@target}">
			<xsl:apply-templates/>
		</target>
</xsl:template>

<xsl:template match='target'>
	<ant dir='../apps/{../@target}' antfile="build.xml" target="${{target}}">
		<property name="input" value="{@in}"/>
		<property name="output" value="{@out}"/>
		<xsl:if test='@palette'>
			<property name="hcd" value="{@palette}"/>
		</xsl:if>
	</ant>
</xsl:template>


<xsl:template match='group' mode='all'>
	<antcall target='{@target}'>
		<param name='target' value='${{target}}'/>
	</antcall>
</xsl:template>


</xsl:stylesheet>
