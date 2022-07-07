rm(list = ls())
library(data.table)

#Data input
sort <- fread("./project/volume/data/interim/melt_data2.csv")

#Ordering 
order <- as.data.table(tstrsplit(sort$id,"_"))
order$V2 <- as.numeric(order$V2)
sort$ranking <- order$V2
sort <- sort[order(sort$ranking),]
sort$ranking <- NULL 

fwrite(sort, "./project/volume/data/interim/model_ready_table.csv")

