#!/usr/bin/perl 
use strict;
use File::Find;

find sub
{
	$File::Find::prune = /^[\._]\w+/;
	print "$File::Find::name\n" unless -d;
}, @ARGV;
