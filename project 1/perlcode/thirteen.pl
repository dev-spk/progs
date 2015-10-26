#!/usr/bin/perl 
# Parse miRPara output

use strict;
use File::Basename; 

my $Home = '/home/complab/bin';
my $intext = $ARGV[0];

# Tool6
!system "$Home/miRPara/miRPara.pl", "-s", "hsa", "-l", "4", "$intext" or die "$!\n"; # default output file in the same place as input file

my $line = ();

(my $fname,my $path, my $suffix) = fileparse($intext, (".fasta", ".fa"));

print "now printing the results of mirpara\n";
print "$path\n";

my $outfi = "$path$fname".'_level_4.out';
open (my $OUX6, "<$outfi") or die "miRPara output file not found:$!\n"; # check: possamples_level_17.out
# find max. probability score
#skip the lines which start with #
my $max = -1; # probability can't be negative
while (<$OUX6>){
        # find max.
        if (/^[^#!]/) { # skip line beginning in # or !
print;
                my @columns = split("\t");
		my $prob = $columns[5];
print "current prob. is $1\n";
                $max = ($prob>$max?$prob:$max);
        }
        # skip lines starting with '#' or skip empty lines
}
$line .= ($max==-1?'NO':"YES:$max");
print "The line is $line\n";
close $OUX6;

