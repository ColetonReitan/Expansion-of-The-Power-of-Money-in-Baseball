library(dplyr)
library(caret)
library(xgboost)
library(ranger)
library(ggplot2)
library(tidyverse)
library(e1071)
library(kernlab)


# Creating models prior to HP tuning 
#INCLUDING SVM TRIAL



# Load data
original_data <- read.csv("C:/Users/colet/Documents/Personal Projects/Predictive2024_Unstandard_MLB_Payroll_Data.csv")
original_data_no2024 <- original_data[original_data$Year != 2024, ]
predictive_2024_data <- original_data[original_data$Year == 2024, ]

# Load feature groupings
corr_feats_main_1 <- read.csv("C:/Users/colet/Documents/Personal Projects/CorrelationCoefFeaturesDF.csv")
corr_feats_main_2 <- read.csv("C:/Users/colet/Documents/Personal Projects/RandomForestFeaturesDF.csv")
corr_feats_main_3 <- read.csv("C:/Users/colet/Documents/Personal Projects/LassoFeatures.csv")
corr_feats_main_4 <- read.csv("C:/Users/colet/Documents/Personal Projects/Hybrid_features.csv")

# Columns to exclude from feature selection
columns_to_exclude <- c("Year", "Team", "Playoff_Status")

# Define feature groupings
feature_groupings <- list(
  feature_grouping_1 = corr_feats_main_1,
  feature_grouping_2 = corr_feats_main_2,
  feature_grouping_3 = corr_feats_main_3,
  feature_grouping_4 = corr_feats_main_4
)


predict_wins <- function(feature_grouping, original_data, predictive_2024_data, columns_to_exclude) {
  # Create Original DataFrame without 2024 Data
  original_data_no2024 <- original_data[original_data$Year != 2024,]
  
  # Standardize Data (Exclude Specified Columns)
  data_to_standardize <- original_data_no2024[, !(names(original_data_no2024) %in% columns_to_exclude)]
  standardized_data <- scale(data_to_standardize)
  
  # Save Mean and Standard Deviation for Later Use
  mean_vals <- attr(standardized_data, "scaled:center")
  sd_vals <- attr(standardized_data, "scaled:scale")
  
  # Standardize 2024 Data Using Same Mean and SD
  standardized_2024_data <- predictive_2024_data
  standardized_2024_data[!(names(standardized_2024_data) %in% columns_to_exclude)] <- scale(
    predictive_2024_data[!(names(predictive_2024_data) %in% columns_to_exclude)],
    center = mean_vals,
    scale = sd_vals
  )
  
  # Filter for Feature Grouping
  corr_feats <- feature_grouping[, !names(feature_grouping) %in% columns_to_exclude]
  
  # Split Data into Training and Testing Sets
  set.seed(123)
  train_index <- sample(1:nrow(corr_feats), 0.8 * nrow(corr_feats))
  train <- corr_feats[train_index, ]
  test <- corr_feats[-train_index, ]
  
  # Linear Regression Model
  lm_model <- lm(Wins ~ ., data = train)
  lm_train_predictions <- predict(lm_model, train)
  lm_test_predictions <- predict(lm_model, test)
  
  # Calculate Training Metrics for Linear Regression
  lm_train_mae <- mean(abs(lm_train_predictions - train$Wins))
  lm_train_mse <- mean((lm_train_predictions - train$Wins)^2)
  lm_train_rmse <- sqrt(lm_train_mse)
  lm_train_r2 <- 1 - sum((lm_train_predictions - train$Wins)^2) / sum((mean(train$Wins) - train$Wins)^2)
  
  # Calculate Testing Metrics for Linear Regression
  lm_test_mae <- mean(abs(lm_test_predictions - test$Wins))
  lm_test_mse <- mean((lm_test_predictions - test$Wins)^2)
  lm_test_rmse <- sqrt(lm_test_mse)
  lm_test_r2 <- 1 - sum((lm_test_predictions - test$Wins)^2) / sum((mean(test$Wins) - test$Wins)^2)
  
  # Predict 2024 Wins with Linear Regression
  lm_predictions_2024 <- predict(lm_model, standardized_2024_data)
  lm_predicted_wins_2024 <- (lm_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  
  # Random Forest Model
  rf_model <- ranger(Wins ~ ., data = train, importance = 'impurity')
  rf_train_predictions <- predict(rf_model, train)$predictions
  rf_test_predictions <- predict(rf_model, test)$predictions
  
  # Calculate Training Metrics for Random Forest
  rf_train_mae <- mean(abs(rf_train_predictions - train$Wins))
  rf_train_mse <- mean((rf_train_predictions - train$Wins)^2)
  rf_train_rmse <- sqrt(rf_train_mse)
  rf_train_r2 <- 1 - sum((rf_train_predictions - train$Wins)^2) / sum((mean(train$Wins) - train$Wins)^2)
  
  # Calculate Testing Metrics for Random Forest
  rf_test_mae <- mean(abs(rf_test_predictions - test$Wins))
  rf_test_mse <- mean((rf_test_predictions - test$Wins)^2)
  rf_test_rmse <- sqrt(rf_test_mse)
  rf_test_r2 <- 1 - sum((rf_test_predictions - test$Wins)^2) / sum((mean(test$Wins) - test$Wins)^2)
  
  # Predict 2024 Wins with Random Forest
  rf_predictions_2024 <- predict(rf_model, standardized_2024_data)$predictions
  rf_predicted_wins_2024 <- (rf_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  
  # XGBoost Model
  feature_cols <- setdiff(colnames(corr_feats), "Wins")
  target_col <- "Wins"
  train_matrix <- as.matrix(train[, feature_cols])
  train_labels <- train[, target_col]
  test_matrix <- as.matrix(test[, feature_cols])
  test_labels <- test[, target_col]
  dtrain <- xgb.DMatrix(data = train_matrix, label = train_labels)
  dtest <- xgb.DMatrix(data = test_matrix, label = test_labels)
  params <- list(
    objective = "reg:squarederror",
    eval_metric = "rmse",
    eta = 0.1,
    max_depth = 6,
    subsample = 0.8,
    colsample_bytree = 0.8
  )
  xgb_model <- xgb.train(params, dtrain, nrounds = 100, watchlist = list(train = dtrain, test = dtest), early_stopping_rounds = 10)
  xgb_train_predictions <- predict(xgb_model, train_matrix)
  xgb_test_predictions <- predict(xgb_model, test_matrix)
  
  # Calculate Training Metrics for XGBoost
  xgb_train_mae <- mean(abs(xgb_train_predictions - train_labels))
  xgb_train_mse <- mean((xgb_train_predictions - train_labels)^2)
  xgb_train_rmse <- sqrt(xgb_train_mse)
  xgb_train_r2 <- 1 - sum((xgb_train_predictions - train_labels)^2) / sum((mean(train_labels) - train_labels)^2)
  
  # Calculate Testing Metrics for XGBoost
  xgb_test_mae <- mean(abs(xgb_test_predictions - test_labels))
  xgb_test_mse <- mean((xgb_test_predictions - test_labels)^2)
  xgb_test_rmse <- sqrt(xgb_test_mse)
  xgb_test_r2 <- 1 - sum((xgb_test_predictions - test_labels)^2) / sum((mean(test_labels) - test_labels)^2)
  
  # Predict 2024 Wins with XGBoost
  d2024 <- xgb.DMatrix(data = as.matrix(standardized_2024_data[, feature_cols]))
  xgb_predictions_2024 <- predict(xgb_model, d2024)
  xgb_predicted_wins_2024 <- (xgb_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  
  # SVM Model
  svm_model <- ksvm(Wins ~ ., data = train, kernel = "rbfdot")
  svm_train_predictions <- predict(svm_model, train)
  svm_test_predictions <- predict(svm_model, test)
  
  # Calculate Training Metrics for SVM
  svm_train_mae <- mean(abs(svm_train_predictions - train$Wins))
  svm_train_mse <- mean((svm_train_predictions - train$Wins)^2)
  svm_train_rmse <- sqrt(svm_train_mse)
  svm_train_r2 <- 1 - sum((svm_train_predictions - train$Wins)^2) / sum((mean(train$Wins) - train$Wins)^2)
  
  # Calculate Testing Metrics for SVM
  svm_test_mae <- mean(abs(svm_test_predictions - test$Wins))
  svm_test_mse <- mean((svm_test_predictions - test$Wins)^2)
  svm_test_rmse <- sqrt(svm_test_mse)
  svm_test_r2 <- 1 - sum((svm_test_predictions - test$Wins)^2) / sum((mean(test$Wins) - test$Wins)^2)
  
  # Predict 2024 Wins with SVM
  svm_predictions_2024 <- predict(svm_model, standardized_2024_data)
  svm_predicted_wins_2024 <- (svm_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  
  # Ensure predictions for 2024 have the correct number of rows
  print(paste("Rows in svm_predictions_2024:", length(svm_predictions_2024)))
  
  return(list(
    metrics = data.frame(
      Model = c("Linear Regression", "Random Forest", "XGBoost", "SVM"),
      Train_MAE = c(lm_train_mae, rf_train_mae, xgb_train_mae, svm_train_mae),
      Train_MSE = c(lm_train_mse, rf_train_mse, xgb_train_mse, svm_train_mse),
      Train_RMSE = c(lm_train_rmse, rf_train_rmse, xgb_train_rmse, svm_train_rmse),
      Train_R2 = c(lm_train_r2, rf_train_r2, xgb_train_r2, svm_train_r2),
      Test_MAE = c(lm_test_mae, rf_test_mae, xgb_test_mae, svm_test_mae),
      Test_MSE = c(lm_test_mse, rf_test_mse, xgb_test_mse, svm_test_mse),
      Test_RMSE = c(lm_test_rmse, rf_test_rmse, xgb_test_rmse, svm_test_rmse),
      Test_R2 = c(lm_test_r2, rf_test_r2, xgb_test_r2, svm_test_r2)
    ),
    predictions_2024 = data.frame(
      Model = c("Linear Regression", "Random Forest", "XGBoost", "SVM"),
      Predicted_Wins_2024 = c(lm_predicted_wins_2024, rf_predicted_wins_2024, xgb_predicted_wins_2024, svm_predicted_wins_2024)
    )
  ))
}


# Storage for results
all_results <- list()

# Loop through each feature grouping
for (group_name in names(feature_groupings)) {
  
  feature_grouping <- feature_groupings[["feature_grouping_1"]]
  
  feature_grouping <- feature_groupings[[group_name]]
  result <- predict_wins(feature_grouping, original_data, predictive_2024_data, columns_to_exclude)
  
  # Add feature group to metrics and predictions
  result$metrics$Feature_Group <- group_name
  result$predictions_2024$Feature_Group <- group_name
  
  # Store results
  all_results[[group_name]] <- result
}

# Combine all metrics and predictions into single DataFrames
combined_metrics <- do.call(rbind, lapply(all_results, `[[`, "metrics"))
combined_predictions <- do.call(rbind, lapply(all_results, `[[`, "predictions_2024"))

# Convert to DataFrame
combined_metrics_df <- as.data.frame(combined_metrics)
combined_predictions_df <- as.data.frame(combined_predictions)

# Ensure that Test_R2 is numeric
combined_metrics_df$Test_R2 <- as.numeric(as.character(combined_metrics_df$Test_R2))

# Identify the row with the highest Test_R2
best_model_row <- combined_metrics_df[which.max(combined_metrics_df$Test_R2), ]

best_model <- best_model_row$Model
best_feature_group <- best_model_row$Feature_Group



# Create a list to store predictions dataframes for each model and feature grouping
all_predictions_list <- list()

# Loop through each unique model and feature grouping
for (model in unique(combined_predictions_df$Model)) {
  for (feature_group in unique(combined_predictions_df$Feature_Group)) {
    # Extract predictions for the current model and feature grouping
    current_predictions <- combined_predictions_df[
      combined_predictions_df$Feature_Group == feature_group &
        combined_predictions_df$Model == model, 
    ]
    
    # Combine with predictive_2024_data
    predictions_with_teams <- cbind(
      predictive_2024_data[, c("Team", "Year")],
      current_predictions[, c("Predicted_Wins_2024", "Model", "Feature_Group")]
    )
    
    # Select the columns we need
    predictions_with_teams <- predictions_with_teams[, c("Team", "Year", "Predicted_Wins_2024", "Model", "Feature_Group")]
    
    # Create a DataFrame name based on model and feature grouping
    df_name <- paste("Predictions_Model_", model, "_FeatureGroup_", feature_group, sep = "")
    
    # Dynamically assign the DataFrame to the environment
    assign(df_name, predictions_with_teams)
  }
}


print(combined_metrics_df)
