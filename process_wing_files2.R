#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#---------------------------C O N F I G U R A T I O N ------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Check if pacman package is installed, if not install it
if (!require("pacman")) install.packages("pacman")
# Unload all packages (clean start)
pacman::p_unload()
# Load required packages using pacman
pacman::p_load(purrr, dplyr, readr, tidyr, stringr)

# Define the input and output directories
input_dir <- "0_input"  # Directory containing input CSV files
output_dir <- "2_output"  # Directory where output will be saved

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#---------------------------R E A D   I N  F I L E S ------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Create output directory if it doesn't exist
dir.create(output_dir, showWarnings = FALSE)

# Get list of CSV file names in input directory
file_names <- list.files(input_dir, 
                         pattern = "\\.csv$",  # Regex pattern matching .csv extension
                         full.names = TRUE)    # Return full file paths

cat("\nprocessing", length(file_names), "files...\n", 
    paste0("\t", file_names, sep = "\n"))

# Read in all CSV files as a list of data frames
files = file_names %>%
  map(~read_csv(.x,                # Read each CSV file
                col_names = F,      # Don't use first row as column names
                show_col_types = F) %>%  # Suppress column type messages
        mutate(source = str_remove(basename(.x),".csv")))  # Add source column with filename (without .csv)
      
# Combine all data frames into one and process the data
df = map_df(files, ~rbind(.x)) %>%  # Combine all data frames by rows
       # Extract trap_id using regex: matches text between backslashes
        mutate(trap_id = str_extract(X1, "(?<=\\\\)[^\\\\]*(?=\\\\[^\\\\]*$)")) %>%
        # Extract wing number (digits after "Wing"), case insensitive
        mutate(wing_number = str_extract(X1, regex("(?<=Wing)\\d+", ignore_case = TRUE))) %>%
        mutate(wing_number = as.numeric(wing_number)) %>%  # Convert to numeric
        # Determine wing side: odd numbers = Left, even numbers = Right
        mutate(wing = if_else(wing_number %% 2 == 0, "L", "R")) %>%
        # Group by source and trap_id to calculate mosquito numbers
        group_by(source, trap_id) %>%
        # Calculate mosquito number by dividing wing number by 2 and rounding up
        mutate(mosquito_number = ceiling(wing_number / 2)) %>%
        # Remove unnecessary columns
        select(-X1, -wing_number) %>%
        # Reshape data from long to wide format (L and R wings as columns)
        pivot_wider(names_from = wing, 
                    values_from = X2) %>%
        ungroup()

missing_wings = df %>% 
  filter(is.na(R)|is.na(L))



# Create output filename with current date
time = Sys.Date()
out_fn = paste0(output_dir, "/processed_mosquito_wings_", time, ".csv")
# Write processed data to CSV
write.csv(df, out_fn, row.names = F)
      
# Print completion message
cat("Processed", nrow(df), "mosquitoes. Check the", output_dir, "folder for results.\n")

out_miss_fn = paste0(output_dir, "/missing_wings_", time, ".csv")

write.csv(missing_wings, out_miss_fn, row.names = F)

cat("Warning:", nrow(missing_wings), "mosquitoes are missing the L or R wing pixel intensity.\n",
    "see ", out_miss_fn, " for details.")