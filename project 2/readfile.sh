#!/bin/bash
# parse a fasta file

#tarID="NM_024674" # different from PERL, use $'string' instead
DONE=false
{ read -N 1 # treat the delim properly 
until $DONE
do 
read -r -d '>' miRID FamID Seq || DONE=true 
Seq="$(echo -e "${Seq}" | tr -d '[[:space:]]')"
echo -e "$FamID\t${Seq:1:7}\t9606" >>miRseed.txt
#SVMicrO/svmicro.pl -m "$Seq" -u "$tarID"
done; }<$1
