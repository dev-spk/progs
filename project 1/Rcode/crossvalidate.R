#!/usr/bin/Rscript
# Perform 5-fold cross-validation of the nnet classifier using the subsets that were split with the crossvalidate.pl script. These text files have a basename-0-1.data convention for the training set
library(nnet)
library(stats)

option <- commandArgs(trailingOnly = TRUE)

ContinTab <- function(true, pred) {
         true <- max.col(true)
         cres <- max.col(pred)
         return(table(true, cres))
     }

mytrset <- trainset[,1:P]
mytset <- testset[, 1:P]
k <- 1
accuracy <- numeric(20)
for(i in 0:4){
   
for(j in 0:4){

if(i != j){
basename <- paste(option, "-", i, "-", j, sep="")
trfname <- paste(basename, ".data", sep="")
tfname <- paste(basename, ".test", sep="")
print(trfname)
trainset <- read.table(toString(trfname))
testset <- read.table(toString(tfname))

trainlabels <- class.ind(trainset[, 6])
testlabels <- class.ind(testset[, 6])

ANN <- nnet(trainset[, 1:5], trainlabels, size = 6, skip=TRUE, rang = 0.1, decay=5e-04, maxit=2000, softmax=FALSE, entropy=FALSE, linout=FALSE, trace=TRUE, Hess=FALSE)

Tab <- ContinTab(testlabels, predict(ANN, testset[,1:5]))
accuracy[k] <- sum(diag(Tab))/sum(rowSums(Tab))
k <- k+1
}
}
}
print(accuracy)


