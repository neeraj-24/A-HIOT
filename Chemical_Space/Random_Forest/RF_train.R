require(caret)
require(randomForest)
data <- read.csv(file="new_with_removed_zeros_y.csv", header=T)
str(data)
data <- data[2:674]
data$y <- as.factor(data$y)
str(data)
set.seed(526582)
ind <- sample(1:nrow(data), round(0.70*nrow(data)))
train <- as.data.frame(data[ind, ])
test <- as.data.frame(data[-ind, ])
str(train)
var_names <- names(data)
formula = as.formula(paste("y ~",  paste(var_names[!var_names %in% "y"], collapse = " + ")))
rf_train_model <- randomForest(formula, data = train,  ntree = 1500, mtry = 50, nodesize = 10, importance=T)
print(rf_train_model)

#Plotting training model
jpeg('RF_training_performance.jpg')
plot(rf_train_model, main="")
legend("right", c("OOB", "0", "1"), text.col=1:6, lty=1:3, col=1:3) 
title(main="Error Rates Random Forest for Training data")
dev.off()

#Variable Importance calculation
jpeg('var_importance.jpg')
impVar <- round(randomForest::importance(rf_train_model), 2) 
impVar[order(impVar[,3], decreasing=TRUE),]
varImpPlot <- varImpPlot(rf_train_model, sort = TRUE, main = "Var Impoirance", n.var=35) ##Plotting_variables
dev.off()

#Random forest model training
tRF<- tuneRF(x = train[,2:673], y = as.factor(train$y), mtryStart = 22, ntreeTry = 5000, stepFactor = 1.5, improve = 0.0001, trace = TRUE, plot = TRUE, doBest = TRUE, nodesize = 10, importance = TRUE )

#scoring of RF training model
train$predict.class <- predict(tRF, train, type = "class", na.action = na.omit)
train$predict.score <- predict(tRF, train, type = "prob")
head(train) 
class(train$predict.score)

#KS and AUC curves #### K-S or Kolmogorov-Smirnov chart
require(ROCR)
jpeg('RF_training_AUC.jpg')
pred <- prediction(train$predict.score[,2], train$y)
perf <- performance(pred, "tpr", "fpr")
plot( perf, colorize=TRUE, lwd=1, main="RF ROC Curve for training", print.cutoffs.at=seq(0, 1, by=0.05), text.adj=c(-0.5, 0.5), text.cex=0.5)
#plot(perf)
dev.off()
KS <- max(attr(perf, 'y.values')[[1]]-attr(perf, 'x.values')[[1]])
auc <- performance(pred,"auc");
auc <- as.numeric(auc@y.values)

#Confusion Matrix for training model
require(e1071)
conf_matrix_rf_train <- confusionMatrix(data = train$predict.class, reference=train$y)
conf_matrix_rf_train

#Prediction on test dataset
test$predict.class <- predict(tRF, test, type="class")
test$predict.score <- predict(tRF, test, type="prob")
conf_matrix_rf_test <- confusionMatrix(data = test$predict.class, reference=test$y)

#KS and AUC on Testing Data
jpeg('RF_internal_test_AUC.jpg')
pred1 <- prediction(test$predict.score[,2], test$y)
perf1 <- performance(pred1, "tpr", "fpr")
plot( perf1, colorize=TRUE, lwd=1, main="RF ROC Curve for internal test", print.cutoffs.at=seq(0, 1, by=0.05), text.adj=c(-0.5, 0.5), text.cex=0.5)
#plot(perf1)
dev.off()
KS1 <- max(attr(perf1, 'y.values')[[1]]-attr(perf1, 'x.values')[[1]])
auc1 <- performance(pred1,"auc");
auc1 <- as.numeric(auc1@y.values)

write.csv(test, "/home/user/DNN_RF/pipeline_validation/dud_e/Chemical_space/Paper_final_run/RF_paper/predicted_internal_test.csv", row.names=TRUE)
