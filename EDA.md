---
title: Title
---


``` r
library(ggplot2)
library(dplyr)
library(tidyr)
library(shiny)
library(scales)
library(forcats)

#Need to update R for these
#install.packages("ggplotly")
#library(ggplotly)

df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
head(df)

#Checking where the NA's are
colSums(is.na(df))
'''
It is expected for there to be missing values in Previous year payroll, percent change and difference for 2011 (there is
no prior data), so likely will drop the 2011 season. 
Also, the high amount of missing values in the suspended column is also expected and ok, there shouldnt be players getting suspended
too often. 
'''

#Checking to make sure the datatypes are what they should be
str(df)
'''
$ Team: chr  $ Year: int $ Payroll.Ranking: int $ Total.Payroll: int  
$ League.Average.Payroll: num $ Previous.Year.Payroll : int  $ Payroll.Percent.Change: num  
$ Payroll.Difference: int  $ Active.Payroll: int  $ Injured: num  
$ Retained : num  $ Buried : num  $ Suspended: num $ Player: chr  
$ Pos: chr  $ Exp: num  $ Status: chr  $ Payroll.Salary : num  
$ Type: chr  $ Average.Age: num  $ W: int  $ L: int  $ W.L.: num  
$ World.Series: chr  $ ALCS : chr  $ NLCS: chr  
$ AL.Division.Series: chr  $ NL.Division.Series: chr  $ Wild.Card.Game : chr  
'''


#######################################################################################3
#Summary Statistics

#Mean of league average payroll - $131,789,584
mean(df$League.Average.Payroll)
#Mean of Total Payroll - $132,927,904 (Expected to be very very close to the same number)
mean(df$Total.Payroll)
#Median of League average payroll - $133,894,291 (Surprisingly close to the mean)
median(df$League.Average.Payroll)
#Median of League average payroll - $125,242,452
median(df$Total.Payroll)


#League average payroll minimum with year
print(paste("Minimum League Average Payroll value:", min(df$League.Average.Payroll, na.rm = TRUE), "Year:", df$Year[which.min(df$League.Average.Payroll)]))
#League average payroll maximum with year
print(paste("Maximum League Average Payroll value:", max(df$League.Average.Payroll, na.rm = TRUE), "Year:", df$Year[which.max(df$League.Average.Payroll)]))

#Total.Payroll Minimum with year
print(paste("Minimum total payroll value:", min(df$Total.Payroll, na.rm = TRUE), "Year:", df$Year[which.min(df$Total.Payroll)]))
#Total Payroll maximum with year
print(paste("Maximum total payroll value:", max(df$Total.Payroll, na.rm = TRUE), "Year:", df$Year[which.max(df$Total.Payroll)]))

#Finding the quartiles for the Total.Payroll
# Compute quartiles
quartiles <- quantile(df$Total.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) df$Year[which.min(abs(df$Total.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}

#Finding the quartiles for league average payroll
# Compute quartiles
quartiles <- quantile(df$League.Average.Payroll, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
# Find the corresponding years for each quartile
quartile_years <- sapply(quartiles, function(x) df$Year[which.min(abs(df$League.Average.Payroll - x))])
# Print the results
for (i in 1:length(quartiles)) {
  print(paste("Quartile", names(quartiles)[i], "value:", quartiles[i], "Year:", quartile_years[i]))
}

###############################################################################3
#Plotting!

#Plotting the Quartiles (with all years)  - This plot is messy
# Create a data frame for plotting
quartile_data <- data.frame(
  Quartile = names(quartiles),
  Value = as.numeric(quartiles),
  Year = quartile_years
)
# Plot the quartiles with ggplot2
ggplot(df, aes(x = Year, y = Total.Payroll)) +
  geom_point() +  # Scatter plot of all data points
  geom_hline(data = quartile_data, aes(yintercept = Value, color = Quartile), linetype = "dashed", size = 1) +
  geom_text(data = quartile_data, aes(x = Year, y = Value, label = paste(Quartile, ":", Value)), vjust = -0.5) +
  labs(title = "Total Payroll and Quartiles Over Years",
       x = "Year",
       y = "Total Payroll") +
  theme_minimal()

# Creating a boxplot for each year in one chart - this one is beautiful
# Plot the box plot with ggplot2
ggplot(df, aes(x = as.factor(Year), y = Total.Payroll / 1000000)) +
  geom_boxplot() +
  scale_y_continuous(labels = label_number_si()) +
  labs(title = "Total Payroll Distribution by Year",
       x = "Year",
       y = "Total Payroll (millions)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability
# Customizing the plot
# Example customization of the box plot
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


#Analyzing the total payroll for each team that won the world series

#This plot shows the teams based on their color (I don't think this is a great way to show it)
# Step 1: Filter the dataframe for teams that have "Won" in the World Series column
won_teams <- df[df$World.Series == "Won", ]
# Step 2: Aggregate total payroll by team and year (assuming each team's payroll is the same for a given year)
aggregate_payroll <- aggregate(Total.Payroll ~ Team + Year, data = won_teams, FUN = function(x) x[1])
# Step 3: Determine the order of teams based on the earliest year they won the World Series
team_order <- aggregate_payroll[order(aggregate_payroll$Year), "Team"]
aggregate_payroll$Team <- factor(aggregate_payroll$Team, levels = unique(aggregate_payroll$Team))
# Step 4: Create a color palette for teams (blue for oldest, red for more recent)
team_palette <- scale_fill_manual(values = colorRampPalette(c("blue", "red"))(length(unique(aggregate_payroll$Team))))
# Step 5: Plot the aggregated data with ordered colors
ggplot(aggregate_payroll, aes(x = Year, y = Total.Payroll / 1e6, fill = Team)) +
  geom_bar(stat = "identity") +
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll for Teams that Won the World Series",
       fill = "Team") +
  team_palette +  # Use the custom color palette
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M")) +  # Format y-axis labels in millions
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



#This plot shows the number of wins by the color. The more red, the more wins. 
#This is a unique and interesting graph to look at

# Step 1: Filter the dataframe for teams that have "Won" in the World Series column
won_teams <- df[df$World.Series == "Won", ]
# Step 2: Aggregate total payroll and wins by team and year
team_stats <- won_teams %>%
  group_by(Team, Abbreviation, Year) %>%
  summarise(Total_Payroll = mean(Total.Payroll),  # Assuming Total.Payroll is constant across rows for each Team and Year
            Total_Wins = mean(W)) %>%  # total wins for each team in each year
  ungroup()
# Step 3: Order teams by total wins (descending)
team_stats <- team_stats %>%
  mutate(Team = fct_reorder(Team, Total_Wins, .desc = TRUE))
# Step 4: Create a color palette for wins (more wins = more red)
team_palette <- scale_fill_gradient(low = "yellow", high = "red",
                                    limits = range(team_stats$Total_Wins),
                                    breaks = pretty_breaks(n = 5))
# Step 5: Plot the data with payroll on y-axis, year on x-axis, and wins-based color gradient
ggplot(team_stats, aes(x = Year, y = Total_Payroll / 1e6, fill = Total_Wins, label = Abbreviation)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll vs. Year for Teams that Won the World Series",
       fill = "Total Wins") +
  team_palette +  # Use the custom color palette
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M")) +  # Format y-axis labels in millions
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotate x-axis labels for better readability
  geom_text(position = position_dodge(width = 0.9),    # Position dodge to match the bars
            vjust = -0.5,                              # Adjust vertical position for better visibility
            size = 3,                                  # Adjust text size
            color = "black",                           # Text color
            aes(label = Abbreviation))    

#Creating reference lines for 2011 and 2023 league average payrolls to include in the plot

# Step 5: Plot the data with payroll on y-axis, year on x-axis, and wins-based color gradient
ggplot(team_stats, aes(x = Year, y = Total_Payroll / 1e6, fill = Total_Wins, label = Abbreviation)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll vs. Year for Teams that Won the World Series",
       fill = "Total Wins") +
  team_palette +  # Use the custom color palette
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M")) +  # Format y-axis labels in millions
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotate x-axis labels for better readability
  geom_text(position = position_dodge(width = 0.9),    # Position dodge to match the bars
            vjust = -0.5,                              # Adjust vertical position for better visibility
            size = 3,                                  # Adjust text size
            color = "black",                           # Text color
            aes(label = Abbreviation)) +               # Use Abbreviation as label
  geom_hline(yintercept = c(unique(df$League.Average.Payroll[df$Year == 2011]) / 1e6, 
                            unique(df$League.Average.Payroll[df$Year == 2023]) / 1e6),
             linetype = "dotdash", color = "black") +  # Add reference lines for 2011 and 2023 average payroll
  annotate("text", x=c(2011), y = c(unique(df$League.Average.Payroll[df$Year == 2011]) / 1e6), 
           label = c("2011 Avg Payroll"),
           vjust = -0.75, hjust = .40, color = "black", fontface = "italic")+
  annotate("text", x=c(2023), y = c(unique(df$League.Average.Payroll[df$Year == 2023]) / 1e6), 
            label = c("2023 Avg Payroll"),
            vjust = -0.75, hjust = 5, color = "black", fontface = "italic")
#
print(unique(df$League.Average.Payroll[df$Year == 2023]))


# Creating a plot with each year's league average payrolls
# This plot makes a little more sense bc it really shows each year's league average payroll
# Step 5: Plot the data with payroll on y-axis, year on x-axis, and wins-based color gradient
ggplot(team_stats, aes(x = Year, y = Total_Payroll / 1e6, fill = Total_Wins, label = Abbreviation)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_point(aes(y = unique(df$League.Average.Payroll) / 1e6), color = "black", size = 3, shape = 1) +  # Add points for league average payroll
  labs(x = "Year", y = "Total Payroll (Millions)",
       title = "Total Payroll vs. Year for Teams that Won the World Series",
       fill = "Total Wins") +
  team_palette +  # Use the custom color palette
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "M")) +  # Format y-axis labels in millions
  scale_x_continuous(breaks = seq(min(df$Year), max(df$Year), by = 1)) +  # Include all years
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotate x-axis labels for better readability
  geom_text(position = position_dodge(width = 0.9),    # Position dodge to match the bars
            vjust = -0.5,                              # Adjust vertical position for better visibility
            size = 3,                                  # Adjust text size
            color = "black",                           # Text color
            aes(label = Abbreviation))       
  
```
