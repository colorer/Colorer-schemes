<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- global type name parameter -->

  <xsl:param name="hrctype" select="'default-type'"/>

  <!-- allows common xml attributes (xml:*, xsi:*, xmlns:*) to appear in any context -->

  <xsl:param name="allow-common-attr" select="'yes'"/>

  <!-- allows any attributes to appear in any context -->

  <xsl:param name="allow-any-attr" select="'no'"/>

  <!-- allows unknown elements everywhere -->

  <xsl:param name="allow-unknown-elements" select="'no'"/>

  <!-- allows unknown root elements -->

  <xsl:param name="allow-unknown-root-elements" select="'no'"/>

  <!-- force single root element checks -->

  <xsl:param name="force-single-root" select="'yes'"/>

  <!-- include prototype definition into target file -->

  <xsl:param name="include-prototype" select="'no'"/>

  <!-- If yes, ignores all annotation/documentation elements in schema -->

  <xsl:param name="drop-annotations" select="'no'"/>

  <!-- path to HRC catalog (colorer.hrc) -->

  <xsl:param name="catalog-path" select="'xml.hrc'"/>

  <!-- path to custom parser file -->

  <xsl:param name="custom-defines" select="'custom.default.xml'"/>

  <!-- ignorecase pseudo-xml -->
  <xsl:param name="ignore-case-sgml" select="'no'"/>
  
  <!-- Use specified single top-level element
       If not specified, all global elements could be at top level of file.
  -->
  <xsl:param name="top-level-element" select="''"/>

  
  <!-- internal anonymous type prefix -->

  <xsl:variable name="anonymous" select="'_hrc_int_'"/>

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
   - The Original Code is the Colorer Library xsd2hrc module.
   -
   - The Initial Developer of the Original Code is
   - Cail Lomecb <cail@nm.ru>.
   - Portions created by the Initial Developer are Copyright (C) 1999-2003
   - the Initial Developer. All Rights Reserved.
   -
   - Contributor(s):
   - Eugene Efremov <4mirror@mail.ru>
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