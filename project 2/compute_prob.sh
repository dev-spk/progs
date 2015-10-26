#!/bin/bash

# For all the microRNA target relations, find the probability 
# that the change in the Gibbs free energy, in the step-wise 
# binding of microRNA to the target. 

# perl matchseed.pl tar3 miR3 4
interacts=$1
len_mer=4

cat /dev/null >alltmps.txt # all E_hybrid scores
cat /dev/null >alltmps.out # all E_open scores
cat /dev/null >tmp.txt  # empty .txt,.out files opened in append mode(see matchseed.pl)
cat /dev/null >tmp.out

DONE=false
{
until $DONE
do
read -r TarID miRID || { DONE=true; exit; }

perl ~/tarprediction/matchseed.pl $TarID $miRID $len_mer
cat tmp.txt >>alltmps.txt
cat tmp.out >>alltmps.out # comment if minimum as the next line
#sort -u -k2,2 -g tmp.out | tail -1 >>alltmps.out # uncomment to extract only the minimums
cat /dev/null >tmp.txt  # empty .txt,.out files opened in append mode(see matchseed.pl)
cat /dev/null >tmp.out
done; }<$interacts
