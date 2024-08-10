library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(reshape2)



# Data preprocessing to create predictive features df 

df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
df <- df %>%
  replace_na(list(Injured = 0, Retained = 0, Buried = 0, Suspended = 0))

df$Player_Group <- gsub("Designated Hitter", "Designated_Hitter", df$Player_Group)

'''
INDEPENDENT VAR FEATURES retained from df
(Team, Year, Playoff_Status, Wins), Total.Payroll, Active.Payroll, Injured, Retained, Buried, Suspended, Average.Age, Payroll.Percent.Change, 
Diff_From_League_Avg_Payroll, Payroll.Ranking, Top1_Percent, Top3_Percent, Top5_Percent
'''

#creating unique df's
ind_features <- df %>%
  distinct(Team, Year, .keep_all = TRUE)
#Creating df ind_features that will have only features to be used in feature selection
ind_features <- ind_features %>%
  select(Team, Year, Playoff_Status, Wins, Total.Payroll, Active.Payroll, Injured, Retained, Buried, Suspended, Average.Age, Payroll.Percent.Change, 
         Diff_From_League_Avg_Payroll, Payroll.Ranking, Top1_Percent, Top3_Percent, Top5_Percent)


#Attempting to fill as many NA's as possible for Exp with interpolation
# Custom function to handle interpolation with fallback to fill
interpolate_with_fill <- function(years, exp) {
  if(sum(!is.na(exp)) < 2) {
    return(exp)
  } else {
    return(approx(years, exp, years, rule = 2)$y)
  }
}
# Fill missing `Exp` values
df <- df %>%
  arrange(Team, Player, Year) %>%  # Ensure data is sorted by team, player, and year
  group_by(Team, Player) %>%
  mutate(Exp = interpolate_with_fill(Year, Exp)) %>%
  fill(Exp, .direction = "downup") %>%  # Carry forward and backward the last known experience
  ungroup()
#Finding Median and Mean Exp and creating columns for them
# Compute median and mean experience for each team in each year
team_exp_stats <- df %>%
  group_by(Team, Year) %>%
  summarise(
    Median_Exp = median(Exp, na.rm = TRUE),
    Mean_Exp = mean(Exp, na.rm = TRUE)
  ) %>%
  ungroup()
ind_features <- ind_features %>%
  left_join(team_exp_stats, by = c("Team", "Year"))
#Guardians are all NA, so imputing with league median and mean exp
# Calculate year-specific league median and mean experience
yearly_stats <- ind_features %>%
  group_by(Year) %>%
  summarize(
    yearly_median_exp = median(Median_Exp, na.rm = TRUE),
    yearly_mean_exp = mean(Mean_Exp, na.rm = TRUE)
  )
# Merge the year-specific stats with the original dataframe
ind_features <- ind_features %>%
  left_join(yearly_stats, by = "Year")
# Impute missing values for the Guardians
ind_features <- ind_features %>%
  mutate(
    Median_Exp = ifelse(is.na(Median_Exp) & Team == "cleveland-guardians", yearly_median_exp, Median_Exp),
    Mean_Exp = ifelse(is.na(Mean_Exp) & Team == "cleveland-guardians", yearly_mean_exp, Mean_Exp)
  )
# Drop the temporary columns
ind_features <- ind_features %>%
  select(-yearly_median_exp, -yearly_mean_exp)



#Creating more features based on existing features in df to be included in ind_features

#Creating Percent of payroll and sum for each position by team and year
# Calculate the sum of payroll by position for each team and year, treating NA as 0
df_position_payroll <- df %>%
  group_by(Team, Year, Pos) %>%
  summarise(Position_Payroll = sum(Payroll.Salary, na.rm = TRUE), .groups = 'drop')
# Ensure all combinations of Team, Year, and Position are represented
df_all_positions <- df %>%
  select(Team, Year) %>%
  distinct() %>%
  crossing(Pos = unique(df$Pos)) %>%
  left_join(df_position_payroll, by = c("Team", "Year", "Pos"))
# Replace NA with 0 in Position_Payroll
df_all_positions <- df_all_positions %>%
  mutate(Position_Payroll = replace_na(Position_Payroll, 0))
# Join with Total.Payroll
df_with_totals <- df %>%
  select(Team, Year, Total.Payroll) %>%
  distinct() %>%
  left_join(df_all_positions, by = c("Team", "Year"))
# Calculate percent of total payroll by position
df_with_totals <- df_with_totals %>%
  mutate(Position_Percent_Payroll = ifelse(Total.Payroll == 0, 0, (Position_Payroll / Total.Payroll) * 100))
# Spread the data to have separate columns for each position
df_position_summary <- df_with_totals %>%
  pivot_wider(names_from = Pos, values_from = c(Position_Payroll, Position_Percent_Payroll), names_sep = "_") %>%
  select(-Total.Payroll)
# Join with ind_features
ind_features <- ind_features %>%
  left_join(df_position_summary, by = c("Team", "Year"))


#Repeating this process for player position group
# Calculate the sum of payroll by player group for each team and year
df_player_group_payroll <- df %>%
  group_by(Team, Year, Player_Group) %>%
  summarise(Player_Group_Payroll = sum(Payroll.Salary, na.rm = TRUE), .groups = 'drop')
# Ensure all combinations of Team, Year, and Player Group are represented
df_all_player_groups <- df %>%
  select(Team, Year) %>%
  distinct() %>%
  crossing(Player_Group = unique(df$Player_Group)) %>%
  left_join(df_player_group_payroll, by = c("Team", "Year", "Player_Group"))
# Replace NA with 0 in Player_Group_Payroll
df_all_player_groups <- df_all_player_groups %>%
  mutate(Player_Group_Payroll = replace_na(Player_Group_Payroll, 0))
# Join with Total.Payroll
df_with_totals_player_group <- df %>%
  select(Team, Year, Total.Payroll) %>%
  distinct() %>%
  left_join(df_all_player_groups, by = c("Team", "Year"))
# Calculate percent of total payroll by player group
df_with_totals_player_group <- df_with_totals_player_group %>%
  mutate(Player_Group_Percent_Payroll = ifelse(Total.Payroll == 0, 0, (Player_Group_Payroll / Total.Payroll) * 100))
# Spread the data to have separate columns for each player group
df_player_group_summary <- df_with_totals_player_group %>%
  pivot_wider(names_from = Player_Group, values_from = c(Player_Group_Payroll, Player_Group_Percent_Payroll), names_sep = "_") %>%
  select(-Total.Payroll)
#Join with ind_features
ind_features <- ind_features %>%
  left_join(df_player_group_summary, by=c("Team", "Year"))


#Removing unneeded df's from global for RAM purposes
# Names of the dataframes you want to keep
keep_dfs <- c("df", "ind_features")
rm(list = setdiff(ls(), keep_dfs))

# Dropping 2011 data. this was planned, served purpose of giving 2012 previous year payroll information. Also dropping 2024 data (na's in target vars)
ind_features_noNA <- ind_features[ind_features$Year >= 2012 & ind_features$Year <= 2023, ]

ind_features_2024 <- ind_features[ind_features$Year >= 2012,]

# Using Standardization to put everything at a mean 0 scale
# List of columns to standardize, including 'Wins'
features_to_standardize <- c("Wins", "Total.Payroll", "Active.Payroll", 
                             "Injured", "Retained", "Buried", "Suspended", 
                             "Average.Age", "Payroll.Percent.Change", 
                             "Top1_Percent", "Top3_Percent", "Top5_Percent",
                             "Diff_From_League_Avg_Payroll", "Payroll.Ranking",
                             "Position_Payroll_1B", "Position_Payroll_2B",
                             "Position_Payroll_3B", "Position_Payroll_C",
                             "Position_Payroll_CF", "Position_Payroll_DH",
                             "Position_Payroll_LF", "Position_Payroll_OF",
                             "Position_Payroll_P", "Position_Payroll_RF",
                             "Position_Payroll_RP", "Position_Payroll_SP",
                             "Position_Payroll_SS", "Position_Percent_Payroll_1B",
                             "Position_Percent_Payroll_2B", "Position_Percent_Payroll_3B",
                             "Position_Percent_Payroll_C", "Position_Percent_Payroll_CF",
                             "Position_Percent_Payroll_DH", "Position_Percent_Payroll_LF",
                             "Position_Percent_Payroll_OF", "Position_Percent_Payroll_P",
                             "Position_Percent_Payroll_RF", "Position_Percent_Payroll_RP",
                             "Position_Percent_Payroll_SP", "Position_Percent_Payroll_SS",
                             "Player_Group_Payroll_Designated_Hitter",
                             "Player_Group_Payroll_Infield", 
                             "Player_Group_Payroll_OutField", 
                             "Player_Group_Payroll_Pitcher",
                             "Player_Group_Percent_Payroll_Infield",
                             "Player_Group_Percent_Payroll_OutField",
                             "Player_Group_Percent_Payroll_Pitcher",
                             "Player_Group_Percent_Payroll_Designated_Hitter",
                             "Median_Exp", "Mean_Exp")


# Standardize the specified features
ind_features_standardized <- ind_features_noNA %>%
  mutate(across(all_of(features_to_standardize), ~ scale(.) %>% as.vector()))
# Check the result
head(ind_features_standardized)


# Save dataframe to a CSV file
write.csv(ind_features_2024, file = "Predictive2024_Unstandard_MLB_Payroll_Data.csv", row.names = FALSE)
getwd()
