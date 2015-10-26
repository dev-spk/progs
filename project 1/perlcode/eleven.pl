#!/usr/bin/perl
# Parse tripletSVM output

#use strict;
use File::Basename;

my $Home = '~/bin';
my $intext = $ARGV[0]; # create a local $intext in the $Home dir.

# retrieve file name
(my $fname,my $path, my $suffix) = fileparse($intext, (".fasta", ".fa", ".txt"));

my $insecd = "~/bin/triplet-svm-classifier060304/$fname".'_secondary_structures';

print "Beginning to run the triplet svm classifier .....................\n";

!system("RNAfold --noPS <$intext >$insecd") or die "could not run RNAfold\n";

!system("$Home/triplet-svm-classifier060304/triplet_svm_classifier.pl $insecd $Home/triplet-svm-classifier060304/predict_format.txt 22") or die "\n";# check predict_format

!system("$Home/libsvm-2.36/svm-predict $Home/triplet-svm-classifier060304/predict_format.txt $Home/triplet-svm-classifier060304/models/trainset_hsa163_cds168_unite.txt.model $Home/triplet-svm-classifier060304/output/outputx") or die "\n"; # result in predict_result; is empty if none predicted. is empty for the example.seq set

# parse outputx file
open (my $OUX3, "<triplet-svm-classifier060304/output/outputx") or die "cannot open file\n";
# single line record: -1,1 or empty
$rec = <$OUX3>;
$rec =~ s/\n/\t/;
if ($rec =~ /^$/) {# is empty
	$line = 'NA';
} elsif($rec =~ '1') {
	$line = "1\t";
#print "The current line after tripletsvm is\n$line\n";
} else {
	$line = "-1\t";
}
print "$line\n";
close $OUX3 if $OUX3 != 0;
#system "rm", "triplet-svm-classifier060304/output/outputx";

