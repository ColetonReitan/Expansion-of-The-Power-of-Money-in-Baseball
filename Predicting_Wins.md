# Predicting 2024 Team Wins

## Process
The prediction phase is here! In the modeling portion of the project, multiple models were created and tested on a handful of feature groupings to uncover the best models, determined through error metric assessment, that hold the greatest insight towards predicting the 2024 MLB season.   
With these best models, predictions of team wins in 2024 will be created. 

## Best Models
The best models were determined in the modeling portion of the project. As a reminder, these models are:
1) SVM with Hyperparameter tuning using Feature Group 3
2) SVM with Hyperparameter tuning using Feature Group 2
3) Linear Regression using Feature Group 3
4) Linear Regression using Feature Group 2

And as an additional reminder, the feature groupings are: 
- Feature Group 2: Average.Age, Active.Payroll, Median_Exp, Retained, Diff_From_League_Avg_Payroll, Position_Percent_Payroll_RP, Top3_Percent 
- Feature Group 3: Average.Age, Active.Payroll, Retained, Injured, Position_Payroll_RP, Top3_Percent

Let's predict!

## Model 1: SVM HP Tuning Feature Group 3

|    | Team                   | Year | Predicted_Wins_2024 | Model | Feature_Group       |
|----|------------------------|------|---------------------|-------|---------------------|
|  1 | chicago-cubs           | 2024 | 94                  | SVM   | feature_grouping_3  |
|  2 | toronto-blue-jays      | 2024 | 92                  | SVM   | feature_grouping_3  |
|  3 | minnesota-twins        | 2024 | 91                  | SVM   | feature_grouping_3  |
|  4 | seattle-mariners       | 2024 | 90                  | SVM   | feature_grouping_3  |
|  5 | st-louis-cardinals     | 2024 | 90                  | SVM   | feature_grouping_3  |
|  6 | kansas-city-royals     | 2024 | 88                  | SVM   | feature_grouping_3  |
|  7 | atlanta-braves         | 2024 | 87                  | SVM   | feature_grouping_3  |
|  8 | baltimore-orioles      | 2024 | 87                  | SVM   | feature_grouping_3  |
|  9 | pittsburgh-pirates     | 2024 | 86                  | SVM   | feature_grouping_3  |
| 10 | new-york-mets          | 2024 | 83                  | SVM   | feature_grouping_3  |
| 11 | milwaukee-brewers      | 2024 | 83                  | SVM   | feature_grouping_3  |
| 12 | chicago-white-sox      | 2024 | 83                  | SVM   | feature_grouping_3  |
| 13 | texas-rangers          | 2024 | 83                  | SVM   | feature_grouping_3  |
| 14 | cincinnati-reds        | 2024 | 82                  | SVM   | feature_grouping_3  |
| 15 | new-york-yankees       | 2024 | 82                  | SVM   | feature_grouping_3  |
| 16 | houston-astros         | 2024 | 82                  | SVM   | feature_grouping_3  |
| 17 | colorado-rockies       | 2024 | 81                  | SVM   | feature_grouping_3  |
| 18 | tampa-bay-rays         | 2024 | 81                  | SVM   | feature_grouping_3  |
| 19 | philadelphia-phillies  | 2024 | 80                  | SVM   | feature_grouping_3  |
| 20 | los-angeles-dodgers    | 2024 | 80                  | SVM   | feature_grouping_3  |
| 21 | los-angeles-angels     | 2024 | 79                  | SVM   | feature_grouping_3  |
| 22 | detroit-tigers         | 2024 | 79                  | SVM   | feature_grouping_3  |
| 23 | san-francisco-giants   | 2024 | 79                  | SVM   | feature_grouping_3  |
| 24 | arizona-diamondbacks   | 2024 | 78                  | SVM   | feature_grouping_3  |
| 25 | san-diego-padres       | 2024 | 75                  | SVM   | feature_grouping_3  |
| 26 | cleveland-guardians    | 2024 | 75                  | SVM   | feature_grouping_3  |
| 27 | boston-red-sox         | 2024 | 73                  | SVM   | feature_grouping_3  |
| 28 | washington-nationals   | 2024 | 73                  | SVM   | feature_grouping_3  |
| 29 | miami-marlins          | 2024 | 71                  | SVM   | feature_grouping_3  |
| 30 | oakland-athletics      | 2024 | 71                  | SVM   | feature_grouping_3  |


Now, as a data scientist, this is my best model.   
However, as a baseball enthusiast, this model isn't too great, for a few reasons.
1) I'm a Yankees fan, and 82 wins in a season is unacceptable.
2) Only 5 teams have 90 or more wins, and none more than 95 wins.  
   - This may be attributed to the lack of taking divisional play into account in my models - where a good team may play a bad team within a division more than another good team may play that bad team because they are outside the division.   
3) Consistently good teams, such as the Yankees, Dodgers, Phillies, and Padres are all around or below the .500 mark (81 wins).  
   - This gives me the hint that this model may be missing the mark somewhere, either overanalyzing or underanalyzing the importance of a certain feature within the feature group.  
   - This may also be attributed to the fact that this is not a time series analysis, so the number of wins from the previous year are not taken into account as a feature for the predicted year.   



## Model 2: SVM HP Tuning Feature Group 2

|    | Team                   | Year | Predicted_Wins_2024 | Model | Feature_Group       |
|----|------------------------|------|---------------------|-------|---------------------|
|  1 | texas-rangers          | 2024 | 97                  | SVM   | feature_grouping_2  |
|  2 | st-louis-cardinals     | 2024 | 95                  | SVM   | feature_grouping_2  |
|  3 | toronto-blue-jays      | 2024 | 93                  | SVM   | feature_grouping_2  |
|  4 | minnesota-twins        | 2024 | 93                  | SVM   | feature_grouping_2  |
|  5 | new-york-yankees       | 2024 | 92                  | SVM   | feature_grouping_2  |
|  6 | atlanta-braves         | 2024 | 91                  | SVM   | feature_grouping_2  |
|  7 | los-angeles-dodgers    | 2024 | 91                  | SVM   | feature_grouping_2  |
|  8 | chicago-cubs           | 2024 | 90                  | SVM   | feature_grouping_2  |
|  9 | milwaukee-brewers      | 2024 | 89                  | SVM   | feature_grouping_2  |
| 10 | kansas-city-royals     | 2024 | 89                  | SVM   | feature_grouping_2  |
| 11 | new-york-mets          | 2024 | 89                  | SVM   | feature_grouping_2  |
| 12 | baltimore-orioles      | 2024 | 89                  | SVM   | feature_grouping_2  |
| 13 | philadelphia-phillies  | 2024 | 88                  | SVM   | feature_grouping_2  |
| 14 | houston-astros         | 2024 | 88                  | SVM   | feature_grouping_2  |
| 15 | chicago-white-sox      | 2024 | 88                  | SVM   | feature_grouping_2  |
| 16 | pittsburgh-pirates     | 2024 | 88                  | SVM   | feature_grouping_2  |
| 17 | colorado-rockies       | 2024 | 87                  | SVM   | feature_grouping_2  |
| 18 | seattle-mariners       | 2024 | 87                  | SVM   | feature_grouping_2  |
| 19 | tampa-bay-rays         | 2024 | 84                  | SVM   | feature_grouping_2  |
| 20 | san-diego-padres       | 2024 | 84                  | SVM   | feature_grouping_2  |
| 21 | san-francisco-giants   | 2024 | 84                  | SVM   | feature_grouping_2  |
| 22 | cincinnati-reds        | 2024 | 84                  | SVM   | feature_grouping_2  |
| 23 | los-angeles-angels     | 2024 | 83                  | SVM   | feature_grouping_2  |
| 24 | arizona-diamondbacks   | 2024 | 83                  | SVM   | feature_grouping_2  |
| 25 | detroit-tigers         | 2024 | 83                  | SVM   | feature_grouping_2  |
| 26 | washington-nationals   | 2024 | 81                  | SVM   | feature_grouping_2  |
| 27 | cleveland-guardians    | 2024 | 80                  | SVM   | feature_grouping_2  |
| 28 | boston-red-sox         | 2024 | 80                  | SVM   | feature_grouping_2  |
| 29 | oakland-athletics      | 2024 | 75                  | SVM   | feature_grouping_2  |
| 30 | miami-marlins          | 2024 | 74                  | SVM   | feature_grouping_2  |


Again, as a data scientist, this is my second best model.   
However, as a baseball enthusiast, this model resulted in terrible predictions!  
1) Simply, these predictions are impossible.  
  - There are only 5 teams at or below a .500 win percentage (81 wins). Obviously, this cannot be the case as these teams do not play external teams, but rather play only the teams within the league. Therefore, it would be impossible for only 5 teams to be .500 or lower.
That's it.


## Model 3: Linear Regression Feature Group 3

|    | Team                   | Year | Predicted_Wins_2024 | Model              | Feature_Group       |
|----|------------------------|------|---------------------|--------------------|---------------------|
|  1 | atlanta-braves         | 2024 | 98                  | Linear Regression  | feature_grouping_3  |
|  2 | toronto-blue-jays      | 2024 | 95                  | Linear Regression  | feature_grouping_3  |
|  3 | new-york-yankees       | 2024 | 94                  | Linear Regression  | feature_grouping_3  |
|  4 | texas-rangers          | 2024 | 93                  | Linear Regression  | feature_grouping_3  |
|  5 | st-louis-cardinals     | 2024 | 91                  | Linear Regression  | feature_grouping_3  |
|  6 | chicago-cubs           | 2024 | 90                  | Linear Regression  | feature_grouping_3  |
|  7 | new-york-mets          | 2024 | 88                  | Linear Regression  | feature_grouping_3  |
|  8 | philadelphia-phillies  | 2024 | 87                  | Linear Regression  | feature_grouping_3  |
|  9 | minnesota-twins        | 2024 | 86                  | Linear Regression  | feature_grouping_3  |
| 10 | seattle-mariners       | 2024 | 85                  | Linear Regression  | feature_grouping_3  |
| 11 | kansas-city-royals     | 2024 | 84                  | Linear Regression  | feature_grouping_3  |
| 12 | baltimore-orioles      | 2024 | 84                  | Linear Regression  | feature_grouping_3  |
| 13 | houston-astros         | 2024 | 84                  | Linear Regression  | feature_grouping_3  |
| 14 | los-angeles-dodgers    | 2024 | 84                  | Linear Regression  | feature_grouping_3  |
| 15 | pittsburgh-pirates     | 2024 | 84                  | Linear Regression  | feature_grouping_3  |
| 16 | milwaukee-brewers      | 2024 | 82                  | Linear Regression  | feature_grouping_3  |
| 17 | cincinnati-reds        | 2024 | 82                  | Linear Regression  | feature_grouping_3  |
| 18 | chicago-white-sox      | 2024 | 82                  | Linear Regression  | feature_grouping_3  |
| 19 | tampa-bay-rays         | 2024 | 81                  | Linear Regression  | feature_grouping_3  |
| 20 | colorado-rockies       | 2024 | 81                  | Linear Regression  | feature_grouping_3  |
| 21 | san-diego-padres       | 2024 | 81                  | Linear Regression  | feature_grouping_3  |
| 22 | arizona-diamondbacks   | 2024 | 81                  | Linear Regression  | feature_grouping_3  |
| 23 | san-francisco-giants   | 2024 | 81                  | Linear Regression  | feature_grouping_3  |
| 24 | boston-red-sox         | 2024 | 80                  | Linear Regression  | feature_grouping_3  |
| 25 | detroit-tigers         | 2024 | 77                  | Linear Regression  | feature_grouping_3  |
| 26 | los-angeles-angels     | 2024 | 76                  | Linear Regression  | feature_grouping_3  |
| 27 | miami-marlins          | 2024 | 74                  | Linear Regression  | feature_grouping_3  |
| 28 | cleveland-guardians    | 2024 | 74                  | Linear Regression  | feature_grouping_3  |
| 29 | oakland-athletics      | 2024 | 72                  | Linear Regression  | feature_grouping_3  |
| 30 | washington-nationals   | 2024 | 71                  | Linear Regression  | feature_grouping_3  |

These predictions do seem like they could be more accurate, however they face a similar problem to that of the second model which is that there are not enough teams below .500.  
Otherwise, I would think that these predictions are solid. 

## Model 4: Linear Regression Feature Group 2

|    | Team                   | Year | Predicted_Wins_2024 | Model              | Feature_Group       |
|----|------------------------|------|---------------------|--------------------|---------------------|
|  1 | atlanta-braves         | 2024 | 99                  | Linear Regression  | feature_grouping_2  |
|  2 | new-york-yankees       | 2024 | 96                  | Linear Regression  | feature_grouping_2  |
|  3 | texas-rangers          | 2024 | 96                  | Linear Regression  | feature_grouping_2  |
|  4 | toronto-blue-jays      | 2024 | 96                  | Linear Regression  | feature_grouping_2  |
|  5 | st-louis-cardinals     | 2024 | 93                  | Linear Regression  | feature_grouping_2  |
|  6 | chicago-cubs           | 2024 | 91                  | Linear Regression  | feature_grouping_2  |
|  7 | philadelphia-phillies  | 2024 | 90                  | Linear Regression  | feature_grouping_2  |
|  8 | new-york-mets          | 2024 | 89                  | Linear Regression  | feature_grouping_2  |
|  9 | minnesota-twins        | 2024 | 89                  | Linear Regression  | feature_grouping_2  |
| 10 | los-angeles-dodgers    | 2024 | 87                  | Linear Regression  | feature_grouping_2  |
| 11 | seattle-mariners       | 2024 | 87                  | Linear Regression  | feature_grouping_2  |
| 12 | kansas-city-royals     | 2024 | 86                  | Linear Regression  | feature_grouping_2  |
| 13 | baltimore-orioles      | 2024 | 86                  | Linear Regression  | feature_grouping_2  |
| 14 | pittsburgh-pirates     | 2024 | 86                  | Linear Regression  | feature_grouping_2  |
| 15 | colorado-rockies       | 2024 | 85                  | Linear Regression  | feature_grouping_2  |
| 16 | houston-astros         | 2024 | 85                  | Linear Regression  | feature_grouping_2  |
| 17 | chicago-white-sox      | 2024 | 85                  | Linear Regression  | feature_grouping_2  |
| 18 | milwaukee-brewers      | 2024 | 84                  | Linear Regression  | feature_grouping_2  |
| 19 | tampa-bay-rays         | 2024 | 84                  | Linear Regression  | feature_grouping_2  |
| 20 | arizona-diamondbacks   | 2024 | 84                  | Linear Regression  | feature_grouping_2  |
| 21 | san-francisco-giants   | 2024 | 84                  | Linear Regression  | feature_grouping_2  |
| 22 | san-diego-padres       | 2024 | 83                  | Linear Regression  | feature_grouping_2  |
| 23 | cincinnati-reds        | 2024 | 83                  | Linear Regression  | feature_grouping_2  |
| 24 | boston-red-sox         | 2024 | 82                  | Linear Regression  | feature_grouping_2  |
| 25 | detroit-tigers         | 2024 | 80                  | Linear Regression  | feature_grouping_2  |
| 26 | los-angeles-angels     | 2024 | 79                  | Linear Regression  | feature_grouping_2  |
| 27 | miami-marlins          | 2024 | 76                  | Linear Regression  | feature_grouping_2  |
| 28 | cleveland-guardians    | 2024 | 76                  | Linear Regression  | feature_grouping_2  |
| 29 | oakland-athletics      | 2024 | 74                  | Linear Regression  | feature_grouping_2  |
| 30 | washington-nationals   | 2024 | 73                  | Linear Regression  | feature_grouping_2  |


Finally, we see that the last model also faces the same problem of not enough teams below .500.   
Although, the yankees have 96 wins, which is a very healthy amount, so I cannot complain!



## Analysis

After analyzing the predictions for MLB team wins in the 2024 season, it is evident that the predictive model was the expected best model; SVM with Hyperparameter Tunining using feature group 3.  
For the rest of the models, it may be said that there was a bias to create more wins than less, as each model had too few teams below a .500 win percentage.   
There may be the need for necessary adjustments moving forward to develop a way to account for league wide wins, and to ensure that the league is balanced in terms of wins and losses.


