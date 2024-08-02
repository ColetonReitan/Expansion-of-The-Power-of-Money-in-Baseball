library(ggplot2)
library(dplyr)
library(tidyr)
library(shiny)
library(scales)
library(forcats)
library(factoextra)
library(skimr)



df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
colnames(df)
table(df$Type)


#Changing some odd values in Pos column
df <- df %>%
  mutate(Pos = case_when(
    Pos == "" ~ "RP",
    Pos == "CL" ~ "RP",
    Pos == "SP1" ~ "SP",
    TRUE ~ Pos
  ))
# Verify the changes
table(df$Pos)

#Grouping the positions into Infield, outfield, pitcher, dh
df <- df %>%
  mutate(Player_Group = case_when(
    Pos %in% c("1B", "2B", "3B", "SS", "C") ~ "Infield", # Infield
    Pos %in% c("LF", "CF", "RF", "OF") ~ "OutField",           # Outfield
    Pos %in% c("SP", "RP", "P") ~ "Pitcher",                 # Pitcher
    Pos == "DH" ~ "Designated Hitter",                            # Designated Hitter
    TRUE ~ NA_character_                            # To handle any unexpected values
  ))
# Verify the changes
table(df$Player_Group)

#Setting new Df's
#Creating unique team df
unique_df <- df %>%
  distinct(Team, Year, .keep_all = TRUE)
# Create a new dataframe that only has teams which did make the playoffs
all_teams <- df %>%
  filter(Year != 2024)
# Create a new dataframe that only has teams which did make the playoffs
playoff_teams <- df %>%
  filter(Year != 2024, 
         Playoff_Status > 0)
# Create a new dataframe that only has teams which did not make the playoffs
dnp_playoff_teams <- df %>%
  filter(Year != 2024, 
         Playoff_Status == 0)
# Create a new dataframe that only has teams which made WS
ws_teams <- df %>%
  filter(Year != 2024, 
         Playoff_Status >= 4)


#Summary Statistics

#Summary Statistics by Position for the league
summary_stats <- all_teams %>%
  group_by(Pos) %>%
  summarise(
    Mean_Payroll_Salary = mean(Payroll.Salary, na.rm = TRUE),
    Median_Payroll_Salary = median(Payroll.Salary, na.rm = TRUE),
    SD_Payroll_Salary = sd(Payroll.Salary, na.rm = TRUE),
    Max_Payroll_Salary = max(Payroll.Salary, na.rm = TRUE),
    Mean_Exp = mean(Exp, na.rm = TRUE),
    Median_Exp = median(Exp, na.rm=TRUE),
    Count = n()
  )
print(summary_stats)

#Summary Statistics by Position for playoff teams
playoffsumm_stats <- playoff_teams %>%
  group_by(Pos) %>%
  summarise(
    Mean_Payroll_Salary = mean(Payroll.Salary, na.rm = TRUE),
    Median_Payroll_Salary = median(Payroll.Salary, na.rm = TRUE),
    SD_Payroll_Salary = sd(Payroll.Salary, na.rm = TRUE),
    Max_Payroll_Salary = max(Payroll.Salary, na.rm = TRUE),
    Mean_Exp = mean(Exp, na.rm = TRUE),
    Median_Exp = median(Exp, na.rm=TRUE),
    Count = n()
  )
print(playoffsumm_stats)

#Summary Statistics by Position for the league
dnpsumm_stats <- dnp_playoff_teams %>%
  group_by(Pos) %>%
  summarise(
    Mean_Payroll_Salary = mean(Payroll.Salary, na.rm = TRUE),
    Median_Payroll_Salary = median(Payroll.Salary, na.rm = TRUE),
    SD_Payroll_Salary = sd(Payroll.Salary, na.rm = TRUE),
    Max_Payroll_Salary = max(Payroll.Salary, na.rm = TRUE),
    Mean_Exp = mean(Exp, na.rm = TRUE),
    Median_Exp = median(Exp, na.rm=TRUE),
    Count = n()
  )
print(dnpsumm_stats)

#Summary Statistics by Position for the league
wssumm_stats <- ws_teams %>%
  group_by(Pos) %>%
  summarise(
    Mean_Payroll_Salary = mean(Payroll.Salary, na.rm = TRUE),
    Median_Payroll_Salary = median(Payroll.Salary, na.rm = TRUE),
    SD_Payroll_Salary = sd(Payroll.Salary, na.rm = TRUE),
    Max_Payroll_Salary = max(Payroll.Salary, na.rm = TRUE),
    Mean_Exp = mean(Exp, na.rm = TRUE),
    Median_Exp = median(Exp, na.rm=TRUE),
    Count = n()
  )
print(wssumm_stats)

# Overall summary statistics
overall_stats <- ws_teams %>%
  summarise(
    Pos = "Overall",
    Mean_Payroll_Salary = mean(Payroll.Salary, na.rm = TRUE),
    Median_Payroll_Salary = median(Payroll.Salary, na.rm = TRUE),
    SD_Payroll_Salary = sd(Payroll.Salary, na.rm = TRUE),
    Max_Payroll_Salary = max(Payroll.Salary, na.rm = TRUE),
    Mean_Exp = mean(Exp, na.rm = TRUE),
    Median_Exp = median(Exp, na.rm=TRUE),
    Count = n()
  )
print(overall_stats)

# Filter the DataFrame for playoff teams and "active" type
active_teams <- df %>%
  filter(Year != 2024, 
         Playoff_Status > 0,
         Type == "table_active")
# Create box plots for salaries grouped by position
ggplot(active_teams, aes(x = Pos, y = Payroll.Salary)) +
  geom_boxplot() +
  labs(title = "Box Plot of Payroll Salaries by Position",
       x = "Position",
       y = "Payroll Salary") +
  theme_minimal()



# Function to calculate outliers and their playoff status counts
calculate_outliers <- function(df) {
  df <- df %>% filter(!is.na(Payroll.Salary))
  Q1 <- quantile(df$Payroll.Salary, 0.25)
  Q3 <- quantile(df$Payroll.Salary, 0.75)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  # Filter outliers
  outliers <- df %>%
    filter(Payroll.Salary < lower_bound | Payroll.Salary > upper_bound)
  
  # Count outliers based on playoff status
  total_outliers <- nrow(outliers)
  playoff_outliers <- nrow(outliers %>% filter(Playoff_Status > 0))
  non_playoff_outliers <- nrow(outliers %>% filter(Playoff_Status == 0))
  world_series_outliers <- nrow(outliers %>% filter(Playoff_Status >= 4))
  
  return(data.frame(Total_Outliers = total_outliers,
                    Playoff_Outliers = playoff_outliers,
                    Non_Playoff_Outliers = non_playoff_outliers,
                    World_Series_Outliers = world_series_outliers))
}

# Group by year and position and calculate outlier counts
outlier_counts <- all_teams %>%
  group_by(Year, Pos) %>%
  summarise(outliers = list(calculate_outliers(cur_data()))) %>%
  unnest_wider(outliers) %>%
  ungroup()

# Print outlier counts
print(outlier_counts)

# Calculate summary statistics for outliers across all years
summary_stats <- outlier_counts %>%
  group_by(Pos) %>%
  summarise(Total_Outliers = sum(Total_Outliers),
            Playoff_Outliers = sum(Playoff_Outliers),
            Non_Playoff_Outliers = sum(Non_Playoff_Outliers),
            World_Series_Outliers = sum(World_Series_Outliers)) %>%
  arrange(desc(Total_Outliers))

# Print summary statistics
print(summary_stats)


# Calculate percentages
percentage_stats <- summary_stats %>%
  mutate(
    Playoff_Percentage = (Playoff_Outliers / Total_Outliers) * 100,
    Non_Playoff_Percentage = (Non_Playoff_Outliers / Total_Outliers) * 100,
    World_Series_Percentage = (World_Series_Outliers / Total_Outliers) * 100
  ) %>%
  pivot_longer(cols = ends_with("Percentage"), 
               names_to = "Outlier_Type", 
               values_to = "Percentage")

# Plot bar chart with percentages
ggplot(percentage_stats, aes(x = Pos, y = Percentage, fill = Outlier_Type)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(title = "Percentage of Outliers by Position and Type",
       x = "Position",
       y = "Percentage (%)",
       fill = "Outlier Type") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


##################################################################
#Visualizing the data

# payroll & position time series

# Calculate average payroll per position and year
average_payroll_per_position <- all_teams %>%
  group_by(Year, Pos) %>%
  summarise(Average_Payroll = mean(Payroll.Salary, na.rm = TRUE)) %>%
  ungroup()
# Plot average payroll per position over the years with facets
ggplot(average_payroll_per_position, aes(x = Year, y = Average_Payroll, color = Pos)) +
  geom_line() +
  facet_wrap(~ Pos, scales = "free_y") +
  labs(title = "Average Payroll per Position Over the Years",
       x = "Year",
       y = "Average Payroll") +
  theme_minimal() +
  scale_y_continuous(labels = scales::label_comma())  # Format y-axis labels with commas



# Percent change for positions

# Calculate average payroll per position and year
average_payroll_per_position <- all_teams %>%
  group_by(Year, Pos) %>%
  summarise(Average_Payroll = mean(Payroll.Salary, na.rm = TRUE)) %>%
  ungroup()

# Calculate yearly percentage change
payroll_change <- average_payroll_per_position %>%
  arrange(Pos, Year) %>%
  group_by(Pos) %>%
  mutate(Percentage_Change = (Average_Payroll - lag(Average_Payroll)) / lag(Average_Payroll) * 100) %>%
  ungroup()

# Plot percentage change in payroll per position over the years
ggplot(payroll_change, aes(x = Year, y = Percentage_Change, color = Pos)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ Pos, scales = "free_y") +  # Use free_y to adjust y-axis for better visibility
  labs(title = "Yearly Percentage Change in Payroll per Position",
       x = "Year",
       y = "Percentage Change (%)") +
  theme_minimal() +
  scale_y_continuous(labels = scales::label_comma())  # Format y-axis labels with commas


# Top 10 players

# Ensure each player appears only once per year with their highest salary
unique_highest_paid_per_year <- all_teams %>%
  group_by(Year, Player) %>%
  arrange(desc(Payroll.Salary)) %>%
  slice(1) %>%
  ungroup()

# Select top 10 highest-paid players for each year
top_players_per_year <- unique_highest_paid_per_year %>%
  group_by(Year) %>%
  arrange(desc(Payroll.Salary)) %>%
  slice_head(n = 10) %>%
  ungroup()

# Create a new column to categorize playoff status
top_players_per_year <- top_players_per_year %>%
  mutate(Playoff_Status_Category = case_when(
    Playoff_Status == 0 ~ "Did Not Make Playoffs",
    Playoff_Status > 0 & Playoff_Status < 4 ~ "Made Playoffs",
    Playoff_Status == 4 ~ "Made World Series",
    Playoff_Status > 4 ~ "Won World Series"
  ))

# Bar plot of top 10 highest-paid players for each year with playoff status colors and position annotations
ggplot(top_players_per_year, aes(x = reorder(Player, -Payroll.Salary), y = Payroll.Salary, fill = Playoff_Status_Category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = Pos), hjust = -0.1, size = 3, color = "black") +  # Add position annotations
  coord_flip() +  # Flip coordinates for better readability
  labs(title = "Top 10 Highest-Paid Players for Each Year",
       x = "Player",
       y = "Payroll Salary",
       fill = "Playoff Status") +
  theme_minimal() +
  scale_y_continuous(labels = scales::label_comma()) +  # Format y-axis labels with commas
  facet_wrap(~ Year, scales = "free_y")  # Facet by year


#Experience Impact on Payroll Salary

# Filter out rows with missing or zero salaries or experience
df_filtered <- all_teams %>%
  filter(!is.na(Payroll.Salary), !is.na(Exp), Payroll.Salary > 0, Exp > 0)

# Scatter plots with regression lines, faceted by position with fixed y-axis
ggplot(df_filtered, aes(x = Exp, y = Payroll.Salary)) +
  geom_point(alpha = 0.5) +  # Scatter plot points
  geom_smooth(method = "lm", color = "blue", se = FALSE) +  # Add linear regression line
  facet_wrap(~ Pos, scales = "fixed") +  # Facet by position with fixed y-axis
  labs(title = "Correlation between Experience and Payroll Salary by Position",
       x = "Experience (Years)",
       y = "Payroll Salary") +
  theme_minimal() +
  scale_y_continuous(labels = scales::label_comma())  # Format y-axis labels with commas

# Calculate correlation coefficients by position
correlation_summary <- df_filtered %>%
  group_by(Pos) %>%
  summarise(Correlation = cor(Exp, Payroll.Salary, use = "complete.obs")) %>%
  arrange(desc(Correlation))

# Print the summary table
print(correlation_summary)




#Payroll Distribution

# Function to get unique team payroll per year
get_unique_team_payroll <- function(df) {
  df %>%
    group_by(Year, Team) %>%
    summarise(Total_Payroll = first(Total.Payroll)) %>%
    ungroup()
}

# Function to calculate payroll summary statistics
calculate_payroll_summary <- function(df, unique_payroll) {
  df %>%
    group_by(Year, Team) %>%
    summarise(
      Top1_Payroll = sum(Payroll.Salary[order(-Payroll.Salary)][1], na.rm = TRUE),
      Top3_Payroll = sum(Payroll.Salary[order(-Payroll.Salary)][1:3], na.rm = TRUE),
      Top5_Payroll = sum(Payroll.Salary[order(-Payroll.Salary)][1:5], na.rm = TRUE)
    ) %>%
    left_join(unique_payroll, by = c("Year", "Team")) %>%
    mutate(
      Top1_Percent = (Top1_Payroll / Total_Payroll) * 100,
      Top3_Percent = (Top3_Payroll / Total_Payroll) * 100,
      Top5_Percent = (Top5_Payroll / Total_Payroll) * 100
    ) %>%
    select(Year, Team, Top1_Percent, Top3_Percent, Top5_Percent)
}

# Unique team payrolls for each group
unique_league_payroll <- get_unique_team_payroll(all_teams)
unique_no_playoff_payroll <- get_unique_team_payroll(dnp_playoff_teams)
unique_playoff_payroll <- get_unique_team_payroll(playoff_teams)
unique_world_series_payroll <- get_unique_team_payroll(ws_teams)

# Calculate summary statistics for each group
league_summary <- calculate_payroll_summary(all_teams, unique_league_payroll)
no_playoff_summary <- calculate_payroll_summary(dnp_playoff_teams, unique_no_playoff_payroll)
playoff_summary <- calculate_payroll_summary(playoff_teams, unique_playoff_payroll)
world_series_summary <- calculate_payroll_summary(ws_teams, unique_world_series_payroll)

# Create a function to convert the summary to a table
create_table <- function(summary_df) {
  summary_df %>%
    group_by(Year) %>%
    summarise(
      `Top 1 Paid & % of Payroll` = mean(Top1_Percent, na.rm = TRUE),
      `Top 3 Paid & % of Payroll` = mean(Top3_Percent, na.rm = TRUE),
      `Top 5 Paid & % of Payroll` = mean(Top5_Percent, na.rm = TRUE)
    ) %>%
    ungroup()
}

# Create tables for each group
league_table <- create_table(league_summary)
no_playoff_table <- create_table(no_playoff_summary)
playoff_table <- create_table(playoff_summary)
world_series_table <- create_table(world_series_summary)

# Print tables
print("Entire League Table")
print(league_table)

print("No Playoff Teams Table")
print(no_playoff_table)

print("Playoff Teams Table")
print(playoff_table)

print("World Series Teams Table")
print(world_series_table)





# Combine all tables into one for easier plotting
combined_summary <- bind_rows(
  league_table %>% mutate(Group = "Entire League"),
  no_playoff_table %>% mutate(Group = "No Playoff Teams"),
  playoff_table %>% mutate(Group = "Playoff Teams"),
  world_series_table %>% mutate(Group = "World Series Teams")
)

# Convert to long format for plotting
combined_summary_long <- combined_summary %>%
  pivot_longer(cols = starts_with("Top"),
               names_to = "Top",
               values_to = "Percentage")

# Plot the data
ggplot(combined_summary_long, aes(x = Year, y = Percentage, color = Group, linetype = Top)) +
  geom_line() +
  geom_point() +
  labs(title = "Percentage of Payroll Allocated to Top Players",
       x = "Year",
       y = "Percentage of Payroll",
       color = "Team Group",
       linetype = "Top Players") +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) + # Format y-axis as percentage
  theme_minimal() +
  theme(legend.position = "bottom") # Position legend at the bottom for clarity
