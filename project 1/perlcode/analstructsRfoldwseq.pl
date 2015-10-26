#!/usr/bin/perl	-w
# input str ((.((.(....).))).....), desired output: max.len. of stems = 3 and max. len. of bulb = 4. There is 1 bulb ....4 nts. there are two stems: (.) and ((.().)) of len. 2 and 3
use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

open (my $FH, "<$ARGV[0]") or die "";
open(my $FO, ">$ARGV[0].stemsandloopswpos.wseq") or die "";

local $/ = '>';
my $L = 0;
getc($FH); # skip the first > char.

# Retrieve the name of seq., nt.seq., and its secondary structure string from RNAfold fasta file
while(<$FH>) {
(my $name, my $seq, $_) = split(/\n/);
print $FO ">$name:\t";
/^(.*)\s+\(.*/;
my @seq = split(//, $seq);
my @str = split(//, $1);
my @stack = ();
my $dotcount = 0;
my @stempos = ();
my @dots = ();
my $pos = 0;
my @posstack = ();
my $poppos = 0;
my $posstem = 0;
my $stridx = 0;
my $r = 0;
my @dotpos = ();
my $pop = 0;

# Read the characters of the seq. from the Left to Right
foreach (@str) {# Iterate for each character in the structure seq.
	$stridx ++; # keep an index
	if (($_ eq '(') or ($_ eq '.') or ($_ eq '+')) {
		push @stack, $_;
		$pos ++; # keep track of the size of the stack
		push @posstack, $stridx-1; # push the position of dot/plus into the stack
	}
	else { # a ')' is seen
	NextPop: do {# pop dots until a lp '(' is seen or a Junction is seen
			$pop = pop @stack; # pop an element
			$poppos = pop @posstack; # pop the corres. position of the element
			if (($pop eq '.') or ($pop eq '+')) { # count the dots popped out consecutively before a lp (
				$dotcount ++;
				push @dotpos, $poppos;
			}
		} until ($pop eq '(') or ($pop eq 'J'); # stop popping when it is J
		if ($pop eq 'J') {# check to see if the the pop out is a Junction
			print $FO 'Stem:', join('', @seq[$stempos[$#stempos] .. $stempos[0]]), ':', $stempos[$#stempos], ':', "$stempos[0]\t" if $#stempos >= 0;# don't wait until printing a bulb, print the current stem
			@stempos = (); # empty stem (positions)
			goto NextPop; # continue reading the structure seq.
		}
                elsif ($str[$stridx] eq '(') {# Check ) -> ( transition occurred: look ahead for a lp immediately after an rp: )( signifies a joint and the beginning of a new stem
			push @stempos, $poppos;
                        print $FO 'Stem:', join('', @seq[$stempos[$#stempos] .. $stempos[0]]), ':', $stempos[$#stempos], ':', "$stempos[0]\t" if $#stempos >= 0; # print the current stem
                        @stempos = (); # empty stem (positions)
			push @stack, 'J'; # mark a joint, know when to write out a stem
			push @posstack, 'J'; # useful to keep an update with the above stack
			goto NextIt;
                }
		if ($dotcount == 0) {# store pop as a duplex
                	push @stempos, $poppos; # push the lp '('; completes 1 iteration
                	# continue with the next iteration until a bulb is seen or the stack is empty 	
		}
		else {# if a bulb, print prev. stem and the current bulb; check the continuity of the positions in the bulb: @dotpos; handles even single base bulges and inter-loop mismatch (the smallest bubble)
			print $FO 'Stem:', join('', @seq[$stempos[$#stempos] .. $stempos[0]]), ':', $stempos[$#stempos], ':', "$stempos[0]\t" if $#stempos >= 0; # first print the current stem if it is non-empty
			$r = ($dotpos[0] - $dotpos[$#dotpos]+1)/($#dotpos+1); # pushed in the reverse, 0th has the end pos. of the bulb; +1 ommitted in the Num. and the Den.	
			# mark it as a Bubble if discontinuous; else mark it as a Bulge if continuous and occurs w/o pushing lp ( and after popping rp ); else mark it as a Loop
			if ($r != 1) {
				print $FO 'Bubble:', join('', @seq[@dotpos]), ':', $dotpos[$#dotpos], ':', "$dotpos[0]\t"; # Inter-loop mismatch(es)
			}	
			elsif (($str[$dotpos[$#dotpos]-1] eq '(') and ($str[$dotpos[0]+1] eq ')')) {# look before and after the Loop
				print $FO 'Loop:', join('', @seq[@dotpos]), ':', $dotpos[$#dotpos], ':', "$dotpos[0]\t";
			}
			else {# before the Loop there is an rp ')'
				print $FO 'Bulge:', join('', @seq[@dotpos]), ':', $dotpos[$#dotpos], ':', "$dotpos[0]\t";
			}
			@stempos = $poppos; @dotpos = (); # start a new stem and emtpy bulb
                	$dotcount = 0; # reset count
		}      
	# the end of one iteration in the stack: popping out of a bulb followed by a lp ( completes one iteration
	}
	NextIt:
}
print $FO "Stem:", join('', @seq[$stempos[$#stempos] .. $stempos[0]]),':', $stempos[$#stempos], ':0', "\n"; # when no further bulb seen or when end of string is reached; equally an empty stack seen
# if the stack is empty print the rest of the nt. sequence (case of overhangs)
#print $FO "overhangs: join";
}
close $FO;
close $FH;
