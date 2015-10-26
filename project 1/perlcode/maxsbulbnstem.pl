#!/usr/bin/perl -w

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

my $st = (); my $bb = ();
my @stems = ();

open (my $FH, "<$ARGV[0]") or die "";
open (my $FO, ">$ARGV[0].maxstemandbulb") or die "";

while(<$FH>) { # do for all lines in the file
#print;
#die;
/^(.*?):/;
print $FO "$1.begin:\t";
my %stems = (/stem:([\(\.]+):(\S+)[\b\t\n]+/g); # match pattern 'stem:(.(:leftpos. bulb:...:leftpos.' all along the line and return
my @longeststem = sort {length($b) <=> length($a)} keys %stems;
 
my $L = 0;

@stems = keys %stems;
# return the first maximal length seq.
foreach (@stems) {
my $L1 = length ($_);
if ($L1 > $L) {
$st = $_;
$L = $L1;
}
}
#print join("\t\t", @_);
#print "\nAlert!!!\n" if ('((..(((((..(((((((' gt '(..((((((');
#die; 
my %bulbs = (/bulb:(.*?):(\S+)[\b\t\n]+/g);
my @longestbulb = sort {length($b) <=> length($a)} keys %bulbs;
my $L2 = 0;

my @bulbs = keys %bulbs;
foreach (@bulbs) {
my $L1 = length($_);
if ($L1 > $L2) {
$bb = $_;
$L2 = $L1;
}
}

print $FO "maxstem:$longeststem[0]\tstlen:", $L, "\tstpos:$stems{$longeststem[0]}\t", "maxbulb:$longestbulb[0]\tbblen:", $L2, "\tbbpos:$bulbs{$longestbulb[0]}\n";
$bb = ();
$st = ();

}

close $FH;
close $FO;
