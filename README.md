# Expansion of The Power of Money in Baseball

## Project Overview
This is my personal analytical continuation and expansion of my project, The Power of Money in Baseball, where I not only try to tell a visual stroy with the data, but conduct a full line analysis that includes data ETL, EDA & supervised (and possibly unsupervised) machine learning modeling and analysis. 

The initial project was an 8-week long assignment for my "Data Visualization" Master's course in which the goal was to tell a visual story using Tableau software, which can be found on my GitHub [here](https://github.com/ColetonReitan/The-Power-of-Money-in-Baseball); 

This project is my personal continuation and expansion of the Power of Money in Baseball. 

## Project Status
As of 7/11/2024, I am currently working in the EDA phase of this analysis.


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
I am currently working through part 2 of EDA (7/11/2024)

### EDA
The exploratory data analysis portion of this project will be broken down into 4 separate analyses: 
1)  League payroll (general)
2)  Playoff and World Series Teams' Payrolls
3)  Top 3rd, middle 3rd, and bottom 3rd team payroll ranking trends
4)  Player and position payroll distribution

### Modeling

### Statistical Analysis


## MetaData

Data Collection is now fully complete! The webscraper is fully functional.

#### Sources 
- All data aside from a team's wins, losses & playoff game appearances was collected from the website spotrac, linked [here](https://www.spotrac.com/mlb).  
- The data for the wins, losses & playoff game appearances was collected from the website baseball referenced, linked [here](https://www.baseball-reference.com/postseason/). The data being collected is for the seasons in years 2011 through 2024, with some possible forecasting insight into 2024.

#### Collection Method
I built a web scraper from scratch using R to collect the necessary data. The web scraper not only imports the data into R but also cleans and merges it into one dataframe. The code for the web scraper can be found in this repository. I'm particularly proud of it.

#### Variable Description
There are currently 31 variables with nearly 20,000 observations that gives me almost 600,000 total values.

**Team**: Team Name  
**Abbreviation**: Team Name Abbreviation  
**Year**: Year of season being examined  
**Payroll.Rank**: Payroll rank for specified team in specified season (1 is highest payroll 30 is lowest)  
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
**Average.Age**: The avereage age of all the players on a specified team    
**W**: The amount of wins a team has in the season  
**L**: The amount of losses a team has in the season  
**W-L%**: The win-loss ratio for a team  
*The following variables are categorical and can be three different values: Won, Lost, or DNP (did not play)*  
**World Series**: Says how the team did in the world series for the specified year  
**ALCS**: Says how the team did in the ALCS for the specified year  
**NLCS**: Says how the team did in the NLCS for the specified year  
**AL Division Series**: Says how the team did in the AL Division Series for the specified year  
**NL Division Series**: Says how the team did in the NL Division Series for the specified year  
**Wild Card Game**: Says how the team did in the Wild Card Game for the specified year  
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
                  Team                   Year           Abbreviation        Payroll.Ranking          Total.Payroll 
                     0                      0                      0                      0                      0 
League.Average.Payroll  Previous.Year.Payroll Payroll.Percent.Change     Payroll.Difference         Active.Payroll 
                     0                   1272                   1272                   1272                      0 
               Injured               Retained                 Buried              Suspended                 Player 
                  4542                    383                   2497                  19000                      0 
                   Pos                    Exp                 Status         Payroll.Salary                   Type 
                     0                   6503                   4431                     68                      0 
           Average.Age                      W                      L                   W.L.           World.Series 
                     0                   1250                   1250                   1250                      0 
                  ALCS                   NLCS     AL.Division.Series     NL.Division.Series         Wild.Card.Game 
                     0                      0                      0                      0                      0
```

It is expected for there to be missing values in Previous year payroll, percent change and difference for 2011 (there is
no prior data).   
The high amount of missing values in the suspended column is also expected and ok, there shouldnt be players getting suspended
too often. Injured, retained, and buried are all expected to have missing values, as not every team has these parts of payroll every season.    
Experience and status has some missing values due to data quality. There wasn't always consistency across the website in terms of these fields being filled for every player.    
W, L, and W.L. should all have the same number of missing values, as these only pertain to the 2024 season (which will be predicted).   

$ Team: chr - $ Year: int - $ Payroll.Ranking: int - $ Total.Payroll: int -   
$ League.Average.Payroll: num - $ Previous.Year.Payroll : int - $ Payroll.Percent.Change: num    
$ Payroll.Difference: int - $ Active.Payroll: int - $ Injured: num    
$ Retained : num - $ Buried : num - $ Suspended: num - $ Player: chr    
$ Pos: chr - $ Exp: num - $ Status: chr - $ Payroll.Salary : num    
$ Type: chr - $ Average.Age: num - $ W: int - $ L: int - $ W.L.: num    
$ World.Series: chr - $ ALCS : chr - $ NLCS: chr    
$ AL.Division.Series: chr - $ NL.Division.Series: chr - $ Wild.Card.Game : chr

## More Research Questions

### Payroll Trends and Discrepancies:  

How have total payrolls for teams evolved over the years?  
What are the trends in league average payrolls over time?  
Are there significant discrepancies in payroll between the highest and lowest spending teams?  

### Payroll vs. Performance:  

Is there a correlation between a team's total payroll and their win-loss record?  
Do higher payrolls consistently lead to better team performance (more wins, playoff appearances, World Series wins)?  

### Payroll Distribution:  

How is payroll distributed among different player statuses (active, injured, retained, etc.)?  
What positions (Pos) receive the highest payroll on average?  

### Impact of Payroll Changes:  

How do changes in payroll from the previous year affect team performance?  
Is there a significant impact of payroll percent change on win-loss records?  

### Defensive and Offensive Contributions:  

How does a team's payroll allocation to different positions correlate with their win-loss record and playoff success?  
Is there a notable difference in payroll for teams with strong defensive vs. offensive statistics?  

### Age and Experience Factors:  

How does the average age of a team correlate with their total payroll and performance?  
Does player experience (Exp) significantly impact payroll distribution?  

### Injury and Retention Impact:  

How do injuries and retained salaries (Injured, Retained) affect a team's total payroll and performance?  
Are there trends in the proportion of payroll allocated to injured or retained players over the years?  

### Playoff Success:  

What is the relationship between total payroll and playoff appearances (ALCS, NLCS, Division Series, Wild Card Game)?  
How do payrolls of World Series winning teams compare to those that did not make it to the playoffs?  

### Salary Allocation:  

How does the salary allocation for different player positions vary among teams with different performance levels?  
Are there specific positions that teams invest more in for better performance outcomes?  







