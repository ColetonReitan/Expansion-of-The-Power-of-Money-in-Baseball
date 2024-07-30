library(ggplot2)
library(dplyr)
library(tidyr)
library(shiny)
library(scales)
library(forcats)
library(factoextra)

#Need to update R for these
#install.packages("ggplotly")
#library(ggplotly)

f <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
#creating unique df's
df <- f %>%
  distinct(Team, Year, .keep_all = TRUE)

colnames(df)

print(which(is.na(df$Previous.Year.Payroll)))
df[is.na(df$Previous.Year.Payroll), ]
unique(df$Year[is.na(df$Previous.Year.Payroll)])

#Checking where the NA's are
colSums(is.na(df))
#Checking to make sure the datatypes are what they should be
str(df)

#Summary Stats

#League Average Payroll
mean(df$League.Average.Payroll)
median(df$League.Average.Payroll)
print(paste("Minimum League Average Payroll value:", min(df$League.Average.Payroll, na.rm = TRUE), "Year:", df$Year[which.min(df$League.Average.Payroll)]))
print(paste("Maximum League Average Payroll value:", max(df$League.Average.Payroll, na.rm = TRUE), "Year:", df$Year[which.max(df$League.Average.Payroll)]))
#Team Total Payroll
mean(df$Total.Payroll)
median(df$Total.Payroll)
print(paste("Minimum total payroll value:", min(df$Total.Payroll, na.rm = TRUE), "Year:", df$Year[which.min(df$Total.Payroll)]))
print(paste("Maximum total payroll value:", max(df$Total.Payroll, na.rm = TRUE), "Year:", df$Year[which.max(df$Total.Payroll)]))

# Compute quartiles for Total Payroll
quartiles <- quantile(df$Total.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) df$Year[which.min(abs(df$Total.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}

#Compute quartiles for league average payroll
quartiles <- quantile(df$League.Average.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) df$Year[which.min(abs(df$League.Average.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}

quartiles_millions <- as.numeric(quartiles) / 1e6
quartile_data <- data.frame(
  Quartile = names(quartiles),
  Value = quartiles_millions,
  Year = quartile_years
)

#Plotting
# Showing quartiles for all years at once
ggplot(df, aes(x = Year, y = Total.Payroll / 1e6)) +
  geom_point() +  # Scatter plot of all data points
  geom_hline(data = quartile_data, aes(yintercept = Value, color = Quartile), linetype = "dashed", size = 1) +
  geom_text(data = quartile_data, aes(x = Year, y = Value, label = paste(Quartile, ":", round(Value, 1))), vjust = -12) +
  labs(title = "Total Payroll and Quartiles Over Years",
       x = "Year",
       y = "Total Payroll (Millions)") +
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M"))+  # Adjust y-axis labels to show values in millions
  scale_x_continuous(breaks = seq(min(df$Year), max(df$Year), by = 1))  # Include all years

#Showing boxplot by year (Much cleaner)
#customization of the box plot
ggplot(df, aes(x = as.factor(Year), y = Total.Payroll / 1000000)) +
  geom_boxplot(fill = "darkred", color = "black", alpha = 0.5, outlier.shape = 5) +  # Customize box plot appearance
  scale_y_continuous(labels = label_number_si()) +  # Format y-axis labels
  labs(title = "Total Payroll Distribution by Year",  # Add title and axis labels
       x = "Year",
       y = "Total Payroll (millions)") +
  theme_minimal() +  # Apply a minimal theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
        panel.grid.major = element_line(color = "gray", linetype = "dashed"),  # Customize grid lines
        legend.position = "bottom")  # Adjust legend position


#Showing total payroll by world series team (color marking team)
won_teams <- df[df$World.Series == "Won", ]
aggregate_payroll <- aggregate(Total.Payroll ~ Team + Year, data = won_teams, FUN = function(x) x[1])
team_order <- aggregate_payroll[order(aggregate_payroll$Year), "Team"]
aggregate_payroll$Team <- factor(aggregate_payroll$Team, levels = unique(aggregate_payroll$Team))
team_palette <- scale_fill_manual(values = colorRampPalette(c("blue", "red"))(length(unique(aggregate_payroll$Team))))
ggplot(aggregate_payroll, aes(x = Year, y = Total.Payroll / 1e6, fill = Team)) +
  geom_bar(stat = "identity") +
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll for Teams that Won the World Series",
       fill = "Team") +
  team_palette +  # Use the custom color palette
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M")) +  # Format y-axis labels in millions
  theme(axis.text.x = element_text(angle = 45, hjust = 1))





df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")

# Filter data for teams that won the World Series
won_teams <- df[df$World.Series == "Won", ]

# Summarize team statistics
team_stats <- won_teams %>%
  group_by(Team, Abbreviation, Year) %>%
  summarise(Total_Payroll = mean(Total.Payroll, na.rm = TRUE),  
            Win_Percentage = mean(W.L., na.rm = TRUE), .groups = 'drop')  # win percentage for each team in each year

# Check if Win_Percentage column is created properly
print(head(team_stats))

# Reorder teams by Win_Percentage
team_stats <- team_stats %>%
  mutate(Team = fct_reorder(Team, Win_Percentage, .desc = TRUE))

# Define the new color gradient for Win_Percentage (blue to red)
team_palette <- scale_fill_gradient(low = "blue", high = "red",
                                    limits = range(team_stats$Win_Percentage),
                                    breaks = pretty_breaks(n = 5))

# Average league payroll by year
league_avg_payroll <- df %>%
  group_by(Year) %>%
  summarise(League_Average_Payroll = mean(League.Average.Payroll, na.rm = TRUE))

# Plot the data
ggplot() +
  geom_bar(data = team_stats, aes(x = Year, y = Total_Payroll / 1e6, fill = Win_Percentage), stat = "identity", position = "dodge") +
  geom_point(data = league_avg_payroll, aes(x = Year, y = League_Average_Payroll / 1e6), color = "black", size = 3, shape = 1) +  # Add points for league average payroll
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll vs. Year for Teams that Won the World Series",
       fill = "Win Percentage") +
  team_palette +  # Use the new custom color palette
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M")) +  # Format y-axis labels in millions
  scale_x_continuous(breaks = seq(min(df$Year), max(df$Year), by = 1)) +  # Include all years
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotate x-axis labels for better readability
  geom_text(data = team_stats, aes(x = Year, y = Total_Payroll / 1e6, label = Abbreviation), 
            position = position_dodge(width = 0.9), vjust = -0.5, size = 3, color = "black")  # Adjust vertical position, text size, and color





#Looking at Payroll Trends and discrepancies

# Yearly total payroll trend for all teams
ggplot(df, aes(x = Year, y = Total.Payroll / 1e6, group = Team, color = Team)) +
  geom_line() +
  labs(title = "Total Payroll Trend by Team (2011-2023)",
       x = "Year", y = "Total Payroll (Millions)") +
  theme_minimal()

# Yearly league average payroll trend
ggplot(df, aes(x = Year, y = League.Average.Payroll / 1e6)) +
  geom_line(color = "red", size = 1) +
  labs(title = "League Average Payroll Trend (2011-2023)",
       x = "Year", y = "League Average Payroll (Millions)") +
  theme_minimal()

#Heatmap that shows total payroll for each team over the years
ggplot(df, aes(x = Year, y = Team, fill = Total.Payroll / 1e6)) +
  geom_tile() +
  scale_fill_gradient(low = "light blue", high = "red") +
  labs(title = "Total Payroll Trend by Team",
       x = "Year",
       y = "Team",
       fill = "Total Payroll (Millions)") +
  scale_x_continuous(breaks = seq(2011, max(df$Year)), limits = c(2010,2025)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))



#Looking at payroll percent changes


# Filter data for relevant columns
payroll_change <- df[, c("Team", "Year", "Payroll.Percent.Change")]
# Plotting using ggplot2
ggplot(payroll_change, aes(x = Year, y = Payroll.Percent.Change, group = Team, color = Team)) +
  geom_line() +  # Line plot
  geom_point(size = 2) +  # Points for each year
  labs(x = "Year", y = "Payroll Percent Change (%)",
       title = "Payroll Percent Change Over the Years",
       color = "Team") +
  theme_minimal() +
  theme(legend.position = "top")  # Position legend at the top
# Calculate league average percent change by year
league_avg_change <- df %>%
  group_by(Year) %>%
  summarise(Avg_Payroll_Percent_Change = mean(Payroll.Percent.Change, na.rm = TRUE)) %>%
  ungroup()
# Print the first few rows to verify
print(head(league_avg_change))
# Plotting league average percent change
ggplot(league_avg_change, aes(x = Year, y = Avg_Payroll_Percent_Change)) +
  geom_line(color = "blue") +  # Line plot
  geom_point(size = 2, color = "blue") +  # Points for each year
  labs(x = "Year", y = "League Average Payroll Percent Change (%)",
       title = "League Average Payroll Percent Change Over the Years") +
  theme_minimal()


# Plotting payroll percent change with winning percentage by color, faceted by team
ggplot(df, aes(x = Year, y = Payroll.Percent.Change, color = W.L.)) +
  geom_point(size = 3, alpha = 0.7) +  # Scatter plot with constant size and adjusted transparency
  facet_wrap(~ Team, labeller = as_labeller(function(x) str_wrap(x, width = 10))) +  # Facet by team
  labs(x = "Year", y = "Payroll Percent Change (%)",
       title = "Payroll Percent Change vs. Year with Winning Percentage by Team",
       color = "Winning Percentage") +
  scale_color_gradient(low = "blue", high = "red") +  # Color gradient for winning percentage
  geom_smooth(method = "loess", se = FALSE) +  # Add smooth trend lines
  theme_minimal() +
  coord_cartesian(ylim = c(-75, 75))  # Set y-axis limits globally


# Plotting total payroll with winning percentage by color, faceted by team
ggplot(df, aes(x = Year, y = Total.Payroll / 1e6, color = W.L.)) +
  geom_point(size = 2, alpha = 0.7) +  # Scatter plot with constant size and adjusted transparency
  facet_wrap(~ Team, labeller = as_labeller(function(x) str_wrap(x, width = 10))) +  # Facet by team
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll vs. Year with Winning Percentage by Team",
       color = "Winning Percentage") +
  scale_color_gradient(low = "blue", high = "red") +  # Color gradient for winning percentage
  geom_smooth(method = "loess", se = FALSE) +  # Add smooth trend lines
  theme_minimal() +
  coord_cartesian(ylim = c(0, max(df$Total.Payroll / 1e6, na.rm = TRUE)))  # Set y-axis limits globally

####################################################################################################

#Trend analysis

#Total Payroll v wins
# Create the scatter plot with payroll in millions, a trend line, and correlation coefficient
ggplot(df, aes(x = Total.Payroll / 1e6, y = Wins)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "MLB Team Payroll vs. Wins (2011-2023)",
       x = "Total Payroll (in millions $)",
       y = "Wins") +
  theme_minimal() +
  annotate("text", x = max(df$Total.Payroll) / 1e6, y = min(df$Wins), 
           label = paste("Correlation: ", round(cor_coeff, 2)), 
           hjust = 1, vjust = -1, size = 5)

#Payroll percent change v wins
# Calculate the correlation coefficient for Payroll Percent Change and Wins
cor_coeff_pct_change <- cor(df$Payroll.Percent.Change, df$Wins, use = "complete.obs")
# Create the scatter plot with Payroll Percent Change and Wins, with a trend line and correlation coefficient
ggplot(df, aes(x = Payroll.Percent.Change, y = Wins)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "MLB Team Payroll Percent Change vs. Wins (2011-2023)",
       x = "Payroll Percent Change (%)",
       y = "Wins") +
  theme_minimal() +
  annotate("text", x = max(df$Payroll.Percent.Change, na.rm = TRUE), y = min(df$Wins, na.rm = TRUE), 
           label = paste("Correlation: ", round(cor_coeff_pct_change, 2)), 
           hjust = 1, vjust = -1, size = 5)


#Payroll Ratio (of league avg) v wins
# Calculate the payroll ratio (percentage of League Average Payroll compared to a team's payroll)
df$Payroll.Ratio <- (df$Total.Payroll / df$League.Average.Payroll) * 100
# Calculate the correlation coefficient for Payroll Ratio and Wins
cor_coeff_ratio <- cor(df$Payroll.Ratio, df$Wins, use = "complete.obs")
# Create the scatter plot with Payroll Ratio and Wins, with a trend line and correlation coefficient
ggplot(df, aes(x = Payroll.Ratio, y = Wins)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "MLB Team Payroll Ratio vs. Wins (2011-2023)",
       x = "Payroll Ratio (%)",
       y = "Wins") +
  theme_minimal() +
  annotate("text", x = max(df$Payroll.Ratio, na.rm = TRUE), 
           y = min(df$Wins, na.rm = TRUE), 
           label = paste("Correlation: ", round(cor_coeff_ratio, 2)), 
           hjust = 1, vjust = -1, size = 5)



# Remove rows with NA, NaN, or Inf values
df <- df %>%
  filter(is.finite(Payroll.Ratio_Scaled) & is.finite(Wins_Scaled))

# Normalize the data before clustering
df$Wins_Scaled <- scale(df$Wins)
df$Payroll.Ratio_Scaled <- scale(df$Payroll.Ratio)

# Perform K-means clustering
set.seed(123)  # For reproducibility
kmeans_result <- kmeans(df[, c("Payroll.Ratio_Scaled", "Wins_Scaled")], centers = 4)  # You can choose the number of clusters (centers)

# Add cluster labels to the DataFrame
df$Cluster <- as.factor(kmeans_result$cluster)

# Get counts of each cluster
cluster_counts <- table(df$Cluster)

# Convert the table to a data frame for easier use
cluster_counts_df <- as.data.frame(cluster_counts)
colnames(cluster_counts_df) <- c("Cluster", "Count")

# Print the cluster counts
print(cluster_counts_df)

# Create the scatter plot with clusters
ggplot(df, aes(x = Payroll.Ratio, y = Wins, color = Cluster)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", col = "blue", se = FALSE) +
  labs(title = "MLB Team Payroll Ratio vs. Wins with Clusters (2011-2023)",
       x = "Payroll Ratio (%)",
       y = "Wins") +
  theme_minimal() +
  scale_color_manual(values = c("red", "orange", "blue", "brown"))  # Customize cluster colors

# If you want to add the counts to the plot, you can use annotation
counts_annotation <- paste("Cluster 1: ", cluster_counts[1], "\n",
                           "Cluster 2: ", cluster_counts[2], "\n",
                           "Cluster 3: ", cluster_counts[3], "\n",
                           "Cluster 4: ", cluster_counts[4])

ggplot(df, aes(x = Payroll.Ratio, y = Wins, color = Cluster)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", col = "blue", se = FALSE) +
  labs(title = "MLB Team Payroll Ratio vs. Wins with Clusters (2011-2023)",
       x = "Payroll Ratio (%)",
       y = "Wins") +
  theme_minimal() +
  scale_color_manual(values = c("red", "orange", "blue", "brown")) +  # Customize cluster colors
  annotate("text", x = max(df$Payroll.Ratio) * 0.8, y = max(df$Wins) * 0.2, label = counts_annotation, hjust = 0)
