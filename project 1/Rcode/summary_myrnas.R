#!/usr/bin/Rscript

myrnas <- read.table("~/bin/mirnaNonmirna.consensus")
names(myrnas) = c("pred.MIReNA", "pred.MiPred", "pred.TripSVM", "pred.ProMiR", "pred.miRPara", "Labels")
myrnas_unique = unique(myrnas)
attach(myrnas_unique)

pdf("summary_myrnas.pdf")
par(mfrow = c(2,2))
summary(pred.miRPara)
p5 <- density(pred.miRPara)
plot(p5)

summary(pred.ProMiR)
p4 <- density(pred.ProMiR, na.rm = TRUE)
plot(p4)

summary(pred.TripSVM)

summary(pred.MiPred)
p2 <- density(pred.MiPred)
plot(p2)

summary(pred.MIReNA)

dev.off()
