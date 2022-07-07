rm(list = ls())
library(data.table)
library(Rtsne)

#Data Input 
pca_dt <- fread("./project/volume/data/interim/pca_dt.csv")

#Tried tsne perplexity 30, 50, 70
tsne <- Rtsne(pca_dt, pca = F, perplexity = 70, check_duplicates = F, max_iter = 5000, stop_lying_iter = 500)
tsne_extract <- data.table(tsne$Y)
fwrite(tsne_extract, "./project/volume/data/interim/tsne_extract.csv")

