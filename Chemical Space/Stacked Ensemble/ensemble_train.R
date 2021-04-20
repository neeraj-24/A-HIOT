require(h2o)
#require(h2oEnsemble)
require(caret)
h2o.init()
data <- h2o.importFile("new_with_removed_zeros_y.csv", header=T)
splits<- h2o.splitFrame(data, ratios = 0.70, seed = -1)
train <- splits[[1]]
test <- splits[[2]]
h2o.exportFile(test, "ENS_internal_test.csv", header=TRUE)
train <- train[2:674]
test <- test[2:674]
train$y <- as.factor(train$y)
test$y <- as.factor(test$y)
nrow(train)
nrow(test)
y <- "y"
x <- setdiff(names(train), y)
nfolds <- 10

#Training Base Layer

#Xtreme Gradient Boost algorithm
my_xgb <- h2o.xgboost(x = x, y = y, training_frame = train, ntrees = 1500, max_depth = 5, min_rows = 2, learn_rate = 0.2, nfolds = nfolds, fold_assignment = "Random", keep_cross_validation_predictions = TRUE, seed = 42) 

jpeg('Ensemble_XGB_performance_training_set.jpg')
perf_xgb <- h2o.performance(model = my_xgb, newdata = test) 
plot(perf_xgb, main="Ensemble XGB perfromance for internal test set")
dev.off()
perf_xgb_auc <- h2o.auc(perf_xgb)

#Random Forest algorithm
my_rf <- h2o.randomForest(x = x, y = y, training_frame = train, ntrees = 1500, nfolds = nfolds, fold_assignment = "Random", keep_cross_validation_predictions = TRUE, seed = 42)

jpeg('Ensemble_RF_performance_training_set.jpg')
perf_rf <- h2o.performance(model = my_rf, newdata = test) #84.61% accuracy
plot(perf_rf, main="Ensemble RF perfromance for internal test set")
dev.off()
perf_rf_auc <- h2o.auc(perf_rf) 

#Deep Learning algorithm
#my_dl <- h2o.deeplearning(x = x, y = y, training_frame = train, epochs = 1000, hidden = c(300,300,300), score_interval = 1,  stopping_rounds = 3,  stopping_metric = "AUC",  seed = 42)

#jpeg('Ensemble(single)_DL_performance_training_set.jpg')
#perf_dl <- h2o.performance(model = my_dl, newdata = test)  #85.25% accuracy
#plot(perf_dl, main="Ensemble(single)_DL_perfromance on test dataset")
#dev.off()
#perf_dl_auc <- h2o.auc(perf_dl)

#Stacked Model with deeplearning
stack_param <- list(epochs = 50, hidden = c(400,200,2), score_interval = 1,  stopping_rounds = 3,  stopping_metric = "AUC",  seed = 42)

ensemble_dl <- h2o.stackedEnsemble(x = x, y = y, training_frame = train, base_models = list(my_rf, my_xgb), metalearner_algorithm = "deeplearning", metalearner_params = stack_param)

jpeg('DL_as_superlearner_performance_training_set.jpg')
ensemle_perf <- h2o.performance(ensemble_dl, test) #87.17% accuracy
plot(ensemle_perf, main="Ensemble_(DL_as_superlearner)_perfromance for internal test set")
dev.off()
ensemeble_auc <- h2o.auc(ensemle_perf)

#Feature selection
jpeg('Ensemble_RF_imp_var_training.jpg')
h2o.varimp_plot(my_rf, 30)
dev.off()

jpeg('Ensemble_XGB_imp_var_training.jpg')
h2o.varimp_plot(my_xgb, 30)
dev.off()

#h2o.varimp_plot(ensemble_dl, 30)
#imp_var <- h2o.varimp(ensemble_dl, 30)
model_independent_ensemble <- h2o.saveModel(object =ensemble_dl, path = getwd(), force = TRUE)

test_predict_ENS <- h2o.predict(object = ensemble_dl, newdata = test )



h2o.exportFile(test_predict_ENS, "ENS_predicted_internal_test.csv", header=TRUE)

h2o.shutdown()
