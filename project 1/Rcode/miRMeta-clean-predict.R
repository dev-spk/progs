#!/usr/bin/Rscript

# At the prediction stage of the miR-Meta predictor
# clean(reset NA to 0, apply unique), a dataset in *.consensus file
# The format of the .consensus file is
# MIReNA	MiPred	TripSVM	ProMiR	miRPara
# hsa-let-7a-1	YES	82.3	1		NA	0	
# hsa-let-7a-3	YES	82.5	1		1.832404007351351	0.801454
# hsa-let-7d	YES	79.1	1		NA	0.86916	
# hsa-CDS	NO	77.4	1		0.4213427218279167	0.08001

# invoke: R CMD BATCH --no-save --no-restore '--args  transform="NA0" infilename="~/bin/Dataset3.consensus" outfname="~/bin/miRMeta.predictions" outfolder="~/bin/Crossvalidatsets2level/"' miRMeta-clean-predict.R

library(ROCR)
library(pcaMethods)
library(nnet)

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

# Scale the values to the interval [-1,1]
attach(myrnas)
myrnas$MIReNA <- sapply(MIReNA, function(x) {if(x == 'YES') {x <- 1} else {x <- -1}})
myrnas$MiPred <- MiPred/100*2 - 1
myrnas$TripSVM <- sapply(TripSVM, function(x) {if(is.na(x)) {x <- 0} else if(x==-1) {x <- -1}else if(x==1) {x <- 1} else if("-" %in% x) {x <- -1} else {x <- 1}}) # change only the NAs; choose x <- NA or 1;values of multiple detections are in combined form e.g., 1-111-1, so treat as neg. if the value had a minus "-"
maxProMiR = max(myrnas$ProMiR, na.rm = TRUE)
myrnas$ProMiR = sapply(ProMiR, function(x) {if(is.na(x)){x <- 0} else if(x <= ThresProMiR) {x = x/ThresProMiR - 1} else {x = (x - ThresProMiR)/maxProMiR}}) # max value in
myrnas$miRPara <- miRPara*2 - 1
#myrnas <- na.omit(myrnas) # check NA's

# standard normalize
myrnas <- transform(myrnas, MIReNA=(MIReNA-mean(MIReNA))/sd(MIReNA), MiPred=(MiPred-mean(MiPred))/sd(MiPred), TripSVM=(TripSVM-mean(TripSVM))/sd(TripSVM), ProMiR=(ProMiR-mean(ProMiR))/sd(ProMiR), miRPara=(miRPara-mean(miRPara))/sd(miRPara))

pcatab = myrnas; # initialize

if(transform %in% c("PCA", "BPCA")) {
# perform PCA or BPCA
pr.out = pca(myrnas[, 1:5], method = tolower(transform), nPcs=5, maxSteps=500)
pcatab = data.frame(pr.out@scores) # for pcaMethods::pca()
}
rm(myrnas)


recs <- pcatab

# 
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-0-P5-H8.RData", sep=""))
model1 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-1-P5-H8.RData", sep=""))
model2 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-2-P5-H8.RData", sep=""))
model3 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-3-P5-H8.RData", sep=""))
model4 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-4-P5-H8.RData", sep=""))
model5 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-5-P5-H8.RData", sep=""))
model6 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-6-P5-H8.RData", sep=""))
model7 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-7-P5-H8.RData", sep=""))
model8 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-8-P5-H8.RData", sep=""))
model9 <- ANN
load(paste(outfolder, "Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-9-P5-H8.RData", sep=""))
model10 <- ANN

head(recs)
head(predict(model1, recs[,1:P])[,2])

preds1 <- as.vector(predict(model1, recs[,1:P])[,2])
preds2 <- as.vector(predict(model2, recs[,1:P])[,2])
preds3 <- as.vector(predict(model3, recs[,1:P])[,2])
preds4 <- as.vector(predict(model4, recs[,1:P])[,2])
preds5 <- as.vector(predict(model5, recs[,1:P])[,2])
preds6 <- as.vector(predict(model6, recs[,1:P])[,2])
preds7 <- as.vector(predict(model7, recs[,1:P])[,2])
preds8 <- as.vector(predict(model8, recs[,1:P])[,2])
preds9 <- as.vector(predict(model9, recs[,1:P])[,2])
preds10 <- as.vector(predict(model10, recs[,1:P])[,2])

pred.table <- cbind(preds1, preds2, preds3, preds4, preds5, preds6, preds7, preds8, preds9, preds10)

avg = rowMeans(pred.table)
#
pred.table <- cbind(pred.table, avg)
pred.table <- data.frame(pred.table)

colnames(pred.table) = c("model1", "model2", "model3", "model4", "model5", "model6", "model7", "model8", "model9", "model10", "avg.score")
rownames(pred.table) = rownames(recs)

write.table(pred.table, file=outfname, row.names=TRUE, col.names=TRUE, sep="\t", quote=FALSE)
