#!/usr/bin/Rscript
# (Project 2) plot ROCs, Accuracy curves of the predictors (in mirnaNonmirna.consensus)
# Perform Principal Component Analysis

library(ROCR)

mynoncodrnas <- read.table("~/tarprediction/Dataset1.meta") # Pass the consensus file containing pos. and neg. cases: mirnaNonmirna.consensus_old, trainingset2.consensus
mynoncodrnas <- unique(mynoncodrnas)
summary(mynoncodrnas)
names(mynoncodrnas) = c("pred.TarSpy", "pred.TThermo", "pred.miRanda", "pred.RNAhyb", "pred.TMiner", "Labels")
#write.table(mynoncodrnas, "mirnaNonmirna_unique.consensus", quote=FALSE, sep = "\t", row.names=FALSE, col.names=FALSE)
attach(mynoncodrnas)


# Plot the ROCs and stdout the contingency tables
if(TRUE) {


pdf("3ROCs_TarPreds.pdf")
par(mfrow = c(2,2))
# For MiPred
rocrobj <- prediction(pred.TarSpy, Labels)
rocrobj <- performance(rocrobj, 'tpr', 'fpr')
plot(rocrobj, xlim = c(0,0.2), ylim = c(0,0.26), main = 'TarSpy')
# For ProMiR
rocrobj <- prediction(pred.TThermo, Labels)
rocrobj <- performance(rocrobj, 'tpr', 'fpr')
plot(rocrobj, main = 'TThermo')
# For miRPara
rocrobj <- prediction(pred.miRanda, Labels)
rocrobj <- performance(rocrobj, 'tpr', 'fpr')
plot(rocrobj, xlim = c(0,0.22), ylim = c(0,0.4), main = 'miRanda')
dev.off()


pdf("3ACCs_TarPreds.pdf")
par(mfrow = c(2,2))
# For MiPred
rocrobj2 <- prediction(pred.TarSpy, Labels)
rocrobj2 <- performance(rocrobj2, 'acc')
plot(rocrobj2, xlim = c(0.99, 1), main = 'TarSpy')
# For ProMiR
rocrobj2 <- prediction(pred.TThermo, Labels)
rocrobj2 <- performance(rocrobj2, 'acc')
plot(rocrobj2, xlim = c(-10, 1.043), main = 'TThermo')
# For miRPara
rocrobj2 <- prediction(pred.miRanda, Labels)
rocrobj2 <- performance(rocrobj2, 'acc')
plot(rocrobj2, xlim = c(140, 1898), main = 'miRanda')



}



cat ('The contingency tables are:', "\n")

# pred.RNAhyb
cat ("\npred.RNAhyb\n")
T1 = table(pred.RNAhyb, Labels)
cat("\nContingency Table:\n")
T1
Accuracy = (T1[1,1]+T1[2,2])/(T1[1,1]+T1[1,2]+T1[2,2]+T1[2,1])
cat("\nAccuracy:\n")
Accuracy

# pred.TarSpy
cat ("\npred.TarSpy:\n")
ThresTarSpy <- 0.990 # YES when pred. prob. > 0
pred.TarSpy_Th = sapply(pred.TarSpy, function(x) {if(x > ThresTarSpy) {x = 'POS'} else {x = 'NEG'}})
T2 = table(pred.TarSpy_Th, Labels)
cat("\nContingency Table:\n")
T2
Accuracy = (T2[1,1]+T2[2,2])/(T2[1,1]+T2[1,2]+T2[2,2]+T2[2,1])
cat("\nAccuracy:\n")
Accuracy

# pred.TMiner
cat ("\npred.TMiner:\n")
T3 = table(pred.TMiner, Labels)
T=T3
cat("\nContingency Table:\n")
T
Accuracy = (T[1,1]+T[2,2])/(T[1,1]+T[1,2]+T[2,2]+T[2,1])
cat("\nAccuracy:\n")
Accuracy

# pred.TThermo
cat ("\npred.TThermo:\n")
ThresTThermo <- -0.50
pred.TThermo_Th = sapply(pred.TThermo, function(x) {if(is.na(x)) {x <- 'NA'} else if(x >= ThresTThermo) {x = 'POS'} else {x = 'NEG'}})
T4 = table(pred.TThermo_Th, Labels)
T=T4
cat("\nContingency Table:\n")
T
Accuracy = (T[1,1]+T[2,2])/(T[1,1]+T[1,2]+T[2,2]+T[2,1])
cat("\nAccuracy:\n")
Accuracy


# pred.miRanda
cat ("\npred.miRanda:\n")
ThresmiRanda <- 0.63
pred.miRanda_Th = sapply(pred.miRanda, function(x) {if(x >= ThresmiRanda) {x = 'POS'} else {x = 'NEG'}})
T5 = table(pred.miRanda_Th, Labels)
T=T5
Accuracy = (T[1,1]+T[2,2])/(T[1,1]+T[1,2]+T[2,2]+T[2,1])
cat("\nAccuracy:\n")
Accuracy


if(FALSE){

# Scale the values to the interval [-1,1]
myrnas <- mynoncodrnas
attach(myrnas)
myrnas$pred.MIReNA <- sapply(pred.MIReNA, function(x) {if(x == 'YES') {x <- 1} else {x <- -1}})
myrnas$pred.MiPred <- pred.MiPred/100*2 - 1
myrnas$pred.TripSVM <- sapply(pred.TripSVM, function(x) {if(is.na(x)) {x <- 0} else if(x==-1) {x <- -1}else if(x==1) {x <- 1} else if("-" %in% x) {x <- -1} else {x <- 1}}) # change only the NAs; choose x <- NA or 1;values of multiple detections are in combined form e.g., 1-111-1, so treat as neg. if the value had a minus "-"
maxProMiR = max(myrnas$pred.ProMiR, na.rm = TRUE)
myrnas$pred.ProMiR = sapply(pred.ProMiR, function(x) {if(is.na(x)){x <- 0} else if(x <= ThresProMiR) {x = x/ThresProMiR - 1} else {x = (x - ThresProMiR)/maxProMiR}}) # max value in
myrnas$pred.miRPara <- pred.miRPara*2 - 1
myrnas <- na.omit(myrnas)
summary(myrnas)


# Perform principal component analysis on scaled values
pr.out = prcomp(myrnas[,1:5], scale=TRUE)
pr.var = pr.out$sdev^2
cat("\nVariance of the Principal Component Scores: \n")
pr.var
pve = pr.var/sum(pr.var)
cat("\nPrincipal Variance Explained, PVE: \n")
pve
#[1] 0.42296107 0.21594145 0.15176890 0.11476598 0.09456259
cat("\nRotation Matrix: \n")
pr.out$rotation
#                    PC1         PC2           PC3        PC4         PC5
#pred.MIReNA  -0.3292186 -0.56253054  0.7364484159 -0.1422093 -0.11222641
#pred.MiPred  -0.5241993  0.08014635  0.0009101205  0.8447952  0.07149736
#pred.TripSVM -0.5417545  0.10875549 -0.3229815936 -0.2857685 -0.71322753
#pred.ProMiR  -0.5415488 -0.10341894 -0.2913466213 -0.3835597  0.68119640
#pred.miRPara -0.1733700  0.80908141  0.5181147932 -0.1931731  0.09783315
pr.out$rotation = -pr.out$rotation;
pr.out$x = -pr.out$x;

# Biplot 
if(FALSE) {
pdf("princompscores_dataset3.pdf")
#par(mfrow=c(2,2))
biplot(pr.out, main="Principal scores", scale=0, cex=0.5, col=c("red","blue"))
#plot(pr.out$x[,1], pr.out$x[,2], pch='*', main='Principal scores', xlab='PC1 scores', ylab='PC2 scores')
#plot(pr.out$x[,3], pr.out$x[,4], pch='*', main='Principal scores', xlab='PC3 scores', ylab='PC4 scores')
#plot(pr.out$x[,4], pr.out$x[,5], pch='*', main='Principal scores', xlab='PC4 scores', ylab='PC5 scores')
dev.off()
}

# Transform the labels to numeric; format of the input to the ANN (see $WORK/CrossvalidatuniqNA0 on Circe)
labels = sapply(myrnas$Label, function(x) {if(x=='POS') {x=1} else {x=-1}}) # transform labels
pcatab = cbind(pr.out$x, Label=labels)
pcatab = data.frame(pcatab)

Mergedata <- function(myrnas, pcatab, doit) {
	if(doit) {return(cbind(myrnas, pcatab))} else {return(pcatab)}
}

#pcatab <- Mergedata(myrnas[,1:5], pcatab, doit = TRUE) # append the cols. of data table to the cols. of the pca table 

poscases = pcatab[pcatab$Label == 1,]
negcases = pcatab[pcatab$Label == -1,]

if(FALSE) {
write.table(poscases, "~/bin/mirnapsuniqNA0", quote=FALSE, sep = "\t", row.names=FALSE, col.names=FALSE) # mirnauniqNA0, mirnauniqNA0app
write.table(negcases, "~/bin/psmirnauniqNA0", quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
}
}
