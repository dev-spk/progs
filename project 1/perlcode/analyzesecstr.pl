#!/usr/bin/perl	-w

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

my $str = '(.((.(....).)))'; # desired output: max.len. of stems = 3 and max. len. of bulb = 4. There is 1 bulb ....4 nts. there are two stems: (.) and ((.().)) of len. 2 and 3

#print substr $str, -1;
my @str = split(//, $str);
my @stack = ();
my @bulblengs = (); my $dotcount = 0;
my @lenstems = (); my $lenstem = 0;

# Read the characters of the seq. from the Left to Right
foreach (@str) {
#print;
	if (($_ eq '(') or ($_ eq '.')) {
		push @stack, $_;
		#print "pushed: $_\n";
	}
	else { # a ')' is seen
		do {
			$_ = pop @stack;
			#print "popped: $_\n";
			$dotcount ++ if $_ eq '.';
		} until $_ eq '(';
		$lenstem ++;
		if ($dotcount <= 2) {# do not consider the 'popped dots' as a bulb: 1 mismatch in stem /or an insert upto a length of 2 
		# continue with the next iteration
		}
		else {
			push @bulblengs, $dotcount; # count as a bulb
			$dotcount = 0; # reset count
			$lenstem += $dotcount;
			push @lenstems, $lenstem;
			$lenstem = 0;
		}
	}
}
print "Max. len. of bulb is ", max(@bulblengs), "\n";
print "Max. len. of stem is ", max(@lenstems), "\n";
