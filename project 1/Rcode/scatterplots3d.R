#!usr/bin/Rscript

# list.files(pattern=".RData")
names(myrnas) = c("MIReNA","MiPred","TripSVM","ProMiR","miRPara", "Label")
dataset$Label = as.factor(myrnas$Labels)

myrnas_m = melt(myrnas, id=c("Label"))
dataset_m <- melt(dataset, id = c("Label"))


pdf("~/perlprogs/myrnas_melt_boxplots.pdf")

p <- ggplot(dataset_m, aes(x=variable, y=value, fill=Label)) + facet_wrap(~Label) + geom_boxplot() + geom_point(alpha=1/8) + labs(x="Principal Components") + labs(y="Principal Component Scores")

q <- ggplot(myrnas_m, aes(x=variable, y=value, fill=Label)) + facet_wrap(~Label) + geom_boxplot()+par(cex=0.8, cex.axis=0.7) + geom_point(alpha=1/8) + labs(x = "Predictors") + labs(y = "Scores") + labs(title = "The distribution of prediction scores")

r <- ggplot(dataset_m, aes(x = variable, y = value)) + facet_wrap( ~ variable) + geom_point(alpha = 1/8) + geom_smooth(method = "lm")

dataset$Label = myrnas$Label

pdf("~/perlprogs/myrnasbpcaggpairs.pdf")
ggpairs(dataset, color="Label")
dev.off()
