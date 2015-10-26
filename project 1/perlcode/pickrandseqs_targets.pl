#!/usr/bin/perl -w

# Sample N records from a file

use File::Basename;

$miRsfile = $ARGV[0];
$targsfile = $ARGV[1];

open(IN, "<$miRsfile") or die "Cannot open file error: $!";

open(IN2, "<$targsfile") or die "Cannot open file error: $!";

#my($basename, $path, $suffix) = fileparse($filename, ('.fasta', '.fa'));

#open(OUT, ">$basename".'_rand2000'."$suffix") or die "Cannot open file error: $!";

local $/ = '>'; # reset here

getc(IN);
getc(IN2);

@miRs = <IN>;
@targs = <IN2>;

foreach(1 .. 1000) {

	$i = rand($#miRs);

	$rec = $miRs[$i]; #splice(@miRs, $i, 1);
	chomp($rec);
	foreach(1 .. 10) {
		$j = rand($#targs);
		$rec2=$targs[$j];
		chomp($rec2);
		
		($recID, $seq) = split(/\s+/, $rec);
		($rec2ID, $seq2) = split(/\s+/, $rec2);
		print "$rec2ID\t$recID\n"; # this order
	}
}

close IN;
close IN2;
#close OUT;


