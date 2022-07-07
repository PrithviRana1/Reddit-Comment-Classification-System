rm(list = ls())
library(data.table)

#Data Input
intermediate <- fread("./project/volume/data/interim/model_ready_table.csv")
train_embed <- fread("./project/volume/data/raw/train_emb.csv")
test <- fread("./project/volume/data/raw/test_file.csv")
test_embed <- fread("./project/volume/data/raw/test_emb.csv")

#Appending Embeddings
train_bind <- cbind(intermediate, train_embed)
fwrite(train_bind, "./project/volume/data/interim/train_bind.csv")
test_text <- test$text
test$text <- NULL
test$subreddit <- 0.1
test_bind <-cbind(test, test_embed)
fwrite(test_bind, "./project/volume/data/interim/test_bind.csv")

test_id <- test_bind$id

train_bind$A <- 1
test_bind$A <- 2
master <- rbind(train_bind, test_bind)
fwrite(master, "./project/volume/data/interim/master.csv")
master_index <- master$A


master$id <- NULL
subreddit <- master$subreddit
master$subreddit <- NULL
master$A <- NULL

#pca master
pca <- prcomp(master)
pca_dt <- data.table(unclass(pca)$x)

fwrite(pca_dt, "./project/volume/data/interim/pca_dt.csv")
