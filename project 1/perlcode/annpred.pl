#!/usr/bin/perl -w

# seven

use strict;
use File::Basename; # core module

my $Home = '/home/complab/bin'; # provide absolute path of the home directory to the system(), avoid ~/bin; the input file resides here

# Check if the input file exists
open (my $IN, "<$ARGV[0]") or die ("Cannot read input file error:$!");

# check if the user wants to accept the new format:(Y/N) if Y, warn: a new file () will be created with modified seq. names. else, warn: MIReNA will be disabled from the package and the output file will not be generated in the output/ folder
print "Warning: if the input file in fasta format does not have the before:num. and after:num. fields in the sequence name(s) then a new copy of the file will be created with the modified seq. name(s) and everything else the same. Do you wish to continue (y/n):";

my $UserIn = <STDIN>;



# Check the right format of the input file
my @L = ();
my $L = ();

if($UserIn =~ /n/i) { # User said No

	while (<$IN>){

		if (substr($_,0,1) eq ">") {

			my $seq = <$IN>;

			chomp($seq); # because new line character is also read in

			$L = length($seq);

			@L = (@L, $L) if ($seq =~ /^[AUGCYNDMSRKWBVHM]+$/i); # allow errors in the seq. in the initial run

			}	

		elsif (/^$/) {

			}

			else {

				die "Error: check the input file at line ...\n";

				}

		}

	}

else { # if the user said Yes

	$ARGV[0].='.modify'; # update input file name

	open(my $INI, '>'.$ARGV[0]) or die "Cannot create file: $!";

	while (<$IN>){

		if (substr($_,0,1) eq ">") {

		chomp(); # because new line character is also read in

		my $seq = <$IN>;

		chomp($seq); # because new line character is also read in

		$L = length($seq);

		@L = (@L, $L) if ($seq =~ /^[AUGCYNDMSRKWBVHM]+$/i); # allow errors in the seq. in initial run

		if(!/(before:\w+after:)|(begin:\w+end:)/){      # because fields are separated with whitespaces

			my $app = ' before:0 after:'.($L-1);

			print $INI $_.$app."\n"; # seq. name(s) will be appended with the before:0 and after:$L-1 fields

			print $INI $seq."\n";

			}		

			}

		elsif (/^$/) {

				}

			else { # not work

				die "Error: check the input file at line ...\n";

				}

		}

		close $INI;

	}

close $IN;

print "Successful!\n";

print "Number of input sequences = ", $#L+1, " Total\n";


# Read the contents of the installation directory
opendir(my $H, $Home) or die "Cannot open directory:$!";

my @contents = grep(!/^\.\.?$/ && -d "$Home/$_", readdir $H);

closedir $H;

# If the sub-directories do not contain the folder 'output', then create it
@contents = grep(/^mir/i | /^pcre/i | /micro/ | /triplet/ | /ProMiR/, @contents);

foreach(@contents) {
	my $Sub = "$Home/$_";

	opendir(my $S, $Sub) or die "Cannot open sub-directory:$!";

	my @cont = grep(!/^\.\.?$/ && -d "$Sub", readdir $S);

	mkdir "$Sub/output" if('output' !~ @cont || @cont == 0) or print "output directory already exists!\n"; # not in

	closedir $S;

	}

# call the predictors on the available list of sequences listed in a fasta or a fastq format

# opendir() or die "Cannot open home directory:$!";

# category 1: tools which run on the long RNA sequences without the need for deep sequencing datasets (Is the prediction on precursor RNAs or Primary RNAs or 3'UTR sequences the same or different?)
# grep the executables contained in the subfolders of the $Home directory

# Tool 1: MIReNA(--predict option) check if the folder contains fasta file for the -f option and a text file for the -t option. Parameters will use default values

local $/ = '>'; # line separator essential before while-loop; changed later before reading output files

my $intext = $ARGV[0]; # input fasta file of all sequences

my $outtext = $ARGV[0].'.consensus'; # to store consensus results

my $strfname = $ARGV[0].'.strs';

open(my $SEQS, "<$intext") or die "\n";

open(my $CON, ">$outtext") or die "\n";

open(my $STRS, ">$strfname") or die "";

getc($SEQS); # skip the first char. of input file of all fasta seqs.

while(<$SEQS>) {

chomp(); # for the trailing '>' separator; modify $_
# write a seq. to file, to pass on to all the predictors
my $intext = "inseqzzzzzzzzzzxvlyptq.fa"; # create a local $intext in the $Home dir.
# retrieve file name
(my $fname,my $path, my $suffix) = fileparse($intext, (".fasta", ".fa", ".txt"));
open(my $INSEQ, ">$intext") or die "\n";
print $INSEQ '>'.$_;
close $INSEQ;

/(^\S+.*)\n?([AUGCYNDMSRKWBVHM\n]+$)/i or die "The sequence has non-[AUGC]:\n$_:$!\n";
print "Processing sequence:\n$1\n$2\n";

my $line = ();
#my $line = "$1\t"; # first write name of seq. to line

# Tool 1 (Option 3:predict pre-miRNA from long sequences in MIReNA fasta format file, Option 4: validate putative pre-miRNA stem-loop sequences containing pre-miRNA, position in beg: and end: fields in the MIReNA fasta format file)
print "Beginning to run MIReNA-2.0 by the predict option ...........\n";
#`rm $Home/MIReNA-2.0/output/out`; # MIReNA-2.0 by default opens in >> (modify) mode
!system("$Home/MIReNA-2.0/MIReNA.sh --predict -l 41 -f $intext -o $Home/MIReNA-2.0/output/oux") or die "\n";#not predicting anything for example.seq set! and yes for the input.txt;filename is 3 characters
# option 4: ../MIReNA.sh --valid -x -f preMi.fa -o out.txt

# Tool 2 (no parameters is easy. this tool might need a temporary directory to store intermediate files. Input txt file in fasta format)
print "Beginning to run miPred ......................................\n";
!system("$Home/MiPred/microRNAcheck_parallel.pl -i $intext -d $Home/MiPred/output -f $Home/MiPred/output/outputx") or die "\n";#must give absolute path

# Tool 3 (The triplet*classifier.pl script requires a pre-miRNA secondary structure predicted file from RNAfold, in the modified fasta as the input; RNAfold must be installed and available from the root; model is for human miRNA only; predict_format file is the input to the svm-predict to do the learning predictions; libsvm newest version 3.18 reported error in the predict_format file, evidently meaning the script 4_libsvm_format.pl writes in an old format so used libsvm2.36 installed in the $Home directory) 
print "Beginning to run the triplet svm classifier .....................\n"; 
my $insecd = "$Home/triplet-svm-classifier060304/$fname".'_secondary_structures';
!system("RNAfold --noPS <$intext >$insecd") or die "\n";

!system("$Home/triplet-svm-classifier060304/triplet_svm_classifier.pl $insecd $Home/triplet-svm-classifier060304/examples/predict_format.txt 22") or die "\n";# check predict_format
!system("$Home/libsvm-2.36/svm-predict $Home/triplet-svm-classifier060304/examples/predict_format.txt $Home/triplet-svm-classifier060304/models/trainset_hsa163_cds168_unite.txt.model $Home/triplet-svm-classifier060304/output/outputx") or die "\n"; # outputx is empty when the seq. sec. structure has multiple loops

# Tool 4 (rRNA prediction in prokaryotic genome sequences; its installation instructions asks for rnammer to be in the user's path)
#system("rnammer -S bac -m lsu,ssu,tsu -gff - <$Home/rnammer-1.2/example/ecoli.fsa");

# Tool 5 (RNAmicro: must prepare alignment file with clustalw)
# system("$Home/bin/RNAmicro1.1.3/RNAmicro -i examples/miRNA.aln -d models/");

# Tool 6 (ProMiR: )
print "Beginning to run ProMiR ........................................\n";
chdir "$Home/ProMiR"; # java needs to compile the main class from the current directory
my $inpromir = "$Home/$intext"; # fasta file in $Home
!system "cp", "$inpromir", "$Home/ProMiR/$intext" or die "Error copying file: $!\n";
!system("java ProMiR $intext") or die "\n"; # predicted good for example.seq; output written to $Home/ProMiR/example.seq.output, where the input file is
chdir "$Home";

print "The present working directory is ****************************************************\n";
my $lmirpara = 4;
# Tool6
!system "$Home/miRPara/miRPara.pl", "-s", "hsa", "-l", "$lmirpara", "$intext" or die "\n"; # default output file in the same place as input file

=pod
write the consensus for the seq.
print "\nResults of MIReNA\n";
system "cat", "$Home/MIReNA-2.0/output/oux";
print "\nResults of MiPred\n";
system "cat", "$Home/MiPred/output/outputx";
print "\nResults of tripletsvm\n";
system "cat", "$insecd";
system "cat", "$Home/triplet-svm-classifier060304/output/outputx";
print "\nResults of ProMiR\n";
system "cat", "$Home/ProMiR/$intext.output";
print "\nResults of miRBoost\n";
system "cat", "$Home/miRBoost/results.txt";
=cut

# open fi
open (my $OUX1, "<$Home/MIReNA-2.0/output/oux") or die "cannot open file: $!\n";
# parse fi
my @rec = <$OUX1>; # read entire file 
my $rec = ();
if ($#rec != -1) {
	$rec = join('', @rec);
	$rec =~ s/\n/\t/g;
	$rec =~ /_(\d+)_(\d+)\s+.*\((-?\d+.*?)\)\s+$/ or die "did not match sequence: $!\n"; # match (-39.30); if num.of ele. > 0 
	$line .= "YES\t"; # YES:MFEscore:loc start-stop
} else {
       $line .= "NO\t";
}
#print "The current line after MIReNA is\n$line\n";
close $OUX1 if $OUX1 != 0; # if file doesnot exist
# remove fi
system "rm", "$Home/MIReNA-2.0/output/oux"; # because MIReNA opens it in '>>' modei

print "now printing Mipred output to file\n";
# Parsing each output file is different
# open fi
open(my $OUX2, "<$Home/MiPred/output/outputx") or die "\n";
@rec = <$OUX2>;
$rec = join('', @rec);
# Sequence Name:        hsa-let-7a-1 before:0 after:79
# Sequence Content:     UGGGAUGAGGUAGUAGGUUGUAUAGUUUUAGGGUCACACCCACCACUGGGAGAUAACUAUACAAUCUACUGUCUUUCCUA
# Length:       80
# Pre-miRNA-like Hairpin?       Yes
# The Secondary Structure:      (((((.(((((((((((((((((((((.....(((...((((....)))).)))))))))))))))))))))))))))))
# MFE:  -34.20
# p-value (shuffle times:1000)  0.001
# Prediction result:    It is a real microRNA precursor
# Prediction confidence:82.3%
$rec =~ s/\t//g; # initially remove all tabs NOT necessary
$rec =~ s/\n/\t/g; # replace all newlines with tab
# Sequence Name:hsa-let-7a-1 before:0 after:79   Sequence Content:UGGGAUGAGGUAGUAGGUUGUAUAGUUUUAGGGUCACACCCACCACUGGGAGAUAACUAUACAAUCUACUGUCUUUCCUA       Length:80       Pre-miRNA-like Hairpin?Yes      The Secondary Structure:(((((.(((((((((((((((((((((.....(((...((((....)))).)))))))))))))))))))))))))))))        MFE:-34.20      p-value (shuffle times:1000)0.001       Prediction result:It is a real microRNA precursor       Prediction confidence:82.3%

# Read some features of the rna sequence from MiPred output, necessary for the final output format
my @seqnam = $rec =~ /Sequence Name:(\S+)/;
my @nucseq = $rec =~ /Sequence Content:(\S+)/;
my @strseq = $rec =~ /Secondary Structure:([(.)]+)/;
my @mfe = $rec =~ /(MFE:\S+)/;
my @Length = $rec =~ /(Length:\S+)/;
my $record = ">@seqnam\t@Length\t@mfe\n@nucseq\n@strseq"; #$preds
print $STRS $record, "\n";

$rec =~ /Prediction result:(\S+\s\S+\s\S+\s\S+\s\S+\s\S+)/ or die "didnot match any seq.\n";
my $pred = ();
if ($1 eq 'It is a real microRNA precursor') {
$pred = 'YES';
$rec =~ /MFE:(-\d+\.\d+)/ or die "didnot match any seq.\n";
#$line .= "MiPred:$pred:$1";# YES:MFE:loc:p-value:pred.confid.
#$rec =~ /p-value\s\(.*\)(0\.\d+)/ or die "didnot match any seq.\n";
#$line .= "::$1";
$rec =~ /Prediction confidence:(\d+[^%]*)%/ or die "didnot match any seq.\n";
$line .= "$1\t"; # YES:MFE:loc:p-value:pred.confid.
} else {
$pred = 'NO';
$rec =~ /MFE:(-\d+\.\d+)/ or die "didnot match any seq.\n";
$line .= "0\t"; # YES:MFE:loc:p-value:pred.confid.
}
#print "The current line after MiPred is\n$line\n";
close $OUX2 if $OUX2 != 0;
system "rm", "$Home/MiPred/output/outputx";

print "Now printing the results of triplet svm to the file $Home/triplet-svm-classifier060304/output/outputx\n";

# parse outputx file
$rec = ();
open (my $OUX3, "<$Home/triplet-svm-classifier060304/output/outputx") or die "cannot open file\n";
# single line record: -1,1 or empty
$rec = <$OUX3>;
$rec =~ s/\n/\t/g;
if ($rec =~ /^$/) {# is empty
        $line .= "NA\t"; # tripletsvm disregards multiple loop structures
} else {
        $line .= "$rec\t";
}
close $OUX3 if $OUX3 != 0;
!system "rm", "$Home/triplet-svm-classifier060304/output/outputx" or die "system() call failure: $!\n";

print "now printing the results of promir\n";

# This file is created even when there is no record
open (my $OUX4, "<$Home/ProMiR/$intext.output") or die "cannot open file\n";
@rec = <$OUX4>;
# check empty file
if ($#rec == -1){ # while(s>=0&&e>=0&&(o==5||o==3)&&p[0]!=null&&!p[0].equals("")&&p[1]!=null&&!p[1].equals("")&&p[0].length()==p[1].length()) {}
$line .= "NA\t"; # if the while loop conditions on the 5p and 3p strands are not satisfied
#print "$line\n";
} else {
$rec = join('', @rec);
#print "$rec\n";
# RF00001;5S_rRNA;AADB02014418.1/10140-10240   9606:Homo sapiens (human)
# predicted region = [33,51]
# predicted orientation = 3
# classification = false
# 1.4583886169102575E-6 3.488712827560753E-5
$rec =~ s/\n/\t/g;
#print $rec, "\n";
# RF00001;5S_rRNA;AADB02014418.1/10140-10240   9606:Homo sapiens (human)        predicted region = [33,51]      predicted orientation = 3       classification = false  1.4583886169102575E-6   3.488712827560753E-5
$rec =~ /predicted region = \[(\d+),(\d+)\][\t\b]+predicted orientation = (\d+)[\t\b]+classification = (\w+)[\t\b]+(\S+)[\t\b]+(\S+)/ or die "didnot match\n";
if (uc("$4") eq 'FALSE') {
$pred = 'NO';
} else {
$pred = 'YES';
}
my $min = ($5>$6?$5:$6);
$line .= "$min\t";
#print "The current line after ProMiR is\n$line\n";
# FALSE::33-51:::3:[1.4583886169102575E-6,3.488712827560753E-5]
}
close $OUX4 if $OUX4 != 0;
!system "rm", "$Home/ProMiR/$intext.output" or die "system() call failure: $!"; # YES:MFE:loc:p-value:predconfid:orientation:interval

print "the current line after ProMiR is\n$line\n";



print "now printing the results of mirpara\n";

my $outmirpara = "$path$fname"."_level_$lmirpara.out"; # the output file name and path defaults to the input file
print "The output file is \n$outmirpara\n";
open (my $OUX6, "<$outmirpara") or die "miRPara output file not found:$!\n"; # check: possamples_level_17.out
# find max. probability score
#skip the lines which start with #
my $maxprob = -1; # probability can't be negative
$/ = "\n";
while (<$OUX6>){
	# find max.
        if (/^[^#]/) { # skip line beginning in # or !
                my @columns = split("\t");
                my $prob = $columns[5];
                $maxprob = ($prob>$maxprob?$prob:$maxprob);
        }
        # skip lines starting with '#' or skip empty lines
}
$line .= ($maxprob==-1?'0':"$maxprob")."\t";
close $OUX6;
system "rm", "$outmirpara"; # YES:MFE:loc:p-value:predconfid:orientation:interval
$/ = '>'; # reset back to '>' for reading every other files 

=pod
# print a line of the consensus table
my $label = 'NEG';
$line .= $label;
=cut

print $CON "$line\n";
print "$line\n";

}
close $CON;
close $SEQS;
close $STRS; # str. and nuc. seq. fasta file

# execute R scripts on .consensus
my $command = "Rscript ~/perlprogs/runpredict.R $outtext"; # pass on the filename (.consensus)
system($command);


{# Combine files: the structures and the predictions

  open($STRS, "<$strfname") or die "";
  open($CON, "<$outtext") or die "";
  open(my $PRED, ">$ARGV[0].predictions") or die "";

  my($Strseq, $Con, $Rec) = ();

  local $/ = '>';
  getc($STRS);
  while(<$STRS>) { # assume num. of records equal in both the files
	
	chomp;
	$Strseq = $_;

	{
		local $/ = "\n";
		$Con = <$CON>;
	}

	$Rec = $Strseq . $Con;
	print $PRED '>'.$Rec;


  }

  close $STRS;
  close $CON;
  close $PRED;

}





# category 2: tools which run on the deep sequencing datasets
