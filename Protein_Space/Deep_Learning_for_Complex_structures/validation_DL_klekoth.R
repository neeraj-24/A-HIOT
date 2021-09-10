require(h2o)
require(caret)
h2o.init(nthreads=-1, max_mem_size="16G")
h2o.removeAll()

#Loading train dataset
train <- h2o.importFile("training_klekoth.csv")
train <- train[2:4862]
print(dim(train))
train$y <- as.factor(train$y)
print(h2o.levels(train$y))

#Loading test dataset
test <- h2o.importFile("validation_klekoth.csv")
test <- test[2:4862]
print(dim(test))
test$y <- as.factor(test$y)
print(h2o.levels(test$y))

#Variable settings
y <- "y"
nfolds <- 10
predictors <- setdiff(names(train), y)
train[,y] <- as.factor(train[,y])
test[,y] <- as.factor(test[,y])

#Modelling_DNN
my_dl_model <- h2o.deeplearning(model_id="dl_model_first", training_frame=train, validation_frame = test, x=predictors, y=y,  nfolds = 10, keep_cross_validation_fold_assignment = TRUE, fold_assignment = "Stratified", activation = "Tanh", score_each_iteration = TRUE, hidden = c(1600, 400, 200, 400, 2), epochs = 50, variable_importances = TRUE, export_weights_and_biases = TRUE, ignore_const_cols = FALSE, seed = 42)

h2o.mean_per_class_error(my_dl_model, train = TRUE, valid = TRUE, xval = TRUE)

conf_mat_test <- h2o.confusionMatrix(my_dl_model, valid = TRUE)
training_auc <- h2o.auc(my_dl_model, train = TRUE)
validation_auc <- h2o.auc(my_dl_model, valid = TRUE)
cross_valid_auc <- h2o.auc(my_dl_model, xval = TRUE)
imp_variables <- head(h2o.varimp(my_dl_model), 20)

#Hyper parameterization with Grid Search

hyper_params <- list(hidden=list(c(1000,100),c(400,200,2)), input_dropout_ratio=c(0,0.05), rate=c(0.01,0.02), rate_annealing=c(1e-10,1e-9,1e-8))

grid <- h2o.grid(algorithm="deeplearning", grid_id="my_dl_grid", training_frame=train, validation_frame = test, x=predictors, y=y, epochs=50, stopping_metric="misclassification", stopping_tolerance=1e-2, stopping_rounds=2, adaptive_rate=F,  momentum_start=0.5,  momentum_stable=0.9, activation=c("Tanh"), max_w2=10, hyper_params=hyper_params)

summary(grid)

#best model with Hyper-parameters

grid <- h2o.getGrid("my_dl_grid",sort_by="err",decreasing=FALSE)
grid@summary_table[1,]
best_model <- h2o.getModel(grid@model_ids[[1]])
print(best_model)
h2o.confusionMatrix(best_model,valid=T)
print(h2o.performance(best_model, valid=T))
print(h2o.logloss(best_model, valid=T))

#Performance Plot

jpeg('DL_validation_perf_with_epochs_klekoth.jpg')
plot(my_dl_model, timestep = "epochs", metric = "classification_error")
dev.off()

jpeg('DL_validation_imp_variables_klekoth.jpg')
h2o.varimp_plot(my_dl_model, 20)
dev.off()

#Predictions on test data

perf_test <- h2o.performance(best_model, test)
jpeg('DL_validation_model_perf_with_test_set_klekoth.jpg')
plot(perf_test, main = "Validation perf for independent dataset")
dev.off()

h2o.logloss(perf_test)
h2o.auc(perf_test)

write.csv(file="kelkoth_validation_top_20_vars.csv", imp_variables )

model_validation_klekoth <- h2o.saveModel(object = best_model, path = getwd(), force = TRUE)

test_predict <- h2o.predict(object = best_model, newdata = test)

h2o.exportFile(test_predict, "DL_klekota_predicted_independent_test.csv", header=TRUE)
h2o.shutdown()
