#!/usr/bin/perl -w

# Check the subfolders in a directory consisted of an 'output' directory or else create it

use strict;

# Read the contents of directory
my $Home = '/home/complab/perlprogs';
opendir(my $H, $Home) or die "Cannot open directory:$!";

my @contents = grep(!/^\.\.?$/, readdir $H);

closedir $H;

mkdir "$Home/output" if('output' !~ @contents); # not in

