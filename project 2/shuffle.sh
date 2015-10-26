#!/bin/bash
#!/usr/bin/awk

# Submit each miR sequence available in a file (on each new line) to the ushuffle command

SEQs=$1

Done=false
{
read -N 1
until $Done 
do
read -r -d '>' miRID FamID seq || Done=true
#echo -e "miRID is $miRID"
/home/complab/tarprediction/ushuffle/main.exe -n 10 -k 2 -seed 1 -s $seq | grep -v $seq | sort -u | awk "{z++; print \">random_$miRID""_\"z\"\\n\"\$0}"
done; }<$SEQs
