# Expansion of The Power of Money in Baseball

## Project Overview
This is my personal analytical continuation and expansion of my project, The Power of Money in Baseball, where I not only try to tell a visual story with the data, but conduct a full stack analysis that includes data ETL, EDA & supervised (and possibly unsupervised) machine learning modeling and analysis. 

The initial project was an 8-week long assignment for my "Data Visualization" Master's course in which the goal was to tell a visual story using Tableau software, which can be found on my GitHub [here](https://github.com/ColetonReitan/The-Power-of-Money-in-Baseball); 

This project is my personal continuation and expansion of the Power of Money in Baseball. 

## Project Status
As of 8/2/2024, I am currently working in the feature selection & modeling phase.


## Project Motivation
As someone who had played baseball from a very young age and for the extent of my academic career, this project serves the purpose to not only continue my practices in data science, but also allows me to continue my passion for the sport in a way other than playing. The sport of baseball is very analytically driven, with tons of data points being measured within the game everyday. However, with this project, I am choosing to find the value in the data points beyond the field and in the front office - specifically when it comes to team payroll data. 

The horror and beauty of payroll in baseball is that teams do not have to fear a payroll cap - as in owners and general managers can spend however much they would like to spend on their team, without restriction. This creates large discrepancies between team payrolls which then leads to the main questions this project is looking to answer - do these large discrepancies in payroll put certain franchises at an advantage or disadvantage? Is there such thing as spending too much money on a team? Should teams be investing more in players in certain positions? These are all questions (along with others to be mentioned) that will be answered with a statistical backing. 


## Reasearch Questions (More in depth questions included at the bottom of this page)
  1. Do payroll discrpancies put franchises at an advantage or disadvantage?

  2. Is there such thing as spending too much money on a team?

  3. Should teams be investing more in certain positions rather than other positions? 

  4. Is there a most winning-est payroll amount? 

  5. Are there league wide trends in payroll? If so, should teams be following them? 

## Methods

### Preprocessing
The Preprocessing portion of this project is broken down into two parts. The first involves the cleaning and integration of the data collected from the web scrapper - this is the data that will be analyzed in EDA. The second portion involves the transformation and creation/reduction in variables suitable for modeling. 

Cleaning and Integration - Performed within the web scrapper code file (Completed_MLB_Payroll_Data):
1) Checking and handling of NA's
2) Duplicate Removal
3) Data error correction
4) Data encoding
5) Handling of COVID-19 (2020) data

Transformation and Feature Creation/Reduction - Performed in preprocessed predictive features file (Predictive_MLB_Payroll_Data):
1) Creating new predictive features based on original data
2) Removing unneeded features
3) Standardizing the data

### EDA
The exploratory data analysis portion of this project will be broken down into 3 separate analyses (using Completed_MLB_Payroll_Data for analyses):    
1)  [League payroll (general)](League_Payroll_EDA.md)
2)  [Playoff and World Series Teams' Payrolls](Playoff_Team_Payroll_EDA.md)
3)  [Player and Position Payroll](Player_and_Position_Payroll_EDA.md)


### Feature Selection 
In terms of feature selection methods, a filter method and a few embedded methods will be used and analyzed to determine the best features to keep in predictive modeling (Using Predictive_MLB_Payroll_Data).    

Filter Methods: 
1) Correlation Analysis

Embedded Methods:   
1) Random Forest Feature Importance
2) L1 Regularization (Lasso Regression)
3) L2 Regularization (Ridge Regression)

### Modeling

### Analysis

## MetaData

Data Collection is now fully complete! The webscraper is fully functional.

#### Sources 
- All data aside from a team's wins, losses & playoff game appearances was collected from the website spotrac, linked [here](https://www.spotrac.com/mlb).  
- The data for the wins, losses & playoff game appearances was collected from the website baseball referenced, linked [here](https://www.baseball-reference.com/postseason/). The data being collected is for the seasons in years 2011 through 2024, with some possible forecasting insight into 2024.

#### Collection Method
I built a web scraper from scratch using R to collect the necessary data. The web scraper not only imports the data into R but also cleans and merges it into one dataframe. The code for the web scraper can be found in this repository. I'm particularly proud of it.

#### Dealing with COVID Data
The MLB in 2020 played a truncated season that consisted of 60 games, which is 37% of a normal season. The MLBPA and MLB came to an agreement that players would be paid 37% of their original salary for that season. Because of this, team total payrolls witnessed massive drops (in the data from spotrac). In order to keep the data as consistent as possible, I decided to calculate the expected (no covid) total payroll of the 2020 season by summing the non-adjusted payroll salaries of all players for each team. In addition to this, I applied the 60 game win loss ratio to every team to give wins and losses results for what would've been a 162 game season. However, this means that my data now says the Dodgers in 2020 are tied for first for the most games won in an MLB season at 116. Although it is unlikely that this team would have tied the MLB single season win record, the importance of having a full 162 games in a season for this analysis is much greater and translating a team's win loss record to a 162 game season would be the best way to do this. Note, 43 wins from a top ranking payroll would be significantly more misleading!!

#### Completed_MLB_Payroll_Data Variable Description
This is the cleaned (aside from certain NA's that were held) data file of all the data points collectd from the web scrapper. In this is data from 2011-2024 seasons and spans across 36 variables with nearly 20,000 observations which gives me almost 700,000 total values. This data contains specific player and team payroll data from every team in every season between 2011-2024.   

**Team**: Team Name  
**Abbreviation**: Team Name Abbreviation  
**Year**: Year of season being examined  
**Payroll.Ranking**: Payroll rank for specified team in specified season (1 is highest payroll 30 is lowest)  
**Total.Payroll**: The total payroll the specified team is paying in the season  
**League.Average.Payroll**: The average payroll across the league for the specified year  
**Previous.Year.Payroll**: The payroll from the previous year for the specified team  
**Payroll.Percent.Change**: The payroll percent change from the previous year for the specified team  
**Payroll.Difference**: The difference of the payroll in the specified year from the previous year  
**Active.Payroll**: The payroll amount that is dedicated to active players (for a team) in a specified year  
**Injured**: The payroll amount that is dedicated to injured players (for a team) in a specified year  
**Retained**: The payroll amount that is retained from players no longer on a team in a specified year  
**Buried**: The payroll amount that is dedicated to players not on the major league roster (minor league players)  
**Suspended**: The payroll amount that is dedicated to players suspended in a specified year    
**Player**: The specified player name  
**Pos**: The position the specified player plays  
**Exp**: The number of years (continuous) of experience a player has  
**Status**: Qualitative description of experience  
**Payroll.Salary**: The salary of the specified player  
**Type**: Which original table the data came from  
**Average.Age**: The average age of all the players on a specified team    
**Wins**: The amount of wins a team has in the season  
**Losses**: The amount of losses a team has in the season  
**W.L.**: The win-loss ratio for a team  
**Player_Group**: Tells where the player position is (Infield, Outfield, Pitcher, Designated_Hitter)    
**Diff_From_League_Average_Payroll**: Tells the difference between a team's total payroll and the league average payroll    
**Top1_Percent**: Gives the percentage of a team's total payroll that the highest paid player on that team takes up in a given year   
**Top3_Percent**: Gives the percentage of a team's total payroll that the 3 highest paid players on that team takes up in a given year   
**Top5_Percent**: Gives the percentage of a team's total payroll that the 5 highest paid players on that team takes up in a given year   
*The following variables are categorical and can be three different values: Won, Lost, or DNP (did not play)*  
**World.Series**: Says how the team did in the world series for the specified year  
**ALCS**: Says how the team did in the ALCS for the specified year  
**NLCS**: Says how the team did in the NLCS for the specified year  
**AL.Division.Series**: Says how the team did in the AL Division Series for the specified year  
**NL.Division.Series**: Says how the team did in the NL Division Series for the specified year  
**Wild.Card.Game**: Says how the team did in the Wild Card Game for the specified year  
**Playoff_Status**: Says how far a team made it into the playoffs: 0=DNP, 1=WC, 2=DS, 3=CS, 4=WS, 5=WSwin

``` r
df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
#Checking where the NA's are
colSums(is.na(df))
#Checking to make sure the datatypes are what they should be
str(df)
```
```r
> colSums(is.na(df))
                        Team                         Year                 Abbreviation                Total.Payroll 
                           0                            0                            0                            0 
              Active.Payroll                      Injured                     Retained                       Buried 
                           0                         4429                          380                         2481 
                   Suspended                       Player                          Pos                          Exp 
                       18247                            0                            0                         5741 
                      Status               Payroll.Salary                         Type                  Average.Age 
                        3671                           65                            0                            0 
                        W.L.                 World.Series                         ALCS                         NLCS 
                        1200                            0                            0                            0 
          AL.Division.Series           NL.Division.Series               Wild.Card.Game               Playoff_Status 
                           0                            0                            0                            0 
      League.Average.Payroll        Previous.Year.Payroll       Payroll.Percent.Change           Payroll.Difference 
                           0                         1267                         1267                         1267 
             Payroll.Ranking                         Wins                       Losses                 Player_Group 
                           0                         1200                         1200                            0 
Diff_From_League_Avg_Payroll                 Top1_Percent                 Top3_Percent                 Top5_Percent 
                           0                            0                            0                            0 
```

It is expected for there to be missing values in Previous year payroll, percent change and difference for 2011 (there is
no prior data).   
The high amount of missing values in the suspended column is also expected and ok, there shouldn't be players getting suspended
too often. Injured, retained, and buried are all expected to have missing values, as not every team has these parts of payroll every season.    
Experience and status have some missing values due to data quality. There wasn't always consistency across the website in terms of these fields being filled for every player.    
Wins, Losses, and W.L. should all have the same number of missing values, as these only pertain to the 2024 season (which will be predicted).     


#### Predictive_MLB_Payroll_Data Variable Description
This is the cleaned and standardized data file of all the data points collectd from the web scrapper. This contains data from 2012-2023 seasons and spans across 53 variables with 360 observations which gives me almost 20,000 total values. This data contains team-specific payroll data, with player specific data averaged, medianed, or grouped in a way so that each player on each team does **not** show up within the data. This data will be used to perform predictive modeling, as there is no repetition of data (bc there is no longer individual player data included) and only the predictive features from the original dataframe were kept. However, additional team-specific player data features were created. 

**Team**: Team Name  
**Abbreviation**: Team Name Abbreviation   
**Year**: Year of season being examined  
**Playoff_Status**: Says how far a team made it into the playoffs: 0=DNP, 1=WC, 2=DS, 3=CS, 4=WS, 5=WSwin  
**Wins**: The amount of wins a team has in the season (Target Variable 1)    
**Total.Payroll**: The total payroll the specified team is paying in the season   
**Active.Payroll**: The payroll amount that is dedicated to active players (for a team) in a specified year  
**Injured**: The payroll amount that is dedicated to injured players (for a team) in a specified year  
**Retained**: The payroll amount that is retained from players no longer on a team in a specified year  
**Buried**: The payroll amount that is dedicated to players not on the major league roster (minor league players)  
**Suspended**: The payroll amount that is dedicated to players suspended in a specified year  
**Average.Age**: The avereage age of all the players on a specified team  
**Payroll.Percent.Change**: The payroll percent change from the previous year for the specified team  
**Diff_From_League_Avg_Payroll**: Tells the difference between a team's total payroll and the league average payroll  
**Payroll.Ranking**: Payroll rank for specified team in specified season (1 is highest payroll 30 is lowest)  
**Top1_Percent**: Gives the percentage of a team's total payroll that the highest paid player on that team takes up in a given year  
**Top3_Percent**: Gives the percentage of a team's total payroll that the 3 highest paid players on that team takes up in a given year    
**Top5_Percent**: Gives the percentage of a team's total payroll that the 5 highest paid players on that team takes up in a given year   
**Median_Exp**: The median number of years of MLB time a team's players have  
**Mean_Exp**: The mean number of years of MLB time a team's players have  
**Position_Payroll_1B**: A team's total payroll salary of players who play first base    
**Position_Payroll_2B**: A team's total payroll salary of players who play second base    
**Position_Payroll_3B**: A team's total payroll salary of players who play third base    
**Position_Payroll_C**: A team's total payroll salary of players who play cather    
**Position_Payroll_CF**: A team's total payroll salary of players who play center field     
**Position_Payroll_DH**: A team's total payroll salary of players who play designated hitter    
**Position_Payroll_LF**: A team's total payroll salary of players who play left field    
**Position_Payroll_OF**: A team's total payroll salary of players who play outfield*    
**Position_Payroll_P**: A team's total payroll salary of players who play pitcher*    
**Position_Payroll_RF**: A team's total payroll salary of players who play right field     
**Position_Payroll_RP**: A team's total payroll salary of players who play relief pitcher    
**Position_Payroll_SP**: A team's total payroll salary of players who play starting pitcher    
**Position_Payroll_SS**: A team's total payroll salary of players who play short stop     
**Position_Percent_Payroll_1B**: The percent of a team's total payroll dedicated to players who play first base    
**Position_Percent_Payroll_2B**: The percent of a team's total payroll dedicated to players who play second base  
**Position_Percent_Payroll_3B**: The percent of a team's total payroll dedicated to players who play third base   
**Position_Percent_Payroll_C**: The percent of a team's total payroll dedicated to players who play cather    
**Position_Percent_Payroll_CF**: The percent of a team's total payroll dedicated to players who play center field    
**Position_Percent_Payroll_DH**: The percent of a team's total payroll dedicated to players who play designated hitter  
**Position_Percent_Payroll_LF**: The percent of a team's total payroll dedicated to players who play left field  
**Position_Percent_Payroll_OF**: The percent of a team's total payroll dedicated to players who play outfield*   
**Position_Percent_Payroll_P**: The percent of a team's total payroll dedicated to players who play pitcher*  
**Position_Percent_Payroll_RF**: The percent of a team's total payroll dedicated to players who play right field  
**Position_Percent_Payroll_RP**: The percent of a team's total payroll dedicated to players who play relief pitcher   
**Position_Percent_Payroll_SP**: The percent of a team's total payroll dedicated to players who play starting pitcher  
**Position_Percent_Payroll_SS**: The percent of a team's total payroll dedicated to players who play shortstop   
**Player_Group_Payroll_Designated_Hitter**: A team's total payroll salary of players who play designated hitter  
**Player_Group_Payroll_Infield**: A team's total payroll salary of players who play infield  
**Player_Group_Payroll_OutField**: A team's total payroll salary of players who play outfield  
**Player_Group_Payroll_Pitcher**: A team's total payroll salary of players who play pitcher  
**Player_Group_Percent_Payroll_Designated_Hitter**: The percent of a team's total payroll dedicated to players who play designated hitter   
**Player_Group_Percent_Payroll_Infield**: The percent of a team's total payroll dedicated to players who play infield  
**Player_Group_Percent_Payroll_OutField**: The percent of a team's total payroll dedicated to players who play outfield  
**Player_Group_Percent_Payroll_Pitcher**: The percent of a team's total payroll dedicated to players who play pitcher  
  
```r
df <- read.csv("C:/Users/colet/Documents/Personal Projects/Predictive_MLB_Payroll_Data.csv")
#Making sure no NA's exist
print(sum(is.na(df)))
```
```
> print(sum(is.na(df)))
[1] 0
```

## More Research Questions

#### Payroll Trends and Discrepancies:  

How have total payrolls for teams evolved over the years?  
What are the trends in league average payrolls over time?  
Are there significant discrepancies in payroll between the highest and lowest spending teams?  

#### Payroll vs. Performance:  

Is there a correlation between a team's total payroll and their win-loss record?  
Do higher payrolls consistently lead to better team performance (more wins, playoff appearances, World Series wins)?  

#### Payroll Distribution:  

How is payroll distributed among different player statuses (active, injured, retained, etc.)?  
What positions (Pos) receive the highest payroll on average?  

#### Impact of Payroll Changes:  

How do changes in payroll from the previous year affect team performance?  
Is there a significant impact of payroll percent change on win-loss records?   

#### Age and Experience Factors:  

How does the average age of a team correlate with their total payroll and performance?  
Does player experience (Exp) significantly impact payroll distribution?  

#### Injury and Retention Impact:  

How do injuries and retained salaries (Injured, Retained) affect a team's total payroll and performance?  
Are there trends in the proportion of payroll allocated to injured or retained players over the years?  

#### Playoff Success:  

What is the relationship between total payroll and playoff appearances (ALCS, NLCS, Division Series, Wild Card Game)?  
How do payrolls of World Series winning teams compare to those that did not make it to the playoffs?  

#### Salary Allocation:  

How does the salary allocation for different player positions vary among teams with different performance levels?  
Are there specific positions that teams invest more in for better performance outcomes?  







