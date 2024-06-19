# Expansion of The Power of Money in Baseball

This is the analytical continuation and expansion of my project, The Power of Money in Baseball

The initial project was an 8-week long assignment for my "Data Visualization" Master's course in which the goal was to tell a visual story using Tableau software, which can be found on my GitHub [here](https://github.com/ColetonReitan/The-Power-of-Money-in-Baseball); 

This project is the continuation and expansion of the Power of Money in Baseball. 


## Project Motivation
As someone who had played baseball from a very young age and for the extent of my academic career, this project serves the purpose to not only continue my practices in data science, but also allows me to continue my passion for the sport in a way other than playing. The sport of baseball is very analytically driven, with tons of data points being measured within the game everyday. However, with this project, I am choosing to find the value in the data points beyond the field and in the front office - specifically when it comes to team payroll data. 

The horror and beauty of payroll in baseball is that teams do not have to fear a payroll cap - as in owners and general managers can spend however much they would like to spend on their team, without restriction. This creates large discrepancies between team payrolls which then leads to the main questions this project is looking to answer - do these large discrepancies in payroll put certain franchises at an advantage or disadvantage? Is there such thing as spending too much money on a team? Should teams be investing more in players in certain positions? These are all questions (along with others to be mentioned) that will be answered with a statistical backing. 


## Reasearch Questions (with more to be included)
Do payroll discrpancies put franchises at an advantage or disadvantage?

Is there such thing as spending too much money on a team?

Should teams be investing more in certain positions rather than other positions? 

Is there a most winning-est payroll amount? 

Are there league wide trends in payroll? If so, should teams be following them? 


## MetaData

As of 6/19/2024, collection data is still udnerway - only need to build the final piece of the scrapper which brings in team wins, losses & playoff appearances.

#### Sources 
All data aside from a team's wins, losses & playoff game appearances was collected from the website spotrac, linked [here](https://www.spotrac.com/mlb).
The data for the wins, losses & playoff game appearances was collected from the website baseball referenced, linked [here](https://www.baseball-reference.com/postseason/).

#### Collection Method
I built my own webscrapper from scratch through R software to bring in the data needed to complete this analysis. The webscraper can be found in this repository. 

The code for the webscrapper not only brings the data into R, but also cleans the data and merges it into one dataframe. 

I'm particularly proud of it. 

#### Variable Description
There are currently 27 variables with over 115,000 observations that gives me a total of 2.9 million values.

**Team**: Team Name

**Year**: Year of season being examined

**Payroll.Rank**: Payroll rank for specified team in specified season (1 is highest payroll 30 is lowest)

**League.Average.Payroll**: The average payroll across the league for the specified year

**Previous.Year.Payroll**: The payroll from the previous year for the specified team

**Payroll.Percent.Change**: The payroll percent change from the previous year for the specified team

**Payroll.Difference**: The difference of the payroll in the specified year from the previous year

**Active.Payroll**: The payroll amount that is dedicated to active players (for a team) in a specified year

**Injured**: The payroll amount that is dedicated to injured players (for a team) in a specified year

**Retained**: The payroll amount that is retained from players no longer on a team in a specified year

**Buried**: 

**Suspended**: The payroll amount that is dedicated to players suspended in a specified year

**Player**: The specified player name

**Pos**: The position the specified player plays

**Exp**: The number of years (continuous) of experience a player has

**Status**: Qualitative description of experience

**Payroll.Salary**: The salary of the specified player

**Adjusted.Payroll.Salary**: 

**Base.Salary**: Base salary for specified player

**Signing.Bonus**: Amount of money given to player for signing in that year

**Incentives.Likely**: Amount of incentives for a player to recieve

**Incentives.Unlikely**: Amount of incentives for a player to recieve

**Type**: Which original table the data came from

**Average.Age**: The avereage age of all the players on a specified team














