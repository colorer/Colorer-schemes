#!/usr/bin/perl 
#
# Perl module for automatic HRC changes tests.
# Validates a set of source files against a given
# set of their previous parse strucure.
#
#  --full   - test all (default)
#  --quick  - test all exclude **/full/*.*
#  --list   - test listed dirs
#  file.lst - test list from file(s)
#

use strict;
use File::Find;
use File::Path;

my $root_path = '../../';
my %prop_path;
set_prop_path($root_path."/path.properties");

my $colorer_path = $root_path.$prop_path{colorer}; 
my $catalog_path = $root_path.$prop_path{catalog};
my $hrd_path     = $root_path.$prop_path{hrd};

my $colorer  = "$colorer_path/bin/colorer -c $catalog_path";
my $diff  = 'diff -U 1 -bB';


my $hrd = (defined $ENV{COLORER5HRD}) ? $ENV{COLORER5HRD} : 'white';


my $validDir = "_valid";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $currentDir = sprintf("__%d-%02d-%02d_%02d-%02d", $year+1900, $mon+1, $mday, $hour, $min);

die "Can't create dir - already exists" unless mkdir $currentDir, 0777;



my $runMode = '--full';
$runMode = shift @ARGV if @ARGV;

my @retlist = ();
my @prnlist = @ARGV;

unless($runMode =~ /^--\w+/)
{
	unshift @ARGV, $runMode;
	@retlist = <>;
}
else
{
	my @lst = ($runMode eq '--list') ? @ARGV : ('.');
	find sub
	{
		$File::Find::prune = /^[\._]\w+/;
		return if $File::Find::dir eq '.';
		$File::Find::prune += /^full/ if $runMode eq '--quick';
		push @retlist, $File::Find::name unless -d;
	}, @lst;
}



print "Running test mode: $runMode @prnlist\n";

my $testRuns = 0;
my $testFailed = 0;
my $timeStart = time();

unlink "$currentDir/fails.html";

open FAILS, ">$currentDir/fails.html";
print FAILS <<"FL";
<html>
<head>
	<link href="../$hrd_path/css/$hrd.css" rel="stylesheet" type="text/css"/>
</head>
<body><pre>
FL
close FAILS;



# start tests

my $failed = '';

foreach (@retlist)
{
	chomp $_;
	s/^\.\///;
	
	my $origname = "$validDir/$_";
	my $fname = "$currentDir/$_";
	my $fdir = $fname;
	$fdir =~ s/\/[^\/]+$//;
	
	print "Processing (".($testRuns+1)."/".($#retlist+1).") $_:\n";
	
	open FAILS, ">>$currentDir/fails.html";
	print FAILS "\n<b>$_</b>:</pre></pre><pre>\n";
	close FAILS;
	
	mkpath($fdir);
	
	my $cres = system "$colorer -ht \"$_\" -dc -dh -ln -o \"$fname.html\"";
	
	my $res = system "$diff \"$origname.html\" \"$fname.html\" 1>>\"$currentDir/fails.html\"";
	
	if ($cres != 0 or $res != 0 or !-r "$fname.html")
	{
		print "failed: $cres, $res, ".(-r "$fname.html")."\n";
		$failed .= "$_<br/>";
		$testFailed++;
	}
	$testRuns++;
}


#final

my $timeEnd = time();

my $perc = sprintf "%.0d", ($testRuns-$testFailed)*100/$testRuns;
my $result = "Test time: ".($timeEnd-$timeStart)." sec, Executed: $testRuns, Passed: ".($testRuns-$testFailed).", Failed: $testFailed, Passed:".$perc."%\n";

print $result;

open FAILS, ">>$currentDir/fails.html";
print FAILS "</pre></pre></pre><h2>$result</h2>";
print FAILS "<h2>Failed tests</h2><br/>$failed" if $testFailed;
close FAILS;

#exit;


# read ant props
sub set_prop_path
{
	open PATH, $_[0];
	while(<PATH>)
	{
		chomp;
		next if /^\s*#/;
		$prop_path{$1} = $2 if /^\s*path\.(\w+)\s*=\s*(\S+)/;
	}
	close PATH;
}
