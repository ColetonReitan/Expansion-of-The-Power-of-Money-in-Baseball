library(rvest)
library(dplyr)
library(stringr)
library(tidyr)

# Specify the years you are interested in
years <- c(2013,2014,2015,2016,2017,2018,2019,2021,2022,2023)

# List of MLB teams (replace with the actual list of teams or scrape it from the website)
teams <- c("arizona-diamondbacks", "atlanta-braves", "baltimore-orioles",
           "boston-red-sox", "chicago-white-sox", "chicago-cubs",
           "cincinnati-reds", "cleveland-guardians", "colorado-rockies",
           "detroit-tigers", "houston-astros", "kansas-city-royals",
           "los-angeles-angels", "los-angeles-dodgers", "miami-marlins",
           "milwaukee-brewers", "minnesota-twins", "new-york-yankees",
           "new-york-mets", "oakland-athletics", "philadelphia-phillies",
           "pittsburgh-pirates", "san-diego-padres", "san-francisco-giants",
           "seattle-mariners", "st-louis-cardinals", "tampa-bay-rays",
           "texas-rangers", "toronto-blue-jays", "washington-nationals")



# Function to clean and convert to numeric
clean_and_numeric <- function(x) {
  as.numeric(str_replace_all(x, "[^0-9.-]", ""))
}

# Function to clean player names
clean_player_name <- function(player_name) {
  # Extract the first and last name
  cleaned_name <- str_extract(player_name, "\\S+\\s+\\S+$")
  # Remove any leading/trailing whitespace
  cleaned_name <- str_trim(cleaned_name)
  return(cleaned_name)
}

# Table IDs to look for
table_ids <- c("table_active", "table_injured", "table_reserved-suspended", "table_dead", "table_deferred", "table_restricted")

# Initialize an empty list to store data frames
list_of_dfs <- list()

# Loop through each team
for (team_slug in teams) {
  # Loop through each year
  for (year in years) {
    # Construct the URL for the specific team and year
    url <- paste0("https://www.spotrac.com/mlb/", team_slug, "/payroll/", year, "/")
    
    # Read HTML content from the URL
    page <- read_html(url)
    
    # Initialize an empty list to store individual data frames for this team and year
    team_year_dfs <- list()
    
    # Loop through each table ID
    for (table_id in table_ids) {
      # Construct the CSS selector for the table
      table_selector <- paste0("#", table_id)
      
      # Try to extract the table node
      table_node <- page %>%
        html_node(table_selector)
      
      # Check if the table node exists
      if (!is.na(table_node)) {
        # Extract the table
        table <- table_node %>%
          html_table(fill = TRUE)
        
        # Check if table is not NULL and is a data frame with two dimensions
        if (!is.null(table) && is.data.frame(table) && nrow(table) > 0 && ncol(table) > 0) {
          # Rename column names containing "Payroll Salary\n                        Adjusted"
          colnames(table) <- gsub("Payroll Salary\n                        Adjusted", "Adjusted Payroll Salary", colnames(table))
          colnames(table) <- gsub("Incentives\n                        Likely", "Incentives Likely", colnames(table))
          colnames(table) <- gsub("Incentives\n                        Unlikely", "Incentives Unlikely", colnames(table))
          colnames(table) <- gsub("Player.*", "Player", colnames(table))
          
          # Remove duplicate column names and empty column names
          colnames(table) <- make.names(colnames(table), unique = TRUE)
          table <- table[, colnames(table) != ""]
          
          # Clean up the "Player" column
          if ("Player" %in% colnames(table)) {
            table$Player <- sapply(table$Player, clean_player_name)
          }
          
          # Add a new column "Type" with the value set to the table ID
          table <- table %>%
            mutate(Type = table_id, Year=year, Team=team_slug)
          
          # Check if any column contains the words "Incentives", "Salary", or "Signing"
          search_terms <- c("Incentives", "Salary", "Signing")
          search_pattern <- paste(search_terms, collapse = "|")
          matched_cols <- grep(search_pattern, colnames(table), value = TRUE)
          
          # Clean and convert to numeric each matched column
          for (col in matched_cols) {
            table[[col]] <- clean_and_numeric(table[[col]])
          }
          
          # Add the table to the list for this team and year with a descriptive name
          table_name <- paste(team_slug, year, table_id, "df", sep = "_")
          team_year_dfs[[table_name]] <- table
        }
      }
    }
    
    # Add the list of data frames for this team and year to the overall list
    list_of_dfs[[paste(team_slug, year, sep = "_")]] <- team_year_dfs
  }
}

# Extract and assign each data frame from list_of_dfs to its own variable
for (team_year in names(list_of_dfs)) {
  for (df_name in names(list_of_dfs[[team_year]])) {
    assign(df_name, list_of_dfs[[team_year]][[df_name]])
  }
}




################################################################################################
#Combining all of the data into 6 dataframes based on their ID
# Active, deferred, injured, restricted, dead, reserved

# Remaking list of data frames to combine
all_data_frames <- ls(pattern = "_df")

# Initialize empty data frames for Active and Deferred
active_data <- data.frame()
deferred_data <- data.frame()
ir_data <- data.frame()
restricted_data <- data.frame()
dead_data <- data.frame()
reserved_data <- data.frame()

# Loop through each team data frame
for (team_df in all_data_frames) {
  
  if (grepl("active", team_df)) {
    active_data <- bind_rows(active_data, get(team_df))
  }
  
  if (grepl("injured", team_df)) {
    ir_data <- bind_rows(ir_data, get(team_df))
  }
  
  if (grepl("dead", team_df)) {
    dead_data <- bind_rows(dead_data, get(team_df))
  }
  
  if (grepl("restricted", team_df)) {
    restricted_data <- bind_rows(restricted_data, get(team_df))
  }
  
  if (grepl("deferred", team_df)) {
    deferred_data <- bind_rows(deferred_data, get(team_df))
  }
  
  if (grepl("reserved-restricted", team_df)) {
    reserved_data <- bind_rows(reserved_data, get(team_df))
  }
}

#Removing unneeded df's from global for RAM purposes
# Names of the dataframes you want to keep
keep_dfs <- c("active_data", "ir_data", "dead_data", "restricted_data", "deferred_data", "reserved_data", "years", "teams")
rm(list = setdiff(ls(), keep_dfs))


#Combining 4 of the 6 different tables we have (excluding deferred & reserved, for now)

# Specify the names of your data frames
data_frame_names <- c("active_data", "ir_data", "restricted_data", "dead_data")

# Create a list of data frames from the specified names
list_of_data_frames <- lapply(data_frame_names, get)

# Combine the data frames using bind_rows
combined_df <- bind_rows(list_of_data_frames)

#Dropping mysterious X columns
combined_df <- combined_df %>%
  select(-starts_with("X"))


###############################################################################################################
#Bringing in Overall Yearly Payroll Data

#Initialize empty df
combined_payroll <- data.frame()

# Define the function to clean team names
clean_team_name <- function(team_name) {
  # Extract initials until the first backslash
  initials <- str_extract(team_name, "^[A-Z]+")
  return(initials)
}

for (year in years) {
  url <- paste0("https://www.spotrac.com/mlb/payroll/_/year/", year)
  webpage <- read_html(url)
  
  # Locate the table after the comment <!--- TABLE --->
  tables <- webpage %>% html_nodes(xpath = "//comment()[contains(., 'TABLE')]/following::table[1]")
  table <- tables %>% html_table(fill = TRUE) %>% .[[1]]
  
  # Assign unique column names
  colnames(table) <- make.names(colnames(table), unique = TRUE)
  
  # Add a Year column
  table <- table %>%
    mutate(Year = year)
  
  # Rename columns to make sure we have consistent column names
  table <- table %>%
    rename(
      Average.Age  = contains("AGE"),
      Total.Payroll = contains("Payroll"),
      Active.Payroll = contains("Active")
    )
  
  # Clean and convert appropriate columns to numeric
  table <- table %>%
    mutate(
      Rank = as.numeric(Rank),
      Total.Payroll = as.numeric(gsub("[^0-9]", "", Total.Payroll)), # Remove non-numeric characters
      Active.Payroll = as.numeric(gsub("[^0-9]", "", Active.Payroll)), # Remove non-numeric characters
      Injured = as.numeric(gsub("[^0-9]", "", Injured)), # Remove non-numeric characters
      Retained = as.numeric(gsub("[^0-9]", "", Retained)), # Remove non-numeric characters
      Buried = as.numeric(gsub("[^0-9]", "", Buried)), # Remove non-numeric characters
      Suspended = as.numeric(gsub("[^0-9]", "", Suspended)), # Remove non-numeric characters
    )
  
  # Clean up the "Team" column
  if ("Team" %in% colnames(table)) {
    table$Team <- sapply(table$Team, clean_team_name)
  }
  
  # Drop the last two rows from the table
  if (nrow(table) > 2) {
    table <- table %>%
      slice(1:(n()-2))
  }
  
  # Separate Wins and Losses from Record column
  if ("Record" %in% colnames(table)) {
    table <- table %>%
      separate(Record, into = c("Wins", "Losses"), sep = "-")
  }
  
  # Combine the scraped table with the previously scraped data
  combined_payroll <- bind_rows(combined_payroll, table)
}


##################################################################################################################
#Combining the two dataframes

# Comprehensive mapping table for MLB teams
team_mapping <- data.frame(
  Abbreviation = c("ARI", "ATL", "BAL", "BOS", "CHC", "CIN", "CLE", "COL", "DET", "HOU",
                   "KCR", "LAA", "LAD", "MIA", "MIL", "MIN", "NYM", "NYY", "OAK", "PHI",
                   "PIT", "SDP", "SEA", "SFG", "STL", "TBR", "TEX", "TOR", "WSN"),
  Expanded = c("arizona-diamondbacks", "atlanta-braves", "baltimore-orioles", "boston-red-sox", "chicago-cubs",
               "cincinnati-reds", "cleveland-guardians", "colorado-rockies", "detroit-tigers", "houston-astros",
               "kansas-city-royals", "los-angeles-angels", "los-angeles-dodgers", "miami-marlins", "milwaukee-brewers",
               "minnesota-twins", "new-york-mets", "new-york-yankees", "oakland-athletics", "philadelphia-phillies",
               "pittsburgh-pirates", "san-diego-padres", "seattle-mariners", "san-francisco-giants", "st-louis-cardinals",
               "tampa-bay-rays", "texas-rangers", "toronto-blue-jays", "washington-nationals")
)


# Merge based on the mapping table
merged_df <- combined_payroll %>%
  right_join(team_mapping, by = c("Team" = "Abbreviation")) %>%
  right_join(combined_df, by = c("Expanded" = "Team")) %>%
  select(-Team)  # Drop redundant 'Team' column

# Drop the Year.y column
merged_df <- merged_df %>%
  select(-Year.y)

# Renaming some columns
merged_df <- merged_df %>%
  rename(
    Year = Year.x,
    Team = Expanded,
    Payroll.Rank = Rank
  )

# Reorder columns
#merged_df <- merged_df %>%
#select(Team, Year, Wins, Losses, Payroll.Rank, Total.Payroll, Active.Payroll, Injured, Retained, Buried, Suspended,Player, Pos, Exp, Status,
#Payroll.Salary,Adjusted.Payroll.Salary, Base.Salary, Signing.Bonus, Incentives.Likely, Incentives.Unlikely, Type, Average.Age)

##############################################################################################################################################
#Including the manually calculated features into the dataframe
#League Average Payroll, (team) Previous Year Payroll, Payroll Percent Change, & Difference from Previous Year Payroll


# Calculate yearly league average payroll manually
yearly_league_avg_payroll <- merged_df %>%
  distinct(Team, Year, .keep_all = TRUE) %>%  # Keep one entry per team per year
  group_by(Year) %>%
  summarise(League.Average.Payroll = sum(Total.Payroll) / 30)
# Merge the league average payroll into the original dataframe
merged_df <- merged_df %>%
  left_join(yearly_league_avg_payroll, by = "Year")


# Calculate previous year's payroll for each team
previous_year_payroll <- merged_df %>%
  distinct(Team, Year, .keep_all = TRUE) %>%  # Keep one entry per team per year
  group_by(Team) %>%
  arrange(Year) %>%
  mutate(Previous.Year.Payroll = lag(Total.Payroll)) %>%
  select(Team, Year, Previous.Year.Payroll)
# Merge the previous year's payroll back into the original dataframe
merged_df <- merged_df %>%
  left_join(previous_year_payroll, by = c("Team", "Year"))


# Calculate total payroll percent change and difference from the previous year
merged_df <- merged_df %>%
  mutate(
    Payroll.Percent.Change = round(if_else(!is.na(Previous.Year.Payroll),
                                           (Total.Payroll - Previous.Year.Payroll) / Previous.Year.Payroll * 100,
                                           NA_real_), 2),
    Payroll.Difference = Total.Payroll - Previous.Year.Payroll
  )


# Reorder columns
merged_df <- merged_df %>%
  select(Team, Year, Wins, Losses, Payroll.Rank, Total.Payroll, League.Average.Payroll, Previous.Year.Payroll, Payroll.Percent.Change, Payroll.Difference, 
         Active.Payroll, Injured, Retained, Buried, Suspended,Player, Pos, Exp, Status,
         Payroll.Salary,Adjusted.Payroll.Salary, Base.Salary, Signing.Bonus, Incentives.Likely, Incentives.Unlikely, Type, Average.Age)

# Save dataframe to a CSV file
#write.csv(merged_df, file = "first_MLBPayroll_Download.csv", row.names = FALSE)
#getwd()
