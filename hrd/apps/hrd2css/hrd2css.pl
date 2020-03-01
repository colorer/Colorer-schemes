#!/usr/bin/perl

use strict;
use XML::Parser;

my $p = XML::Parser->new(Handlers => {Start => \&handler});
open(FILE, $ARGV[0]) or die "Could not open file $ARGV[0]";
local $/;
my $data = <FILE>;
close(FILE);
$data =~ s/ encoding="UTF-8"//;
$data =~ s/\xFF//g;

print "/* Generated with hrd2css.pl from $ARGV[0] */\n\n";

$p->parse($data);

sub handler
{
    my ($this, $element, %attr) = @_;

    if ($element eq 'assign' && exists $attr{name})
    {
        my $name = $attr{name};
        $name =~ s/\W/-/g;

        my $style = '';
        $style .= "\tcolor: $attr{fore};\n" if exists $attr{fore};
        $style .= "\tbackground-color: $attr{back};\n" if exists $attr{back};
        $style .= "\tfont-weight: bold;\n" if exists $attr{style} && ($attr{style} & 1);
        $style .= "\tfont-style: italic;\n" if exists $attr{style} && ($attr{style} & 2);
        $style .= "\ttext-decoration: underline;\n" if exists $attr{style} && ($attr{style} & 4);

        if (length($style))
        {
            print ".$name {\n$style}\n\n";
        }
    }
}