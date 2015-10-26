#!/usr/bin/perl -w
# Parse ProMiR output

use strict;
# This file is created even when there is no record
open (my $OUX4, "<nonmirnasing.fasta.output") or die "cannot open file\n";
my @rec = <$OUX4>;
# check empty file
if ($#rec == -1){ # while(s>=0&&e>=0&&(o==5||o==3)&&p[0]!=null&&!p[0].equals("")&&p[1]!=null&&!p[1].equals("")&&p[0].length()==p[1].length()) {}
my $line .= 'NA';
print "$line\n";
}
else{

my $rec = join('', @rec);

print "$rec\n";
# RF00001;5S_rRNA;AADB02014418.1/10140-10240   9606:Homo sapiens (human)
# predicted region = [33,51]
# predicted orientation = 3
# classification = false
# 1.4583886169102575E-6	3.488712827560753E-5

# parse fi
#$rec =~ s/\t//g; # remove tabs NOT necessary
$rec =~ s/\n/\t/g;


print $rec, "\n";
# RF00001;5S_rRNA;AADB02014418.1/10140-10240   9606:Homo sapiens (human)	predicted region = [33,51]	predicted orientation = 3	classification = false	1.4583886169102575E-6	3.488712827560753E-5

$rec =~ /predicted region = \[(\d+),(\d+)\][\t\b]+predicted orientation = (\d+)[\t\b]+classification = (\w+)[\t\b]+(\S+)[\t\b]+(\S+)/ or die "didnot match\n";

my $line .= uc("$4")."::$1-$2:::$3:[$5,$6]\t";


print "The current line after ProMiR is\n$line\n";
# FALSE::33-51:::3:[1.4583886169102575E-6,3.488712827560753E-5]
}
close $OUX4 if $OUX4 != 0;
