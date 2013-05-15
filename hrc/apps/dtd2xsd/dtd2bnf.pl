#!/usr/local/bin/perl5
#
# Bert Bos <bert@w3.org>
# Created: 17 Mar 1998
# $Id$
#

my $linelen = 72;

my $PROG = substr($0, rindex($0, "/") + 1);
my $USAGE = "Usage: $PROG file\n";

my $string = "(?:\"([^\"]*)\"|\'([^\']*)\')";
my %pent;			# Parameter entities
my %attributes;			# Attribute lists
my @element;			# Elements in source order
my %model;			# Content models


# Parse a string into an array of "words".
# Words are whitespace-separated sequences of non-whitespace characters,
# or quoted strings ("" or ''), with the quotes removed.
sub parsewords {
    my $line = $_[0];
    my @words = ();
    while ($line ne '') {
	if ($line =~ /^\s+/) {
	    # Skip whitespace
	} elsif ($line =~ /^\"((?:[^\"]|\\\")*)\"/) {
	    push(@words, $1);
	} elsif ($line =~ /^\'((?:[^\']|\\\')*)\'/) {
	    push(@words, $1);
	} elsif ($line =~ /^\S+/) {
	    push(@words, $&);
	} else {
	    die "Cannot happen\n";
	}
	$line = $';
    }
    return @words;
}

# break lines at or before $linelen, indent continuation lines $indent
sub break
{
    my ($linelen, $indent, $line) = @_;
    my $result = '';
    $line =~ s/\s+$//o;		# Remove trailing whitespace
    while (length($line) > $linelen) {
	my $i = $linelen;
	BREAK: while (1) {
	    if (substr($line, $i, 1) =~ /\s/so) {
		# found a space
		last BREAK;
	    }
	    if ($i <= $linelen) {$i--;} else {$i++;}
	    if ($i == $indent) {
		# no space found to the left, try to the right
		$i = $linelen + 1;
	    }
	    if ($i == length($line)) {
		# no space found anywhere
		last BREAK;
	    }
	}
	my $part = substr($line, 0, $i);
	$part =~ s/\s+$//o;	# Remove trailing spaces
	$result .= $part;	# Add to result
	$line = substr($line, $i + 1);
	$line =~ s/^\s+//o;	# Remove leading spaces
	if (length($line) != 0) {
	    $result .= "\n";
	    $line = (' ' x $indent) . $line;
	}
    }
    if (length($line) != 0) {$result .= $line;}
    return $result;
}


# Store content model, return empty string
sub store_elt
{
    my ($name, $model) = @_;
    $model =~ s/\#PCDATA/TEXT*/gio;
    $model =~ s/\s+/ /gso;
    push(@element, $name);
    $element{$name} = $model;
    return '';
}


# Store attribute list, return empty string
sub store_att
{
    my ($element, $atts) = @_;
    $atts =~ s/\#FIXED//gio;	# Remove #FIXED
    my @words = parsewords($atts);
    $attributes{$element} = [ @words ];
    return '';
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


# Main

$/ = undef;
my $buf = <>;

# remove comments
$buf =~ s/<!--.*?-->\s+//gso;

# remove processing instructions
$buf =~ s/<\?.*?>\s+//gso;

# loop until parameter entities fully expanded
my $i;
do {
    # store parameter entities
    $buf =~ s/<!ENTITY\s+%\s+(\S+)\s+$string/($pent{$1}=$2.$3.$4),$&/gsioe;
    # count # of substitutions
    $i = 0;
    # expand parameter entities
    $buf =~ s/%([a-z0-9.-]+);?/$i++,$pent{$1}/gsioe;
} while ($i != 0);

# remove all entities (parameter and other)
$buf =~ s/<!ENTITY.*?>\s+//gsio;

# store attribute lists
$buf =~ s/<!ATTLIST\s+(\S+)\s+(.*?)>/store_att($1, $2)/gsioe;

# store content models
$buf =~ s/<!ELEMENT\s+(\S+)\s+(.+?)>/store_elt($1, $2)/gsioe;

# find maximum length of non-terminals
my $maxlen = max(map(length, @element)) + 4;

# loop over elements, writing EBNF
foreach $e (@element) {
    $model = $element{$e};

    # print rule for element $e
    my $s = sprintf("%-${maxlen}s = ", $e);
    $s .= "\"<$e\" ${e}_att* ( \"/>\" | \">\" ${e}_cnt \"</$e>\" )";
    print break($linelen, $maxlen + 3, $s) . "\n";

    # print rule for $e's attributes
    printf("%-${maxlen}s = ", "${e}_att");
    my $h = $attributes{$e};
    my @atts = @$h;
    if ($#atts == -1) {
	print ";empty\n";
    } else {
	for (my $i = 0; $i <= $#atts; $i += 3) {
	    if ($i != 0) {print ' ' x $maxlen . " | ";}
	    # use only name, ignore type and default
	    print "\"$atts[$i]\" \"=\" STRING\n";
	}
    }

    # print rule for $e's content model
    $s = sprintf("%-${maxlen}s = ", "${e}_cnt");
    if ($model =~ /^EMPTY$/io) {
	$s .= ";empty";
    } elsif ($model =~ /^ANY$/io) {
	$s .= "( " . join(" | ", sort @element) . " )*";
    } else {
	$model =~ s/\s+$//o;	# remove trailing spaces
	if ($model =~ /\)$/o) {
	    chop($model);	# remove final ')'
	    $model = substr($model, 1); # remove initial '('
	}
	$model =~ s/\(/ \( /go; # one space around '('
	$model =~ s/\)/ \) /go; # one space around ')'
	$model =~ s/\|/ \| /go; # one space around '|'
	$model =~ s/,/ /go;	# one space instead of ','
	$model =~ s/\s+\?/\?/go; # no spaces before '?'
	$model =~ s/\s+\*/\*/go; # no spaces before '*'
	$model =~ s/\s+\+/\+/go; # no spaces before '+'
	$model =~ s/\s+/ /go;	# no multiple spaces
	$model =~ s/^ //o;	# no initial space
	$s .= "$model";
    }
    print break($linelen, $maxlen + 3, $s) . "\n\n";
}

# print auxiliary tokens
printf "%-${maxlen}s = \"\'\" TEXT* \"\'\" | \'\"\' TEXT* \'\"\'\n", "STRING";
printf "%-${maxlen}s = (any legal XML character)\n", "TEXT";
