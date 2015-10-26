#!usr/bin/Rscript -w
# non-linear decision fit in the 3-dimensional scatter plot

require("rgl")

# load the pca or bpca dataset
load("/home/complab/bin/mirnaNonmirna.consensus7765bpca.RData")

colorlabels <- sapply(labels, function(x) {if(x == 'POS' | x == 1) x <- rgb(0,0,1) else if(x =='NEG' | x == -1 | x == 0) x <- rgb(1,0,0)}) 

dataset$Label <- sapply(dataset$Label, function(x) {if(x == -1) x <- 0 else x <- x})
dataset$Label <- as.factor(dataset$Label)

#plot the 3-dimensional scatterplot
open3d()
with(dataset, plot3d(PC1, PC2, PC3, col = colorlabels))

R1 <- with(dataset, range(PC1))
R2 <- with(dataset, range(PC2))
#R5 <- with(dataset, range(PC5))

fit <- with(dataset, glm(Label ~ PC1 + PC2 + PC3, family = binomial))

coeffs <- coef(fit)
a <- coeffs['PC1']
b <- coeffs['PC2']
c <- coeffs['PC3']
d <- coeffs['(Intercept)']

x1 <- seq(R1[1], R1[2], , 12)
x2 <- seq(R2[1], R2[2], , 12)
x5 <- outer(x1, x2, function(x1, x2) {x <- (0.5 - d - a*x1^2 - b*x1*x2^3)/c})

surface3d(x1, x2, x5, alpha=0.3)

#planes3d(a,b,c, col="blue", alpha=1/3)
# plot the surface of the probability densities



# plot the Bayes decision boundary



# plot the classifier decision boundary



