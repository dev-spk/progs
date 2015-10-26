#!/usr/bin/env bash
#!/usr/bin/awk

# Run the predictors for each target interaction; pass the 2 col. interaction text file, allmiRs.fa and allTars.fa 
 
interacts=$1
allmiRs=$2
allTars=$3

cat /dev/null >allpredictions.meta
cat /dev/null >allpredictions.log

DONE=false
{
until $DONE
do 
   read -r tarID miRID || DONE=true
   awk "BEGIN{RS=\">\"} FNR>1 && i==0 && /$miRID/ {printf \">\"\$0; i++}" $allmiRs >miR1.fa
   awk "BEGIN{RS=\">\"} FNR>1 && i==0 && /$tarID/ {printf \">\"\$0; i++}" $allTars >Tar1.fa
   ./tarpred.sh miR1.fa Tar1.fa testCDS.fa &>>allpredictions.log # output in predictions.meta (default)
   cat predictions.meta >>allpredictions.meta
#   rm -f miR1.fa Tar1.fa
done; }<$interacts
