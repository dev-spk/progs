#!/bin/Rscript

# Predict on the postive and negative cases of D-1 using the predicted models

require(nnet)

# load the models and run predictions on the complete dataset
poscases <- read.table("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0.data")
negcases <- read.table("~/bin/Crossvalidatsets2level/Dataset1-negcases-NA0.data")

recs <- rbind(poscases, negcases)
labels <- recs[, 6]


# 
load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-3-0-P5-H3.RData")
model1 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-3-1-P5-H3.RData")
model2 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-3-2-P5-H3.RData")
model3 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-3-P5-H6.RData")
#model4 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-4-P5-H6.RData")
#model5 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-5-P5-H6.RData")
#model6 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-6-P5-H6.RData")
#model7 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-7-P5-H6.RData")
#model8 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-8-P5-H6.RData")
#model9 <- ANN
#load("~/bin/Crossvalidatsets2level/Dataset1-poscases-NA0Dataset1-negcases-NA0fold-10-9-P5-H6.RData")
#model10 <- ANN

preds1 <- as.vector(predict(model1, recs[,1:P])[,2])
preds2 <- as.vector(predict(model2, recs[,1:P])[,2])
preds3 <- as.vector(predict(model3, recs[,1:P])[,2])
#preds4 <- as.vector(predict(model4, recs[,1:P]))
#preds5 <- as.vector(predict(model5, recs[,1:P]))
#preds6 <- as.vector(predict(model6, recs[,1:P]))
#preds7 <- as.vector(predict(model7, recs[,1:P]))
#preds8 <- as.vector(predict(model8, recs[,1:P]))
#preds9 <- as.vector(predict(model9, recs[,1:P]))
#preds10 <- as.vector(predict(model10, recs[,1:P]))

#head(preds1)
#head(preds2)

#
pred.table <- cbind(labels, preds1, preds2, preds3)
pred.table <- data.frame(pred.table)

colnames(pred.table) = c("label", "model1", "model2", "model3")
rownames(pred.table) = rownames(recs)

outfname <- "~/bin/Crossvalidatsets2level/Dataset1-NA0.predictions"

write.table(pred.table, file=outfname, row.names=TRUE, col.names=TRUE, sep="\t", quote=FALSE)
head(pred.table)
tail(pred.table)
