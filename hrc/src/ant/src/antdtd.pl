#!/usr/bin/perl
use strict;

open XMLIN, shift or die $!;

my %rest=
(
 mapper => ['from','to'],
 replaceregexp => ['match','replace'],
 regexp => ['pattern',''],
 substitution => ['','expression'],
);

#fix wrong dtd...

my $hack="          expression \%string; #IMPLIED"; # param
my $hack2=<<FAIL;
          if \%string; #IMPLIED
          unless \%string; #IMPLIED
          message \%string; #IMPLIED
FAIL

my $element='';
my $ignore=0;
while(<XMLIN>)
{
 if($ignore)
 {
 	$ignore=0 if/name CDATA #IMPLIED>/;
 	next
 }
 if(/<!ELEMENT target EMPTY>/)
 {
 	$ignore=1;
 	next
 }
 
 if(m|<!ATTLIST (\w+)|)
 {
  $element=$1;
  $_ .="$hack\n" if($element eq 'param');
  $_ .="$hack2" if($element eq 'fail');
 }

 s|<\?xml version="1\.0" encoding="UTF-8" \?>\s|
<!ENTITY \% string \"CDATA\">
<!ENTITY \% restring \"CDATA\">
<!ENTITY \% rplstring \"CDATA\">
<!ENTITY \% FPI \"CDATA\">
          
<!ELEMENT stlist (#PCDATA)>
<!ELEMENT stcheckin (#PCDATA)>
<!ELEMENT stcheckout (#PCDATA)>
\n|g;


 s/publicid CDATA #IMPLIED/publicid %FPI; #IMPLIED/g;
 s|<!ELEMENT fail EMPTY>|<!ELEMENT fail (#PCDATA)>|g;
 s@<!ELEMENT ant EMPTY>@<!ELEMENT ant (property|reference)*>@g;

 s{(\w+)\s+CDATA\s+#IMPLIED}
 {
  my $attrib=$1;
  my $type="string";
  if($rest{$element})
  {
   $type = "restring" if($rest{$element}[0] eq $attrib);
   $type = "rplstring" if($rest{$element}[1] eq $attrib);
  }
  "$attrib \%$type; #IMPLIED"
 }esg;
 print;
}
