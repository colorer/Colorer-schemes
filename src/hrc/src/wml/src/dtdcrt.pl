#!/usr/bin/perl 
# for fix std wml13.dtd:
# perl dtdcrt.pl wml13.dtd> wml.dtd

#while(<>) not work - mixed cr/lf
foreach(split/[\x0a\x0d]/,join('',<>))
{
 s&<!ENTITY \% text     "#PCDATA \| \%emph;">&<!ENTITY \% text     " \%emph;">&;
 s/%(text|flow|fields);/#PCDATA | %$1;/ unless m/<\!ENTITY/;
 next if m/xml:\w+/;
 print $_,"\n";
}