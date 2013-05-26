#!/usr/bin/perl

$count=0;
while (<>) {
	if (/>([^<>].*?)</) {
		print "$1\n";
		$mod = $count % 3;
		print "COUNT is $mod !!!!!!! \n";
		$count++;
	}
}
