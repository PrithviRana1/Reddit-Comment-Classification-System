rm(list = ls())
library(data.table)
library(xgboost)
library(Rtsne)

#Data Input
master <- fread("./project/volume/data/interim/master.csv")
master_index <- master$A
tsne_extract <- fread("./project/volume/data/interim/tsne_extract.csv")
train_bind <- fread("./project/volume/data/interim/train_bind.csv")
test_bind <-fread("./project/volume/data/interim/test_bind.csv")

#Saving id
test_id <- test_bind$id


tsne_extract$index <- master_index
tsne_train <- tsne_extract[index==1]
tsne_test <- tsne_extract[index==2]
tsne_train$index <- NULL
tsne_test$index <- NULL

tsne_train$subreddit <- train_bind$subreddit
y_train <- as.matrix(tsne_train$subreddit)
tsne_train$subreddit <- NULL
tsne_train <- as.matrix(tsne_train)

dtrain <- xgb.DMatrix(tsne_train, label=y_train, missing = NA)


tsne_test <- as.matrix(tsne_test)
dtest <- xgb.DMatrix(tsne_test, missing = NA)

hyper_parm_tune <- NULL


#-----------------------------#
# Use cross validation        #
#-----------------------------#

# Create my parameters

#--Tuning--#
#Tried eta = (0.02,0.03,0.04,0.01)
#      min_child_weight = 0.5,0.3
#best eta = 0.02, min_child_weight = 0.5, max_depth = 5

myparams <- list( objective = "multi:softprob", 
                  gamma = 0.02, 
                  booster = "gbtree", 
                  eval_metric = "mlogloss",
                  eta = 0.02,
                  max_depth = 5, 
                  min_child_weight = 0.5, 
                  subsample = 1.0,
                  colsample_bytree = 1.0,
                  tree_method = "hist",
                  num_class = 10)

XGBfit <- xgb.cv(params = myparams,
                 nfold = 5,
                 nrounds = 100000, 
                 missing = NA,
                 data = dtrain,
                 print_every_n = 1,
                 early_stopping_rounds = 25)

best_tree_n <- unclass(XGBfit)$best_iteration
new_row <- data.table(t(myparams))
new_row$best_tree_n <- best_tree_n
test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_mlogloss_mean
new_row$test_error <- test_error
hyper_parm_tune <- rbind(new_row, hyper_parm_tune)

#-------------------------#
#Fit model                #
#-------------------------#

watchlist <- list(train = dtrain)

XGBfit <- xgb.train(params = myparams,
                    nrounds = best_tree_n, 
                    missing = NA,
                    data = dtrain,
                    watchlist = watchlist,
                    print_every_n = 1
)
pred <- predict(XGBfit, newdata = dtest)

saveRDS(XGBfit, "./project/volume/models/XGB.model")


#Submission
submit <- matrix(pred, ncol=10, byrow=T)
submit <- as.data.table(submit)
submit$id <- test_id
submit
setnames(submit, c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10"), c("subredditcars", "subredditCooking", "subredditMachineLearning", "subredditmagicTCG", "subredditpolitics", "subredditReal_Estate", "subredditscience", "subredditStockMarket", "subreddittravel", "subredditvideogames"))
submit <- submit[,.(id,subredditcars,subredditCooking,subredditMachineLearning,subredditmagicTCG,subredditpolitics,subredditReal_Estate,subredditscience,subredditStockMarket,subreddittravel,subredditvideogames)]
fwrite(submit, "./project/volume/data/processed/submission_file.csv")
