#!/usr/bin/perl -w

# Scale and normalize the individual features retrieved from a text file and 
# store the scaled & normalized values to another text file  

#use strict;

use File::Basename;
#use List::Util qw(first max maxstr min minstr reduce shuffle sum);


my $filename = $ARGV[0];
my $outfname = ScaleAndNormalize($filename);




# Perform scaling and normalization of the individual features
sub ScaleAndNormalize {


	my $filename = "@_";
	my($basename, $path, $suffix) = fileparse($filename, ('.data', '.test', '.valid', '.consensus', '.con'));
	
	my $outfname = "$path"."$basename".'-normalized'."$suffix";

	# input args. is the consensus file name
	open(FH, "<$filename");

	my(@predrefs, @one, @two, @three, @four, @five, @label, @list);

	while(<FH>) { # each feature in a string

		chomp();
		
		@list = split /\s+/;
	
		push @one, $list[0];
		push @two, $list[1];
		push @three, $list[2];
		push @four, $list[3];
		push @five, $list[4];
	
		push @label, $list[5]; # final col. is a label

	}
	
	@predrefs = (\@one, \@two, \@three, \@four, \@five);

	foreach my $predref (@predrefs) { # each predictor separately
	
		@$predref = stdnormalize(@$predref);
#		@$predref = simplerescale(@$predref);

	}
	
	push @predrefs, \@label; # save the labels

	printpreds(\@predrefs, $outfname);

	close FH;

	return($outfname);


}




# find range of each feature
sub range {
	
	my @arr = @_;
	@arr = sort {$a <=> $b} @arr;
	($arr[0], $arr[$#arr]);

}


sub sum {

	my @arr = @_;
	my $total;
	foreach(@arr){
		$total += $_;
	}
	return($total);

}

# find the mean and std.dev of the features
sub mean {
	
	my @arr = @_;
	sum(@arr)/($#arr+1);

}

sub stddev {

	my @arr = @_;
	my $mean = mean(@arr);
	my($diff, $total);
	foreach(@arr){
		$diff = $_ - $mean;
		$total += ($diff*$diff);
	}
	sqrt($total/$#arr); # unbiased

}

# simply re-scale
sub simplerescale { # scale the values to the interval [-1,1]

	my @values = @_; 
	my($min, $max) = range(@values);
	my $range = $max - $min;
	my $j=0;
	foreach(@values) {
		$values[$j] = ($_-$min)/$range; # (i) scale to the interval [0,1]
		$values[$j] = $values[$j]*2 - 1;# (ii) re-scale to the interval [-1,1] 
		$j++;
	}
	return(@values);


}

# standard normalize
sub stdnormalize { # Want to keep mean=0 and std.dev.=1 

        my @values = @_;
        
        my $mean = mean(@values);
        my $stddev = stddev(@values);
        my $i=0;
        foreach(@values) { # and then do the normalization; mean=0, std.dev.=1    
                $values[$i] = ($_ - $mean)/$stddev;
                $i++;
        }

        return(@values);


}


# write out to a text file      
sub printpreds {

	my $dataref= shift @_;
	my $outfilename = shift @_;
	my @predrefs = @{$dataref};
	
	my @one = @{$predrefs[0]};	
	my $numcases = $#one+1; # equal in all predictor's vecs.
	my($one, $two, $three, $four, $five, $label, $line);
		
	open(FHO, ">$outfilename");

	foreach(1 .. $numcases) {
	
		$one = shift @{$predrefs[0]}; # should have used foreach() loop, instead
		$two = shift @{$predrefs[1]};
		$three = shift @{$predrefs[2]};
		$four = shift @{$predrefs[3]};
		$five = shift @{$predrefs[4]};

		$label = shift @{$predrefs[5]};

		$line = "$one\t" . "$two\t" . "$three\t" . "$four\t" . "$five\t" . "$label"; 
		print FHO "$line\n";
	
	}
	close FHO;

}

sub checkNAs {

	my $val = @_;
	
	return($val == 'NA');

}




