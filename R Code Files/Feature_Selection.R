library(VIM)
library(ranger)
library(caret)
library(xgboost)
library(glmnet)
library(mlbench)
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(reshape2)
library(glmnet)
library(Metrics)  
library(MASS)



#Feature Selection Notebook

ind_features_standardized <- read.csv("C:/Users/colet/Documents/Personal Projects/Predictive_MLB_Payroll_Data.csv")


#setting the test and train sets
# Remove non-predictive and non-numeric columns
new_df <- ind_features_standardized[, !names(ind_features_standardized) %in% c("Team", "Year", "Playoff_Status")]
#Train/set 80/20
set.seed(123)
size <- floor(.8 * nrow(new_df))
train_ind <- sample(seq_len(nrow(new_df)), size=size)
train <- new_df[train_ind, ]
xtrain <- train[,2:49]
ytrain<- train[,1]
#Creating values not chosen
#test values
test <- new_df[-train_ind,]
xtest<-test[,2:49]
ytest<-test[,1]


#Filter Methods

# Correlation analysis with wins

# Calculate correlation coefficients between each feature and the target variable
correlations <- cor(xtrain, ytrain)
correlation_df <- data.frame(Feature = rownames(correlations), Correlation = correlations)
# Creating Bar Plot of features and correlations
ggplot(correlation_df, aes(x = reorder(Feature, Correlation), y = Correlation)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Feature Correlation with Wins", x = "Feature", y = "Correlation Coefficient") +
  theme_minimal()


# Define a correlation threshold
threshold <- 0.3
# Filter features based on the correlation threshold
filtered_features_df <- correlation_df[abs(correlation_df$Correlation) > threshold, ]
# Get the names of the filtered features
filtered_features <- filtered_features_df$Feature

# Reduce the training data to include only the filtered features
xtrain_filtered <- xtrain[, filtered_features]
train_filtered <- data.frame(Wins = ytrain, xtrain_filtered)
# Reduce the testing data to include only the filtered features
xtest_filtered <- xtest[, filtered_features]
test_filtered <- data.frame(Wins = ytest, xtest_filtered)
# Creating Bar Plot of reduced features
ggplot(filtered_features_df, aes(x = reorder(Feature, Correlation), y = Correlation)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Feature Correlation with Wins", x = "Feature", y = "Correlation Coefficient") +
  theme_minimal()

# Checking for collinearity 
# create heatmap by calculating the correlation matrix for the reduced dataframe
correlation_matrix <- cor(train_filtered)
# Melt the reduced correlation matrix
melted_corr_reduced <- melt(correlation_matrix)
# Create the heatmap with x-axis labels at a 90-degree angle and a title
ggplot(data = melted_corr_reduced, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name = "Correlation") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 12)) +
  coord_fixed() +
  ggtitle("Correlation Heatmap of Filtered Features")

#Removing highly correlated features in the reduced df
# Set a threshold for collinearity
threshold <- 0.75
# Find columns to remove
remove_cols <- findCorrelation(correlation_matrix, cutoff = threshold, names = TRUE)
# Filter the dataframe to remove highly collinear features
train_filtered_reduced <- train_filtered %>% select(-all_of(remove_cols))
# Print the names of removed features
print(remove_cols)
# Print the remaining features
print(colnames(train_filtered_reduced))

# Creating final correlation bar chart
# Calculate the correlation with the target variable 'Wins'
correlations <- cor(train_filtered_reduced, use = "complete.obs")
correlation_df <- data.frame(Feature = colnames(correlations), Correlation = correlations["Wins",])
# Remove the correlation with 'Wins' itself (if included in the dataset)
correlation_df <- correlation_df %>% filter(Feature != "Wins")
# Create the bar plot
ggplot(correlation_df, aes(x = reorder(Feature, Correlation), y = Correlation)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Feature Correlation with Wins", x = "Feature", y = "Correlation Coefficient") +
  theme_minimal()

# Extract the feature names from `correlation_df`
selected_features <- correlation_df$Feature
# Create a new dataframe with selected features, 'Team', 'Year', and 'Wins'
new_df <- ind_features_standardized %>%
  select(all_of(c("Team", "Year", selected_features, "Wins")))
# Print the structure of the new dataframe
print(head(new_df))# Save dataframe to a CSV file
#Save Corrlation Coefficient Features
write.csv(new_df, file = "CorrelationCoefFeaturesDF.csv", row.names = FALSE)
getwd()



# Names of the dataframes you want to keep
keep_dfs <- c("df", "ind_features", "ind_features_standardized", "xtrain", "ytrain", "xtest","ytest")
rm(list = setdiff(ls(), keep_dfs))



#Embedded Methods


#Random Forest Feature Importance

# Train the RandomForest model using the training data
model <- ranger(Wins ~ ., data = data.frame(Wins = ytrain, xtrain), importance = "permutation")
# Extract feature importance
importance <- model$variable.importance
# Create a DataFrame with important features and their importance scores
importance_score_df <- data.frame(
  Feature = names(importance),
  Importance = importance
)
# Sort the data frame in descending order based on the importance
importance_score_df <- importance_score_df[order(-importance_score_df$Importance), ]
# Plot using ggplot2
ggplot(importance_score_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "orange") +
  coord_flip() +
  labs(title = "Feature Importance", x = "Feature", y = "Importance") +
  theme_minimal()
# Make predictions on the test data
y_pred <- predict(model, data = data.frame(xtest))$predictions
# Calculate evaluation metrics
mae_value <- mae(ytest, y_pred)
mse_value <- mse(ytest, y_pred)
rmse_value <- sqrt(mse_value)
r2_value <- cor(ytest, y_pred)^2
# Print metrics
print(paste("Mean Absolute Error (MAE):", round(mae_value, 2)))
print(paste("Mean Squared Error (MSE):", round(mse_value, 2)))
print(paste("Root Mean Squared Error (RMSE):", round(rmse_value, 2)))
print(paste("R-squared (R²):", round(r2_value, 2)))

# Subset to the top 10 features
top10_importance <- importance_score_df[1:15, ]
# Plot using ggplot2
ggplot(top10_importance, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "orange") +
  coord_flip() +
  labs(title = "Top 15 Feature Importance", x = "Feature", y = "Importance") +
  theme_minimal()
print(top10_importance)

# List of features with coefficients having an absolute value >= 0.13
selected_features <- c("Average.Age", "Active.Payroll", "Median_Exp",
                       "Diff_From_League_Avg_Payroll", "Position_Percent_Payroll_RP", "Retained", "Top3_Percent")
# Create a subset of the DataFrame with only the selected features
rf_df <- ind_features_standardized[, c("Wins", "Team", "Year", selected_features)]
#Save Random Forest Features
write.csv(rf_df, file = "RandomForestFeaturesDF.csv", row.names = FALSE)
getwd()




# Names of the dataframes you want to keep
keep_dfs <- c("df", "ind_features", "ind_features_standardized", "xtrain", "ytrain", "xtest","ytest")
rm(list = setdiff(ls(), keep_dfs))



# L1 regularization (Lasso regression)
#Creating lambda array
lambda.array <- seq(from = 0.01, to = 100, by = 0.01)
# Convert to matrix if not already
xtrain_matrix <- as.matrix(xtrain)
xtest_matrix <- as.matrix(xtest)

# Lasso Regression 
lassoFit <- glmnet(xtrain_matrix, ytrain, alpha = 1, lambda = lambda.array)
summary(lassoFit)
#Lambdas in relation to the coefficients
plot(lassoFit, xvar='lambda', label=T)
# Goodness of fit
plot(lassoFit, xvar='dev', label=T)
#predicted values
y_predicted_lass <- predict(lassoFit, s=min(lambda.array), newx = xtest_matrix)

# Coefficients
coefficients_lasso  <- predict(lassoFit, s = min(lambda.array), newx = xtest, type = 'coefficients')
coefficients_lasso_df <- as.data.frame(as.matrix(coefficients_lasso))
coefficients_lasso_df$Feature <- rownames(coefficients_lasso_df)
# Rename the column for clarity
colnames(coefficients_lasso_df)[1] <- "Coefficient"
# Sort the data frame in descending order based on the coefficients
coefficients_lasso_df <- coefficients_lasso_df[order(-coefficients_lasso_df$Coefficient), ]
# Plot the sorted coefficients
ggplot(coefficients_lasso_df, aes(x = reorder(Feature, -Coefficient), y = Coefficient)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Flip the coordinates to make it easier to read
  xlab("Features") +
  ylab("Coefficient Value") +
  ggtitle("Lasso Regression Coefficients") +
  theme_minimal()
# Remove the intercept term if present
coefficients_lasso_df <- coefficients_lasso_df[rownames(coefficients_lasso_df) != "(Intercept)", ]
# Filter coefficients with absolute value >= 0.1
significant_coefficients <- coefficients_lasso_df[abs(coefficients_lasso_df$Coefficient) >= 0.1, ]
# Count significant coefficients
significant_count <- nrow(significant_coefficients)
print(paste("Number of features with absolute coefficient >= 0.1:", significant_count))
# Display the filtered coefficients
print(significant_coefficients)
# Plot the sorted coefficients
ggplot(significant_coefficients, aes(x = reorder(Feature, -Coefficient), y = Coefficient)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Flip the coordinates to make it easier to read
  xlab("Features") +
  ylab("Coefficient Value") +
  ggtitle("Lasso Regression Coefficients") +
  theme_minimal()

# List of features with coefficients having an absolute value >= 0.13
selected_features <- c("Average.Age", "Active.Payroll", "Position_Payroll_RP",
                       "Top3_Percent", "Injured", "Retained")
# Create a subset of the DataFrame with only the selected features
subset_df <- ind_features_standardized[, c("Wins", "Team", "Year", selected_features)]#Save Random Forest Features
write.csv(subset_df, file = "LassoFeatures.csv", row.names = FALSE)
getwd()

# SSE, SST, rsquare
sst <- sum((ytest - mean(ytest))^2)
sse <- sum((y_predicted_lass- ytest)^2)  
rsquare_lasso <- 1 - (sse/sst)  
#MSE 
mse_lasso <- (sum((y_predicted_lass - ytest)^2) / length(y_predicted_lass))
mse_lasso
plot(ytest, y_predicted_lass, main = 'Predicted, actual wins')
# Print MSE and R-squared
print(paste("Mean Squared Error (MSE) for Lasso:", round(mse_lasso, 2)))
print(paste("R-squared (R²) for Lasso:", round(rsquare_lasso, 2)))


# Names of the dataframes you want to keep
keep_dfs <- c("df", "ind_features", "ind_features_standardized", "xtrain", "ytrain", "xtest","ytest")
rm(list = setdiff(ls(), keep_dfs))



# Hybrid Wrapper-embedded Method

# Backward Selection followed by rf feature importance
# Create train and test data frames
train <- data.frame(Wins = ytrain, xtrain)
test <- data.frame(Wins = ytest, xtest)
# Perform Backward Selection
full_model <- lm(Wins ~ ., data = train)
step_model <- stepAIC(full_model, direction = "backward")
summary(step_model)
# Extract the final set of features
final_features <- names(coef(step_model))[-1]
print(final_features)
# Create a new training dataset with only the final features
train_final <- train[, c("Wins", final_features)]
# Fit the Random Forest model with the selected features
rf_model <- ranger(Wins ~ ., data = train_final, importance = 'impurity')
# Extract feature importance
feature_importance <- rf_model$variable.importance
feature_importance_df <- data.frame(
  Feature = names(feature_importance),
  Importance = feature_importance
)
# Plot the feature importance scores
ggplot(feature_importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "red") +
  coord_flip() +
  labs(title = "Feature Importance Scores After Backward Selection", x = "Feature", y = "Importance Score") +
  theme_minimal()
# Make predictions on the test data
y_pred <- predict(rf_model, data = data.frame(xtest))$predictions
# Calculate evaluation metrics
mae_value <- mae(ytest, y_pred)
mse_value <- mse(ytest, y_pred)
rmse_value <- sqrt(mse_value)
r2_value <- cor(ytest, y_pred)^2
# Print metrics
print(paste("Mean Absolute Error (MAE):", round(mae_value, 2)))
print(paste("Mean Squared Error (MSE):", round(mse_value, 2)))
print(paste("Root Mean Squared Error (RMSE):", round(rmse_value, 2)))
print(paste("R-squared (R²):", round(r2_value, 2)))


# Select the top 7 most important features
top_features <- names(sort(feature_importance, decreasing = TRUE))[1:7]
train_top <- train[, c("Wins", top_features)]
# Plot the feature importance scores for the top 7 features
top_feature_importance_df <- feature_importance_df[feature_importance_df$Feature %in% top_features, ]
ggplot(top_feature_importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "red") +
  coord_flip() +
  labs(title = "Top 7 Feature Importance Scores After Backward Selection", x = "Feature", y = "Importance Score") +
  theme_minimal()
# Print the final set of top features
print(top_feature_importance_df)
# Create a subset of the DataFrame with only the selected features
hybrid_df <- ind_features_standardized[, c("Wins", "Team", "Year", top_features)]#Save Random Forest Features
write.csv(hybrid_df, file = "Hybrid_features.csv", row.names = FALSE)
getwd()
