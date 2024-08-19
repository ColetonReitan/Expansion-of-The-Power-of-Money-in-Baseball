library(dplyr)
library(caret)
library(xgboost)
library(ranger)
library(ggplot2)
library(tidyverse)


#Creating Models with HyperParameter Tuning



# Load data
original_data <- read.csv("C:/Users/colet/Documents/Personal Projects/Predictive2024_Unstandard_MLB_Payroll_Data.csv")
original_data_no2024 <- original_data[original_data$Year != 2024, ]
predictive_2024_data <- original_data[original_data$Year == 2024, ]

# Load feature groupings
corr_feats_main_1 <- read.csv("C:/Users/colet/Documents/Personal Projects/CorrelationCoefFeaturesDF.csv")
corr_feats_main_2 <- read.csv("C:/Users/colet/Documents/Personal Projects/RandomForestFeaturesDF.csv")
corr_feats_main_3 <- read.csv("C:/Users/colet/Documents/Personal Projects/LassoFeatures.csv")
corr_feats_main_4 <- read.csv("C:/Users/colet/Documents/Personal Projects/Hybrid_features.csv")
# Define feature groupings
feature_groupings <- list(
  feature_grouping_1 = corr_feats_main_1,
  feature_grouping_2 = corr_feats_main_2,
  feature_grouping_3 = corr_feats_main_3,
  feature_grouping_4 = corr_feats_main_4
)

# Columns to exclude from feature selection
columns_to_exclude <- c("Year", "Team", "Playoff_Status")


# Define the function to predict wins
predict_wins_HP <- function(feature_grouping, original_data, predictive_2024_data, columns_to_exclude) {
  # Filter the original data to exclude columns
  original_data_no2024 <- original_data[original_data$Year != 2024, ]
  predictive_2024_data <- original_data[original_data$Year == 2024, ]
  
  # Standardize the data, excluding specified columns
  data_to_standardize <- original_data_no2024[, !(names(original_data_no2024) %in% columns_to_exclude)]
  standardized_data <- scale(data_to_standardize)
  
  # Retrieve mean and standard deviation for inverse transformation
  mean_vals <- attr(standardized_data, "scaled:center")
  sd_vals <- attr(standardized_data, "scaled:scale")
  
  # Standardize predictive 2024 data
  standardized_2024_data <- predictive_2024_data
  standardized_2024_data[!(names(standardized_2024_data) %in% columns_to_exclude)] <- scale(
    predictive_2024_data[!(names(predictive_2024_data) %in% columns_to_exclude)],
    center = mean_vals,
    scale = sd_vals
  )
  
  # Filter for Feature Grouping
  feature_cols <- intersect(names(feature_grouping), names(original_data))
  feature_cols <- setdiff(feature_cols, columns_to_exclude)
  
  # Prepare datasets with selected features
  corr_feats <- cbind(standardized_data[, feature_cols], Wins = original_data_no2024$Wins)
  standardized_2024_data <- cbind(standardized_2024_data[, feature_cols], Wins = predictive_2024_data$Wins)
  
  # Convert to data.frame
  corr_feats <- as.data.frame(corr_feats)
  standardized_2024_data <- as.data.frame(standardized_2024_data)
  
  # Split Data into Training and Testing Sets
  set.seed(123)
  train_index <- sample(1:nrow(corr_feats), 0.8 * nrow(corr_feats))
  train <- corr_feats[train_index, ]
  test <- corr_feats[-train_index, ]
  
  results <- list()
  predictions_2024 <- list()
  
  # Linear Regression
  lm_model <- lm(Wins ~ ., data = train)
  
  # Training Metrics
  lm_train_predictions <- predict(lm_model, train)
  lm_train_mae <- mean(abs(lm_train_predictions - train$Wins))
  lm_train_mse <- mean((lm_train_predictions - train$Wins)^2)
  lm_train_rmse <- sqrt(lm_train_mse)
  lm_train_r2 <- summary(lm_model)$r.squared
  
  # Testing Metrics
  lm_predictions <- predict(lm_model, test)
  lm_mae <- mean(abs(lm_predictions - test$Wins))
  lm_mse <- mean((lm_predictions - test$Wins)^2)
  lm_rmse <- sqrt(lm_mse)
  lm_r2 <- 1 - sum((lm_predictions - test$Wins)^2) / sum((mean(test$Wins) - test$Wins)^2)
  
  results <- rbind(results, data.frame(Model = "Linear Regression", 
                                       Train_MAE = lm_train_mae, Train_MSE = lm_train_mse, Train_RMSE = lm_train_rmse, Train_R2 = lm_train_r2,
                                       Test_MAE = lm_mae, Test_MSE = lm_mse, Test_RMSE = lm_rmse, Test_R2 = lm_r2))
  
  lm_predictions_2024 <- predict(lm_model, standardized_2024_data)
  lm_predicted_wins_2024 <- (lm_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  predictions_2024 <- rbind(predictions_2024, data.frame(Model = "Linear Regression", Predicted_Wins_2024 = lm_predicted_wins_2024))
  
  # Random Forest with Hyperparameter Tuning
  rf_control <- trainControl(method = "cv", number = 5)
  rf_grid <- expand.grid(mtry = c(2, 4, 6), splitrule = "variance", min.node.size = c(1, 3, 5))
  rf_model <- train(Wins ~ ., data = train, method = "ranger", trControl = rf_control, tuneGrid = rf_grid, importance = 'impurity')
  
  # Training Metrics
  rf_train_predictions <- predict(rf_model, train)
  rf_train_mae <- mean(abs(rf_train_predictions - train$Wins))
  rf_train_mse <- mean((rf_train_predictions - train$Wins)^2)
  rf_train_rmse <- sqrt(rf_train_mse)
  rf_train_r2 <- 1 - sum((rf_train_predictions - train$Wins)^2) / sum((mean(train$Wins) - train$Wins)^2)
  
  # Testing Metrics
  rf_predictions <- predict(rf_model, test)
  rf_mae <- mean(abs(rf_predictions - test$Wins))
  rf_mse <- mean((rf_predictions - test$Wins)^2)
  rf_rmse <- sqrt(rf_mse)
  rf_r2 <- 1 - sum((rf_predictions - test$Wins)^2) / sum((mean(test$Wins) - test$Wins)^2)
  
  results <- rbind(results, data.frame(Model = "Random Forest", 
                                       Train_MAE = rf_train_mae, Train_MSE = rf_train_mse, Train_RMSE = rf_train_rmse, Train_R2 = rf_train_r2,
                                       Test_MAE = rf_mae, Test_MSE = rf_mse, Test_RMSE = rf_rmse, Test_R2 = rf_r2))
  
  rf_predictions_2024 <- predict(rf_model, standardized_2024_data)
  rf_predicted_wins_2024 <- (rf_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  predictions_2024 <- rbind(predictions_2024, data.frame(Model = "Random Forest", Predicted_Wins_2024 = rf_predicted_wins_2024))
  
  # XGBoost with Hyperparameter Tuning
  print("Starting XGBoost hyperparameter tuning...")
  feature_cols <- setdiff(feature_cols, "Wins")
  train_matrix <- as.matrix(train[, feature_cols])
  train_labels <- train[, "Wins"]
  test_matrix <- as.matrix(test[, feature_cols])
  test_labels <- test[, "Wins"]
  dtrain <- xgb.DMatrix(data = train_matrix, label = train_labels)
  dtest <- xgb.DMatrix(data = test_matrix, label = test_labels)
  xgb_grid <- expand.grid(
    eta = c(0.01, 0.1, 0.3),
    max_depth = c(3, 6, 9),
    subsample = c(0.5, 0.7, 1.0),
    colsample_bytree = c(0.5, 0.7, 1.0),
    nrounds = 100
  )
  
  best_xgb_model <- NULL
  best_xgb_r2 <- -Inf
  best_xgb_params <- list()
  
  for (i in 1:nrow(xgb_grid)) {
    params <- list(
      objective = "reg:squarederror",
      eval_metric = "rmse",
      eta = xgb_grid$eta[i],
      max_depth = xgb_grid$max_depth[i],
      subsample = xgb_grid$subsample[i],
      colsample_bytree = xgb_grid$colsample_bytree[i]
    )
    xgb_model <- xgb.train(params = params, data = dtrain, nrounds = xgb_grid$nrounds[i], verbose = 0)
    xgb_predictions <- predict(xgb_model, dtest)
    xgb_train_predictions <- predict(xgb_model, dtrain)
    xgb_test_predictions <- predict(xgb_model, dtest)
    
    # Training Metrics
    xgb_train_mae <- mean(abs(xgb_train_predictions - train_labels))
    xgb_train_mse <- mean((xgb_train_predictions - train_labels)^2)
    xgb_train_rmse <- sqrt(xgb_train_mse)
    xgb_train_r2 <- 1 - sum((xgb_train_predictions - train_labels)^2) / sum((mean(train_labels) - train_labels)^2)
    
    # Testing Metrics
    xgb_test_mae <- mean(abs(xgb_test_predictions - test_labels))
    xgb_test_mse <- mean((xgb_test_predictions - test_labels)^2)
    xgb_test_rmse <- sqrt(xgb_test_mse)
    xgb_test_r2 <- 1 - sum((xgb_test_predictions - test_labels)^2) / sum((mean(test_labels) - test_labels)^2)
    
    # Update best model if current model is better
    if (xgb_test_r2 > best_xgb_r2) {
      best_xgb_model <- xgb_model
      best_xgb_r2 <- xgb_test_r2
      best_xgb_train_mae <- xgb_train_mae
      best_xgb_train_mse <- xgb_train_mse
      best_xgb_train_rmse <- xgb_train_rmse
      best_xgb_train_r2 <- xgb_train_r2
      best_xgb_mae <- xgb_test_mae
      best_xgb_mse <- xgb_test_mse
      best_xgb_rmse <- xgb_test_rmse
      best_xgb_r2 <- xgb_test_r2
      best_xgb_params <- params
      
      
      # Print the best parameters when updated
      cat("Updating best XGBoost model. New best R2 =", xgb_test_r2, "\n")
      print("Best XGBoost params:")
      print(best_xgb_params)
    }    
  }
  
  results <- rbind(results, data.frame(Model = "XGBoost", 
                                       Train_MAE = best_xgb_train_mae, Train_MSE = best_xgb_train_mse, Train_RMSE = best_xgb_train_rmse, Train_R2 = best_xgb_train_r2,
                                       Test_MAE = best_xgb_mae, Test_MSE = best_xgb_mse, Test_RMSE = best_xgb_rmse, Test_R2 = best_xgb_r2))
  
  # Predict 2024 Wins with XGBoost using the best model
  dtest_2024 <- xgb.DMatrix(data = as.matrix(standardized_2024_data[, feature_cols]))
  xgb_predictions_2024 <- predict(best_xgb_model, dtest_2024)
  xgb_predicted_wins_2024 <- (xgb_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  predictions_2024 <- rbind(predictions_2024, data.frame(Model = "XGBoost", Predicted_Wins_2024 = xgb_predicted_wins_2024))
  
  # Initialize variables
  C_values <- c(1, 10, 50, 100)
  sigma_values <- c(0.001,0.05,0.01,0.1)
  
  best_svm_model <- NULL
  best_svm_r2 <- -Inf
  best_svm_C <- NULL
  best_svm_sigma <- NULL
  
  # Prepare matrices
  train_matrix <- as.matrix(train[, feature_cols])
  train_labels <- train$Wins
  test_matrix <- as.matrix(test[, feature_cols])
  test_labels <- test$Wins
  
  # Expand.grid for hyperparameters
  for (C in C_values) {
    for (sigma in sigma_values) {
      cat("Training SVM with C =", C, "and sigma =", sigma, "\n")
      
      # Train SVM model
      svm_model <- ksvm(
        x = train_matrix,
        y = train_labels,
        kernel = "rbfdot",
        kpar = list(sigma = sigma),
        C = C
      )
      
      # Predict on training and test data
      svm_train_predictions <- predict(svm_model, newdata = train_matrix)
      svm_test_predictions <- predict(svm_model, newdata = test_matrix)
      
      # Training Metrics
      svm_train_mae <- mean(abs(svm_train_predictions - train_labels))
      svm_train_mse <- mean((svm_train_predictions - train_labels)^2)
      svm_train_rmse <- sqrt(svm_train_mse)
      svm_train_r2 <- 1 - sum((svm_train_predictions - train_labels)^2) / sum((mean(train_labels) - train_labels)^2)
      
      # Testing Metrics
      svm_test_mae <- mean(abs(svm_test_predictions - test_labels))
      svm_test_mse <- mean((svm_test_predictions - test_labels)^2)
      svm_test_rmse <- sqrt(svm_test_mse)
      svm_test_r2 <- 1 - sum((svm_test_predictions - test_labels)^2) / sum((mean(test_labels) - test_labels)^2)
      
      
      # Update best model if current model is better
      if (svm_test_r2 > best_svm_r2) {
        best_svm_model <- svm_model
        best_xgb_r2 <- xgb_test_r2
        best_svm_train_mae <- svm_train_mae
        best_svm_train_mse <- svm_train_mse
        best_svm_train_rmse <- svm_train_rmse
        best_svm_train_r2 <- svm_train_r2
        best_svm_mae <- svm_test_mae
        best_svm_mse <- svm_test_mse
        best_svm_rmse <- svm_test_rmse
        best_svm_r2 <- svm_test_r2
        best_svm_C <- C
        best_svm_sigma <- sigma
        
      }
      
    }
  }
  
  results <- rbind(results, data.frame(Model = "SVM", 
                                       Train_MAE = best_svm_train_mae, Train_MSE = best_svm_train_mse, Train_RMSE = best_svm_train_rmse, Train_R2 = best_svm_train_r2,
                                       Test_MAE = best_svm_mae, Test_MSE = best_svm_mse, Test_RMSE = best_svm_rmse, Test_R2 = best_svm_r2))
  
  
  # Print the best hyperparameters
  cat("Best SVM model found with C =", best_svm_C, "and sigma =", best_svm_sigma, "with Test R2 =", best_svm_r2, "\n")
  
  # Predict on 2024 data
  svm_predictions_2024 <- predict(best_svm_model, newdata = as.matrix(standardized_2024_data[, feature_cols]))
  svm_predicted_wins_2024 <- (svm_predictions_2024 * sd_vals["Wins"]) + mean_vals["Wins"]
  predictions_2024 <- rbind(predictions_2024, data.frame(Model = "SVM", Predicted_Wins_2024 = svm_predicted_wins_2024))
  
  
  
  # Return results and predictions
  return(list(
    metrics = results,
    predictions_2024 = predictions_2024
  ))
}




# Storage for results
all_results <- list()

# Loop through each feature grouping
for (group_name in names(feature_groupings)) {
  feature_grouping <- feature_groupings[[group_name]]
  result <- predict_wins_HP(feature_grouping, original_data, predictive_2024_data, columns_to_exclude)
  
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


# Reshape the data to long format
combined_metrics_long <- combined_metrics %>%
  pivot_longer(cols = c(Train_R2, Test_R2), names_to = "Dataset", values_to = "R2")

# Plot the data
ggplot(combined_metrics_long, aes(x = Model, y = R2, fill = Dataset)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  labs(title = "Model Performance (R2)", y = "R2", fill = "Dataset") +
  scale_fill_manual(values = c("Train_R2" = "blue", "Test_R2" = "red"))

print(combined_metrics_df)
