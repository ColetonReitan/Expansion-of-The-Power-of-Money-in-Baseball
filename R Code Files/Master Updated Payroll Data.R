library(rvest)
library(dplyr)
library(stringr)
library(tidyr)
library(purrr)

#https://www.spotrac.com/mlb/cleveland-guardians/overview/_/year/2014/sort/cap_total2
#Guardians stat link

# Specify the years you are interested in
years <- c(2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024)

# List of MLB teams (replace with the actual list of teams or scrape it from the website)
teams <- c("arizona-diamondbacks", "atlanta-braves", "baltimore-orioles",
           "boston-red-sox", "chicago-white-sox", "chicago-cubs",
           "cincinnati-reds", "colorado-rockies",
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
##############################################################################################
#Guardians data was hidden in different part of website that did not follow same html formatting
#This section retrieves the guardians data

# Function to fetch and process team payroll data
fetch_process_team_payroll <- function(team_slug, year, table_id_map, drop_columns) {
  # Construct URL
  url <- paste0("https://www.spotrac.com/mlb/", team_slug, "/overview/_/year/", year, "/sort/cap_total2")
  
  # Read HTML content
  page <- read_html(url)
  
  # Extract tables
  tables <- page %>% html_nodes("#table")
  
  # Remove last three tables if present
  if (length(tables) > 3) {
    tables <- tables[1:(length(tables) - 3)]
  }
  
  # Get table IDs based on number of tables
  table_ids <- table_id_map[[as.character(length(tables))]]
  
  # Initialize list to store data frames
  team_year_dfs <- list()
  
  # Process each table
  for (i in seq_along(tables)) {
    table <- tables[i] %>% html_table(fill = TRUE) %>% as.data.frame()
    table_id <- table_ids[i]
    
    # Rename columns
    colnames(table) <- gsub("Payroll.Salary.........................Adjusted", "Payroll.Salary", colnames(table))
    colnames(table) <- gsub("Player.*", "Player", colnames(table))
    
    # Add Year, Type, and Team columns
    table <- table %>%
      mutate(Year = year, Type = table_id, Team = team_slug)
    
    # Clean up Player column
    if ("Player" %in% colnames(table)) {
      table$Player <- sapply(table$Player, function(player_name) str_trim(str_extract(player_name, "\\S+\\s+\\S+$")))
    }
    
    # Drop specified columns
    table <- table %>% select(-one_of(drop_columns))
    
    # Convert Payroll.Salary to numeric
    if ("Payroll.Salary" %in% colnames(table)) {
      table$Payroll.Salary <- as.numeric(gsub("[^0-9.-]", "", table$Payroll.Salary))
    }
    
    # Store table in list
    table_name <- paste(team_slug, year, table_id, "df", sep = "_")
    team_year_dfs[[table_name]] <- table
  }
  
  return(team_year_dfs)
}

# Specify the years you are interested in
years <- c(2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2021,2020, 2022, 2023, 2024)

# Define table IDs based on number of tables present
table_id_map <- list(
  "1" = c("active"),
  "2" = c("active", "dead"),
  "3" = c("active", "injured", "dead"),
  "4" = c("active", "injured", "suspended", "dead")
)

# Columns to drop
drop_columns <- c("Luxury.Tax", "Luxury.Tax...........................League.CBT", 
                  "Cash.Total", "Free.Agent.........................Year")

# Initialize empty list to store all data frames
list_of_dfs <- list()

# Loop through each year and each team slug
for (year in years) {
  team_slugs <- c("cleveland-guardians", "miami-marlins")
  
  for (team_slug in team_slugs) {
    # Fetch and process team payroll data
    team_year_dfs <- fetch_process_team_payroll(team_slug, year, table_id_map, drop_columns)
    
    # Add team and year specific data frames to list
    list_of_dfs[[paste(team_slug, year, sep = "_")]] <- team_year_dfs
  }
}

# Extract and assign each data frame from list_of_dfs to its own variable in global environment
for (team_year in names(list_of_dfs)) {
  for (df_name in names(list_of_dfs[[team_year]])) {
    assign(df_name, as.data.frame(list_of_dfs[[team_year]][[df_name]]), envir = .GlobalEnv)
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
    restricted_data <- bind_rows(reserved_data, get(team_df))
  }
}



#Removing unneeded df's from global for RAM purposes
# Names of the dataframes you want to keep
keep_dfs <- c("active_data", "ir_data", "dead_data", "restricted_data", "deferred_data", "reserved_data")
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
  select(-starts_with("X"),-Var.7,-Age)


###############################################################################################################
#Bringing in Overall Yearly Payroll Data

# Specify the years you are interested in
years <- c(2011,2012, 2013,2014,2015,2016,2017,2018,2019,2020,2021, 2022, 2023,2024)

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

# Replace "FLA" with "MIA" in the Team column
combined_payroll <- combined_payroll %>%
  mutate(Team = ifelse(Team == "FLA", "MIA", Team))
combined_payroll <- combined_payroll %>%
  select(-Rank)

combined_payroll <- combined_payroll %>%
  group_by(Year) %>%  # Group by Year
  arrange(Year, desc(Total.Payroll)) %>%  # Arrange by Year and Total.Payroll in descending order
  mutate(Payroll.Ranking = row_number()) %>%  # Create ranking column
  ungroup()  # Ungroup to return to original data frame structure



##################################################################################################################
#Combining the two dataframes

# Comprehensive mapping table for MLB teams
team_mapping <- data.frame(
  Abbreviation = c("ARI", "ATL", "BAL", "BOS", "CHC", "CIN", "CLE", "COL", "DET", "HOU",
                   "KC", "LAA", "LAD", "MIA", "MIL", "MIN", "NYM", "NYY", "OAK", "PHI",
                   "PIT", "SD", "SEA", "SF", "STL", "TB", "TEX", "TOR", "WSH", "CHW", "FLA"),
  Expanded = c("arizona-diamondbacks", "atlanta-braves", "baltimore-orioles", "boston-red-sox", "chicago-cubs",
               "cincinnati-reds", "cleveland-guardians", "colorado-rockies", "detroit-tigers", "houston-astros",
               "kansas-city-royals", "los-angeles-angels", "los-angeles-dodgers", "miami-marlins", "milwaukee-brewers",
               "minnesota-twins", "new-york-mets", "new-york-yankees", "oakland-athletics", "philadelphia-phillies",
               "pittsburgh-pirates", "san-diego-padres", "seattle-mariners", "san-francisco-giants", "st-louis-cardinals",
               "tampa-bay-rays", "texas-rangers", "toronto-blue-jays", "washington-nationals", "chicago-white-sox", "miami-marlins")
)


# Merge based on the mapping table and the year
merged_df <- combined_payroll %>%
  left_join(team_mapping, by = c("Team" = "Abbreviation")) %>%  # Convert abbreviations to expanded names
  left_join(combined_df, by = c("Expanded" = "Team", "Year" = "Year")) # Merge with combined_df on team and year

# Drop unneeded columns
merged_df <- merged_df %>%
  select(-Wins, -Losses, -Incentives.Likely, -Incentives.Unlikely, -Adjusted.Payroll.Salary, -Base.Salary, -Signing.Bonus)

# Renaming some columns
merged_df <- merged_df %>%
  rename(
    Abbreviation = Team,
    Team = Expanded,
  )

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
  select(Team, Abbreviation, Year, Payroll.Ranking, Total.Payroll, League.Average.Payroll, Previous.Year.Payroll, Payroll.Percent.Change, Payroll.Difference, 
         Active.Payroll, Injured, Retained, Buried, Suspended, Player, Pos, Exp, Status,
         Payroll.Salary, Type, Average.Age)

# Save dataframe to a CSV file
#write.csv(merged_df, file = "first_MLBPayroll_Download.csv", row.names = FALSE)
#getwd()

########################################################################################################33
#Bringing in playoff appearances and win/loss data

# Function to convert team names to the desired convention
convert_team_name <- function(team_name) {
  team_name <- gsub(" ", "-", team_name)  # Replace spaces with hyphens
  tolower(team_name)  # Convert to lowercase
}

# Initialize an empty list to store data frames
postseason_data_list <- list()
season_record_data_list <- list()

# Loop through each year from 2013 to 2023, excluding 2020
for (year in 2011:2023) {
  # Set the URL for the specific year's standings
  url_standings <- paste0('https://www.baseball-reference.com/leagues/majors/', year, '-standings.shtml')
  
  # Read the raw HTML content for standings
  raw_html_standings <- read_html(url_standings)
  
  # Extract season record tables (standings)
  season_record_tables <- raw_html_standings %>%
    html_nodes("table") %>%
    map_df(~ html_table(.))
  
  # Drop the GB column and rename Tm to Team
  season_record_tables <- season_record_tables %>%
    select(-GB) %>%
    rename(Team = Tm)
  
  # Add a Year column
  season_record_tables <- season_record_tables %>%
    mutate(Year = year,
           Team = gsub(" ", "-", Team),
           Team = tolower(Team))
  
  # Store season record data for the current year in the list
  season_record_data_list[[paste0("season_record_", year)]] <- season_record_tables
  
  # Read the raw HTML content for postseason results
  raw_html_postseason <- raw_html_standings  # Using the same HTML content for postseason
  
  # Extract the commented section containing the "Postseason" table
  commented_html <- raw_html_postseason %>%
    html_nodes(xpath = "//comment()") %>%
    html_text() %>%
    grep("div_postseason", ., value = TRUE) %>%
    gsub("<!--|-->", "", .)
  
  # Parse the extracted HTML content for postseason
  postseason_parsed <- read_html(commented_html)
  
  # Extract the table rows for postseason
  rows <- postseason_parsed %>% html_nodes("tr")
  
  # Initialize an empty data frame for the postseason data
  postseason_data <- data.frame(Series = character(),
                                Outcome = character(),
                                stringsAsFactors = FALSE)
  
  # Loop through each row and extract the relevant data
  for (row in rows) {
    series <- row %>% html_node("td:nth-child(1) a") %>% html_text(trim = TRUE)
    outcome <- row %>% html_node("td:nth-child(3)") %>% html_text(trim = TRUE)
    
    if (!is.na(series) & !is.na(outcome)) {
      postseason_data <- rbind(postseason_data, data.frame(Series = series,
                                                           Outcome = outcome,
                                                           stringsAsFactors = FALSE))
    }
  }
  
  # Split Outcome into Winning Team and Losing Team
  postseason_data <- postseason_data %>%
    mutate(Winning_Team = sub("^(.*?)\\s+over\\s+(.*?)$", "\\1", Outcome),
           Losing_Team = sub("^(.*?)\\s+over\\s+(.*?)$", "\\2", Outcome))
  
  # Remove the original Outcome column if no longer needed
  postseason_data <- postseason_data[, c("Series", "Winning_Team", "Losing_Team")]
  
  # Add a Year column with the current year
  postseason_data$Year <- year
  
  # Convert team names to the desired convention
  postseason_data <- postseason_data %>%
    mutate(Winning_Team = case_when(
      TRUE ~ convert_team_name(Winning_Team)
    ),
    Losing_Team = case_when(
      TRUE ~ convert_team_name(Losing_Team)
    ))
  
  # Store the postseason data for the current year in the list
  postseason_data_list[[paste0("postseason_", year)]] <- postseason_data
}

# Combine all season record data frames into one
combined_season_record <- map_dfr(season_record_data_list, ~ .x)

# Combine all postseason data frames into one
combined_postseason <- map_dfr(postseason_data_list, ~ .x)

# Clean up the "Team" column
# Define a function to apply multiple replacements
replace_team_names <- function(df) {
  df %>%
    mutate(
      Team = gsub("st\\.-louis-cardinals", "st-louis-cardinals", Team),
      Team = gsub("florida-marlins", "miami-marlins", Team),
      Team = gsub("cleveland-indians", "cleveland-guardians", Team),
      Team = gsub("los-angeles-angels-of-anaheim", "los-angeles-angels", Team)
    )
}

# Apply the function to your dataframe
combined_season_record <- replace_team_names(combined_season_record)

print("Combined Postseason Data:")
print(combined_postseason)
# Clean up the "Team" column
# Define a function to apply multiple replacements
replace_team_names <- function(df) {
  df %>%
    mutate(
      Winning_Team = gsub("st\\.-louis-cardinals", "st-louis-cardinals", Winning_Team),
      Losing_Team = gsub("st\\.-louis-cardinals", "st-louis-cardinals", Losing_Team),
      Losing_Team = gsub("los-angeles-angels-of-anaheim", "los-angeles-angels", Losing_Team),
      Winning_Team = gsub("los-angeles-angels-of-anaheim", "los-angeles-angels", Winning_Team),
      Winning_Team = gsub("cleveland-indians", "cleveland-guardians", Winning_Team),
      Losing_Team = gsub("cleveland-indians", "cleveland-guardians", Losing_Team)
    )
}

# Apply the function to your dataframe
combined_postseason <- replace_team_names(combined_postseason)
###########################
# the Merged_df with the combined_season_record df
# Merge based on the 'Team' and 'Year' columns
final_merged_df <- merge(merged_df, combined_season_record, by = c("Team", "Year"), all = TRUE)

#Removing unneeded df's from global for RAM purposes
# Names of the dataframes you want to keep
keep_dfs <- c("active_data", "ir_data", "dead_data", "restricted_data", "deferred_data", "reserved_data", "merged_df", 
              "combined_season_record", "combined_postseason", "final_merged_df")
rm(list = setdiff(ls(), keep_dfs))





# List of all possible playoff series
playoff_series <- c("World Series", "ALCS", "NLCS", "AL Division Series", 
                    "NL Division Series", "Wild Card Game")

# Add empty columns for playoff series with default value "DNP" (Did Not Play)
final_merged_df[, playoff_series] <- "DNP"

# Loop through each playoff series and fill in "Won" or "Lost" if the team participated
for (series in playoff_series) {
  # Check if the series exists in combined_postseason for each team and year
  final_merged_df[series] <- sapply(1:nrow(final_merged_df), function(i) {
    team <- final_merged_df$Team[i]
    year <- final_merged_df$Year[i]
    if (any(combined_postseason$Series == series & combined_postseason$Year == year & 
            (combined_postseason$Winning_Team == team | combined_postseason$Losing_Team == team))) {
      # Team participated in the series, check if they won or lost
      if (any(combined_postseason$Series == series & combined_postseason$Year == year & combined_postseason$Winning_Team == team)) {
        return("Won")
      } else {
        return("Lost")
      }
    } else {
      # Team did not play in the series
      return("DNP")
    }
  })
}

#Adding additional PlayoffStatus Column
# Create the new variable based on the conditions
final_merged_df <- final_merged_df %>%
  mutate(Playoff_Status = case_when(
    World.Series == "Won" ~ 5,
    World.Series == "Lost" ~ 4,
    ALCS == "Won" ~ 4,
    ALCS == "Lost" ~ 3,
    NLCS == "Won" ~ 4,
    NLCS == "Lost" ~ 3,
    AL.Division.Series == "Won" ~ 3,
    AL.Division.Series == "Lost" ~ 2,
    NL.Division.Series == "Won" ~ 3,
    NL.Division.Series == "Lost" ~ 2,
    Wild.Card.Game == "Won" ~ 2,
    Wild.Card.Game == "Lost" ~ 1,
    TRUE ~ 0  # DNP or any other cases
  ))

                             
# Save dataframe to a CSV file
write.csv(final_merged_df, file = "Completed_MLB_Payroll_Data.csv", row.names = FALSE)
getwd()

unique_values <- unique(final_merged_df$Team)
print(unique_values)

#############################################################################################
#Making sure everything in the data looks right
df <- read.csv("C:/Users/colet/Documents/Personal Projects/Completed_MLB_Payroll_Data.csv")
colnames(df)
colSums(is.na(df))
#Everything looks good








