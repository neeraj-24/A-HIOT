require(h2o)
require(caret)
h2o.init(nthreads=-1, max_mem_size="16G")
h2o.removeAll()
data <- h2o.importFile("/home/user/DNN_RF/pipeline_validation/dud_e/Biological_space/validation_set/validation_pdbqt/validation_vs_output/complex_files_FPs/calculated_fingerprints/final_run_training+validation/training_klekoth.csv")
#data <- data[2:4862]
print(dim(data))
splits<- h2o.splitFrame(data, ratios = 0.40, seed = -1)
train <- splits[[1]]
test <- splits[[2]]
h2o.exportFile(test, "/home/user/DNN_RF/pipeline_validation/dud_e/Biological_space/validation_set/validation_pdbqt/validation_vs_output/complex_files_FPs/calculated_fingerprints/final_run_training+validation/DL_klelota_internal_test.csv", header=TRUE)
train <- train[2:4862]
test <- test[2:4862]
train$y <- as.factor(train$y)
test$y <- as.factor(test$y)
y <- "y"
nfolds <- 10
predictors <- setdiff(names(train), y)
train[,y] <- as.factor(train[,y])
test[,y] <- as.factor(test[,y])

#Modelling_DNN
my_dl_model <- h2o.deeplearning(model_id="dl_model_first", training_frame=train, validation_frame = test, x=predictors, y=y,  nfolds = 10, keep_cross_validation_fold_assignment = TRUE, fold_assignment = "Stratified", activation = "RectifierWithDropout", score_each_iteration = TRUE, hidden = c(400, 200, 400, 2), epochs = 50, variable_importances = TRUE, export_weights_and_biases = TRUE, ignore_const_cols = FALSE, seed = 42)

h2o.mean_per_class_error(my_dl_model, train = TRUE, valid = TRUE, xval = TRUE)

conf_mat_test <- h2o.confusionMatrix(my_dl_model, valid = TRUE)
training_auc <- h2o.auc(my_dl_model, train = TRUE)
validation_auc <- h2o.auc(my_dl_model, valid = TRUE)
cross_valid_auc <- h2o.auc(my_dl_model, xval = TRUE)
imp_variables<-head(h2o.varimp(my_dl_model), 20)

#Hyper parameterization with Grid Search

hyper_params <- list(hidden=list(c(100,100),c(200,200,200)), input_dropout_ratio=c(0,0.05), rate=c(0.01,0.02), rate_annealing=c(1e-10,1e-9,1e-8))

grid <- h2o.grid(algorithm="deeplearning", grid_id="my_dl_grid", training_frame=train, validation_frame = test, x=predictors, y=y, epochs=50, stopping_metric="misclassification", reproducible=TRUE, stopping_tolerance=1e-2, stopping_rounds=2, adaptive_rate=F,  momentum_start=0.5,  momentum_stable=0.9, activation=c("RectifierWithDropout"), max_w2=10, hyper_params=hyper_params)

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

jpeg('DL_training_perf_with_epochs_klekoth.jpg')
plot(my_dl_model, timestep = "epochs", metric = "classification_error")
dev.off()

jpeg('DL_training_imp_variables_klekoth.jpg')
h2o.varimp_plot(my_dl_model, 20)
dev.off()

#Predictions on test data
perf_test <- h2o.performance(best_model, test)
jpeg('DL_training_model_perf_with_test_set_klekoth.jpg')
plot(perf_test, main = "Training perf for internal test set")
dev.off()
h2o.logloss(perf_test)
h2o.auc(perf_test)

write.csv(file="kelkoth_train_top_20_vars.csv", imp_variables )

model_training_klekoth <- h2o.saveModel(object = best_model, path = getwd(), force = TRUE)

test_predict <- h2o.predict(object = best_model, newdata = test)
h2o.exportFile(test_predict, "/home/user/DNN_RF/pipeline_validation/dud_e/Biological_space/validation_set/validation_pdbqt/validation_vs_output/complex_files_FPs/calculated_fingerprints/final_run_training+validation/DL_klekota_predicted_internal_test.csv", header=TRUE)
h2o.shutdown()
