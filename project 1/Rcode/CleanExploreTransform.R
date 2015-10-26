#!/usr/bin/Rscript

# clean(reset NA to 0, apply unique), explore and transform (method=NA0, PCA, BPCA) a dataset in *.consensus file
# The format of the .consensus file is
# MIReNA	MiPred	TripSVM	ProMiR	miRPara
# hsa-let-7a-1	YES	82.3	1		NA	0	POS
# hsa-let-7a-3	YES	82.5	1		1.832404007351351	0.801454	POS
# hsa-let-7d	YES	79.1	1		NA	0.86916	POS
# hsa-CDS	NO	77.4	1		0.4213427218279167	0.08001		NEG

# invoke: R CMD BATCH --no-save --no-restore '--args  transform="NA0" infilename="~/bin/Dataset3.consensus" outfolder="~/bin/Crossvalidatsets2level/"' CleanExploreTransform.R

#library(ROCR)
library(pcaMethods)

# infilename <- "~/bin/Dataset3.consensus"
# transform <- "NA0" # only NA0, BPCA, PCA, etc.
# outfolder <- "~/bin/Crossvalidatsets2levels/"
args <- commandArgs(TRUE) # return a list

for(i in 1:length(args)){
	eval(parse(text=args[[i]]))
}

mynoncodrnas <- read.table(toString(infilename), header=TRUE) # Pass the consensus file containing pos. and neg. cases: mirnapseudomirna.consensus, mirnaNonmirna.consensus_old, trainingset2.consensus
basename <- strsplit(basename(infilename), "[.]")[[1]][1] # split only at '.'

mynoncodrnas <- unique(mynoncodrnas)

# Threshold values of the predictors
ThresmiPred <- 0 # YES when pred. prob. > 0
ThresProMiR <- 0.017
ThresmiRPara <- 0.80

attach(mynoncodrnas)
MiPred_Th = sapply(MiPred, function(x) {if(x > ThresmiPred) {x = 'POS'} else {x = 'NEG'}})
TripSVM_m <- sapply(TripSVM, function(x) {if(is.na(x)) {x <- 'NEG'} else if(x==-1) {x <- 'NEG'}else if(x==1) {x <- 'POS'} else if("-" %in% x) {x <- 'NEG'} else {x <- 'POS'}})
ProMiR_Th = sapply(ProMiR, function(x) {if(is.na(x)) {x <- 'NEG'} else if(x >= ThresProMiR) {x = 'POS'} else {x = 'NEG'}})
miRPara_Th = sapply(miRPara, function(x) {if(x >= ThresmiRPara) {x = 'POS'} else {x = 'NEG'}})

myrnas <- mynoncodrnas
rm(mynoncodrnas)

print("Table for MIReNA")
tab <- with(myrnas, table(MIReNA, Label))
print("Accuracy is")
(tab[1,1]+tab[2,2])/(tab[1,1]+tab[1,2]+tab[2,1]+tab[2,2])*100
print("Table for mipred")
tab <- with(myrnas, table(MiPred_Th, Label))
print("Accuracy is")
(tab[1,1]+tab[2,2])/(tab[1,1]+tab[1,2]+tab[2,1]+tab[2,2])*100
print("Table for TripSVM")
tab <- with(myrnas, table(TripSVM_m, Label))
print("Accuracy is")
(tab[1,1]+tab[2,2])/(tab[1,1]+tab[1,2]+tab[2,1]+tab[2,2])*100
print("Table for miRPara")
tab <- with(myrnas, table(miRPara_Th, Label))
print("Accuracy is")
(tab[1,1]+tab[2,2])/(tab[1,1]+tab[1,2]+tab[2,1]+tab[2,2])*100
print("Table for ProMiR")
tab <- with(myrnas, table(ProMiR_Th, Label))
print("Accuracy is")
(tab[1,1]+tab[2,2])/(tab[1,1]+tab[1,2]+tab[2,1]+tab[2,2])*100

# Scale the values to the interval [-1,1]
attach(myrnas)
myrnas$MIReNA <- sapply(MIReNA, function(x) {if(x == 'YES') {x <- 1} else {x <- -1}})
myrnas$MiPred <- MiPred/100*2 - 1
myrnas$TripSVM <- sapply(TripSVM, function(x) {if(is.na(x)) {x <- 0} else if(x==-1) {x <- -1}else if(x==1) {x <- 1} else if("-" %in% x) {x <- -1} else {x <- 1}}) # change only the NAs; choose x <- NA or 1;values of multiple detections are in combined form e.g., 1-111-1, so treat as neg. if the value had a minus "-"
maxProMiR = max(myrnas$ProMiR, na.rm = TRUE)
myrnas$ProMiR = sapply(ProMiR, function(x) {if(is.na(x)){x <- 0} else if(x <= ThresProMiR) {x = x/ThresProMiR - 1} else {x = (x - ThresProMiR)/maxProMiR}}) # max value in
myrnas$miRPara <- miRPara*2 - 1
myrnas <- na.omit(myrnas) # check NA's

# Perform principal component analysis with normalization
#pr.out = prcomp(myrnas[,1:5], scale=TRUE)

# Transform the labels to numeric; format of the input to the ANN (see $WORK/CrossvalidatuniqNA0 on Circe)
myrnas$Label = sapply(myrnas$Label, function(x) {if(x=='POS') {x=1} else {x=-1}}) # transform labels

pcatab = myrnas; # initialize

if(transform %in% c("PCA", "BPCA")) {
# standard normalize
myrnas <- transform(myrnas, MIReNA=(MIReNA-mean(MIReNA))/sd(MIReNA), MiPred=(MiPred-mean(MiPred))/sd(MiPred), TripSVM=(TripSVM-mean(TripSVM))/sd(TripSVM), ProMiR=(ProMiR-mean(ProMiR))/sd(ProMiR), miRPara=(miRPara-mean(miRPara))/sd(miRPara))
# perform PCA or BPCA
pr.out = pca(myrnas[, 1:5], method = tolower(transform), nPcs=5, maxSteps=500)
pcatab = data.frame(pr.out@scores, Label=myrnas$Label) # for pcaMethods::pca()
}
#pcatab = cbind(pr.out$x, Label=myrnas$Label) # for prcomp()
rm(myrnas)

poscases = pcatab[pcatab$Label == 1,]
negcases = pcatab[pcatab$Label == -1,]

if(TRUE) { # These files useful to write out the x-fold crossvalidation sets. Use with crossvalidateall2level.R
posfname <- paste(outfolder, basename, "-poscases-", transform, ".data", sep="")
negfname <- paste(outfolder, basename, "-negcases-", transform, ".data", sep="")

write.table(poscases, file=posfname, quote=FALSE, sep = "\t", row.names=TRUE, col.names=TRUE) # mirnauniqNA0(Dataset-1), mirnauniqNA0app, mirnapsuniqNA0(pseudo Dataset-3)
write.table(negcases, file=negfname, quote=FALSE, sep="\t", row.names=TRUE, col.names=TRUE) # psmirnauniqNA0(D-3)

rdatafname <- paste(outfolder, basename, "-", transform, ".RData", sep="")
save(poscases, negcases, file=rdatafname)

}


