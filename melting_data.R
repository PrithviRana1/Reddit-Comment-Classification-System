rm(list=ls())
library(data.table)


#Data Input
test <- fread("./project/volume/data/raw/test_file.csv")
test_embed <- fread("./project/volume/data/raw/test_emb.csv")
train <- fread("./project/volume/data/raw/train_data.csv")
train_embed <- fread("./project/volume/data/raw/train_emb.csv")


#Removing text column
train_text <- train$text
train$text <- NULL

#Melt
melt_data <- melt(train, id=c("id"), variable.name = "subreddit")

#Data Wrangling
melt_data2 <- melt_data[value == 1]
melt_data2$subreddit <- as.numeric(melt_data2$subreddit)
melt_data2$value <- NULL
melt_data2$subreddit <- melt_data2$subreddit - 1
melt_data2

fwrite(melt_data2, "./project/volume/data/interim/melt_data2.csv")
