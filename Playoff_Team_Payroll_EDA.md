---
# Exploratory Data Analysis of Playoff and World Series Teams' Payroll Data
---
This EDA will look into the payrolls of all teams that had made the playoffs from the years 2011 through 2023 (important to note 2024 data will not be in this EDA) separately from the teams that did not make the playoffs each year. The two teams that made the world series in each of these years will also be analyzed along the way.   
Subsetted dataframes have been created to hold data of playoff, world series, and non-playoff teams.  

**Libraries Used:**  
library(ggplot2)  
library(dplyr)  
library(tidyr)  
library(shiny)  
library(scales)  
library(forcats)  

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
  filter(World.Series %in% c("DNP", "DNP") &
           ALCS %in% c("DNP", "DNP") &
           NLCS %in% c("DNP", "DNP") &
           AL.Division.Series %in% c("DNP", "DNP") &
           NL.Division.Series %in% c("DNP", "DNP") &
           Wild.Card.Game %in% c("DNP", "DNP"))
# Create a new dataframe that only has teams which have made the ws
world_series_teams  <- df %>%
  filter(World.Series %in% c("Won", "Lost"))
```


# Summary Statistics

```r
#Define bins based on payroll rankings
unique_playoff <- unique_playoff %>%
  mutate(Payroll_Ranking_Bin = case_when(
    Payroll.Ranking <= 5 ~ "Top 5",
    Payroll.Ranking <= 10 ~ "Top 10",
    Payroll.Ranking <= 15 ~ "Top 15",
    Payroll.Ranking > 15 & Payroll.Ranking <= 30 ~ "Bottom 15",
    TRUE ~ "Other"  # Handle any other cases if needed
  ))
# Calculate the counts and percentages of unique teams in each bin
payroll_bin_percentages <- unique_playoff %>%
  group_by(Payroll_Ranking_Bin) %>%
  summarise(
    Unique_Teams = n(),
    Percentage = (Unique_Teams / n_distinct(unique_playoff)) * 100
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
      <td>30</td>
      <td>11.2%</td>
    </tr>
    <tr>
      <td>Top 10</td>
      <td>39</td>
      <td>14.6%</td>
    </tr>
    <tr>
      <td>Top 15</td>
      <td>46</td>
      <td>17.2%</td>
    </tr>
    <tr>
      <td>Bottom 15</td>
      <td>153</td>
      <td>57.1%</td>
    </tr>
  </table>
</div>


From 2011 through 2023, nearly 65% of all teams that had made the playoffs had a payroll ranking of 1st-15th, whereas only 35% of teams in the playoffs had a payroll ranking from 16th-30th (which would be the bottom 15 payroll ranks).  
Nearly 75% of all teams that had made the world series had a payroll ranking of 1st-15th, whereas about 25% of teams in the world series had a payroll ranking from 16th-30th. However, it is impressive that 25% of teams with a 15th-30th payroll ranking have made the world series, as of the 
teams that made playoffs, only 35% had this payroll ranking.   
It can also be seen that 38.5% of teams that have made the world series have a payroll ranking from 1st-5th, which is the second highest percentage seen for any ranking bucket between the three tables.  
56% of all teams that have not made the playoffs have a payroll ranking from 16th-30th, which should be an immediate signifier for teams to spend more money and try to stay out of the bottom 15 payroll rankings.   
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


| Statistic                         | Entire League           | Missed Playoffs Teams   | Playoff Teams           | World Series Teams     |
|-----------------------------------|-------------------------|-------------------------|-------------------------|------------------------|
| Average Total Payroll             | $125,002,065            | $115,363,146            | $146,176,085            | $154,443,976           |
| Median Total Payroll              | $115,521,847            | $105,327,192            | $139,541,596            | $141,063,248           |
| Average Payroll Percent Change    | 11.47%                  | 7.35%                   | 20.38%                  | 21.38%                 |
| Median Payroll Percent Change     | 6.49%                   | 3.38%                   | 11.96%                  | 15.54%                 |
| Average Payroll Difference        | $5,388,975              | $262,152                | $16,452,121             | $18,238,098            |
| Median Payroll Ranking            | 15.50                   | 18.00                   | 10.50                   | 7.50                   |
| Average Win Percentage            | 50.00%                  | 46.20%                  | 58.35%                  | 59.39%                 |
| Average Wins                      | 77.06                   | 70.90                   | 90.58                   | 90.73                  |
| Average Losses                    | 77.06                   | 82.66                   | 64.75                   | 63.35                  |
| Average Age                       | 27.85                   | 27.60                   | 28.39                   | 28.40                  |
| Average Experience                | 4.75                    | 4.47                    | 5.32                    | 6.74                   |
| Average Injured Payroll           | $16,337,702             | $17,501,925             | $13,721,471             | $15,277,480            |
| Average Suspended Payroll         | $3,289,866              | $3,215,600              | $3,463,154              | $1,000,000             |
| Average Retained Payroll          | $17,661,419             | $19,849,059             | $12,725,207             | $14,224,511            |



The monetary summaries are the most important values to observe when looking across with the whole league summary. Clearly, there is a trend of teams that spend more money have a greater chance of making the playoffs (and world series) than teams that don't. It is interesting to
see that the average and median percent chnage is highest for world series teams, which could speak towards teams spending more money and acquiring free agent talent in the offseason, which could be the difference maker for a team to make it that far. Another interesting aspect is that 
world series and playoff teams seem to spend less money on players that don't play - what is meant by that is the combined payroll of injured, suspended and retained for playoff and world series teams is much lower than that of teams that did not make playoffs.  

---

| Quartile         | Value                | Year |
|------------------|----------------------|------|
| Quartile 25%     | $100,231,573.25      | 2015 |
| Quartile 50%     | $139,541,596.50      | 2017 |
| Quartile 75%     | $182,868,384.75      | 2022 |
