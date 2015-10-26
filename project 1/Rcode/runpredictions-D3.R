#!/bin/Rscript

# Predict on the postive and negative cases of D-3 using the predicted models

require(nnet)

# load the models and run predictions on the complete dataset
poscases <- read.table("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0.data")
negcases <- read.table("~/bin/Crossvalidatsets2level/Dataset3-negcases-NA0.data")

recs <- rbind(poscases, negcases)
labels <- recs[, 6]

# 
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-0-P5-H8.RData")
model1 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-1-P5-H8.RData")
model2 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-2-P5-H8.RData")
model3 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-3-P5-H8.RData")
model4 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-4-P5-H8.RData")
model5 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-5-P5-H8.RData")
model6 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-6-P5-H8.RData")
model7 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-7-P5-H8.RData")
model8 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-8-P5-H8.RData")
model9 <- ANN
load("~/bin/Crossvalidatsets2level/Dataset3-poscases-NA0Dataset3-negcases-NA0fold-10-9-P5-H8.RData")
model10 <- ANN

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

#head(preds1)
#head(preds2)

#
pred.table <- cbind(labels, preds1, preds2, preds3, preds4, preds5, preds6, preds7, preds8, preds9, preds10)
pred.table <- data.frame(pred.table)

colnames(pred.table) = c("label", "model1", "model2", "model3", "model4", "model5", "model6", "model7", "model8", "model9", "model10")
rownames(pred.table) = rownames(recs)

outfname <- "~/bin/Crossvalidatsets2level/Dataset3-NA0.predictions"

write.table(pred.table, file=outfname, row.names=TRUE, col.names=TRUE, sep="\t", quote=FALSE)
head(pred.table)
tail(pred.table)
