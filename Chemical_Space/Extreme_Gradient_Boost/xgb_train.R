require(caret)
require(e1071)
require(dplyr)
require(xgboost)
require(data.table)
require(Matrix)
require(ROCR)
data <- read.csv(file="new_with_removed_zeros_y.csv", header=T)
data <- data[2:674]
is.na(data)

#data preparation
data$y <- as.factor(data$y)
ind <- sample(1:nrow(data), round(0.70*nrow(data)))
train <- as.data.frame(data[ind,])
test <- as.data.frame(data[-ind,])

#XGB data preparation
setDT(train)
setDT(test)
labels <- train$y
ts_label <- test$y

#One-hot Encoding
new_tr <- model.matrix(~.+0, data = train[,-c("y"),with=F])
new_ts <- model.matrix(~.+0, data = test[,-c("y"), with=F])
labels <- as.numeric(labels)-1
ts_label <- as.numeric(ts_label)-1
dtrain <- xgb.DMatrix(data = new_tr,label = labels)
dtest <- xgb.DMatrix(data = new_ts,label=ts_label)

#XGB Modelling
parameters <- list(booster = "gbtree", objective = "binary:logistic", eta=0.5, gamma=1, max_depth=10, min_child_weight=1, subsample=1, colsample_bytree=1)

xgb_cross_val <- xgb.cv( params = parameters, data = dtrain, nrounds = 1000, nfold = 5, showsd = T, stratified = T, print_every_n = 10, early_stop_round = 20, maximize = F, verbose=T, eval_metric = 'auc', prediction = T )

#Plotting ROC for 5-fold CV 
require(pROC)
jpeg('XGB_training_Five_fold_CV.jpg')
plot(pROC::roc(response = labels, predictor = xgb_cross_val$pred, levels=c(0, 1)), lwd=1.5, main="ROC Curve for 5 fold CV", print.cutoffs.at=seq(0, 1, by=0.05), text.adj=c(-0.5, 0.5), text.cex=0.5)
dev.off()

xgb_model <- xgb.train (params = parameters, data = dtrain, nrounds = 5000, watchlist = list(val=dtest, train=dtrain), print_every_n = 10, early_stop_round = 10, maximize = F , eval_metric = "auc", prediction = T)

#Performance on training dataset
xgbpred_tr <- predict (xgb_model, dtrain)
xgbpred_tr <- ifelse (xgbpred_tr > 0.5,1,0)
xgbpred_tr <- as.factor(xgbpred_tr)
tr_label <- as.factor(labels)
conf_matrix_training <- confusionMatrix (xgbpred_tr, tr_label)

#Performance on testing dataset
xgbpred <- predict (xgb_model,dtest)
xgbpred <- ifelse (xgbpred > 0.5,1,0) # Rounding off predictions
xgbpred <- as.factor(xgbpred)
ts_label <- as.factor(ts_label)
conf_matrix_testing <-confusionMatrix (xgbpred, ts_label)


#Plotting important variables
jpeg('XGB_training_important_varables.jpg')
model <- xgb.dump(xgb_model, with_stats=TRUE)
names <- dimnames(dtrain)[[2]]
importance_matrix <- xgb.importance(names, model=xgb_model)[0:30]
xgb.plot.importance(importance_matrix)
dev.off()

#Plotting AUC for training
jpeg('XGB_training_AUC.jpg')
prediction_for_AUC_tr <- predict(xgb_model, dtrain)
xgb_pred_for_auc_tr <- prediction(prediction_for_AUC_tr, tr_label)
xgb_perf_for_auc_tr <- performance(xgb_pred_for_auc_tr, "tpr", "fpr")
plot( xgb_perf_for_auc_tr, avg="threshold", colorize=TRUE, lwd=1, main="ROC Curve for training model", print.cutoffs.at=seq(0, 1, by=0.05), text.adj=c(-0.5, 0.5), text.cex=0.5)
dev.off()

#Plotting AUC for test
jpeg('XGB_internal_test_AUC.jpg')
prediction_for_AUC <- predict(xgb_model, dtest)
xgb_pred_for_auc <- prediction(prediction_for_AUC, ts_label)
xgb_perf_for_auc <- performance(xgb_pred_for_auc, "tpr", "fpr")
plot( xgb_perf_for_auc, avg="threshold", colorize=TRUE, lwd=1, main="ROC Curve for internal test", print.cutoffs.at=seq(0, 1, by=0.05), text.adj=c(-0.5, 0.5), text.cex=0.5)
dev.off()

