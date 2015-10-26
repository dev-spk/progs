#!/usr/bin/perl	-w

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

#my $str = '((.((.(....).))).....)'; # desired output: max.len. of stems = 3 and max. len. of bulb = 4. There is 1 bulb ....4 nts. there are two stems: (.) and ((.().)) of len. 2 and 3

open (my $FH, "<$ARGV[0]") or die "";
open(my $FO, ">$ARGV[0].stemsandloops") or die "";

local $/ = '>';
my $L = 0;
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
# print $FO "@str\n";

# Read the characters of the seq. from the Left to Right
foreach (@str) {
	#$pos ++; # not here
	if (($_ eq '(') or ($_ eq '.') or ($_ eq '+')) {
		push @stack, $_;
		#print "pushed: $_\n";
	}
	else { # a ')' is seen
		do {
			$_ = pop @stack;
			#print "I am at $_"; sleep(1);
			#print "popped: $_\n";
			if (($_ eq '.') or ($_ eq '+')) {
				$dotcount ++;
				push @dots, $_;
			}
		} until $_ eq '(';
		# $lenstem ++;
		# push @stemstr, $_; # first push the lp '(' into the stem structure
		if ($dotcount <= 2) {# do not consider the 'popped dots' as a bulb: allow 1 mismatch in stem /or an insert upto a length of 2 
			push @stemstr, @dots; # after pushing '(' push the dots; completes 1 iteration
			push @stemstr, $_; # first push the lp '(' into the stem structure
			@dots = (); # empty dots
			$dotcount = 0;
		# continue with the next iteration until a bulb is seen or the stack is empty
		}
		else { # if it is a bulb
			print $FO "stem:", join('', @stemstr), "\t"; # first print the current stem even if it is empty
			print $FO "bulb:", join('', @dots), "\t";
			@stemstr = $_; @dots = (); # start a new stem and emtpy bulb
			#push @bulblengs, $dotcount; # count as a bulb
			#$lenstem += $dotcount;
			#push @lenstems, $lenstem;
			$dotcount = 0; # reset count
			#$lenstem = 0;
		}
	}
}
print $FO "stem:", join('',@stemstr), "\n"; # when no further bulb seen or when end of string is reached; equally an empty stack seen 
#print "Max. len. of bulb is ", max(@bulblengs), "\n";
#print "Max. len. of stem is ", max(@lenstems), "\n";
}
close $FO;
close $FH;
