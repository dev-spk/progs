#!/usr/bin/perl -w

# Check the subfolders in a directory consisted of an 'output' directory or else create it

use strict;

# Read the contents of directory
my $Home = '/home/complab/perlprogs';

opendir(my $H, $Home) or die "Cannot open directory:$!";

my @contents = grep(!/^\.\.?$/ && -d "$Home/$_", readdir $H);

closedir $H;

#print join("\n", @contents);
#print "\n";

# If the first sub-directory does not contains the folder 'output', then create it
my $Sub = "$Home/@contents[1,]";

opendir(my $S, $Sub) or die "Cannot open sub-directory:$!";

my @cont = grep(!/^\.\.?$/ && -d "$Sub", readdir $S);

#print join(@cont, "\n");

mkdir "$Sub/output" if('output' !~ @cont || @cont==0) or print "output directory already exists!\n"; # not in


closedir $S;
