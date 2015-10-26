library(rgl)
load(url("http://statweb.stanford.edu/~tibs/ElemStatLearn/datasets/ESL.mixture.rda"))
dat <- ESL.mixture
ddat <- data.frame(y=dat$y, x1=dat$x[,1], x2=dat$x[,2])
 
 
## create 3D graphic, rotate to view 2D x1/x2 projection
par3d(FOV=1,userMatrix=diag(4))
plot3d(dat$xnew[,1], dat$xnew[,2], dat$prob, type="n", xlab="x1", ylab="x2", zlab="", axes=FALSE, box=TRUE, aspect=1)
 
## plot points and bounding box
x1r <- range(dat$px1)
x2r <- range(dat$px2)
pts <- plot3d(dat$x[,1], dat$x[,2], 1, type="p", radius=0.5, add=TRUE, col=ifelse(dat$y, "orange", "blue"))
lns <- lines3d(x1r[c(1,2,2,1,1)], x2r[c(1,1,2,2,1)], 1)
 
## draw Bayes (True) classification boundary in blue
dat$probm <- with(dat, matrix(prob, length(px1), length(px2)))
dat$cls <- with(dat, contourLines(px1, px2, probm, levels=0.5))
pls0 <- lapply(dat$cls, function(p) lines3d(p$x, p$y, z=1, color="blue"))
 
## compute probabilities; plot classification boundary associated with local linear logistic regression
probs.loc <- apply(dat$xnew, 1, function(x0) {
    ## smoothing parameter
    l <- 1/2
    ## compute (Gaussian) kernel weights
    d <- colSums((rbind(ddat$x1, ddat$x2) - x0)^2)
    k <- exp(-d/2/l^2)
    ## local fit at x0
    fit <- suppressWarnings(glm(y ~ x1 + x2, data=ddat, weights=k, family=binomial(link="logit")))
    ## predict at x0
    as.numeric(predict(fit, type="response", newdata=as.data.frame(t(x0))))
  })
 
dat$probm.loc <- with(dat, matrix(probs.loc, length(px1), length(px2))) # resize the vector of probs.loc into a matrix
dat$cls.loc <- with(dat, contourLines(px1, px2, probm.loc, levels=0.5)) # 
pls <- lapply(dat$cls.loc, function(p) lines3d(p$x, p$y, z=1))
 
## plot probability surface and decision plane
sfc <- surface3d(dat$px1, dat$px2, probs.loc, alpha=1.0, color="gray", specular="gray")
qds <- quads3d(x1r[c(1,2,2,1)], x2r[c(1,1,2,2)], 0.5, alpha=0.4, color="gray", lit=FALSE)

