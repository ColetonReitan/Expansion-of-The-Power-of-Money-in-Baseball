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
# Create a new dataframe that only has teams which did not make the playoffs
dnp_playoff_teams <- df %>%
  filter(World.Series %in% c("DNP", "DNP") |
           ALCS %in% c("DNP", "DNP") |
           NLCS %in% c("DNP", "DNP") |
           AL.Division.Series %in% c("DNP", "DNP") |
           NL.Division.Series %in% c("DNP", "DNP") |
           Wild.Card.Game %in% c("DNP", "DNP"))
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
```
(This code was repeated for world series and missed playoffs teams)  

<div style="display: flex; justify-content: space-between;">
  <!-- First table: Playoff Teams Payroll Ranking Breakdown -->
  <table>
    <tr>
      <th colspan="3">Playoff Teams Payroll Ranking Breakdown</th>
    </tr>
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
    </tr>
  </table>

  <!-- Second table: World Series Teams Payroll Ranking Breakdown -->
  <table>
    <tr>
      <th colspan="3">World Series Teams Payroll Ranking Breakdown</th>
    </tr>
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
    </tr>
  </table>

  <!-- Third table: DNP Breakdown -->
  <table>
    <tr>
      <th colspan="3">Missed Playoffs Teams Breakdown</th>
    </tr>
    <tr>
      <th>Payroll_Ranking_Bin</th>
      <th>Unique_Teams</th>
      <th>Percentage</th>
    </tr>
    <tr>
      <td>Top 5</td>
      <td>70</td>
      <td>16.7%</td>
    </tr>
    <tr>
      <td>Top 10</td>
      <td>70</td>
      <td>16.7%</td>
    </tr>
    <tr>
      <td>Top 15</td>
      <td>70</td>
      <td>16.7%</td>
    </tr>
    <tr>
      <td>Bottom 15</td>
      <td>210</td>
      <td>50%</td>
    </tr>
  </table>
</div>


From 2011 through 2023, nearly 65% of all teams that had made the playoffs had a payroll ranking of 1st-15th, whereas only 35% of teams in the playoffs had a payroll ranking from 16th-30th (which would be the bottom 15 payroll ranks).  
Nearly 75% of all teams that had made the world series had a payroll ranking of 1st-15th, whereas about 25% of teams in the world series had a payroll ranking from 16th-30th. However, it is impressive that 25% of teams with a 15th-30th payroll ranking have made the world series, as of the 
teams that made playoffs, only 35% had this payroll ranking.   
It can also be seen that 38.5% of teams that have made the world series have a payroll ranking from 1st-5th, which is the highest percentage seen for any ranking bucket between the two tables.  
50% of all teams that have not made the playoffs have a payroll ranking from 16th-30th, which should be an immediate signifier for teams to spend more money and try to stay out of the bottom 15 payroll rankings.   
Simply looking at these tables may give early insight to one of the research questions, frankly stating yes, increasing payroll gives increased chances at making the playoffs as well as the world series. 

--- 

```r
playoff_summary <- playoff_teams %>%
  summarise(
    avg_total_payroll = mean(Total.Payroll, na.rm = TRUE),
    median_total_payroll = median(Total.Payroll, na.rm = TRUE),
    avg_payroll_percent_change = mean(Payroll.Percent.Change, na.rm = TRUE),
    median_payroll_percent_change = median(Payroll.Percent.Change, na.rm = TRUE),
    avg_payroll_difference = mean(Payroll.Difference, na.rm = TRUE),
    median_payroll_ranking = median(Payroll.Ranking, na.rm = TRUE),
    avg_payroll_salary = mean(Payroll.Salary, na.rm=TRUE),
    median_payroll_salary = median(Payroll.Salary, na.rm=TRUE),
    avg_win_percentage = mean(`W.L.`, na.rm = TRUE),
    avg_wins = mean(W, na.rm = TRUE),
    avg_losses = mean(L, na.rm = TRUE),
    avg_age = mean(Average.Age, na.rm = TRUE),
    avg_experience = mean(Exp, na.rm = TRUE),
    avg_injured_payroll = mean(Injured, na.rm = TRUE),
    avg_suspended_payroll = mean(Suspended, na.rm = TRUE)
  )
```
(The code above only shows playoff summary, but the same is repeated for world series and whole league stats)  

| Statistic                            | Playoff Team Summary       | World Series Team Summary   | Whole League Team Summary  |
|--------------------------------------|----------------------------|-----------------------------|----------------------------|
| **Average Total Payroll**            | $148,149,017               | $157,277,259                | $127,951,682               |
| **Median Total Payroll**             | $140,926,169               | $143,782,286                | $116,341,526               |
| **Average Payroll Percent Change**   | 20.74%                     | 21.91%                      | 11.54%                     |
| **Median Payroll Percent Change**    | 12.88%                     | 15.54%                      | 6.14%                      |
| **Average Payroll Difference**       | $17,020,537                | $18,365,042                 | $5,619,189                 |
| **Median Payroll Ranking**           | 10                         | 7                           | 16                         |
| **Average Payroll Salary**           | $3,564,169                 | $3,817,308                  | $3,025,691                 |
| **Median Payroll Salary**            | $720,000                   | $750,000                    | $702,500                   |
| **Average Win Percentage**           | 58.32%                     | 59.22%                      | 49.68%                     |
| **Average Wins**                     | 90.82                      | 91.65                       | 77.05                      |
| **Average Losses**                   | 64.86                      | 64.14                       | 78.01                      |
| **Average Age**                      | 28.39                      | 28.41                       | 27.87                      |
| **Average Experience**               | 4.55                       | 4.59                        | 3.94                       |
| **Average Injured Payroll**          | $13,933,589                | $14,882,149                 | $18,805,694                |
| **Average Suspended Payroll**        | $3,496,710                 | $1,000,000                  | $2,928,907                 |
| **Average Retained Payroll**         | $13,577,089                | $14,901,214                 | $18,420,435                |

The monetary summaries are the most important values to observe when looking across with the whole league summary. Clearly, there is a trend of teams that spend more money, have a greater chance of making the playoffs (and world series) than teams that don't. It is interesting to
see that the average and median percent chnage is highest for world series teams, which could speak towards teams spending more money and acquiring free agent talent in the offseason, which could be the difference maker for a team to make it that far. Another interesting aspect is that 
world series and playoff teams seem to spend less money on players that don't play - what is meant by that is the combined payroll of injured, suspended and retained for playoff and world series teams is much lower than that of the league as a whole. 
