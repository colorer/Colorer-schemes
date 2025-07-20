<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" encoding="utf-8"/>
<xsl:strip-space elements="*"/>

<xsl:template match='target-list'>
	<project name="src.all.lst" default="all" basedir=".">
		<property name="root" value="../.." description="hrc project root location"/>
		<property name="util" value="${{root}}/apps/ant/util.xml" description="ant utils location"/>
		<property name="this" value="${{root}}/src" description="this project location"/>
		
		<property name="src" value="src" description="this project sourse"/>
		<property name="bin" value="ready" description="this project output dir"/>
		<property name="target" value="all" description="default subproject target"/>
		<property name="bin.prot" value="${{root}}/hrc" description="this project proto.hrc addon"/>
		
		<target name="all">
			<xsl:apply-templates/>
		</target>
		
	</project>
</xsl:template>

<xsl:template match='target'>
	<ant dir="{@type}" antfile="build.xml" target="${{target}}">
		<property name="this" value="${{this}}/{@type}"/>
		<property name="bin" value="${{bin}}/{@place}"/>
		<property name="bin.prot" value="${{bin.prot}}"/>
	</ant>
</xsl:template>

</xsl:stylesheet>
