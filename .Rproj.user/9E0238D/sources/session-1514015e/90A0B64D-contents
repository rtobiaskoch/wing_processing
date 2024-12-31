#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#---------------------------C O N F I G U R A T I O N ------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

if (!require("pacman")) install.packages("pacman")
pacman::p_unload()
pacman::p_load(purrr, dplyr, readr, tidyr, stringr)


# Define the input and output directories
input_dir <- "0_input"
output_dir <- "2_outpgit statut"

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#---------------------------R E A D   I N  F I L E S ------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# Create output directory if it doesn't exist
dir.create(output_dir, showWarnings = FALSE)

#get list of csv file names
file_names <- list.files(input_dir, 
                         pattern = "\\.csv$", 
                         full.names = TRUE)

cat("processing", length(file_names), "files.")

#read in csvs as list
files = file_names %>%
  map(~read_csv(.x, 
                col_names = F,
                show_col_types = F) %>%
        mutate(source = str_remove(basename(.x),".csv"))
  )
      

#create a single row for each mosquito
df = map_df(files, ~rbind(.x)) %>%
  mutate(wing_number = str_extract(X1, "(?<=Wing)\\d+")) %>% #extract the wing number from 1st column
  mutate(wing_number = as.numeric(wing_number)) %>% #conver to number
  mutate(wing = if_else(wing_number %% 2 == 0, "L", "R")) %>% #if number odd make it Left and even convert to Right
  group_by(source) %>%
  mutate(mosquito_number = ceiling(wing_number / 2)) %>% #get the mosquito number
  select(-X1, -wing_number) %>%
  pivot_wider(names_from = wing, 
              values_from = X2)

write.csv(df, "2_output/processed_mosquito_wings.csv", row.names = F)

cat("Processed", nrow(df), "mosquitoes. Check the", output_dir, "folder for results.\n")
