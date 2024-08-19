# Modeling
(This page is in progress)

## Process  
The modeling process entails selecting different supervised machine learning models that may be best suited for the data, running the models against the data, assessing the performance of the models, conducting hyperparameter tuning, analyzing all of the models' performance to determine the best models, and finally predicting team wins in the 2024 MLB season.  
The goal is to create a model that best predicts 2024 team wins based on the predetermined feature groups.   
The feature groups have be selected in the feature selection portion of the project.   
The data has been split into training and testing sets with an 80/20 split.  
Multiple supervised machine learning models will be used and assessed. 

## Feature Groups
Each of the feature groups created in the feature selection portion of the project were loaded into R and named as feature_grouping_#.   
```r
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
```

### Feature Group Variables
To reiterate, the feature groupings are as follows: 

- **Feature Group 1:**  Average.Age, Active.Payroll, Median_Exp, Retained, Payroll.Percent.Change, Player_Group_Payroll_Pitcher, Player_Group_Payroll_OutField, Top1_Percent  

- **Feature Group 2:** Average.Age, Active.Payroll, Median_Exp, Retained, Diff_From_League_Avg_Payroll, Position_Percent_Payroll_RP, Top3_Percent 

- **Feature Group 3:** Average.Age, Active.Payroll, Retained, Injured, Position_Payroll_RP, Top3_Percent  

- **Feature Group 4:** Average.Age, Retained, Position_Payroll_RP, Top3_Percent, Payroll.Percent.Change, Total.Payroll, Payroll.Ranking

Note* The standardized values of the features were used in the modeling process  


## Selecting Models
In order to create as accurate of a model as possible, it's important to first choose models that work best with the data and help produce the results being looked for. The selected supervised machine learning models have been selected and will be used throughout the modeling portion of the project:   

### Chosen Models
- Multiple Linear Regression Model  
    A simple and interpretable model but may not perform well if there are complex relationships.   
- Support Vector Machine (Regressor) Model  
    An effective model in high dimensional spaces that can handle non-linear relationships, but may require careful hyperparameter tuning.  
- Random Forest (Regressor) Model  
    An accurate model that reduces overfitting but may be less interpretable than a simpler model.  
- XGBoost (Regressor) Model  
    A high performance model that reduces overfitting through regularization but also requires careful hyperparameter tuning. 


## Creating Models
The code for the modeling was created so that each feature grouping would used by each model in one run.  
- Created a function named predict_wins that would take the current feature group data, standardize and split the feature group data, then apply this standardized and split feature group data to each model, while collecting the results for later analysis.
```r
predict_wins <- function(feature_grouping, original_data, predictive_2024_data, columns_to_exclude) {
```
- Created a for loop that uses each feature grouping's data with the predict_wins function and collect results.
```r
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
```
- The full code is available in the R code files area of this repository.

The modeling libaries/functions used in R are as follows: 
  - lm() function in base R was used for the multiple linear regression model
  - ranger() function in the ranger library was used for the random forest model
  - xgb.train() function in the xgboost library was used for the xgboost model
  - ksvm() function in the kernlab library was used for the svm model

### Hyperparameter Tuning
A second function named predict_wins_HP was created which applied Grid Search hyperparameter tuning to each of the models (aside from multiple linear regression) in order to improve the error metrics of the models.   
This function follows a very similar layout to that of predict_wins aside from the hyperparameter tuning. The multiple linear regression model was kept in this function to ensure data consistency.   

The hyperparameter tuning adjustments are as follows: 
- Random Forest Model: uses a grid search approach with 5-fold cross-validation to find the optimal values for mtry, splitrule, and min.node.size parameters.  
- XGBoost Model: uses a grid search approach to evaluate different combinations of eta, max_depth, subsample, and colsample_bytree parameters, with 100 rounds for each combination.
- SVM Model: uses a grid search approach to evaluate different combinations of C and sigma parameters by iterating through all possible combinations from specified lists.  


## Model Error Metrics
After running the models on the data, it's important to assess how the models did by examining the models' error metrics.
Since this is a regression analysis, the metrics being examined are as follows:  
- MAE (Mean Absolute Error): Measures the average absolute difference between actual and predicted values.
- MSE (Mean Squared Error): Measures the average of the squared differences between actual and predicted values.  
- RMSE (Root Mean Squared Error): Measures the square root of the average squared differences between actual and predicted values, highlighting larger errors more.  
- R² (R-squared or Coefficient of Determination): Indicates the proportion of the variance in the actual values that is predictable from the predicted values, with 1 being a perfect fit.  

The error metrics for the Initial Models and the Hyperparameter Tuned Models are below.   

### Initial Model Metrics
| Model            | Feature Group | Train_MAE | Train_MSE | Train_RMSE | Train_R2 | Test_MAE | Test_MSE | Test_RMSE | Test_R2 |
|------------------|------------------|-----------|-----------|------------|----------|----------|----------|-----------|---------|
| Linear Regression | 1                | 0.600     | 0.585     | 0.765      | 0.409    | 0.624    | 0.566    | 0.753     | 0.431   |
| Linear Regression | 2                | 0.610     | 0.600     | 0.774      | 0.394    | 0.592    | 0.542    | 0.736     | 0.455   |
| Linear Regression | 3                | 0.619     | 0.601     | 0.775      | 0.392    | 0.585    | 0.540    | 0.735     | 0.457   |
| Linear Regression | 4                | 0.612     | 0.613     | 0.783      | 0.381    | 0.627    | 0.567    | 0.753     | 0.430   |
| Support Vector Machine              | 1                | 0.453     | 0.412     | 0.642      | 0.584    | 0.686    | 0.687    | 0.829     | 0.310   |
| Support Vector Machine               | 2                | 0.466     | 0.414     | 0.644      | 0.581    | 0.613    | 0.611    | 0.782     | 0.386   |
| Support Vector Machine               | 3                | 0.484     | 0.436     | 0.660      | 0.560    | 0.586    | 0.529    | 0.727     | 0.469   |
| Support Vector Machine               | 4                | 0.484     | 0.444     | 0.667      | 0.551    | 0.664    | 0.659    | 0.812     | 0.338   |
| Random Forest     | 1                | 0.268     | 0.121     | 0.348      | 0.878    | 0.619    | 0.584    | 0.764     | 0.413   |
| Random Forest     | 2                | 0.269     | 0.120     | 0.346      | 0.879    | 0.615    | 0.587    | 0.766     | 0.411   |
| Random Forest     | 3                | 0.281     | 0.127     | 0.357      | 0.871    | 0.601    | 0.559    | 0.748     | 0.438   |
| Random Forest     | 4                | 0.281     | 0.131     | 0.362      | 0.868    | 0.670    | 0.645    | 0.803     | 0.353   |
| XGradient Boosting           | 1                | 0.356     | 0.213     | 0.462      | 0.785    | 0.636    | 0.602    | 0.776     | 0.396   |
| XGradient Boosting           | 2                | 0.412     | 0.279     | 0.528      | 0.718    | 0.645    | 0.623    | 0.789     | 0.374   |
| XGradient Boosting           | 3                | 0.399     | 0.252     | 0.502      | 0.746    | 0.610    | 0.571    | 0.756     | 0.426   |
| XGradient Boosting           | 4                | 0.393     | 0.252     | 0.502      | 0.745    | 0.623    | 0.590    | 0.768     | 0.408   |  

The initial model error metrics display an array of inormation that give early insight as to which model may be the most reliable as well as which feature grouping provides the most insight.  
- Feature Group 3 is consistently the most interpretable, with each model showing the highest test R2 values for that grouping  
- Linear regression model is the most reliable model, holding the highest R2 of all the models  
- Random forest is showing early signs of model overfitting, possessing a strong train R2 but a marginally weak test R2  
- Test MAE, MSE, and RSME are fairly consistent across all models  



### Model Metrics with HyperParameter Tuning
| Model             | Feature Group | Train_MAE | Train_MSE | Train_RMSE | Train_R2 | Test_MAE | Test_MSE | Test_RMSE | Test_R2 |
|-------------------|------------------|-----------|-----------|------------|----------|----------|----------|-----------|---------|
| Linear Regression | 1                | 0.600     | 0.585     | 0.765      | 0.409    | 0.624    | 0.566    | 0.753     | 0.431   |
| Linear Regression | 2                | 0.610     | 0.600     | 0.774      | 0.394    | 0.592    | 0.542    | 0.736     | 0.455   |
| Linear Regression | 3                | 0.619     | 0.601     | 0.775      | 0.392    | 0.585    | 0.540    | 0.735     | 0.457   |
| Linear Regression | 4                | 0.612     | 0.613     | 0.783      | 0.381    | 0.627    | 0.567    | 0.753     | 0.430   |
| Support Vector Machine               | 1                | 0.549     | 0.533     | 0.730      | 0.462    | 0.618    | 0.560    | 0.749     | 0.437   |
| Support Vector Machine               | 2                | 0.558     | 0.530     | 0.728      | 0.464    | 0.579    | 0.527    | 0.726     | 0.471   |
| Support Vector Machine               | 3                | 0.524     | 0.483     | 0.695      | 0.512    | 0.578    | 0.521    | 0.722     | 0.476   |
| Support Vector Machine               | 4                | 0.555     | 0.542     | 0.736      | 0.453    | 0.620    | 0.568    | 0.754     | 0.429   |
| Random Forest     | 1                | 0.227     | 0.085     | 0.292      | 0.914    | 0.622    | 0.596    | 0.772     | 0.401   |
| Random Forest     | 2                | 0.226     | 0.083     | 0.288      | 0.916    | 0.612    | 0.595    | 0.772     | 0.402   |
| Random Forest     | 3                | 0.251     | 0.101     | 0.317      | 0.898    | 0.595    | 0.557    | 0.746     | 0.441   |
| Random Forest     | 4                | 0.281     | 0.131     | 0.363      | 0.867    | 0.661    | 0.632    | 0.795     | 0.365   |
| XGradient Boosting           | 1                | 0.000     | 0.000     | 0.001      | 1.000    | 0.637    | 0.623    | 0.789     | 0.375   |
| XGradient Boosting           | 2                | 0.321     | 0.166     | 0.407      | 0.833    | 0.623    | 0.589    | 0.767     | 0.409   |
| XGradient Boosting           | 3                | 0.067     | 0.008     | 0.087      | 0.992    | 0.610    | 0.553    | 0.744     | 0.444   |
| XGradient Boosting           | 4                | 0.539     | 0.458     | 0.676      | 0.538    | 0.665    | 0.657    | 0.811     | 0.340   |

With hyperparameter tuning, it is expected for the models to perform better, with majority basis being on the R2 with the other error metrics being taken into consideration.    
The hyperparameter tuning on the models solidify and provide further insight as to which model is the most reliable as well as which feature grouping provides the greatest insights.  
- Support Vector Machines hold the consistently highest R2, aided by the hyperparameter tuning performed to the models  
- Feature Group 3 continues to contain the best insight for the models
- Random forest and xgboost hyperparameter tuning resulted in more overfitting, although the models do perform better on the testing set  

## Best Models 

### Best of Each Type of Model
| Model             | Feature Group | Train_MAE | Train_MSE | Train_RMSE | Train_R2 | Test_MAE | Test_MSE | Test_RMSE | Test_R2 |
|-------------------|------------------|-----------|-----------|------------|----------|----------|----------|-----------|---------|
| Linear Regression | 3                | 0.619     | 0.601     | 0.775      | 0.392    | 0.585    | 0.540    | 0.735     | 0.457   |
| Support Vector Machine*               | 3                | 0.524     | 0.483     | 0.695      | 0.512    | 0.578    | 0.521    | 0.722     | 0.476   |
| Random Forest*     | 3                | 0.251     | 0.101     | 0.317      | 0.898    | 0.595    | 0.557    | 0.746     | 0.441   |
| XGradient Boosting*           | 3               | 0.067     | 0.008     | 0.087      | 0.992    | 0.610    | 0.553    | 0.744     | 0.444   |

This table shows the best performing model for each of the models used, with each finding feature group 3 to provide the greatest amount of insight. 

### Top Overall Models
| Model             | Feature Group | Train_MAE | Train_MSE | Train_RMSE | Train_R2 | Test_MAE | Test_MSE | Test_RMSE | Test_R2 |
|-------------------|------------------|-----------|-----------|------------|----------|----------|----------|-----------|---------|
| Support Vector Machine*               | 3                | 0.524     | 0.483     | 0.695      | 0.512    | 0.578    | 0.521    | 0.722     | 0.476   |
| Support Vector Machine*               | 2                | 0.558     | 0.530     | 0.728      | 0.464    | 0.579    | 0.527    | 0.726     | 0.471   |
| Linear Regression | 3                | 0.619     | 0.601     | 0.775      | 0.392    | 0.585    | 0.540    | 0.735     | 0.457   |
| Linear Regression | 2                | 0.610     | 0.600     | 0.774      | 0.394    | 0.592    | 0.542    | 0.736     | 0.455   |

This table shows the best overall performing models, taking into account the R2 value as well as the testing error metrics.   
- SVM with hyperparameter tuning using feature groups 2 and 3 are the best models, holding the lowest test error metrics along with the highest R2 values.
- Linear regression models performed similarly to that of the SVM models, however the measure of R2 was lower with higher test error metrics. 
