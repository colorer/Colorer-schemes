#! perl
#
# Mary Holstege (holstege@mathling.com) 2001/05/15
# derived from
#
# Yuichi Koike ($Id$)
# derived from
#
# Dan Connolly
# derived from
#
# Bert Bos <bert@w3.org>
# Created: 17 Mar 1998
#

use strict;

# Handling command line argument
my $targetNS = "http://www.w3.org/namespace/";
my $prefix = "t";
my $alias = 0;
my $file = "";
my %SimpleTypes;
my @AttrGroupPatterns;
my @ModelGroupPatterns;
my @SubstitutionGroupPatterns;
my %SubstitutionGroup;
my @ComplexTypePatterns;

my %Mixed;
my %ModelGroup;
my $mapping_file;
my $pcdata_flag = 0;
my $pcdata_simpletype = "string";
my $debug = 0;
my $skipxmlattr = 0;

while ($#ARGV >= 0) {
   my $para = shift(@ARGV);
   if ($para eq "-ns") {
      $targetNS = shift(@ARGV);
   } elsif ($para eq "-prefix") {
      $prefix = shift(@ARGV);
   } elsif ($para eq "-alias") {
      $alias = 1;
   } elsif ($para eq "-pcdata") {
      # Treat #PCDATA by itself as being string (or other simple type
      # if so designated in the mapping file)
      $pcdata_flag = 1;
   } elsif ($para eq "-mapfile") {
      $mapping_file = shift(@ARGV);
   } elsif ($para eq "-simpletype") {
      my($pat) = shift(@ARGV);
      my($b) = shift(@ARGV);
      $SimpleTypes{$pat} = $b;
   } elsif ($para eq "-attrgroup") {
      push(@AttrGroupPatterns, shift(@ARGV));
   } elsif ($para eq "-modelgroup") {
      push(@ModelGroupPatterns, shift(@ARGV));
   } elsif ($para eq "-substgroup") {
      push(@SubstitutionGroupPatterns, shift(@ARGV));
   } elsif ($para eq "-skipxmlattr") {
      $skipxmlattr = 1;
   } elsif ($para eq "-complextype") {
     push(@ComplexTypePatterns, shift(@ARGV));
   } elsif ($para eq "-debug") {
      $debug = 1;
   } else {
      $file = $para;
   }
}

open( INTERMEDIATE, ">intermediate.out");

# Alias dictionary: defaults
my %alias_dic;
$alias_dic{"URI"} = "anyURI";
$alias_dic{"LANG"} = "language";
$alias_dic{"NUMBER"} = "nonNegativeInteger";
$alias_dic{"Date"} = "date";
#$alias_dic{"Boolean"} = "boolean";

if ( $mapping_file )
{
   # print STDERR "Open mapping $mapping_file ";
   if ( !open( MAPPINGS, "<$mapping_file" ) )
   {
      # print STDERR "unsuccessful.\n";
   }
   else {
      # print STDERR "successful.\n";
      while ( <MAPPINGS> ) {
        chop;
        if ( /^alias\s+([^ \t]+)\s*=\s*([^ \t]+)\s*/i ) {
           $alias_dic{$1} = $2;
        }
        elsif ( /^simpletype\s+([^ \t]+)\s*=\s*([^ \t]+)\s*/i ) {
           $SimpleTypes{$1} = $2;
        }
        elsif ( /^attrgroup\s+([^ \t]+)\s*/i ) {
           push( @AttrGroupPatterns, $1 );
        }
        elsif ( /^modelgroup\s+([^ \t]+)\s*/i ) {
           push( @ModelGroupPatterns, $1 );
        }
        elsif ( /^substgroup\s+([^ \t]+)\s*/i ) {
           push( @SubstitutionGroupPatterns, $1 );
        }
        elsif ( /^complextype\s+([^ \t]+)\s*/i ) {
           push( @ComplexTypePatterns, $1 );
        }
        elsif ( /^pcdata\s+([^ \t]+)\s*/i ) {
           ## BUGLET: doesn't pay attention to prefix; just a special alias
           $pcdata_simpletype = $1;
        }
      }
   }

   foreach my $key (keys(%alias_dic))
   {
      # print STDERR "Alias \%$key to $alias_dic{$key}\n"
   }
}

# Variable declaration
my $linelen = 72;

my $PROG = substr($0, rindex($0, "/") + 1);
my $USAGE = "Usage: $PROG file\n";

my $str = "(?:\"([^\"]*)\"|\'([^\']*)\')";
my %pent;       # Parameter entities
my %attributes;     # Attribute lists
my @element;      # Elements in source order
my %model;        # Content models

# Main
$/ = undef;

# Open file, remove comment and include external entity
my $buf = openFile($file);

open( RAW, ">raw.out");
print RAW $buf;

# Alias treatment
my $alias_ident = "_alias_";
if ($alias eq 1) {
   foreach my $key (keys(%alias_dic)) {
      my $aliaskey = sprintf("%s%s%s", $alias_ident, $key, $alias_ident);
      $buf =~ s/\%$key;/$aliaskey/gsie;
   }
}

my %imports;
   # store external parameter entities
   while ($buf =~ s/<!ENTITY\s+%\s+(\S+)\s+PUBLIC\s+$str\s+$str.*?>//sie) {
     # print STDERR "$1 is $4.$5\n";
      $imports{$1} = $4.$5;
   }
   while ($buf =~ s/<!ENTITY\s+%\s+(\S+)\s+SYSTEM\s+$str.*?>//sie) {
     # print STDERR "$1 is $2.$3\n";
      $imports{$1} = $2.$3;
   }

     foreach my $key (keys(%imports)) {
     $pent{$key} = "  <!_IMPORT $imports{$key}> ";
     }

# store all parameter entities
while ($buf =~ s/<!ENTITY\s+%\s+(\S+)\s+$str\s*>//sie) {
    my($n, $repltext) = ($1, $2.$3);
    my ($pat);

    next if $pent{$n}; # only the first declaration of an entity counts

    foreach $pat (keys %SimpleTypes){
      if ($n =~ /^$pat$/){
        $buf .= " <!_DATATYPE $n $SimpleTypes{$pat} $repltext> ";
        $pent{$n} = "#DATATYPEREF $n";
        undef $n;
        last;
      }
    }

    foreach $pat (@AttrGroupPatterns){
      if ($n =~ /^$pat$/){
        $buf .= " <!_ATTRGROUP $n $repltext> ";
        $pent{$n} = "#ATTRGROUPREF $n";
        undef $n;
        last;
      }
    }

    foreach $pat (@ModelGroupPatterns){
      if ($n =~ /^$pat$/){
        $buf .= " <!_MODELGROUP $n $repltext> ";
        $pent{$n} = "#MODELGROUPREF $n";
        undef $n;
        last;
      }
    }

    foreach $pat (@SubstitutionGroupPatterns){
      if ($n =~ /^$pat$/){
        $buf .= " <!_SUBSTGROUP $n $repltext> ";
        $pent{$n} = "#SUBSTGROUPREF $n";
        undef $n;
        last;
      }
    }

    foreach $pat (@ComplexTypePatterns) {
      if ($n =~ /^$pat$/){
        $buf .= " <!_COMPLEXTYPE $n $repltext> ";
        $pent{$n} = "#COMPLEXTYPEREF $n";
        undef $n;
        last;
      }
    }

    $pent{$n}=$repltext if $n;
}

open( MUNGED, ">munged.out");
print MUNGED $buf;

# remove all general entities
$buf =~ s/<!ENTITY\s+.*?>//gsie;

# loop until parameter entities fully expanded
my $i;
do {
   # count # of substitutions
   $i = 0;
   # expand parameter entities
   $buf =~ s/%([a-zA-Z0-9_\.-]+);?/$i++,$pent{$1}/gse;
} while ($i != 0);

# treat conditional sections
# BUG: Doesn't handle nested conditional sections right
while($buf =~ s/<!\[\s*INCLUDE\s*\[([^\]]*\][^\]][^\]]*|[^\]]*)\]\]>/$1/sie) {}
while($buf =~ s/<!\[\s*IGNORE\s*\[([^\]]*\][^\]][^\]]*|[^\]]*)\]\]>/$1/sie) {}

open( EXPANDED, ">expanded.out");
print EXPANDED $buf;

# store attribute lists
$buf =~ s/<!ATTLIST\s+(\S+)\s+(.*?)>/store_att($1, $2)/gsie;

# store content models
$buf =~ s/<!ELEMENT\s+(\S+)\s+(.+?)>/store_elt($1, $2)/gsie;

#print "<?xml version='1.0'?>\n";
print "<schema
  xmlns='http://www.w3.org/2001/XMLSchema'
  targetNamespace='$targetNS'
  xmlns:$prefix='$targetNS'>\n";

# find maximum length of non-terminals
#my $maxlen = max(map(length, @element)) + 4;

# write imports
$buf =~ s/<!_IMPORT\s+(\S+)\s*>/write_import($1)/gsie;

# write simple type declarations
$buf =~ s/<!_DATATYPE\s+(\S+)\s+(\S+)\s+(.+?)>/write_simpleType($1, $2, $3)/gsie;

# write complex type declarations
$buf =~ s/<!_COMPLEXTYPE\s+(\S+)\s+(.+?)>/write_complexType($1, $2)/gsie;

# write attribute groups
$buf =~ s/<!_ATTRGROUP\s+(\S+)\s+(.+?)>/write_attrGroup($1, $2)/gsie;

# write model groups
$buf =~ s/<!_MODELGROUP\s+(\S+)\s+(.+?)>/write_modelGroup($1, $2)/gsie;

# write subsitution groups
$buf =~ s/<!_SUBSTGROUP\s+(\S+)\s+(.+?)>/write_substitutionGroup($1, $2)/gsie;

my $str2 = "(\"[^\"]*\"|\'[^\']*\')";
# write notation declarations
$buf =~ s/<!NOTATION\s+(\S+)\s+PUBLIC\s+$str2\s+$str2\s*>/write_notation($1, $2, $3)/gsie;
$buf =~ s/<!NOTATION\s+(\S+)\s+PUBLIC\s+$str2\s*>/write_notation($1, $2)/gsie;

print INTERMEDIATE $buf;

my($e);

# loop over elements, writing XML schema
foreach $e (@element) {
   my $h = $model{$e};
   my $h2 = $attributes{$e};
   my @model = @$h;
   my $isSimple = ($pcdata_flag eq 1) && ($model[1] eq '#PCDATA') &&
      ( ($#model eq 2) ||
       ( ($#model eq 3) && ($model[3] eq '*') ) );

   my $substGroup = $SubstitutionGroup{$e};
   if ( $substGroup )
   {
      $substGroup = " substitutionGroup='$substGroup'";
   }

   # print rule for element $e
   if ( $isSimple && ! $h2 )
   {
      # Assume (#PCDATA) is string
      print "\n <element name='$e' type='$pcdata_simpletype'$substGroup>\n";
   }
   else {
      print "\n <element name='$e'$substGroup>\n";
   }

   if ( $isSimple )
   {
      # Assume (#PCDATA) is string
      if ( $h2 )
      {
        print "  <complexType>\n";
        print "  <simpleContent>\n";
        print "  <extension base='string'>\n";
      }
   }

   else {
      # print rule for $e's content model
      print "  <complexType";
      if ($model[0] eq 'EMPTY') {
        if (! $h2 ) {
           print "/>\n";
        } else {
           print ">\n";
        }
      }
      elsif ( $model[0] eq 'ANY' )
      {
        print ">\n";
        print "   <sequence>\n";
        print "   <any namespace='$targetNS'/>\n";
        print "   </sequence>\n";
      }
      else {
        if ( $debug eq 1 ) {
           # print STDERR "==mixed? @model\n"; #@@
        }
        if (&isMixed(@model)) {
           print " mixed='true'>\n";
        }
        else {
           print ">\n";
        }

        my @list = &makeChildList('', @model);
        &printChildList(3, @list);
      }
   }

   # print rule for $e's attributes
   if (! $h2) {
      # nothing
   } else {
      &printAttrDecls(@$h2);
      if ( $isSimple ) {
        print "   </extension>\n";
        print "   </simpleContent>\n";
      }
   }

   if ( !$h2 && $isSimple ) {
      # Do nothing
   }
   elsif ($h2 || $model[0] ne 'EMPTY') {
      print "  </complexType>\n";
   }

   print " </element>\n";
}

print "</schema>\n";
exit;

sub printSpace
{
   my ($num) = $_[0];
   for (my $i=0; $i<$num; $i++) {
      print " ";
   }
}

sub printChildList
{
   my ($num, @list) = @_;

   my @currentTag = ();
   for (my $i=0; $i<= $#list; $i++) {
      my $n = $list[$i];

      if ($n eq 0 || $n eq 1 || $n eq 2 || $n eq 3) {
        if ( ($pcdata_flag eq 0) && ($n eq 0 || $n eq 1) && $list[$i+1] eq 20)
        {
           # The whole list is 0 20 or 1 20; i.e. (#PCDATA) or (#PCDATA)*.
           # Don't generate a sequence child; mixed handles all this.
        }
        else {
           if ( $currentTag[$#currentTag] eq "" && $n eq 0 )
           {
              push(@currentTag, "");
           }

           printSpace($num); $num++;
           print "<sequence";
           if ($n eq 1) {
              print " minOccurs='0' maxOccurs='unbounded'";
           } elsif ($n eq 2) {
              print " maxOccurs='unbounded'";
           } elsif ($n eq 3) {
              print " minOccurs='0' maxOccurs='1'";
           }
           print ">\n";
           push(@currentTag, "sequence");
        }
      } elsif ($n eq 10 || $n eq 11 || $n eq 12 || $n eq 13) {
        printSpace($num); $num++;
        print "<choice";
        if ($n eq 11) {
           print " minOccurs='0' maxOccurs='unbounded'";
        } elsif ($n eq 12) {
           print " maxOccurs='unbounded'";
        } elsif ($n eq 13) {
           print " minOccurs='0' maxOccurs='1'";
        }
        print ">\n";
        push(@currentTag, "choice");
      } elsif ($n eq 20) {
        my $tag = pop(@currentTag);
        if ($tag ne "") {
           $num--; printSpace($num);
           print "</", $tag, ">\n";
        }
      } else {
        printSpace($num);
        if ($n eq '#MODELGROUPREF') {
           print "<group ref='";
           my $eltname = $list[++$i];
           if ( $eltname =~ /:/ ) {
              print "$eltname'";
           }
           else {
              print "$prefix:$eltname'";
           }
        }
        elsif ($n eq '#COMPLEXTYPEREF') {
           my $eltname = $list[++$i];
           if ( $eltname =~ /:/ ) {
              print "<element name='$eltname' type='$eltname'";
           }
           else {
              print "<element name='$eltname' type='$prefix:$eltname'";
           }
        }
        elsif ($n eq '#SUBSTGROUPREF') {
           my $eltname = $list[++$i];
           if ( $eltname =~ /:/ ) {
              print "<element ref='$eltname'";
           }
           else {
              print "<element ref='$prefix:$eltname'";
           }
        } else {
           if ( $n =~ /:/ ) {
              print "<element ref='$n'";
           }
           else {
              print "<element ref='$prefix:$n'";
           }
        }

#?? (foo+, bar+, quux?)
#??why       if ($currentTag[$#currentTag] ne "choice") {
           if ($list[$i+1] eq "+") {
              print " maxOccurs='unbounded'";
              $i++;
           } elsif ($list[$i+1] eq "?") {
              print " minOccurs='0' maxOccurs='1'";
              $i++;
           } elsif ($list[$i+1] eq "*") {
              print " minOccurs='0' maxOccurs='unbounded'";
              $i++;
           }
#        }
        print "/>\n";
      }
   }
}

sub makeChildList {
   my ($groupName, @model) = @_;
   print INTERMEDIATE "GROUPNAME=", $groupName, "; MODEL=", @model, "\n";
   my @ret = ();
   my @brace = ();
   for (my $i=0; $i<=$#model; $i++) {
      my $n = $model[$i];

      if ($n eq "(") {
        push(@ret, 0);
        push(@brace, $#ret);
      } elsif ($n eq ")") {
        if ($model[$i+1] eq "*") {
           $ret[$brace[$#brace]] += 1;
           $i++;
        } elsif ($model[$i+1] eq "+") {
           $ret[$brace[$#brace]] += 2;
           $i++;
        } elsif ($model[$i+1] eq "?") {
           $ret[$brace[$#brace]] += 3;
           $i++;
        }
        pop(@brace);
        push(@ret, 20);
      } elsif ($n eq ",") {
        $ret[$brace[$#brace]] = 0;
      } elsif ($n eq "|") {
        $ret[$brace[$#brace]] = 10;
      } elsif ($n eq "#PCDATA") {
        if ($model[$i+1] eq "|") {
           $i++;
        }
        if($groupName){
           $Mixed{$groupName} = 1;
        }
      } else {
        push(@ret, $n);
      }
   }

   # "( ( a | b | c )* )" gets mapped to "0 10 a b c 20 20" which will generate
   # a spurious sequence element. This is not too harmful when this is an
   # element content model, but with model groups it is incorrect.
   # In general we need to strip off 0 20 from the ends when it is redundant.
   # Redundant means: there is some other group that bounds the whole list.
   # Note that it gets a little tricky:
   # ( (a|b),(c|d) ) gets mapped to "0 10 a b 20 10 c d 20 20". If one
   # naively chops off the 0 and 20 on the groups that there is a 10 on one
   # end and a 20 on the other, one loses the bounding sequence, which is
   # required in this case.
   #
   if ( $ret[0] eq 0 && $ret[$#ret] eq 20 && $ret[$#ret-1] eq 20 &&
      ( $ret[1] eq 0 || $ret[1] eq 1 || $ret[1] eq 2 || $ret[1] eq 3 ||
        $ret[1] eq 10 || $ret[1] eq 11 || $ret[1] eq 12 || $ret[1] eq 13 )
      )
   {
      # OK, it is possible that the 0 20 is redundant. Now scan for balance:
      # All interim 20 between the proposed new start and the proposed new
      # final one should be at level 1 or above.
      my $depth = 0;
      my $redundant_paren = 1;  # Assume redundant until proved otherwise
      for ( my $i = 1; $i <= $#ret-1; $i++ )
      {
        if ( $ret[$i] eq 20 )
        {
           $depth--;
           if ( $i < $#ret-1 && $depth < 1 )
           {
              $redundant_paren = 0;
#             # print STDERR "i=$i,depth=$depth\n";
           }
        }
        elsif ( $ret[$i] eq 0 ||
              $ret[$i] eq 1 ||
              $ret[$i] eq 2 ||
              $ret[$i] eq 3 ||
              $ret[$i] eq 10 ||
              $ret[$i] eq 11 ||
              $ret[$i] eq 12 ||
              $ret[$i] eq 13
              )
        {
           $depth++;
        }
      }  # for

      if ( $redundant_paren eq 1 )
      {
        # print STDERR "Truncating @ret\n";
        @ret = @ret[1..$#ret-1];
      }
   }

   if ( $debug eq 1 ) {
      # print STDERR "@model to @ret\n";
   }
   return @ret;
}


sub printAttrDecls{
    my @atts = @_;

    for (my $i = 0; $i <= $#atts; $i++) {
      if ($atts[$i] eq '#ATTRGROUPREF'){
        print "   <attributeGroup ref='$prefix:$atts[$i+1]'/>\n";
        $i ++;
      } else {
        # attribute name
        my $skip = 0;
        $skip = 1 if ($skipxmlattr and ($atts[$i] =~ /xml:/ or $atts[$i] =~ /xmlns:/));
        print "   <attribute name='$atts[$i]'" if (!$skip);

        # attribute type
        my @enume;
        $i++;
        if ($atts[$i] eq "(") {
           # like `attname ( yes | no ) #REQUIRED`
           $i++;
           while ($atts[$i] ne ")") {
              if ($atts[$i] ne "|") {
                push(@enume, $atts[$i]);
              }
              $i++;
           }
        } elsif ($atts[$i] eq '#DATATYPEREF'){
           print " type='$prefix:$atts[++$i]'" if (!$skip);
        } elsif ($atts[$i] eq '#COMPLEXTYPEREF'){
           print " type='$prefix:$atts[++$i]'" if (!$skip);
        } elsif ($alias eq 1 && $atts[$i] =~ s/$alias_ident//gsie) {
           # alias special
           print " type='$alias_dic{$atts[$i]}'" if (!$skip);
        } elsif ($atts[$i] =~ /ID|IDREF|ENTITY|NOTATION|IDREFS|ENTITIES|NMTOKEN|NMTOKENS/) {
           # common type for DTD and Schema
           print " type='$atts[$i]'" if (!$skip);
        } else {
           # `attname CDATA #REQUIRED`
           print " type='string'" if (!$skip);
        }

        $i++;

        # #FIXED
        if($atts[$i] eq "#FIXED") {
           $i++;
           print " fixed='$atts[$i]'/>\n" if (!$skip);
        } else {
           # minOccurs
           if ($atts[$i] eq "#REQUIRED") {
              print " use='required'" if (!$skip);
           } elsif ($atts[$i] eq "#IMPLIED") {
              print " use='optional'" if (!$skip);
           } else {
              print " default='$atts[$i]'" if (!$skip);
           }

           # enumerate
           if ($#enume eq -1) {
              print "/>\n" if (!$skip);
           } else {
              print ">\n" if (!$skip);
              print "    <simpleType>\n" if (!$skip);
              print "     <restriction base='string'>\n" if (!$skip);
              &write_enum(@enume) if (!$skip);
              print "     </restriction>\n" if (!$skip);
              print "    </simpleType>\n" if (!$skip);
              print "   </attribute>\n" if (!$skip);
           }
        }
      }
    }
}

sub write_enum{
    my(@enume) = @_;

    for (my $j = 0; $j <= $#enume; $j++) {
      print "      <enumeration value='$enume[$j]'/>\n";
    }
}


# Parse a string into an array of "words".
# Words are whitespace-separated sequences of non-whitespace characters,
# or quoted strings ("" or ''), with the quotes removed.
# HACK: added () stuff for attlist stuff
# Parse words for attribute list
sub parsewords {
   my $line = $_[0];
   $line =~ s/(\(|\)|\||\+|\?|\*)/ $1 /g;
   my $token;
   my @words = ();

   while ($line ne '') {
      if ($line =~ /^\s+/) {
        # Skip whitespace
      } elsif ($line =~ /^\"((?:[^\"]|\\\")*)\"/) {
        $token = $1;
        $token =~ s/^://gso;
        $token =~ s/$prefix://gso;
        push(@words, $token);
      } elsif ($line =~ /^\'((?:[^\']|\\\')*)\'/) {
        $token = $1;
        $token =~ s/^://gso;
        $token =~ s/$prefix://gso;
        push(@words, $token);
      } elsif ($line =~ /^\S+/) {
        $token = $&;
        $token =~ s/^://gso;
        $token =~ s/$prefix://gso;
        push(@words, $token);
      } else {
        die "Cannot happen\n";
      }
      $line = $';
   }
    return @words;
}

# Store content model, return empty string
sub store_elt
{
   my ($name, $model) = @_;
   $model =~ s/\s+/ /gso;
   $name =~ s/$prefix://gso;
   $name =~ s/^[^:]+://gso;  ###XYZZY latest
   print INTERMEDIATE "NAME=", $name, "\n";
   print INTERMEDIATE "MODEL=", $model, "\n";
   push(@element, $name);

   my @words;
   while ($model =~ s/^\s*(\(|\)|,|\+|\?|\||[\w:_\.-]+|\#\w+|\*)//) {
      push(@words, $1);
      print INTERMEDIATE "WORD=", $1, "\n";
   };
   $model{$name} = [ @words ];
   return '';
}


# Store attribute list, return empty string
sub store_att
{
   my ($element, $atts) = @_;
   my @words = parsewords($atts);
   $element =~ s/$prefix://gso;
   $element =~ s/^[^:]+://gso;  ###XYZZY latest
#   $element =~ s/://gso;
   $attributes{$element} = [ @words ];
   return '';
}

sub write_import
{
  my($file) = @_;
  $file =~ s/dtd$/xsd/;
  print "\n  <import namespace='$targetNS' schemaLocation='$file'/>\n";
}  # write_import

sub write_simpleType{
    my($n, $b, $stuff) = @_;
    my @words = parsewords($stuff);

    print "\n  <simpleType name='$n'>\n";
    print "   <restriction base='$b'>\n";
#    # print STDERR "\n==stuff:\n$stuff \n\n===\n", join('|', @words);

    my $i = 0;
    my @enume;

    if ($words[$i] eq "(") {
      $i++;
      while ($words[$i] ne ")") {
        if ($words[$i] ne "|") {
           push(@enume, $words[$i]);
        }
        $i++;
      }
      write_enum(@enume);
    }

   print "   </restriction>\n";
    print "  </simpleType>\n";
}

sub write_complexType
{
    my($n, $stuff) = @_;
    my @words = parsewords($stuff);

    my($n, $stuff) = @_;
    my @words = parsewords($stuff);

    print "\n  <complexType name='$n'>\n";
    print "<!-- $stuff -->\n";

    my @list = &makeChildList($n, '(', @words, ')');
    &printChildList(3, @list);

    print "  </complexType>\n";
}  # write_complexType

sub write_attrGroup{
    my($n, $stuff) = @_;
    my @words = parsewords($stuff);

    print "\n  <attributeGroup name='$n'>\n";
#    # print STDERR "\n==stuff:\n$stuff \n\n===\n", join('|', @words);
    printAttrDecls(@words);
    print "  </attributeGroup>\n";
}

sub write_modelGroup{
    my($n, $stuff) = @_;
    my @words = parsewords($stuff);

    print "\n  <group name='$n'>\n";
    print "<!-- $stuff -->\n";

    my @list = &makeChildList($n, '(', @words, ')');
    &printChildList(3, @list);

    $ModelGroup{$n} = \@list;

    print "  </group>\n";
}

sub write_substitutionGroup
{
    my($n, $stuff) = @_;
    my @words = parsewords($stuff);

    print "\n  <element name='$n' abstract='true'>\n";

    my @list = &makeChildList($n, '(', @words, ')');
   for ( my $i = 0; $i < $#list; $i++ )
   {
      $SubstitutionGroup{ $list[$i] } = $n;
   }

    print "  </element>\n";
}

sub write_notation
{
    my($n, $p, $s) = @_;

  # No quotes around $p and $s, we already pulled them in
    print "\n  <notation name='$n' public=$p";
  if ( $s ) {
    print " system=$s";
  }
  print "/>\n";
}

sub isMixed{
    my(@model) = @_;
   my $isSimple = ($pcdata_flag eq 1) && ($model[1] eq '#PCDATA') &&
      ( ($#model eq 2) ||
       ( ($#model eq 3) && ($model[3] eq '*') ) );

   if ( $debug eq 1 ) {
      # print STDERR "++ mixed? @model\n"; #@@
   }

   if ( $isSimple )
   {
      if ( $debug eq 1 )
      {
        # print STDERR "++ no; simple type. @model\n"; #@@
      }
      return 0;
   }

    my($i);

    for ($i = 0; $i <= $#model; $i++) {
      if ( $model[$i] eq '#PCDATA' ||
         ($model[$i] eq '#MODELGROUPREF' && $Mixed{$model[$i+1]}) ||
         ($model[$i] eq '#SUBSTGROUPREF' && $Mixed{$model[$i+1]}) )
      {
        if ( $debug eq 1 ) {
           # print STDERR "++ yes! $i @model\n"; #@@
        }
        return 1;
      }
    }

   if ( $debug eq 1 ) {
      # print STDERR "++ no. @model\n"; #@@
   }

    return 0;
}

# Return maximum value of an array of numbers
sub max
{
   my $max = $_[0];
   foreach my $i (@_) {
      if ($i > $max) {$max = $i;}
   }
   return $max;
}


# 1) Open file
# 2) Remove comment, processing instructions, and general entities
# 3) Include external parameter entities recursively
# 4) Return the contents of opened file
sub openFile {
   my $file = $_[0];

   my %extent;
   my $bufbuf;
   if ($file ne "") {
      # print STDERR "open $file ";
      if(! open AAA, $file) {
        # print STDERR " failed!!\n";
        return "";
      }
      # print STDERR " successful\n";
      $bufbuf = <AAA>;
   } else {
      # print STDERR "open STDIN successful\n";
      $bufbuf = <>;
   }

   # Strip newlines
   $bufbuf =~ s/\n//gso;

   # remove comments
   $bufbuf =~ s/<!--.*?-->//gso;

   # remove processing instructions
   $bufbuf =~ s/<\?.*?>//gso;

     # store external parameter entities
     while ($bufbuf =~ s/<!ENTITY\s+%\s+(\S+)\s+PUBLIC\s+$str\s+$str.*?>//sie) {
       # print STDERR "$1 is $4.$5\n";
        $extent{$1} = $4.$5;
     }
     while ($bufbuf =~ s/<!ENTITY\s+%\s+(\S+)\s+SYSTEM\s+$str.*?>//sie) {
       # print STDERR "$1 is $2.$3\n";
        $extent{$1} = $2.$3;
     }

     # read external entity files
   foreach my $key (keys(%extent)) {
       my $entrep = openFile($extent{$key});
     $bufbuf =~ s/%$key;/${entrep}/gsie;
   }

   return $bufbuf;
}

#
# Changes: 2002/06/25 mh
# Apply fix from Andreus Leue for recursive ext. entity files
# Changes: 2001/05/15 mh
# Changed to namespace of rec.
# Changes: 2001/01/10 mh
# Switch to CR syntax
# Support external mapping file for type aliases, simple types, model and
#    attribute groups
# Map ANY correctly to wildcard rather than element 'ANY'
# Support treating lead PCDATA as string or other aliased simple type instead
# of as mixed content (may be more appropriate for data-oriented DTDs)
#    e.g. <!ELEMENT title (#PCDATA)> => <element name="title" type="string"/>
# Support subsitution groups.
#
# 2001/01/12 mh
# Support NOTATION declarations
# Fix handling of nested conditional sections
# Attempt to compensate for DTDs that are already constructed for namespaces
#   BUG: Easy to get this wrong

# Cail Lomecb <cail@nm.ru>
# Mon 18 Nov 01:17:19 2002
# - New parameter -skipxmlattr
#   to skip all xml:* and xmlns:* attributes
# - some minor bugfixes

## TODO: Change import of external DTDs into schema import
## remove xmlns 'attributes'
