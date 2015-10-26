#!/usr/bin/perl -w

# Solve:
# 1a. Given a miR 'seed'(N) and a long nucleotide sequence (mRNA), find the start & 
#     the end locations of the n-mers(=match 'site') on the target.
#
#  b. Extend 2 x the Length of remaining microRNA(N-n) on either side of the matched site. 
#     Find the free-energy change during hybridization, delta_G_H, using the RNAcofold, e.g.,
#
#     echo "AUUUUCGCGAAAAAAAAAAAAAAAAAAAAAAAAUUUUCCCCGGG&UUUUUUUUUUUUUUUUUUUUUUUUUCGCG" | RNAcofold --noGU --noPS
#
#     AUUUUCGCGAAAAAAAAAAAAAAAAAAAAAAAAUUUUCCCCGGG&UUUUUUUUUUUUUUUUUUUUUUUUUCGCG
#     .....((((((((((((((((((((((((((((...........&.)))))))))))))))))))))))))))) (-27.20)
#
#  c. Find the local unpaired probabilities at the matched sites using the RNAplfold, 
#     W = 80, L = 40, u = 20.
# Two databases: microRNAs, 3pUTRs ([ATGC] is assumed)

#################################################################################################################
# Usage: ./matchseed.pl tarfile.fa miRfile.fa
#################################################################################################################


use strict;

# input args
my $tarID = $ARGV[0]; # optional
my $miRID = $ARGV[1]; # optional
my $len_mer = $ARGV[2]; # length of mer

print "processing for $miRID\t$tarID ......\n";

# check record in database(s) and extract sequence
my @miRs = find_seq($miRID, 'mature_hsa.fa');
my $miR = $miRs[0]; # 1st match
my @UTRs= find_seq($tarID, 'hg18_3UTR_TMiner.fa');#'Tarb_ENSG_Refseq_UTRs.fa'); # return all splice variants

#print "Splice variants are \n", join("\n", @UTRs), "\n";

foreach my $UTR(@UTRs) { # Do the following for all the splice variants

if(isempty(\$UTR, \$miR)){
  print "error: $tarID and/or $miRID unavailable\n";
  exit 1;
}


my $seed = substr($miR, 1, 6); # nuc. 2-7
my $len_miR = length($miR);
my $len_extension = 2 * ($len_miR - $len_mer);

my @mers = get_mers($seed, $len_mer);


# Compute the change in Gibbs free-energy during hybridization
# Write the local match neighboring sequences-microRNA duplex in a fasta file
{
  local *STDOUT;
  open(STDOUT, ">tmp.fa") or die "cannot open file error: $!";
  print_extd_sequences_in_fasta_format(\@mers, $len_mer, $len_extension, \$UTR, $tarID, $miRID, $miR); # miR and the UTR sequences
  close STDOUT;
}
# Fold the sequences with RNAcofold
my $cmd = "RNAcofold --noPS --noGU <tmp.fa >tmp.str"; # Not allow G-U pairings
system($cmd);

# print_str_file('tmp.str');
{
  local *STDOUT;
  open(STDOUT, ">>tmp.txt") or die();
  print_strfileTotext('tmp.str');
  close STDOUT;
}

# Input .str file and print the imperfect match sites in .npp file
# print_imperfect_match_sites('tmp.str');
# correct_secondary_structures('tmp.str.npp'); # do with hand

# (c) Compute the local unpaired probabilities
# Write the local match neighboring sequences in a fasta file
{
  local *STDOUT;
  my $M = 40; # check why not 40? length of extension on each side of the match
  open(STDOUT, ">tmp2.fa") or die "cannot open file error: $!";
  print_extd_sequences_in_fasta_format(\@mers, $len_mer, $M, \$UTR, $tarID, $miRID, ''); # only the UTR sequence
  close(STDOUT);
}


{ # Do seperately for E_open because extension length of 2x(length of remaining miRNA) won't suffice for a W = 80 window
  local *STDOUT;
  # Find the probability that the matched site is unpaired
  my($W, $L, $u) = (80, 40, 20); # default values: (80, 40, 20); $u >= $len
  open(STDOUT, ">>tmp.out") or die("cannot open file error: $!");
  print_probability_the_match_site_is_unpaired('tmp2.fa', $W, $L, $u);
  close(STDOUT);
}


}

=pod
# Keep only the match site with the lowest open energy 
$cmd = "sort -u -k2,2 -g tmp.out | tail -1";
system($cmd); 


# Filter the open energy scores of each match site, keep only the lowest
{
  print_lowest_open_energy_scores('tmp.out');
}
=cut




sub print_lowest_open_energy_scores{

 my $fname = $_[0]; 
 
 open(FH, "<$fname") or die("cannot open file $fname: $!\n"); 


 close FH;

}

sub print_probability_the_match_site_is_unpaired{

  my($infname, $W, $L, $u) = @_;

  # For input .fa file RNAplfold prints the output in individual _lunp files for each sequence id
  open(IN, "<$infname") or die("cannot open file error: $!");
  # for each sequence in the .fa file find unpaired probability

  local $/ = '>';
  getc(IN);

  while(<IN>){
    
    chomp;
    my($Head, $seq) = split("\n");
    my($tarID, $miRID, $Len, $s, $e, $mer, $len, $st, $en, $st_mer, $end_mer) = split('_', $Head); # locations in UTR coordinates
    my $cmd = "echo $seq | RNAplfold -W $W -L $L -u $u"; # output in plfold_lunp by default
    system($cmd);

    # load the probability matrix from the file
    open(LF, "<plfold_lunp") or die("cannot open file error: $!");
    local $/ = "\n";
    my $line = <LF>; # 1st header line
    $line = <LF>; # 2nd header line
    my($i, @array) = (0);
    while(<LF>){ # array begin on 3rd line
      $array[$i++] = [split("\t+")];
    }
    close LF;
    local $/ = '>';

    # extract the probability that the match site is unpaired 
    # row corresponds to the position, i of nucleotide in the sequence
    # column corresponds to the length, L of the sequence between [i-L+1 .. i]
    my @arr = @{$array[$end_mer - $s]}; # list of probabilities corresponding to the last position in the mer
    my $Pr_unpaired = $arr[$len]; # column number is the length of the mer     				# change this line of code -- avg. prob. over the match side using a sliding window
    my $R = 8.314; # gas constant J/(mol*K)
    my $T = 37 + 273.15; # Kelvin
    print "$Head\t", $R * $T * log($Pr_unpaired), "\n"; # base e
  
  }

  local $/ = "\n";
  close IN;

}

# For each mer in the list @mers extract the neighboring sequences 
# of length l_offset on both sides of the match in the UTR.
sub print_extd_sequences_in_fasta_format{
  
  my($ref_mers, $len_mer, $len_exd, $ref_UTR, $tarID, $miRID, $miR) = @_;  
  my @mers = @$ref_mers;
  my $UTR = $$ref_UTR;

  foreach my $mer(@mers){ # foreach mer in the seed

  # (a) Find start and end locations of the n-mer on the target
  my $comp_mer = complement($mer); # mer is from microRNA, therefore, complementary to the site
  my @locs = locs_match($UTR, $comp_mer); # coordinates of the match on the UTR

  # (b) Get the neighborhood local sequence
  if($#locs != -1){ # check non-empty

    # extend the locations and extract the sequences at the extended locations
    my($ref_offsets, $ref_lengths) = extended_locs(\@locs, $len_exd); # coo. on the UTR
    my @ext_sites = get_sites(\$UTR, $ref_offsets, $ref_lengths); 

    # Store the coordinates of the extended sequences in a header 
    my $i = 0; 
    foreach my $ext_site(@ext_sites){
      my($start, $end) = split('_', $locs[$i]); # coordinates of the match in the UTR
      my $Head = ">$tarID\_$miRID\_$$ref_lengths[$i]\_" # length of extended sequence
               ."$$ref_offsets[$i]\_".($$ref_offsets[$i] + $$ref_lengths[$i] - 1) # coordinates of the extd.seq. in UTR
               ."_$mer\_$len_mer\_1_$len_mer\_" # 0-coordinates of the seed(2-7) in the miR
               .$start."\_".$end; # .($start - $$ref_offsets[$i])."\_".($end - $$ref_offsets[$i++]); # coordinates of the mer in local seq.
		$i++;		

      if($miR ne ''){

        print "$Head\n$ext_site\&", scalar reverse($miR),"\n"; # join the flipiped-miR 
   
      } else{
   
        print "$Head\n$ext_site\n";
   
      } 

   }
  }
 }
}


# check perfect pairing at the matched sites and print the imperfect matched sites
sub print_imperfect_match_sites{

  my $fname = $_[0];

  open(FH, "<$fname") or die("cannot open file error: $!");
  open(FO, ">$fname.npp") or die("cannot open file error: $!");
  
  local $/ = '>';
  getc(FH);

  # Check the secondary structure for perfect pairing at the matched site
  while(<FH>){

    my($Head, $nseq, $sstr) = split("\n");
    my($tarID, $miRID, $L, $s, $e, $mer, $len, $st, $en, $start, $end) = split('_', $Head);

    if(!perfect_pair(substr($sstr, $start, $end - $start + 1))){

       print FO ">$Head\n$nseq\n$sstr\n";
    }
  
  }      
  close FH;
  close FO;

}


sub perfect_pair{

  my $str = $_[0];

  if($str eq '(((('){
    return 1;
  } else{
    return 0;
  }

}


sub print_str_file{

  my $str_file = $_[0];
  # extract and print secondary structure of the matches
  open(SF, "<$str_file") or die "cannot open file error: $!";
  local $/ = '>';
  getc(SF);
  while(<SF>){
    chomp();
    print ">$_";
  }
  close SF;

}


sub print_strfileTotext{

  my $fa_file = $_[0];
  local $/ = '>';
  open(FA, "<$fa_file") or die "cannot open file error: $!";
  getc(FA);
  while(<FA>){      
    chomp;
    /(.*)\s+(.*)\s+(.*)\s+\((.*)\)\s+/; #/^([^\n]+)\n([AUGCT]+)\n([(.)]+).\((.*)\)\n/i;
    print "$1\t$2\t$3\t$4\n";
  }
  close FA;

}


sub get_sites { # get sites on the target

  my($ref_lseq, $ref_offsets, $ref_lengths) = @_;

  my(@ext_sites);
  my $N = length($$ref_lseq);
  my $i = 0;

  foreach my $offset(@$ref_offsets){
  
    if($offset >= 0 && ($offset + $$ref_lengths[$i]) < $N){# handle exception if above extremes
      my $ext_site = substr($$ref_lseq, $offset, $$ref_lengths[$i++]);
      push @ext_sites, $ext_site;
    }
  }

  return @ext_sites;

}


sub extended_locs{ # compute the coordinates after extension

  my($ref_locs, $len_ext) = @_;

  my(@offsets, @lengths);

  foreach(@$ref_locs){

    my($s, $e) = split("_");
    my($offset, $length) = ($s - $len_ext, ($e - $s + 1) + 2 * $len_ext); #

    push @offsets, $offset;
    push @lengths, $length;
    
  }

  return(\@offsets, \@lengths);

}


sub print_locs_all_mers_in_target{

  my($longseq, $seed, $len_mer) = @_;
  my @mers = get_mers($seed, $len_mer);

  foreach my $mer(@mers){

    my $comp_mer = complement($mer);
    my @locs = locs_match($longseq, $comp_mer);
   
    print "$longseq\t$seed\t$len_mer\t$mer\t", join("\n$longseq\t$seed\t$len_mer\t$mer\t", @locs), "\n";

  }

}


sub get_mers {
  
  my($seed, $len_mer) = @_;
  my(@mers,$i);

  while(my $mer = substr($seed, $i++, $len_mer)){

    if(length($mer) == $len_mer){
      push @mers, $mer;
    }
  }

  return @mers;

}


sub complement {# (i) complement the seed: A <-> U, G <-> C
  
  my($pattern) = @_;
  my %COMPLEMENT = ( 'A' => 'T', # UTRs have 'T's
  	  	     'U' => 'A',
	  	     'G' => 'C',
	  	     'C' => 'G',
	  	     'a' => 't',
	  	     'u' => 'a',
	  	     'g' => 'c',
	  	     'c' => 'g' );
  my $L = length($pattern);
  my($c, $comp_pattern) = (undef, undef);

  foreach my $i(0 .. $L-1){
    
    $c = substr($pattern, $i, 1);
    $comp_pattern .= $COMPLEMENT{$c};
  
  }

  return $comp_pattern;

}


sub locs_match {# (ii) match all occurences of the seed to the long sequence; return locations

  my($longseq, $pattern) = @_;
  my @locs;
 
  while ($longseq =~ /($pattern)/gi){ # do not use $_, has nothing
  
    my $start = pos($longseq) - length($1); # position of the current match in the sequence
    my $end = $start + length($1) - 1;

    push @locs, "$start\_$end";
    # push @locs, "$1\t$start\t$end"; # save match
  
  }

  return(@locs);

}


sub find_seq {

  my($recID, $database) = @_;
  my @seqs = ();

  local $/ = '>';

  open(IN, "<$database") or die("cannot open file error: $!");
  getc(IN);
  while(<IN>){ # returns the sequence of the first match
   
    if(/$recID/){
      chomp;
      /(\S+)\n+([AUGCT]+)\n/i;
      push @seqs, $2;

    }  

  }     
 
  close IN;
  return @seqs;
}
 

sub isempty {

  if(${$_[0]} eq '' || ${$_[1]} eq '') {
  
    return 1;
  
  } else {
    
    return 0;
  }

}
