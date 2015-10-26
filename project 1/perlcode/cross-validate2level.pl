#!/usr/bin/perl -w
# revised from cross-validate.pl
#
# For one step in 5-fold cross-validation; output is the accuracy of the ANN and the parameters of the ANN in out.txt

#Format of driver file:(revised)
#TARGETS:
#ANN
#....
#INPUTS:
#positivefile
#negativefile

#use strict;
# use File::Basename;

# Read in the TRAIN, TEST, VALIDATE cases from the files mentioned in in.txt


# usage: cross-validate.pl [-norun] < experiment-driver-file
# -norun is used to cause the creation of the testfiles without
# running the targets.  Useful for lisp-based programs.

#Format of driver file:(originally)
#TARGETS:
#cmd-line1
#cmd-line2
#cmd-line3
#...
#INPUTS:
#inputfile1
#inputfile2
#...

# Each target will be executed with each input.  The inputs are just
# basenames.  For instance if you have foo.data and foo.names, the
# input line should just say foo.  This will create a set of input
# files for 10-fold cross validation (foo-[0-9].data, foo-[0-9.test]
# and foo-[0-9].names).  (Note the *.names are hard links, so if you
# edit one of the files, they will all change.)

#TARGETS:
#id3
#bag
#boost
#INPUTS:
#test1
#test2

# The average accuracy for each learner will be reported.  (Averaged
# over the 10 runs.)

#$norun = 0;
#if ($ARGV[0] eq "-norun") {
#    $norun = 1;
#    shift(@ARGV);
#}

sub check_accuracy {
    my($basename,$outname) = @_;
    if (!$outname) {
	$outname = "$basename.out";
    }
    my(@predictions, @actual);
    my(@inputs);
    my($i, $num, $correct);
    open(IN, "<$outname") || die "Couldn't open $outname\n";
    undef($/);
    while(<IN>) {
	@predictions = split(/\s+/);
    }
    close(IN);
    $/ = "\n";
    open(IN, "<$basename.test") || die "Couldn't open $basename.test\n";
    while(<IN>) {
	@inputs = split(/,/);
	# Remove leading and trailing whitespace and trailing .
	$inputs[$#inputs] =~ s/^(\s+)|(\.?\s+)$//g;
	push(@actual, ($inputs[$#inputs]));
	$num++;
    }
    if ($#predictions != $num-1) {
	print STDERR "Warning: $basename |predictions| = $#predictions, |test| = $#actual, \$num = $num\n";
    }
    for($i=0; $i<$num; $i++) {
	if ($predictions[$i] eq $actual[$i]) {
	    $correct++;
	}
    }
    return $correct/$num; # TPs
}
# Read the driver file
$state = 0;			# Looking for targets
while (<>) {
    chop();
    if (/^\#|^\s*$/) {		# Skip comment and blank lines
 	next;
    }
    if (/^TARGETS:$/) {
	$state = 0;		# Looking for targets
	next;
    }
    if (/^INPUTS:$/) {
	$state = 1;		# Looking for input files
	next;
    }
    if ($state == 0) {
	push(@targets, $_)
    } elsif ($state == 1) {
	push(@inputs, $_)
    }
}

my $f = 5; 
# For each input file, read data into array
foreach $input (@inputs) {
    my @fold; # has subsets of data
    print "Dataset: $input\n";
    open(IN, "$input.data") || die "Couldn't open $input.data\n";
    while(<IN>) {# could have used @data = <IN>;
	push(@data, $_);
    }
    close(IN);
    $count = $#data; # count the cases
    $foldcount = int($count / $f + .5); # round the size of each subset to 1/10-th size
    $foldnum = 0;
    for($i=0; $i<=$count; $i++) { # divide data into subsets
	if ($i >= ($foldnum+1)*$foldcount) { # increment block
	    $foldnum++;
	}
	$j = int(rand($#data+1)); # j is the offset passed to splice; one element picked, shouldn't use srand (revised 'int')
	($line) = splice(@data,$j, 1); # pick the j-th case only
	$fold[$foldnum] .= "$line";
    }
    for($i=0; $i<$f; $i++) { # write-out to files; index for TEST 
		print "Fold $i\n";
        	$basename = "$input-$i"; # indx. TEST
        	#link "$input.names", "$basename.names"; # ?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        	open(TRAIN, "+>$basename.data") ||
                	die "Couldn't open $basename.data\n";
        	open(TEST, "+>$basename.test") or 
			die "Couldn't open $basename.test\n";
        	print TEST $fold[$j]; 
		for($k=0; $k<$f; $k++) { # index for TRAIN
    			if($k == $i) {next} # index of TRAIN ne to index of TEST
			print TRAIN $fold[$k]; # print all other subsets except $i
		}
		# completes one iteration of file-writing
		close(TRAIN);
        	close(TEST);
    }
}
# Run targets	
# Concatenate $i positive subset with the corresponding $i negative subset, use $basename-$i
for($i=0; $i<$f; $i++) {
	$basename1 = "$inputs[0]-$i"; 
	$basename2 = "$inputs[1]-$i";
	$basename3 = "$inputs[0]"."$inputs[1]"."fold-$f-$i"; # positive, negative samples
	$cmdline = "cat $basename1.data $basename2.data >$basename3.data";
        system($cmdline);
	$cmdline = "cat $basename1.test $basename2.test >$basename3.test";
	system($cmdline);
        unlink("$basename1.data", "$basename1.test", "$basename2.data", "$basename2.test");
	push @inputsnew, $basename3; # new list 
	$basename = $basename3; # save the new basename
	undef($basename1);
	undef($basename2);
	undef($basename3);
     	# finished writing the subset 

#if (!$norun) {
	# Run all the targets
   	foreach $target (@targets) {
 	   $cmdline = "$target $basename"; # pass the file's basename to target
	   print "running: $target $basename\n";
	   system($cmdline);
	   $accuracy = &check_accuracy("$basename");
	   $accuracy{"$target-$input"} .= "$accuracy,";
	   $targetname = $target;
	   $targetname =~ s/\s+/_/g;
	   rename("$basename.out", "$targetname-$basename.out");
	   #unlink ("$basename.names", "$basename.data", "$basename.test", "$basename.out");
        }
}

#}
    
#if (!$norun) {
foreach $target (@targets) {
    foreach $input (@inputsnew) {
       $accuracy = $accuracy{"$target-$input"};
       chop($accuracy);
       @accuracies = split(/,/, $accuracy);
       $avg = 0;
       for($i = 0; $i<=$#accuracies; $i++) {
	  $avg += $accuracies[$i];
       }
       $avg /= $#accuracies+1;
       print "$target $input: $avg\n";
   }
}
#}
