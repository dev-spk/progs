#!/usr/bin/perl
# Parse MIReNA output file

my $Home = "~/bin";
# open fi
open (my $OUX1, "<$Home/MIReNA-2.0/output/oux") or die "cannot open file: $!\n";
# parse fi
my @rec = <$OUX1>; # read entire file 
my $rec = ();
if ($#rec != -1) {
$rec = join('', @rec);
$rec =~ s/\n/\t/g;
print $rec, "\n";
$rec =~ /_(\d+)_(\d+)\s+.*\((-?\d+.*?)\)\s+$/ or die "did not match sequence: $!\n"; # match (-39.30); if num.of ele. > 0 
$line .= "MIReNA:YES:$3:$1-$2\t"; # YES:MFEscore:loc start-stop
}
else {
        $line .= "MIReNA:NO::\t";
}
print "The current line after MIReNA is\n$line\n";
# close fi
close $OUX1 if $OUX1 != 0; # if file doesnot exist

system "rm", "$Home/MIReNA-2.0/output/oux";
