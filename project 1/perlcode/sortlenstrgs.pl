#!/usr/bin/perl -w

use strict;

my %hash = (
	'(' => 11,
	'((' => 31,
	'(..(('=> 3,
	'...' => 1,
	'(....' => 6
);
#print sort {$b <=> $a} keys %hash, "\n";
my @longest = sort {length($b) <=> length($a)} keys %hash;
print join(', ', @longest), "\n";
print "longest key: $longest[0]\n";
print "value at the key: $hash{$longest[0]}\n";

print "lexically . is greater than (\n" if '.' gt '(';
