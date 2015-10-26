#!/usr/bin/perl -w

# Sample N records from a fasta file

use File::Basename;

$filename = $ARGV[0];

open(IN, "<$filename") or die "Cannot open file error: $!";

#my($basename, $path, $suffix) = fileparse($filename, ('.fasta', '.fa'));

#open(OUT, ">$basename".'_rand2000'."$suffix") or die "Cannot open file error: $!";

#local $/ = '>'; # uncomment if fasta

getc(IN);

@List = <IN>;

foreach(1 .. 2000) {


	$i = rand($#List);

	$rec = splice(@List, $i, 1);
	#chomp($rec); # uncomment if fasta 
print $rec;
#	print OUT '>', $rec; 

}

close IN;
#close OUT;


