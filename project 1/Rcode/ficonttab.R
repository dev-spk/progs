#!/usr/bin/Rscript
args <- commandArgs(TRUE)
mytab = read.table(args[1])
attach(mytab)
V3_th = sapply(V3, function(x) {if(x <= 0){x = -1} else {x = 1}})
contingencyt = table(V3_th, V4)
contintab = table(V3_th, V4)
(contintab[1,1]+contintab[2,2])/(contintab[1,1]+contintab[1,2]+contintab[2,1]+contintab[2,2])
