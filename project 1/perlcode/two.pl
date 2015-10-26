#!/usr/bin/perl -w

# Print the folders inside a directory without .. or .:w

use strict;

# Read the contents of directory
my $Home = '/home/complab/bin';
opendir(my $H, $Home) or die "Cannot open directory:$!";

my @contents = grep(!/^\.\.?$/, readdir $H);

closedir $H;

print join("\n", @contents);
