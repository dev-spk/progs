#!/usr/bin/Rscript
# (Run Predictions on the new set) Run the ANN on the PCA transformation of the Dataset-3 (or Dataset-1) where the best choice of the combination of parameters: Num. principal vectors, Num. hidden nodes, Num. folds, is given by the Cross-validation results (buildmodel.R and Xvalidateall2level.R)

library(nnet)
library(stats)


# load the model: ANN, Num.PVs, Num.H.nodes, NFolds, maxProMiR, etc
load("~/bin/mirnaNonmirna.consensus7765.RData")

# Read the file w/ *.consensus extension
filename <- commandArgs(trailingOnly = TRUE)
myrnas <- read.table(toString(filename))

# Name the data frame columns
names(myrnas) = c("pred.MIReNA", "pred.MiPred", "pred.TripSVM", "pred.ProMiR", "pred.miRPara")

# Threshold the predictions
attach(myrnas)
# MIReNA
# MiPred
ThresmiPred <- 0 # YES when pred. prob. > 0
pred.MiPred_Th = sapply(pred.MiPred, function(x) {if(x > ThresmiPred) {x = 'POS'} else {x = 'NEG'}})
# Tripsvm
pred.TripSVM_m <- sapply(pred.TripSVM, function(x) {if(is.na(x)) {x <- 'NA'} else if(x==-1) {x <- 'NEG'}else if(x==1) {x <- 'POS'} else if("-" %in% x) {x <- 'NEG'} else {x <- 'POS'}})
# ProMiR
ThresProMiR <- 0.017
pred.ProMiR_Th = sapply(pred.ProMiR, function(x) {if(is.na(x)) {x <- 'NA'} else if(x >= ThresProMiR) {x = 'POS'} else {x = 'NEG'}})
# miRPara
ThresmiRPara <- 0.80
pred.miRPara_Th = sapply(pred.miRPara, function(x) {if(x >= ThresmiRPara) {x = 'POS'} else {x = 'NEG'}})

# ProMiR score is inverse of probabilities, could reach very large; compute it at model building 
#maxProMiR = max(myrnas$pred.ProMiR, na.rm = TRUE)

# Reset NA to 0; Scale the values to the interval [-1, 1]
myrnas$pred.MIReNA <- sapply(pred.MIReNA, function(x) {if(x == 'YES') {x <- 1} else {x <- -1}})
myrnas$pred.MiPred <- pred.MiPred/100*2 - 1
myrnas$pred.TripSVM <- sapply(pred.TripSVM, function(x) {if(is.na(x)) {x <- 0} else if(x==-1) {x <- -1}else if(x==1) {x <- 1} else if("-" %in% x) {x <- -1} else {x <- 1}}) # change only the NAs; choose x <- NA or 1;values of multiple detections are in combined form e.g., 1-111-1, so treat as neg. if the value had a minus "-"
myrnas$pred.ProMiR = sapply(pred.ProMiR, function(x) {if(is.na(x)){x <- 0} else if(x <= ThresProMiR) {x = x/ThresProMiR - 1} else {x = (x - ThresProMiR)/maxProMiR}}) # max value in
myrnas$pred.miRPara <- pred.miRPara*2 - 1
myrnas <- na.omit(myrnas) # to be sure before the PCA


# Perform principal component analysis (w/o variance normalization)
meanMIReNA <- sampmeans[1]; meanMiPred <- sampmeans[2]; meanTripSVM <- sampmeans[3]; meanProMiR <- sampmeans[4]; meanmiRPara <- sampmeans[5]

sdMIReNA <- sampsd[1]; sdMiPred <- sampsd[2]; sdTripSVM <- sampsd[3]; sdProMiR <- sampsd[4]; sdmiRPara <- sampsd[5]
 
myrnas <- transform(myrnas, pred.MIReNA<-(pred.MIReNA-meanMIReNA)/sdMIReNA, pred.MiPred<-(pred.MiPred-meanMiPred)/sdMiPred, pred.TripSVM<-(pred.TripSVM-meanTripSVM)/sdTripSVM, pred.ProMiR<-(pred.ProMiR-meanProMiR)/sdProMiR, pred.miRPara<-(pred.miRPara-meanmiRPara)/sdmiRPara) 
dataset <- as.matrix(myrnas[,1:5]) %*% pr.out$rotation

# Get Principal component scores for the dataset
dataset = data.frame(dataset)

probabilities <- predict(ANNlist$ANN, dataset[, 1:NumPVs]) # in model.RData

predlabels <- sapply(max.col(probabilities), function(x){if(x==1)x<-'====> Prediction = NO' else x<-'====> Prediction = YES'})

myrnas <- cbind(myrnas, predlabels)

write.table(myrnas, filename, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
