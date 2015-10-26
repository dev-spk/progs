#!/usr/bin/Rscript
# Perform 5-fold cross-validation of the nnet classifier using the subsets that were split with the crossvalidate.pl script. These text files have a basename-0-1.data convention for the training set
library(nnet)
library(stats)

# Compute contingency table
ContingTab <- function(true, pred) {
         true <- max.col(true)
         cres <- max.col(pred)
         return(table(true, cres))
     }
# Cross-validation subfunction: nnet classify on a single splitted set, with a common base name and an index -0-1 etc.
Xvalidatennet <- function(trainset, testset, hidlay1siz, P){
	ncols <- ncol(trainset)
	trainlabels <- class.ind(trainset[, ncols])
	testlabels <- class.ind(testset[, ncols])
	ANN <- nnet(trainset[, 1:P], trainlabels, size=hidlay1siz, skip=TRUE, rang=0.1, decay=5e-04, maxit=2000)
	Tab <- ContingTab(testlabels, predict(ANN, testset[, 1:P]))
	accuracy <- sum(diag(Tab))/sum(rowSums(Tab))
	return(accuracy)
}
# Cross-validate, given the num. of folds, the num.principal vectors and the size of hid.layer1
Xvalidateall <- function(basename, fold, P, hidlay1siz) {
	indx <- 1
        fold0 <- fold-1
        NumSets <- fold*fold0 # permutation(fold, 2)
        accuracy <- numeric(NumSets)
        for(i in 0:fold0){

                for(j in 0:fold0){

                        if(i != j){
                                filename <- paste(basename, "-", i, "-", j, sep="")
                                trfname <- paste(filename, ".data", sep="")
                                tfname <- paste(filename, ".test", sep="")
                                print(trfname)
                                trainset <- read.table(toString(trfname))
                                testset <- read.table(toString(tfname))
				
		                accuracy[indx] <- Xvalidatennet(trainset, testset, hidlay1siz, P) 
				indx <- indx+1
                        }

                }
        }
        return(accuracy)
}




basename <- commandArgs(trailingOnly = TRUE)
#indx <- 1
HLSizes = c(6,8,10,12)
NumPVs = c(2,3,4,5)
Folds = c(5,8,10,12)
#Accuracies = numeric(length(HLSizes)*length(NumPVs)*length(Folds), )
for(hidlay1siz in HLSizes) {
	cat("Starting for the size of hidden-layer-1: ", hidlay1siz,"\n======================================================================================\n")
	for(P in NumPVs) {
		cat("Starting for the P.Vs 1 to ", P,"\n*******************************************************************\n")
		for(fold in Folds) {
			Accuracies <- Xvalidateall(basename, fold, P, hidlay1siz)
			cat("Fold = ", fold,"\tP = ",P,"\thidden layer size = ",hidlay1siz, "\n-------------------------------------------------------\nAccuracies = ", Accuracies, "\n")
			#indx <- indx+1
		}
	}	
}

