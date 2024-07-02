# Expansion of The Power of Money in Baseball

## Project Overview
This is my personal analytical continuation and expansion of my project, The Power of Money in Baseball, where I not only try to tell a visual stroy with the data, but conduct a full line analysis that includes data ETL, EDA & supervised (and possibly unsupervised) machine learning modeling and analysis. 

The initial project was an 8-week long assignment for my "Data Visualization" Master's course in which the goal was to tell a visual story using Tableau software, which can be found on my GitHub [here](https://github.com/ColetonReitan/The-Power-of-Money-in-Baseball); 

This project is my personal continuation and expansion of the Power of Money in Baseball. 

## Project Status
As of 6/25/2024, I am currently working in the EDA phase of this analysis.


## Project Motivation
As someone who had played baseball from a very young age and for the extent of my academic career, this project serves the purpose to not only continue my practices in data science, but also allows me to continue my passion for the sport in a way other than playing. The sport of baseball is very analytically driven, with tons of data points being measured within the game everyday. However, with this project, I am choosing to find the value in the data points beyond the field and in the front office - specifically when it comes to team payroll data. 

The horror and beauty of payroll in baseball is that teams do not have to fear a payroll cap - as in owners and general managers can spend however much they would like to spend on their team, without restriction. This creates large discrepancies between team payrolls which then leads to the main questions this project is looking to answer - do these large discrepancies in payroll put certain franchises at an advantage or disadvantage? Is there such thing as spending too much money on a team? Should teams be investing more in players in certain positions? These are all questions (along with others to be mentioned) that will be answered with a statistical backing. 


## Reasearch Questions (with more to be included)
  1. Do payroll discrpancies put franchises at an advantage or disadvantage?

  2. Is there such thing as spending too much money on a team?

  3. Should teams be investing more in certain positions rather than other positions? 

  4. Is there a most winning-est payroll amount? 

  5. Are there league wide trends in payroll? If so, should teams be following them? 

## Methods
I am currently workingthrough the methods portion of this project, and have recently started EDA

### EDA

### Modeling

### Statistical Analysis


## MetaData

Data Collection is now fully complete! The webscraper is fully functional.

#### Sources 
- All data aside from a team's wins, losses & playoff game appearances was collected from the website spotrac, linked [here](https://www.spotrac.com/mlb).  
- The data for the wins, losses & playoff game appearances was collected from the website baseball referenced, linked [here](https://www.baseball-reference.com/postseason/). The data being collected is for the seasons in years 2012 through 2023, with some possible forecasting insight into 2024.

#### Collection Method
I built a web scraper from scratch using R to collect the necessary data. The web scraper not only imports the data into R but also cleans and merges it into one dataframe. The code for the web scraper can be found in this repository. I'm particularly proud of it.

#### Variable Description
There are currently 29 variables with over 16,000 observations that gives me over 400,000 total values.

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









