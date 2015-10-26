#!/usr/bin/Rscript
#(Build Model) Construct ANN on the PCA transformation of the Dataset-3 (or Dataset-1) where the best choice of the combination of parameters: Num. principal vectors, Num. hidden nodes, Num. folds, is given by the Cross-validation results
# Regenerate the test set with 1/Num.Folds-Ths of the data and the remaining for the train set (without the use of crossvalidate.pl or Xvalidatennet2levelall.R)
# *.consensus must have both POS(~50%) and NEG(~50%) cases
# Save all the parameters to a *.RData file

# Run as: Rscript buildmodel.R ~/bin/mirnaNonmirna.consensus
library(nnet)
library(stats)
library(pcaMethods) # need only when "method=bpca" used

# Compute contingency table
ContingTab <- function(true, pred) {
         true <- max.col(true) # return indices of the two column matrix: (0,1)/(1,0)/(1,0)/(0,1)
         cres <- max.col(pred)
         return(table(true, cres))
}

# Cross-validation subfunction: nnet classify on a single splitted set, with a common base name and an index -0-1 etc.
Xvalidatennet <- function(trainset, testset, hidlay1siz, P){
        ncols <- ncol(trainset) # last col. is a label
        trainlabels <- class.ind(trainset[, ncols]) # write labels vector in two column format: e.g., '1' in col1 if label is '-1' and '0' in col2
        testlabels <- class.ind(testset[, ncols])
        ANN <- nnet(trainset[, 1:P], trainlabels, size=hidlay1siz, skip=TRUE, rang=0.1, decay=5e-04, maxit=2000)
        Tab <- ContingTab(testlabels, predict(ANN, testset[, 1:P]))
        accuracy <- sum(diag(Tab))/sum(rowSums(Tab))
#        ANNlist = list(ANN=ANN, contTab=Tab, accuracy=accuracy)
        return(ANN)
}


# Read the file w/ *.consensus extension
filename <- commandArgs(trailingOnly = TRUE)
myrnas <- read.table(toString(filename))

# Name the data frame columns
names(myrnas) = c("pred.MIReNA", "pred.MiPred", "pred.TripSVM", "pred.ProMiR", "pred.miRPara", "Label")


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
pred.ProMiR_Th = sapply(pred.ProMiR, function(x) {if(is.na(x)) {x <- NA} else if(x >= ThresProMiR) {x = 'POS'} else {x = 'NEG'}})
# miRPara
ThresmiRPara <- 0.80
pred.miRPara_Th = sapply(pred.miRPara, function(x) {if(x >= ThresmiRPara) {x = 'POS'} else {x = 'NEG'}})


# ProMiR score is inverse of probabilities, could reach very large; compute it at model building 
maxProMiR = max(myrnas$pred.ProMiR, na.rm = TRUE)


# Reset NA to 0; Scale the values to the interval [-1, 1]
myrnas$pred.MIReNA <- sapply(pred.MIReNA, function(x) {if(x == 'YES') {x <- 1} else {x <- -1}})
myrnas$pred.MiPred <- pred.MiPred/100*2 - 1
myrnas$pred.TripSVM <- sapply(pred.TripSVM, function(x) {if(is.na(x)) {x <- 0} else if(x==-1) {x <- -1}else if(x==1) {x <- 1} else if("-" %in% x) {x <- -1} else {x <- 1}}) # change only the NAs; choose x <- NA or 1;values of multiple detections are in combined form e.g., 1-111-1, so treat as neg. if the value had a minus "-"
myrnas$pred.ProMiR = sapply(pred.ProMiR, function(x) {if(is.na(x)){x <- 0} else if(x <= ThresProMiR) {x = x/ThresProMiR - 1} else {x = (x - ThresProMiR)/maxProMiR}}) # max value in
myrnas$pred.miRPara <- pred.miRPara*2 - 1
# myrnas <- na.omit(myrnas) # to be sure before the PCA


# Perform principal component analysis with normalization
method <- "bpca"
# pr.out = prcomp(myrnas[,1:5], scale=TRUE)
pr.out = pca(myrnas[, 1:5], method = method, nPcs=5, maxSteps=500)

# Transform the labels: YES/NO to 1/-1
labels = sapply(myrnas$Label, function(x) {if(x=='POS') {x=1} else {x=-1}}) # transform labels


# Get Principal component scores for the dataset; Preserve Labels
#dataset = cbind(pr.out$x, Label=labels) # for prcomp() only

dataset = cbind(pr.out@scores, Label=labels)

dataset = data.frame(dataset)


# Best options 
NumPVs <- 4
NumHnodes <- 6
NumFolds <- 8

# random subsetting
NumCases <- nrow(dataset) 
seed <- 7765
set.seed(seed)
trIndices = sample(1:NumCases, size = round(NumCases*(NumFolds-1)/NumFolds), replace = FALSE)

# write the train and test sets
trSet <- dataset[trIndices,]
tsSet <- dataset[-trIndices,]

# Construct the ANN
ANNlist <- Xvalidatennet(trSet, tsSet, NumHnodes, NumPVs)

sampmeans = colMeans(myrnas[, -6])
sampsd = sapply(myrnas[, -6], sd)

recfilename <- paste(filename, seed, method, ".RData", sep="")
save(list=ls(), file=recfilename, ascii=TRUE)

