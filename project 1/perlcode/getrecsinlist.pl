#!/usr/bin/perl 
# extract records whose names(e.g hsa-let-7a) are in a list file from a fasta database
# supply two files: a list file and a fasta file database


# list of names - file; valid.names of precursors
open(FH, "<$ARGV[0]") or die "cannot open file $ARGV[0]\n";
@names = <FH>;
$names = join('', @names); # list has only a subset of names

# fasta file from which to pick records e.g., mature_Hs.fa
open(FH2, "<$ARGV[1]") or die "cannot open file $ARGV[1]\n";

local $/='>';

getc(FH2);


while(<FH2>) {

  chomp();

  /^(\S+)/; # extract the first non-whitespace word
#  $name = lc($1); 
  $name = $1;

# print "searching for $name in the mature hsa-miRs: $ARGV[1]\n";

  if($names =~ /$name/) { # match name to the list
     print '>'.$_;
  } #else {
    # print "$name not found\n";
 #}

}
close(FH);
close(FH2);
