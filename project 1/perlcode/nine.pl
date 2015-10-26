#!/usr/bin/perl -w
# parse MiPred output file

use strict;

open (my $FH, "<MiPred/output/outputx") or die "\n";

my @rec = <$FH>; 
my $rec = join('', @rec);
undef @rec;
print $rec;

# Sequence Name:	hsa-let-7a-1 before:0 after:79
# Sequence Content:	UGGGAUGAGGUAGUAGGUUGUAUAGUUUUAGGGUCACACCCACCACUGGGAGAUAACUAUACAAUCUACUGUCUUUCCUA
# Length:	80
# Pre-miRNA-like Hairpin?	Yes
# The Secondary Structure:	(((((.(((((((((((((((((((((.....(((...((((....)))).)))))))))))))))))))))))))))))
# MFE:	-34.20
# p-value (shuffle times:1000)	0.001
# Prediction result:	It is a real microRNA precursor
# Prediction confidence:82.3%

$rec =~ s/\t//g; # initially remove all tabs NOT necessary

$rec =~ s/\n/\t/g; # replace all newlines with tab

print $rec;

#sequence Name:hsa-let-7a-1 before:0 after:79	Sequence Content:UGGGAUGAGGUAGUAGGUUGUAUAGUUUUAGGGUCACACCCACCACUGGGAGAUAACUAUACAAUCUACUGUCUUUCCUA	Length:80	Pre-miRNA-like Hairpin?Yes	The Secondary Structure:(((((.(((((((((((((((((((((.....(((...((((....)))).)))))))))))))))))))))))))))))	MFE:-34.20	p-value (shuffle times:1000)0.001	Prediction result:It is a real microRNA precursor	Prediction confidence:82.3%

$rec =~ /Prediction result:(\S+\s\S+\s\S+\s\S+\s\S+\s\S+)/ or die "didnot match any seq.\n";
my $pred = ();
my $line = ();
if ($1 eq 'It is a real microRNA precursor') {
$pred = 'YES';
$rec =~ /MFE:(-\d+\.\d+)/ or die "didnot match any seq.\n";
$line .= "$pred:$1";# YES:MFE:loc:p-value:pred.confid.
$rec =~ /p-value\s\(.*\)(0\.\d+)/ or die "didnot match any seq.\n";
$line .= "::$1";
$rec =~ /Prediction confidence:(\d+[^%]*%)/ or die "didnot match any seq.\n";
$line .= ":$1\t"; # YES:MFE:loc:p-value:pred.confid.
}
else {
$pred = 'NO';
$rec =~ /MFE:(-\d+\.\d+)/ or die "didnot match any seq.\n";
$line .= "$pred:$1::\t"; # YES:MFE:loc:p-value:pred.confid.
}

close $FH;

print "$line\n";
# YES:-34.20::0.001:82.3%
