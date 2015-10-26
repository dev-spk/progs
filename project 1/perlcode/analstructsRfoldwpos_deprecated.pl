#!/usr/bin/perl	-w

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

#my $str = '((.((.(....).))).....)'; # desired output: max.len. of stems = 3 and max. len. of bulb = 4. There is 1 bulb ....4 nts. there are two stems: (.) and ((.().)) of len. 2 and 3

open (my $FH, "<$ARGV[0]") or die "";
open(my $FO, ">$ARGV[0].stemsandloopswpos.wpos") or die "";

local $/ = '>';
my $L = 0;
getc($FH); # skip the first > char.

# Retrieve the name of seq. and its secondary structure string from RNAfold fasta file
while(<$FH>) {
(my $name, my $seq, $_) = split(/\n/);
print $FO ">$name:\t";
/^(.*)\s+\(.*/;
#print "Structure: $1\n";
#print substr $str, -1;
my @str = split(//, $1);
my @stack = ();
# my @bulblengs = (); 
my $dotcount = 0;
# my @lenstems = (); my $lenstem = 0;
my @stemstr = ();
my @dots = ();
my $pos = 0;
my $posstem = 0;
my $stridx = 0;
# print $FO "@str\n";

# Read the characters of the seq. from the Left to Right
foreach (@str) {
	$stridx ++; # keep an index
	if (($_ eq '(') or ($_ eq '.') or ($_ eq '+')) {
		push @stack, $_;
		#print "pushed: $_\n";
		$pos ++; # keep track of the size of the stack
	}
	else { # a ')' is seen
		do {
			$_ = pop @stack;
			$pos --;
			#print "I am at $_"; sleep(1);
			#print "popped: $_\n";
			if (($_ eq '.') or ($_ eq '+')) {
				$dotcount ++;
				push @dots, $_;
			}
		} until $_ eq '(';
		# $lenstem ++;
		# push @stemstr, $_; # first push the lp '(' into the stem structure
		# $posstem = $pos+1;
		if ($dotcount <= 2) {# do not consider the 'popped dots' as a bulb: allow 1 mismatch in stem /or an insert upto a length of 2 
			$posstem = $pos+1; # update the starting position of the stem
			push @stemstr, @dots; # first push the dots into the stem structure
			push @stemstr, $_; # after pushing the dots push the lp '('; completes 1 iteration
			@dots = (); # empty dots
			$dotcount = 0;
		# continue with the next iteration until a bulb is seen or the stack is empty
		}
		else { # if it is a bulb
			print $FO 'stem:', join('', @stemstr), ':', $posstem, "\t" if $posstem != 0; # first print the current stem even if it is empty
			print $FO 'bulb:', join('', @dots), ':', $stridx-1, "\t"; # +1 because an lp '(' of the next stem! is also popped after the bulb 
			@stemstr = $_; @dots = (); # start a new stem and emtpy bulb
			#push @bulblengs, $dotcount; # count as a bulb
			#$lenstem += $dotcount;
			#push @lenstems, $lenstem;
			$dotcount = 0; # reset count
			#$lenstem = 0;
		}
	}
}
print $FO "stem:", join('', @stemstr),':1', "\n"; # when no further bulb seen or when end of string is reached; equally an empty stack seen 
#print "Max. len. of bulb is ", max(@bulblengs), "\n";
#print "Max. len. of stem is ", max(@lenstems), "\n";
}
close $FO;
close $FH;
