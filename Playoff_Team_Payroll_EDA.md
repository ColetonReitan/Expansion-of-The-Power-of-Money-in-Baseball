---
# Exploratory Data Analysis of Playoff and World Series Teams' Payroll Data
---
This EDA will look into the payrolls of all teams that had made the playoffs from the years 2011 through 2023. The two teams that made the world series in each of these years will also be analyzed along the way.   
A subsetted dataframe has been created to hold only data of teams that had made the playoffs along with a dataframe that holds only the data of the teams that made the world series. 

```r
# Create a new dataframe that only has teams which have made the playoffs
playoff_teams <- df %>%
  filter(World.Series %in% c("Won", "Lost") |
           ALCS %in% c("Won", "Lost") |
           NLCS %in% c("Won", "Lost") |
           AL.Division.Series %in% c("Won", "Lost") |
           NL.Division.Series %in% c("Won", "Lost") |
           Wild.Card.Game %in% c("Won", "Lost"))
# Create a new dataframe that only has teams which have made the ws
world_series_teams  <- df %>%
  filter(World.Series %in% c("Won", "Lost"))
```

**Libraries Used:**  
library(ggplot2)  
library(dplyr)  
library(tidyr)  
library(shiny)  
library(scales)  
library(forcats)  



# Summary Statistics

```r
# Define bins based on payroll rankings (Breaking down for playoff teams)
playoff_teams <- playoff_teams %>%
  mutate(Payroll_Ranking_Bin = case_when(
    Payroll.Ranking <= 5 ~ "Top 5",
    Payroll.Ranking <= 10 ~ "Top 10",
    Payroll.Ranking <= 15 ~ "Top 15",
    Payroll.Ranking > 15 & Payroll.Ranking <= 30 ~ "Bottom 15",
    TRUE ~ "Other"  # Handle any other cases if needed
  ))
# Ensure each team is counted once per year
unique_teams_per_year <- playoff_teams %>%
  distinct(Team, Year, .keep_all = TRUE)
# Calculate the counts and percentages of unique teams in each bin
payroll_bin_percentages <- unique_teams_per_year %>%
  group_by(Payroll_Ranking_Bin) %>%
  summarise(
    Unique_Teams = n(),
    Percentage = (Unique_Teams / n_distinct(unique_teams_per_year)) * 100
  )

# Define bins based on payroll rankings (Breaking down for world series teams)
world_series_teams <- world_series_teams %>%
  mutate(Payroll_Ranking_Bin = case_when(
    Payroll.Ranking <= 5 ~ "Top 5",
    Payroll.Ranking <= 10 ~ "Top 10",
    Payroll.Ranking <= 15 ~ "Top 15",
    Payroll.Ranking > 15 & Payroll.Ranking <= 30 ~ "Bottom 15",
    TRUE ~ "Other"  # Handle any other cases if needed
  ))
# Ensure each team is counted once per year
unique_teams_per_year <- world_series_teams %>%
  distinct(Team, Year, .keep_all = TRUE)
# Calculate the counts and percentages of unique teams in each bin
payroll_bin_percentages <- unique_teams_per_year %>%
  group_by(Payroll_Ranking_Bin) %>%
  summarise(
    Unique_Teams = n(),
    Percentage = (Unique_Teams / n_distinct(unique_teams_per_year)) * 100
  )

```
<table>
  <tr>
    Playoff Teams Payroll Ranking Breakdown
  <tr>
    <th>Payroll_Ranking_Bin</th>
    <th>Unique_Teams</th>
    <th>Percentage</th>
  </tr>
  <tr>
    <td>Top 5</td>
    <td>35</td>
    <td>28.7%</td>
  </tr>
  <tr>
    <td>Top 10</td>
    <td>26</td>
    <td>21.3%</td>
  </tr>
  <tr>
    <td>Top 15</td>
    <td>19</td>
    <td>15.6%</td>
  </tr>
  <tr>
    <td>Bottom 15</td>
    <td>42</td>
    <td>34.4%</td>
</table>


 <table>
  <tr>
    World Series Teams Payroll Ranking Breakdown
  <tr>
    <th>Payroll_Ranking_Bin</th>
    <th>Unique_Teams</th>
    <th>Percentage</th>
  </tr>
  <tr>
    <td>Top 5</td>
    <td>10</td>
    <td>38.5%</td>
  </tr>
  <tr>
    <td>Top 10</td>
    <td>7</td>
    <td>26.9%</td>
  </tr>
  <tr>
    <td>Top 15</td>
    <td>2</td>
    <td>7.69%</td>
  </tr>
  <tr>
    <td>Bottom 15</td>
    <td>7</td>
    <td>26.9%</td>
</table>

From 2011 through 2023, nearly 65% of all teams that had made the playoffs had a payroll ranking of 1st-15th, whereas only 35% of teams in the playoffs had a payroll ranking from 16th-30th (which would be the bottom 15 payroll ranks).  
Nearly 75% of all teams that had made the world series had a payroll ranking of 1st-15th, whereas about 25% of teams in the world series had a payroll ranking from 16th-30th. However, it is impressive that 25% of teams with a 15th-30th payroll ranking have made the world series, as of the 
teams that made playoffs, only 35% had this payroll ranking. 
It can also be seen that 38.5% of teams that have made the world series have a payroll ranking from 1st-5th, which is the highest percentage seen for any ranking bucket between the two tables.


