<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs='http://www.w3.org/2001/XMLSchema'
	xmlns:l='urn:local'
>

<xsl:output method="text" encoding="UTF-8" indent="no"/>
<xsl:strip-space elements="*"/>


<!-- 
 !
 ! functions
 !
 !-->

<!-- char2hex -->

<xsl:function name='l:hdcvt' as='xs:string'>
	<xsl:param name='dh' as='xs:integer'/>
	
	<xsl:value-of select="
		if($dh &lt; 10) then 
			$dh 
		else 
			translate(xs:string($dh - 10), '012345', 'ABCDEF')
	"/>
</xsl:function>


<xsl:function name='l:dec2hex' as='xs:string'>
	<xsl:param name='dec' as='xs:integer'/>
	
	<xsl:value-of select="
		if(($dec div 16) &lt; 1) then
			l:hdcvt($dec mod 16)
		else
			concat(l:dec2hex($dec idiv 16), l:dec2hex($dec mod 16))
	"/>
</xsl:function>


<xsl:function name='l:char2hex' as='xs:string'>
	<xsl:param name='char' as='xs:string'/>
	
	<xsl:value-of select="l:dec2hex(string-to-codepoints($char))"/>
</xsl:function>



<!-- alignment 8x0 -->

<xsl:function name='l:align' as='xs:string'>
	<xsl:param name='hex' as='xs:string'/>
	<xsl:variable name='psz' select='8 - string-length($hex)'/>
	<xsl:variable name='prf' select="for $i in 1 to $psz return '0'"/>
	
	<xsl:value-of select="concat(string-join($prf,''), $hex)"/>
</xsl:function>



<!-- getref -->

<xsl:function name='l:getrefval'>
	<xsl:param name="where"/>
	
	<xsl:if test="not($where/@allow = 'no')">
		<xsl:value-of select='$where/@value'/>
	</xsl:if>
</xsl:function>


<xsl:function name="l:getdef">
	<xsl:param name="where"/>
	<xsl:param name="ref"/>
	
	<xsl:variable name="res" select="l:getrefval($where/*[@name = $ref])"/>
	
	<xsl:if test="not(string-length($res)) and string-length($ref)">
		<xsl:message>Warning: refrense <xsl:value-of select="$ref"/> not found, use default.</xsl:message>
	</xsl:if>
	
	<xsl:value-of select="
		if(not(string-length($res))) then
			l:getrefval($where/*[@name = $where/@default])
		else
			$res
	"/>
</xsl:function>




<!--
 !
 ! part I: to local xml
 !
 !--> 

<xsl:variable name="defs" 
	select="document(farkeys/defs/@href)/defs"
/>

<xsl:variable name="defmask" 
	select="$defs/mask/@default"
/>

<xsl:variable name="cursor" 
	select="$defs/colors/cursor"
/>

<xsl:variable name="back" 
	select="$defs/colors/col[@name = 'back']/@value"
/>


<!--
[HKEY_CURRENT_USER\Software\Far2\Colors\Highlight\Group8]
"IgnoreMask"=dword:00000000
"Mask"="*.cpp,*.c,*.C,*.cc,*.asm,*.pas,*.sql,*.d,*.m4,*.y,*.l,*.f,*.for"
"UseDate"=dword:00000000
"DateType"=dword:00000000
"DateAfter"=hex:00,00,00,00,00,00,00,00
"DateBefore"=hex:00,00,00,00,00,00,00,00
"DateRelative"=dword:00000000
"UseSize"=dword:00000000
"SizeAboveS"=""
"SizeBelowS"=""
"UseAttr"=dword:00000000
"IncludeAttributes"=dword:00000000
"ExcludeAttributes"=dword:00000000
"NormalColor"=dword:00000012
"SelectedColor"=dword:00000000
"CursorColor"=dword:00000000
"SelectedCursorColor"=dword:00000000
"MarkCharNormalColor"=dword:00000000
"MarkCharSelectedColor"=dword:00000000
"MarkCharCursorColor"=dword:00000000
"MarkCharSelectedCursorColor"=dword:00000000
"MarkChar"=dword:000025cb
"ContinueProcessing"=dword:00000000
-->

<xsl:template match="type">
	<xsl:variable name='char' select='l:getdef($defs/keys, @ref)'/>
	<xsl:variable name='fore' select='l:getdef($defs/colors, ../@ref)'/>
	
	<xsl:variable name="cb" select="$cursor/@back"/>
	<xsl:variable name="cf" select="if($cursor/@fore)then $cursor/@fore else $fore"/>
	
	<xsl:variable name='mask' select="string-join(file,',')"/>
	
	<l:type pos='{position()}' order="{@n}" char='{$char}'>
		<l:key name='IgnoreMask' value=''/>
		<l:str name='Mask' value="{if($mask) then $mask else $defmask}"/>
		<l:key name='UseDate' value=''/>
		<l:key name='DateType' value=''/>
		<l:hex name='DateAfter'/>
		<l:hex name='DateBefore'/>
		<l:key name='DateRelative' value=''/>
		<l:key name='UseSize' value=''/>
		<l:str name='SizeAboveS' value=''/>
		<l:str name='SizeBelowS' value=''/>
		<l:key name='UseAttr' value="{if(@attr) then '1' else '0'}"/>
		<l:key name='IncludeAttributes' value='{@attr}'/>
		<l:key name='ExcludeAttributes' value=''/>
		<l:key name='NormalColor' value="{$back}{$fore}"/>
		<l:key name='SelectedColor' value=''/>
		<l:key name='CursorColor' value="{$cb}{$cf}"/>
		<l:key name='SelectedCursorColor' value=''/>
		<l:key name='MarkCharNormalColor' value=''/>
		<l:key name='MarkCharSelectedColor' value=''/>
		<l:key name='MarkCharCursorColor' value=''/>
		<l:key name='MarkCharSelectedCursorColor' value=''/>
		<l:key name='MarkChar' value='{l:char2hex($char)}'/>
		<l:key name='ContinueProcessing' value=''/>
	</l:type>
</xsl:template>




<!--
 !
 ! part II: to reg
 !
 !-->
 
<xsl:variable name="dirname"
	select="'HKEY_CURRENT_USER\Software\Far2\Colors\Highlight'"
/>



<xsl:template match='l:reg'>
<xsl:text>REGEDIT4

[-</xsl:text><xsl:value-of select="$dirname"/><xsl:text>]

</xsl:text>
	<xsl:apply-templates/>
</xsl:template>



<xsl:template match='l:type'>
	<xsl:value-of select="concat('[', $dirname, '\Group', @pos - 1, ']')"/>
	<xsl:apply-templates/>
	<xsl:call-template name="cr-lf"/>
	<xsl:call-template name="cr-lf"/>
</xsl:template>



<xsl:template match='l:key'>
	<xsl:next-match/>
	<xsl:text>dword:</xsl:text>
	<xsl:value-of select='l:align(@value)'/>
</xsl:template>

<xsl:template match='l:str'>
	<xsl:next-match/>
	<xsl:value-of select="concat('&quot;',@value,'&quot;')"/>
</xsl:template>

<xsl:template match='l:hex'>
	<xsl:next-match/>
	<xsl:text>hex:00,00,00,00,00,00,00,00</xsl:text>
</xsl:template>


<xsl:template match='l:*'>
	<xsl:call-template name="cr-lf"/>
	<xsl:value-of select="concat('&quot;',@name,'&quot;=')"/>
</xsl:template>


<xsl:template name="cr-lf">
<xsl:text>
</xsl:text>
</xsl:template>


<!--
 !
 ! core
 !
 !-->

<xsl:template match="farkeys">
	<!-- part I -->
	<xsl:variable name='reg'>
		<l:reg>
			<xsl:apply-templates select="group/type">
				<xsl:sort select="@n" data-type="number"/>
			</xsl:apply-templates>
		</l:reg>
	</xsl:variable>
	
	<!-- part II -->
	<xsl:apply-templates select='$reg/l:reg'/>
</xsl:template>

</xsl:stylesheet>
<!-- ***** BEGIN LICENSE BLOCK *****
   - Version: MPL 1.1/GPL 2.0/LGPL 2.1
   -
   - The contents of this file are subject to the Mozilla Public License Version
   - 1.1 (the "License"); you may not use this file except in compliance with
   - the License. You may obtain a copy of the License at
   - http://www.mozilla.org/MPL/
   -
   - Software distributed under the License is distributed on an "AS IS" basis,
   - WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
   - for the specific language governing rights and limitations under the
   - License.
   -
   - The Original Code is the FarKeys addon.
   -
   - The Initial Developer of the Original Code is
   - Eugene Efremov <4mirror@mail.ru>.
   - Portions created by the Initial Developer are Copyright (C) 2005-2010
   - the Initial Developer. All Rights Reserved.
   -
   - Contributor(s):
   -
   - Alternatively, the contents of this file may be used under the terms of
   - either the GNU General Public License Version 2 or later (the "GPL"), or
   - the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
   - in which case the provisions of the GPL or the LGPL are applicable instead
   - of those above. If you wish to allow use of your version of this file only
   - under the terms of either the GPL or the LGPL, and not to allow others to
   - use your version of this file under the terms of the MPL, indicate your
   - decision by deleting the provisions above and replace them with the notice
   - and other provisions required by the LGPL or the GPL. If you do not delete
   - the provisions above, a recipient may use your version of this file under
   - the terms of any one of the MPL, the GPL or the LGPL.
   -
   - ***** END LICENSE BLOCK ***** -->
