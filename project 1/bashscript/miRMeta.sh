#!/bin/bash

#   (I) Generate metadata 
#  (II) Clean and transform the data; Split the dataset into two files: pos.,neg. 
# (III) Write the f-fold crossvalidation sets - extract pos/f records randomly without replacement, do so for neg. file, concatenate both the files; repeat f-times
#  (IV)	Generate f number of Models 	
#   (V) Predict on the f models and write the predictions to a line  

# Dataset-1

#I. Generate data
#perl ~/perlprogs/eight ~/bin/mirna_Hsapiens_valid.fasta POS #output in *.modify.consensus
#perl ~/perlprogs/eight ~/bin/mirna_Hsapiens_remaining.fasta POS
#perl ~/perlprogs/eight ~/bin/Rfam.fasta.Homosapiens.nonmirna NEG

#cat ~/bin/mirna_Hsapiens_valid.fasta.modify.consensus > ~/bin/Dataset1.consensus
#sed -e '1d' ~/bin/mirna_Hsapiens_remaining.fasta.modify.consensus >> ~/bin/Dataset1.consensus
#sed -e '1d' ~/bin/Rfam.fasta.Homosapiens.nonmirna.modify.consensus >> ~/bin/Dataset1.consensus


# Dataset-3

#I. Generate data
#perl ~/perlprogs/eight ~/bin/pseudo_miRNAs_rand2000.fa NEG

#cat ~/bin/mirna_Hsapiens_valid.fasta.modify.consensus > ~/bin/Dataset3.consensus
#sed -e '1d' ~/bin/mirna_Hsapiens_remaining.fasta.modify.consensus >> ~/bin/Dataset3.consensus
#sed -e '1d' ~/bin/pseudo_miRNAs_rand2000.fa.modify.consensus >> ~/bin/Dataset3.consensus



cd ~/bin/Crossvalidatsets2level/



echo $'Began Processing Dataset-1 **********************************************\n'

#II. Clean
#R CMD BATCH --no-save --no-restore '--args  transform="NA0" infilename="~/bin/Dataset1.consensus" outfolder="~/bin/Crossvalidatsets2level/"' ~/perlprogs/CleanExploreTransform.R

#III. Split the dataset
#perl ~/bin/Crossvalidatsets2level/cross-validate2level.pl ~/bin/Crossvalidatsets2level/INPUTS-D-1.fi

#IV. Generate Models and Accuracies
#R CMD BATCH --no-save --no-restore '--args datasetname="~/bin/Crossvalidatsets2level/Dataset1" pcamethod="NA0" basename="~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0"' ~/perlprogs/crossvalidateall2level.R 

#V. Run predictions on Dataset-1
#R CMD BATCH --no-save --no-restore ~/perlprogs/runpredictions-D1.R



echo $'Began Processing Dataset-3 **********************************************\n'

#II. Clean
#R CMD BATCH --no-save --no-restore '--args  transform="NA0" infilename="~/bin/Dataset3.consensus" outfolder="~/bin/Crossvalidatsets2level/"' ~/perlprogs/CleanExploreTransform.R

#III. Split the dataset
#perl ~/bin/Crossvalidatsets2level/cross-validate2level.pl ~/bin/Crossvalidatsets2level/INPUTS-D-3.fi

#IV. Generate Models and Accuracies
#R CMD BATCH --no-save --no-restore '--args datasetname="~/bin/Crossvalidatsets2level/Dataset3" pcamethod="NA0" basename="~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0"' ~/perlprogs/crossvalidateall2level.R

#V. Run predictions on Dataset-3
#R CMD BATCH --no-save --no-restore ~/perlprogs/runpredictions-D3.R


