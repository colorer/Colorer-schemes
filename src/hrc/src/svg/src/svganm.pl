#!/usr/bin/perl
# script for fix svg scheme
use strict;

my $flin= shift(@ARGV);
my $text;

unless(open(XMLIN,"$flin")) 
{
 die("File $flin not foind. Transformation failed.\n");
}
while(<XMLIN>)
{
 $text.=$_;
}
close(XMLIN);

my $imp=<<XLINK

  xmlns:xlink="http://www.w3.org/1999/xlink">

  <annotation>
    <documentation>
    
    This schema of SVG (Scalable Vector Graphics) language was 
    generated from svg10.dtd (DTD documentaniton see below)

    by dtd2xsd.pl (c) Mary Holstege, Yuichi Koike, Dan Connolly, Bert Bos bert\@w3.org

    and adopted for using in colorer library as source for HRC syntax generation
    
    by svganm.pl (c) Eugene Efremov 4mirror\@mail.ru

   DTD documentation here: 
=====================================================================
  This is the DTD for SVG 1.0.

  The specification for SVG that corresponds to this DTD is available at:

    http://www.w3.org/TR/2001/REC-SVG-20010904/

  Copyright (c) 2000 W3C (MIT, INRIA, Keio), All Rights Reserved.

  For SVG 1.0:

    Namespace:
      http://www.w3.org/2000/svg  

    Public identifier:
      PUBLIC "-//W3C//DTD SVG 1.0//EN"

    URI for the DTD:
      http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd
=============================================================================    
    </documentation>
  </annotation>

  <import namespace="http://www.w3.org/1999/xlink" 
    schemaLocation="xlink.xsd"/>

    
XLINK
;

# это можно и руками (если - один раз)...
$text=~s#(<schema.*?)>#$1 $imp#sg;

# а это - нет.
$text=~s{<attribute name='(\w+):(\w+)'(.*?)(/>|>.*?</attribute>)}
{
 my $ns=$1;
 my $attr=$2;
 my $res=" ";
 if($ns=~/xml/)
 {
  $res="<!--$ns:$attr was here -->";
 }
 else
 {
  $res="<attribute ref='$ns:$attr' form='qualified'/>";
 }
 $res;
}seg;


print $text;
