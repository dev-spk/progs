#!/usr/bin/env bash
#!/usr/bin/awk

# Input FASTA files/Output TEXT Files
miRs=$1 # miRs ; # not get shift to work
UTRs=$2 # targets
CDSFile=$3 # CDS portion of the genes necessary for targetThermo
#ResultFile=shift # all predictors use file; open in 'w' mode 
#TThermoSelFile=shift # optional

# Home directory
Home="$HOME/tarprediction"

species="human"

# Constant for RNAhybrid
case $species in 
	human) UTRtaxfi="3utr_human" taxID="9606";;
	mouse) UTRtaxfi="3utr_mouse" taxID="10090";;
#	fish) UTRtaxfi="3utr_fish" taxID="7955";; # not found in tarscan/UTR_sequences.txt
#	worm) UTRtaxfi="3utr_worm" taxID="6239";;
#	fly) UTRtaxfi="3utr_fly" taxID="7227";;
	*) echo -n "Species name, not found !!! Select from human | mouse | fish | worm";;
esac


# Database files (fix these !!)
UTRalnFile="$Home/targetscan/conserved/UTRaln.txt" # downloaded, created 2012
# Write the temporary alignment file
echo "$(grep \> $UTRs | awk '{print substr($1,2)}' >list_UTRs.txt)" # use temp files
echo "$(grep -f list_UTRs.txt $UTRalnFile >UTRaln_list.txt)" # use temp files

UTRBase="$Home/TargetMiner/hg18_3utr.txt" # update; if target not in file, TMiner writes out NOTHING !!! 
#miRBase="$HOME/bin/workonmiRBase/mature.fa" # for Target Miner


# Absolute path to the Predictors
tScanCons="$Home/targetscan/conserved/targetscan_60.pl"
tScanCont="$Home/targetscan/contextscores/targetscan_60_context_scores.pl"
targetSpy="$Home/targetSpy/bin/TargetSpy"
targetThermo="$Home/targetThermo/runtargetprediction.pl"
miranda=$(which miranda) # miranda is in the PATH
rnahybrid=$(which RNAhybrid)
targetMiner="$Home/TargetMiner/TargetMiner"
svmicro="$Home/SVMicrO/svmicro.pl"

if [[ ! -r $miRs && ! -r $UTRs && ! -r $CDSFile ]] # how about double brackets [[expression]]: conditional expression; like [[expression]] && echo "" && exit 1
then
	echo 'the input file(s) doesnot exist or check read/write permissions'
	exit 1
fi

if [[ ! -x $tScanCons && ! -x $tScanCont && ! -x $targetSpy && ! -x $targetThermo && ! -x $miranda && ! -x $rnahybrid && ! -x $targetMiner && ! -x $svmicro ]]
then
        echo "the target file(s) doesn't exist"
        exit 1
fi

#**** Create temporary files necessary to store single records ****
#****************************************************************** 
ResultFile=$(mktemp --tmpdir=tmp/ --suffix=.result) # givin. absolute path to TMiner gives Error: Cannot write to File
OutFile=$(mktemp --tmpdir=$Home/tmp/ --suffix=.out)
#metaFile=$(mktemp --tmpdir=$Home/ --suffix=.meta)

#set +C

Headline="miRID\tTarGeneID\tTSpy-score\tTThermo-score\tMiranda-score\tRNAhyb-score\tTMiner-score\tSVMicro-score\tmiRFamID\tmiRSeq\tmiRseed\tTarSeq"
echo -e "$Headline" >predictions.meta

DONEo=false
{ read -N 1 # first character is '>'
until $DONEo
do
      read -r -d '>' miRID FamID miRSeq || DONEo=true # $miRBase
    
      miRSeq="$(echo -e "${miRSeq}" | tr -d '[[:space:]]')"

      #**** Create temporary files necessary to store single records ****
      #******************************************************************
      # Write the miR to a fasta file
      miR1=$(mktemp --tmpdir=$Home/tmp/ --suffix=.fa) # create in /tmp
        echo -e '>'$miRID'\n'$miRSeq >$miR1 # recognize \newline; more safe than -e "$miRID"
      # Write additional input files that go in various other formats
      miRmature1=$(mktemp --tmpdir=$Home/tmp/ --suffix=.txt)
        echo -e $FamID'\t'$taxID'\t'$miRID'\t'$miRSeq >$miRmature1
      miRseed1=$(mktemp --tmpdir=$Home/tmp/ --suffix=.txt)
        seed=${miRSeq:1:7} # skip 1 nuc. (using the offset)
        echo -e $FamID'\t'$seed'\t'$taxID >$miRseed1
      miR1_TM=$(mktemp --tmpdir=$Home/tmp/ --suffix=.fa) # TargetMiner not function well w/o this extra line
        echo -e '>'$miRID'\t'$FamID'\n'$miRSeq'\n>' >$miR1_TM # second tab-seperated field must 

      
      echo -e "the micro RNA file has\n$(cat $miR1)\n"

      DONEi=false
      { read -N 1 # first character is '>'
      until $DONEi
      do	
	    read -r -d '>' refseqID tarSeq || DONEi=true
	    
	    tarSeq="$(echo -e "${tarSeq}" | tr -d '[[:space:]]')"
	        
	    #**** Create temporary files necessary to store single records ****
	    #******************************************************************
	    # Write the UTR to a fasta file	
	    UTR1=$(mktemp --tmpdir=$Home/tmp/ --suffix=.fa)
	      echo -e ">$refseqID\n$tarSeq" >$UTR1 
	    # Write additional input files that go in various other formats
            UTR1_TM=$(mktemp --tmpdir=$Home/tmp/ --suffix=.fa)
              echo -e ">something $refseqID\n$tarSeq\n>" >$UTR1_TM # TM not function well w/o this extra line
	    experivalid1=$(mktemp --tmpdir=$Home/tmp/ --suffix=.txt)	    
	      echo -e ">$miRID\t$refseqID\n>" >$experivalid1
	   
	    echo -e "processing for the miR:$miRID and target:$refseqID\n"
	    echo -e "seed sequence is $seed, for miR:$miRID, family:$FamID, taxonomy:$taxID\n"
	    echo -e "the UTR is \n$(cat $UTR1)\n"
            
	    #************ Provide the Options for the Predictors **************
	    #******************************************************************
	    optsTSpy="-microRNAs $miR1 -transcripts $UTR1 -result $ResultFile.gz" # can give UTRBase also
	    optsTThermo="-miFile $miR1 -UTRFile $UTR1 -CDSFile $CDSFile -outFile $ResultFile" # can give UTRBase; -SelUTRFile $TThermoSelFile    
	    optsmiranda="$miR1 $UTR1 -out $ResultFile" # can give UTRBase
	    optsrnahyb="-s $UTRtaxfi -t $UTR1 -q $miR1" # can give UTRBase

	    # TargetScan takes 3 and 4 column format types of the input files
	    optsTScan1="$miRseed1 UTRaln_list.txt $OutFile"
	    optsTScan2="$miRmature1 UTRaln_list.txt $OutFile $ResultFile"
	    
	    # TargetMiner has two column format of the test file
	    optsTMiner="-test $experivalid1 -3utr $UTR1_TM -mir $miR1_TM" # don't forget this order; fast if given UTR1_TM

	    # SVmicro has different input parameters
	    optsSVmicro="-m $miRSeq -u $refseqID"
: <<'END'	
	    #******************** Call the Predictors ************************
	    #*****************************************************************
	    echo "===================== 1. Running TargetScan ======================="
	      echo "Command: $tScanCons $optsTScan1" 
              echo "$($tScanCons $optsTScan1)"  # conserved
	    echo "Command: $tScanCont $optsTScan2" # context
            echo "$($tScanCont $optsTScan2)"
	    echo -e "The prediction is:\n$(cat $OutFile)\n"
	    echo -e "The prediction is:\n$(cat $ResultFile)\n"
	    # TScan_parser here
	    $(cat /dev/null >$ResultFile) # empty essential
END
	    echo "===================== 2. Running TargetSpy ========================"
	    echo "Command: $targetSpy $optsTSpy"
	    echo "$($targetSpy $optsTSpy)"
	    #echo -e "The prediction is:\n$(cat $ResultFile)\n"
	    echo -e "The prediction is:\n$(zcat $ResultFile.gz)\n"
            score2=$(zcat $ResultFile.gz | awk 'NR==2 {if($NF=="."){printf "NEG"} else{printf $NF}}') # TSpy_parser here
#	    $(zcat /dev/null >$ResultFile.gz) # empty essential; some error
	    
	    echo "===================== 3. Running TargetThermo ====================="
	    echo "Command: perl $targetThermo $optsTThermo"
	    echo "$(perl $targetThermo $optsTThermo)"
	    echo -e "The prediction is:\n$(cat $ResultFile)\n"
	    score3=$(sed '1,1d' $ResultFile | awk '{if($3!=""){printf $3} else{printf "NA"}}') # TT_parser here 
	    $(cat /dev/null >$ResultFile) # empty essential
	    
	    echo "===================== 4. Running miRanda =========================="
	    echo "Command: $miranda $optsmiranda"
	    echo "$($miranda $optsmiranda)"
	    echo -e "The prediction is:\n$(cat $ResultFile)\n"
	    score4=$(awk '/>>/ {printf $3}' $ResultFile) # miRanda_parser here
	    if [[ $score4 == "" ]]
	    then 
		score4="NEG" 
	    fi
	    $(cat /dev/null >$ResultFile) # empty essential
	    
	    echo "===================== 5. Running RNAhybrid ========================"
	    echo "Command: $rnahybrid $optsrnahyb"
	    echo "$($rnahybrid $optsrnahyb >$ResultFile)"
	    score5=$(awk '/target too long/ {printf "NA"}' $ResultFile) # RHyb_parser here 
	    if [[ $score5 != "NA"  ]]
	    then 
	    	score5="POS"
	    fi
	    $(cat /dev/null >$ResultFile) # empty essential

	    echo "===================== 6. Running TargetMiner ======================"
	    cd "$Home/TargetMiner" # TM looks for SVMpackage in the current directory
	    echo "Command: $targetMiner $optsTMiner"
	    echo "$($targetMiner $optsTMiner)"
            #echo -e "The prediction is in the \'output\' file\n"
	    score6=$(cat $Home/TargetMiner/output) # TM_parser here; result in output file
	    if [[ $score6 == "" ]]
	    then
	    	score6="NA"
		echo "Error! Update the targets file for TargetMiner: $UTRBase"
	    fi	
	    cd "$Home"
	    
	    echo "===================== 7. Running SVMicro =========================="
	    echo "Command: perl $svmicro $optsSVmicro"
	    echo "$(perl $svmicro $optsSVmicro >$ResultFile)"
	    echo -e "The prediction is:\n$(cat $ResultFile)\n"
	    score7=$(awk '/UTR score:/ {printf $3}' $ResultFile) # SVMicro_parse here
	    
	    echo -e "\nThe scores for $miRID and $refseqID are \nscore2=$score2\nscore3=$score3\nscore4=$score4\nscore5=$score5\nscore6=$score6\nscore7=$score7\n"	    
	    
	    record="\n$miRID\t$refseqID\t$score2\t$score3\t$score4\t$score5\t$score6\t$score7\t$FamID\t$miRSeq\t$seed\t$tarSeq"
	    echo -e "$record" >>predictions.meta

            $(cat /dev/null >$ResultFile) # empty essential, targetSpy won't write the resultFile in the case of negative predictions 
	    rm -f "$UTR1 $experivalid1 $OutFile" # donot delete the results file until all done
done; } <$UTRs

rm -f "$miR1 $miRmature1 $miRseed1"

done; } <$miRs

rm "$ResultFile $ResultFile.gz" # all done

rm "tmp/tmp.*"
