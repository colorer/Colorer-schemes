#!/usr/bin/perl

use strict;

my $php=0;
my $mode=0;
my $mname=0;
my $mnumb=0;
my $mconst=0;
my ($class, $method, $dl, $depr);
my %rep=('<' => '&lt;', '>' => '&gt;', '&' => '&amp;', '"' => '&quot;', "'" => '&apos;');

print <<XMLS;
<?xml version="1.0" encoding="UTF-8"?>
<php>
XMLS

while(<>)
{
	#first line
	if(/<!-- PHP Language Constructs -->/)
	{
		print "<lang>\n";
		next;
	}
	
	#language
	unless($php || $mode)
	{
		if(/<!-- PHP/)
		{
			print "</lang>\n<consts>\n";
			$php = 1;
			next;
		}
		next if/^\s*$/;
		
		my $type = (s/^~//) ? 'type' : 'key';
		$type = "func" if/^__/;
		$type = "const" if/^__[A-Z]+__/;
		my $name = $1 if/^([\w_]+)/;
		print "<$type name='$name'/>\n";
		next;
	}
	
	#consts
	unless($mode)
	{
		if(/<!-- I\./)
		{
			print"</consts>\n<packages>\n";
			$mode = 1;
			redo;
		}
		next if/^\s*$|<!--/;
		
		my $name=$1 if/^([\w_]+)/;
		print "<const name='$name'/>\n";
		next;
	}
	
	
	#all library...
	#header
	if(/<!-- ([IVXLCDM]+)\. (.+?)\s*-->/)
	{
		print "</package>\n" if $mnumb;
		
		$mconst = 0;
		$depr = 0;
		
		$mnumb = $1;
		$mname = $2;
		$depr = ($mname=~s/\s*\[deprecated\]\s*//i);
		my $desc = $mname;
		$mname=~s/\s*Functions\s*//i;
		$mname=~s/[^\w_]/-/img;
		$mname=~s/-{2,}/-/img;
		$mname=~s/^[\s\.\-]*|[\s\.\-]*$//mg;
		$desc=~s/([<>\&\"\'])/$rep{$1}/gs;
		
		print "<package name='$mname' number='$mnumb' desc='$desc'";
		print " depr='on'" if $depr;
		print ">\n";
		next;
	}
	
	if(/^\s*$/)
	{
		$mconst = 1;
		next;
	}
	
	#library const
	if($mconst)
	{
		my $name=$1 if/^([\w_]+)/;
		print "<const name='$name'/>\n" if $name;
		next;
	}
	
	
	#default: library functions
	my ($foo, $bar) = ($1, $2) if/^(\S+)\s+--\s+(.*?)$/;
	$bar =~ s/([<>\&\"\'])/$rep{$1}/gs;
	($class, $dl, $method, $depr) = ();
	$depr = ($bar=~s/\s*\[deprecated\]\s*//i);
	($class, $dl, $method) = ($1, $2, $3) if $foo=~m/^([\w_]+)(::|->)([\w_]+)$/;
	
	if($class)
	{
		my $call = ($dl eq '::') ? 'static' : 'dynamic';
		print "<method class='$class' call='$call' name='$method' decs='$bar'";
	}
	else
	{
		print "<function name='$foo' decs='$bar'";
	}
	print " depr='on'" if $depr;
	print "/>\n";
}

print <<XMLE;
</package>
</packages>
</php>
XMLE
