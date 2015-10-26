#!/usr/bin/Rscript
# Do the plots. Perform x-fold cross-validation of the nnet classifier for each case of the combination of (NumOfPCs, NumOfHid.nodes, NumOfFolds)
# The data subsets were available (see crossvalidate.pl). These text files have a basenamefold-5-0.data convention for the training set
# Save the ANN in each case to .RData and report the accuracies for each crossvalidation.

# invoke: R CMD BATCH --no-save --no-restore '--args datasetname="Dataset1" pcamethod="NA0" basename="Dataset1-poscases-NA0Dataset1-negcases-NA0"' ~/perlprogs/crossvalidateall2level.R 

library(nnet)
library(stats)

# Compute contingency table
ContingTab <- function(true, pred) {
         true <- max.col(true)
         cres <- max.col(pred)
         return(table(true, cres))
     }
# Cross-validation subfunction: nnet classify on a single splitted set, with a common base name and an index -0-1 etc.
Xvalidatennet <- function(trainset, testset, P, hidlay1siz, RDatafilename){
	ncols <- ncol(trainset)
	trainlabels <- class.ind(trainset[, ncols]) # last col. is labels
	testlabels <- class.ind(testset[, ncols])
	ANN <- nnet(trainset[, 1:P], trainlabels, size=hidlay1siz, skip=TRUE, rang=0.1, decay=5e-04, maxit=2000)
	predlabels <- predict(ANN, testset[, 1:P])
	Tab <- ContingTab(testlabels, predlabels)
	accuracy <- sum(diag(Tab))/sum(rowSums(Tab))
	
	# Write nnet to .RData file and the predictions on the test set to .Predictions file (also preserve the 'records' indices)	
	save(ANN, P, hidlay1siz, testset, predlabels, accuracy, RDatafilename, file = RDatafilename, ascii=TRUE)
	
	return(accuracy)
}
# 2-level Cross-validate, given the num. of folds, the num.principal vectors and the size of hid.layer1
Xvalidateall <- function(basename, fold, P, hidlay1siz) {
	indx <- 1
        fold0 <- fold-1 # 0 reference filenames
        NumSets <- fold0 # 3-level CV, use fold*fold0 or permutation(fold, 2)
        accuracy <- numeric(NumSets)
        for(i in 0:fold0) { # for each train set
			
        	        filename <- paste(basename, "fold-", fold, "-", i, sep="")
                        trfname <- paste(filename, ".data", sep="")
                        tfname <- paste(filename, ".test", sep="")
                        print(trfname)
                        
			trainset <- read.table(toString(trfname), header=TRUE, sep="\t")
                        testset <- read.table(toString(tfname), header=TRUE, sep="\t")

			RDatabasename <- paste(filename, "-P", P, "-H", hidlay1siz, sep="")
			RDatafilename <- paste(RDatabasename, ".RData", sep="")
				
		        accuracy[indx] <- Xvalidatennet(trainset, testset, P, hidlay1siz, RDatafilename) 
			indx <- indx+1
        } 
	return(accuracy)
}

args <- commandArgs(trailingOnly = TRUE)

for(i in 1:length(args)){
        eval(parse(text=args[[i]]))
}

HLSizes = c(3,6,8,10,12,15)
NumPVs = c(2,3,4,5)
Folds = c(3,5,8,10) # preset in ~/bin/Crossvalidatsets2level/cross-validate2level.pl
records = data.frame()

for(P in NumPVs) {
	cat("Starting for the P.Vs 1 to ", P,"\n*******************************************************************\n")
	for(hidlay1siz in HLSizes) {
		cat("Starting for the size of hidden-layer-1: ", hidlay1siz,"\n======================================================================================\n")
		for(fold in Folds) { 
			Accuracies <- Xvalidateall(basename, fold, P, hidlay1siz)
			cat("Fold = ", fold,"\tP = ",P,"\thidden layer size = ",hidlay1siz, "\n-------------------------------------------------------\nAccuracies = ", Accuracies, "\n")
			df = data.frame(NumPVs=P, Hlay1siz=hidlay1siz, Fold=fold, accuracies=Accuracies)
			records <- rbind(records, df)
		}
	}	
}
recfilename <- paste(datasetname, pcamethod, "Accuracies_proj2.RData", sep="-")
save(records, file=recfilename, ascii=TRUE)

if(TRUE) {
# Do a boxplot of the crossvalidation results
load(recfilename)
crecord <- paste(records$NumPVs, records$Hlay1siz, records$Fold, sep=",")
splitRecord <- split(records$accuracies, factor(crecord))
pdf(paste(datasetname,pcamethod, "ANNboxplots_proj2.pdf", sep=""))
boxplot(splitRecord, horizontal=FALSE, las=2, pch=5, cex=0.3, cex.axis=0.3, col=c("red","blue","green","yellow","orange","cyan"), main="Cross-validation: Accuracy as a function of PCs, Hid.Nodes and Folds", xlab="(NumOfPCs, NumOfHid.nodes, NumOfFolds)", ylab="Accuracy")
dev.off()
}
