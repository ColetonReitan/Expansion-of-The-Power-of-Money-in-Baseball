library(ggplot2)
library(dplyr)
library(tidyr)
library(shiny)
library(scales)
library(forcats)
library(knitr)
library(formattable)
library(kableExtra)
library(reshape2)
library(gridExtra)
library(grid)

#This EDA will be excluding 2024 data, as it looks across into playoffs as well, and
#at this point in time, all 2024 teams are DNP for playoffs so the data would be skewed.

df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
colnames(df)

#Creating a league df with no 2024 data
df_2023 <- df %>%
  filter(Year != 2024)
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
  filter(Year != 2024, 
           World.Series %in% c("DNP", "DNP") &
           ALCS %in% c("DNP", "DNP") &
           NLCS %in% c("DNP", "DNP") &
           AL.Division.Series %in% c("DNP", "DNP") &
           NL.Division.Series %in% c("DNP", "DNP") &
           Wild.Card.Game %in% c("DNP", "DNP"))
# Create a new dataframe that only has teams which have made the ws
world_series_teams  <- df %>%
  filter(World.Series %in% c("Won", "Lost"))

#creating unique df's
unique_df <- df_2023 %>%
  distinct(Team, Year, .keep_all = TRUE)
unique_playoff <- playoff_teams %>%
  distinct(Team, Year, .keep_all = TRUE)
unique_ws <- world_series_teams %>%
  distinct(Team, Year, .keep_all = TRUE)
unique_dnp <- dnp_playoff_teams %>%
  distinct(Team, Year, .keep_all = TRUE)

############################################################################################33
# Binning payroll rankings

# Function to bin teams based on payroll rankings and calculate percentages
bin_and_summarize_teams <- function(df, team_type) {
  df <- df %>%
    mutate(Payroll_Ranking_Bin = case_when(
      Payroll.Ranking <= 5 ~ "Top 5",
      Payroll.Ranking <= 10 ~ "Top 10",
      Payroll.Ranking <= 15 ~ "Top 15",
      Payroll.Ranking > 15 & Payroll.Ranking <= 30 ~ "Bottom 15",
      TRUE ~ "Other"  # Handle any other cases if needed
    ))
  
  payroll_bin_percentages <- df %>%
    group_by(Payroll_Ranking_Bin) %>%
    summarise(
      Unique_Teams = n(),
      Percentage = (Unique_Teams / n_distinct(df)) * 100  # Percentage based on the number of teams in the bin
    ) %>%
    arrange(match(Payroll_Ranking_Bin, c("Top 5", "Top 10", "Top 15", "Bottom 15", "Other")))
  
  cat(paste0("# ", team_type, " Summary\n"))
  print(payroll_bin_percentages)
  cat("\n")
}

# Apply the function to the different dataframes
bin_and_summarize_teams(unique_playoff, "Playoff Teams")
bin_and_summarize_teams(unique_ws, "World Series Teams")
bin_and_summarize_teams(unique_dnp, "DNP Teams")

###################################################################################3
# Summary statistics for playoff/ws teams (also including all teams for comparison)

# Define the function to calculate summary statistics for a given dataframe
calculate_summary <- function(df) {
  summary <- df %>%
    summarise(
      avg_total_payroll = mean(Total.Payroll, na.rm = TRUE),
      median_total_payroll = median(Total.Payroll, na.rm = TRUE),
      avg_payroll_percent_change = mean(Payroll.Percent.Change, na.rm = TRUE),
      median_payroll_percent_change = median(Payroll.Percent.Change, na.rm = TRUE),
      avg_payroll_difference = mean(Payroll.Difference, na.rm = TRUE),
      median_payroll_ranking = median(Payroll.Ranking, na.rm = TRUE),
      avg_win_percentage = mean(`W.L.`, na.rm = TRUE),
      avg_wins = mean(Wins, na.rm = TRUE),
      avg_losses = mean(Losses, na.rm = TRUE),
      avg_age = mean(Average.Age, na.rm = TRUE),
      avg_experience = mean(Exp, na.rm = TRUE),
      avg_injured_payroll = mean(Injured, na.rm = TRUE),
      avg_suspended_payroll = mean(Suspended, na.rm = TRUE),
      avg_retained_payroll = mean(Retained, na.rm = TRUE)
    )
  return(summary)
}

# Create a list of dataframes to loop over
dfs <- list(unique_df, unique_dnp, unique_playoff, unique_ws)
names(dfs) <- c("Entire League", "Missed Playoffs Teams", "Playoff Teams", "World Series Teams")

# Initialize an empty list to store summaries
summaries <- list()

# Loop over each dataframe and calculate the summary
for (name in names(dfs)) {
  dff <- dfs[[name]]
  summary <- calculate_summary(dff)
  summaries[[name]] <- summary
}

# Create a formatted string for each summary
formatted_summaries <- lapply(names(summaries), function(name) {
  summary <- summaries[[name]]
  sprintf(
    "%s Summary Statistics:
    Average Total Payroll: $%s
    Median Total Payroll: $%s
    Average Payroll Percent Change: %.2f%%
    Median Payroll Percent Change: %.2f%%
    Average Payroll Difference: $%s
    Median Payroll Ranking: %.2f%%
    Average Win Percentage: %.2f%%
    Average Wins: %.2f
    Average Losses: %.2f
    Average Age: %.2f
    Average Experience: %.2f
    Average Injured Payroll: $%s
    Average Suspended Payroll: $%s
    Average Retained Payroll: $%s",
    name,
    formatC(summary$avg_total_payroll, format = "d", big.mark = ","),
    formatC(summary$median_total_payroll, format = "d", big.mark = ","),
    summary$avg_payroll_percent_change,
    summary$median_payroll_percent_change,
    formatC(summary$avg_payroll_difference, format = "d", big.mark = ","),
    summary$median_payroll_ranking,
    summary$avg_win_percentage * 100,  # Converting proportion to percentage
    summary$avg_wins,
    summary$avg_losses,
    summary$avg_age,
    summary$avg_experience,
    formatC(summary$avg_injured_payroll, format = "d", big.mark = ","),
    formatC(summary$avg_suspended_payroll, format = "d", big.mark = ","),
    formatC(summary$avg_retained_payroll, format = "d", big.mark = ",")
  )
})

# Print the formatted summaries
for (formatted_summary in formatted_summaries) {
  cat(formatted_summary, "\n\n")
}

##################################################################################################3
# Compute quartiles for total payroll of playoff teams
quartiles <- quantile(unique_playoff$Total.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) unique_playoff$Year[which.min(abs(unique_playoff$Total.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}
#Plotting playoff quartiles
quartiles_millions <- as.numeric(quartiles) / 1e6
quartile_data <- data.frame(
  Quartile = names(quartiles),
  Value = quartiles_millions,
  Year = quartile_years
)
ggplot(playoff_teams, aes(x = as.factor(Year), y = Total.Payroll / 1000000)) +
  geom_boxplot(fill = "darkred", color = "black", alpha = 0.5, outlier.shape = 5) +  # Customize box plot appearance
  scale_y_continuous(labels = label_number_si()) +  # Format y-axis labels
  labs(title = "Total Payroll Distribution by Year for Playoff Teams",  # Add title and axis labels
       x = "Year",
       y = "Total Payroll (millions)") +
  theme_minimal() +  # Apply a minimal theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
        panel.grid.major = element_line(color = "gray", linetype = "dashed"),  # Customize grid lines
        legend.position = "bottom")  # Adjust legend position


# Compute quartiles for Total Payroll of missed playoff teams
quartiles <- quantile(unique_dnp$Total.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) unique_dnp$Year[which.min(abs(unique_dnp$Total.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}
#Plotting missed playoffs quartiles
quartiles_millions <- as.numeric(quartiles) / 1e6
quartile_data <- data.frame(
  Quartile = names(quartiles),
  Value = quartiles_millions,
  Year = quartile_years
)
ggplot(unique_dnp, aes(x = as.factor(Year), y = Total.Payroll / 1000000)) +
  geom_boxplot(fill = "darkred", color = "black", alpha = 0.5, outlier.shape = 5) +  # Customize box plot appearance
  scale_y_continuous(labels = label_number_si()) +  # Format y-axis labels
  labs(title = "Total Payroll Distribution by Year for Missed Playoff Teams",  # Add title and axis labels
       x = "Year",
       y = "Total Payroll (millions)") +
  theme_minimal() +  # Apply a minimal theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
        panel.grid.major = element_line(color = "gray", linetype = "dashed"),  # Customize grid lines
        legend.position = "bottom")  # Adjust legend position

# Compute quartiles for total payroll of ws teams
quartiles <- quantile(unique_ws$Total.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) unique_ws$Year[which.min(abs(unique_ws$Total.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}

######################################################################################################################
# Visualizing

#Sum of payrolls

#Creating new df that has combined total league payroll stats
# Summarize the total payroll by year for playoff teams
total_payroll_playoff <- aggregate(Total.Payroll ~ Year, data = unique_playoff, sum)
# Summarize the total payroll by year for missed playoff teams
total_payroll_missed <- aggregate(Total.Payroll ~ Year, data = unique_dnp, sum)
# Rename the columns for clarity
colnames(total_payroll_playoff) <- c("Year", "Playoff.Payroll")
colnames(total_payroll_missed) <- c("Year", "Missed.Playoff.Payroll")
# Merge the data frames
total_payroll_combined <- merge(total_payroll_playoff, total_payroll_missed, by = "Year", all = TRUE)
# Calculate the total league payroll by year
total_payroll_combined <- total_payroll_combined %>%
  mutate(Total_League_Payroll = Playoff.Payroll + Missed.Playoff.Payroll)
# Calculate percentages
total_payroll_combined <- total_payroll_combined %>%
  mutate(Playoff_Percentage = (Playoff.Payroll / Total_League_Payroll) * 100,
         Missed_Playoff_Percentage = (Missed.Playoff.Payroll / Total_League_Payroll) * 100)
# Replace NA values with 0
total_payroll_combined[is.na(total_payroll_combined)] <- 0
# Calculate the difference
total_payroll_combined$Difference <- total_payroll_combined$Playoff.Payroll - total_payroll_combined$Missed.Playoff.Payroll


#Creating stacked bar plot for sum of total payroll w/values
# Reshape the data frames and create a new column for legend
total_payroll_combined_long <- reshape2::melt(total_payroll_combined, id.vars = "Year", 
                                              measure.vars = c("Playoff.Payroll", "Missed.Playoff.Payroll"), 
                                              variable.name = "Category", value.name = "Amount")
# Define a custom formatting function for thousands
format_thousands <- function(x) {
  ifelse(x >= 1e6, sprintf("%.1fM", x / 1e6), sprintf("%.0fK", x / 1e3))
}
# Apply the custom formatting function
total_payroll_combined_long <- total_payroll_combined_long %>%
  group_by(Year) %>%
  mutate(label_pos = Amount,
         label_text = format_thousands(Amount))
# Create a stacked bar plot with vertical values inside the bars
ggplot(total_payroll_combined_long, aes(x = Year, y = Amount, fill = Category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = label_text),
            position = position_stack(vjust = 0.5), size = 5, color = "black",
            angle = 90, hjust = 0.5) +  # Set angle to 90 for vertical text
  labs(title = "Total Payroll by Year for Playoff and Missed Playoff Teams", 
       x = "Year", 
       y = "Total Payroll (in millions)",
       fill = "Payroll Category") +
  scale_y_continuous(labels = scales::dollar_format(scale = 1e-6, suffix = "M")) +
  scale_fill_manual(values = c("Playoff.Payroll" = "skyblue", "Missed.Playoff.Payroll" = "lightcoral")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Creating stacked bar plot for sum of total payroll w/percentages
total_payroll_combined_long <- reshape2::melt(total_payroll_combined, id.vars = "Year", 
                                              measure.vars = c("Playoff_Percentage", "Missed_Playoff_Percentage"), 
                                              variable.name = "Category", value.name = "Percentage")
ggplot(total_payroll_combined_long, aes(x = Year, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity", position = "stack") +
  geom_text(aes(label = sprintf("%.1f%%", Percentage)),
            position = position_stack(vjust = 0.5), size = 5, color = "black", angle = 90, hjust = 0.5) +
  labs(title = "Percentage of Total League Payroll by Year", 
       x = "Year", 
       y = "Percentage of Total Payroll",
       fill = "Payroll Category") +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_fill_manual(values = c("Playoff_Percentage" = "skyblue", "Missed_Playoff_Percentage" = "lightcoral")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Creating a bar plot with a trend line for the differences
ggplot(total_payroll_combined, aes(x = Year, y = Difference)) +
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "Difference in Payroll between Playoff and Missed Playoff Teams by Year", 
       x = "Year", 
       y = "Payroll Difference (in millions)") +
  scale_y_continuous(labels = scales::dollar_format(scale = 1e-6, suffix = "M")) +
  theme_minimal()



#Payroll cpmponent plots

# Calculate total payroll including Active.Payroll
payroll_with_active <- unique_playoff %>%
  group_by(Year) %>%
  summarize(
    Active.Payroll = sum(Active.Payroll, na.rm = TRUE),
    Injured = sum(Injured, na.rm = TRUE),
    Retained = sum(Retained, na.rm = TRUE),
    Buried = sum(Buried, na.rm = TRUE),
    Suspended = sum(Suspended, na.rm = TRUE)
  )
# Reshape the data to a long format
payroll_with_active_long <- melt(payroll_with_active, id.vars = "Year", 
                                 variable.name = "Component", value.name = "Amount")
# Calculate the total payroll amount for each year including Active.Payroll
total_payroll_with_active <- payroll_with_active_long %>%
  group_by(Year) %>%
  summarize(Total_Amount = sum(Amount, na.rm = TRUE))
# Merge total payroll with the long format data to calculate percentages
payroll_with_active_long <- merge(payroll_with_active_long, total_payroll_with_active, by = "Year") %>%
  mutate(Percentage = (Amount / Total_Amount) * 100)
# Filter out the Active.Payroll component for plotting
payroll_to_plot <- payroll_with_active_long %>%
  filter(Component != "Active.Payroll" & Percentage > 0)
# Create a summary table with both amount and percentage for each component
payroll_summary_playoff <- payroll_with_active_long %>%
  filter(Component != "Active.Payroll") %>%
  pivot_wider(names_from = Component, 
              values_from = c(Amount, Percentage), 
              names_sep = "_",
              values_fn = list(Amount = sum, Percentage = sum)) %>%
  arrange(Year)
print(payroll_summary_playoff, n = Inf, width = Inf)
# Create a stacked bar plot for payroll components by year excluding Active.Payroll with percentages
ggplot(payroll_to_plot, aes(x = Year, y = Amount, fill = Component)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = sprintf("%.1f%%", Percentage)),
            position = position_stack(vjust = 0.5), size = 3, color = "black") +
  labs(title = "Payroll Components by Year (Excluding Active Payroll in Plot)", 
       subtitle = "Playoff Teams",
       x = "Year", 
       y = "Payroll Amount (in millions)",
       fill = "Payroll Component") +
  scale_y_continuous(labels = scales::dollar_format(scale = 1e-6, suffix = "M")) +
  scale_fill_manual(values = c("Injured" = "lightcoral", 
                               "Retained" = "lightgreen", "Buried" = "lightyellow", 
                               "Suspended" = "lightgrey")) +
  coord_cartesian(ylim = c(0, max(payroll_to_plot$Amount) * 1.5)) + # Adjust zoom if needed
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Adjust text angle for readability


# Calculate total payroll including Active.Payroll
payroll_with_active <- unique_dnp %>%
  group_by(Year) %>%
  summarize(
    Active.Payroll = sum(Active.Payroll, na.rm = TRUE),
    Injured = sum(Injured, na.rm = TRUE),
    Retained = sum(Retained, na.rm = TRUE),
    Buried = sum(Buried, na.rm = TRUE),
    Suspended = sum(Suspended, na.rm = TRUE)
  )
# Reshape the data to a long format
payroll_with_active_long <- melt(payroll_with_active, id.vars = "Year", 
                                 variable.name = "Component", value.name = "Amount")
# Calculate the total payroll amount for each year including Active.Payroll
total_payroll_with_active <- payroll_with_active_long %>%
  group_by(Year) %>%
  summarize(Total_Amount = sum(Amount, na.rm = TRUE))
# Merge total payroll with the long format data to calculate percentages
payroll_with_active_long <- merge(payroll_with_active_long, total_payroll_with_active, by = "Year") %>%
  mutate(Percentage = (Amount / Total_Amount) * 100)
# Filter out the Active.Payroll component for plotting
payroll_to_plot <- payroll_with_active_long %>%
  filter(Component != "Active.Payroll" & Percentage > 0)
# Create a summary table with both amount and percentage for each component
payroll_summary_missed <- payroll_with_active_long %>%
  filter(Component != "Active.Payroll") %>%
  pivot_wider(names_from = Component, 
              values_from = c(Amount, Percentage), 
              names_sep = "_",
              values_fn = list(Amount = sum, Percentage = sum)) %>%
  arrange(Year)
print(payroll_summary_missed, n = Inf, width = Inf)
# Create a stacked bar plot for payroll components by year excluding Active.Payroll with percentages
ggplot(payroll_to_plot, aes(x = Year, y = Amount, fill = Component)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = sprintf("%.1f%%", Percentage)),
            position = position_stack(vjust = 0.5), size = 3, color = "black") +
  labs(title = "Payroll Components by Year (Excluding Active Payroll in Plot)", 
       subtitle = "Missed Playoff Teams",
       x = "Year", 
       y = "Payroll Amount (in millions)",
       fill = "Payroll Component") +
  scale_y_continuous(labels = scales::dollar_format(scale = 1e-6, suffix = "M")) +
  scale_fill_manual(values = c("Injured" = "lightcoral", 
                               "Retained" = "lightgreen", "Buried" = "lightyellow", 
                               "Suspended" = "lightgrey")) +
  coord_cartesian(ylim = c(0, max(payroll_to_plot$Amount) * 2.0)) + # Adjust zoom if needed
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Adjust text angle for readability



