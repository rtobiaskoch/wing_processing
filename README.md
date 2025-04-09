# Mosquito Wing Data Processor

This script processes mosquito wing measurement data from multiple CSV files, extracting relevant information and organizing it into a structured format.

## Requirements
- R (version 4.0 or higher)
- Required packages: `purrr`, `dplyr`, `readr`, `tidyr`, `stringr`

## Input Files
- Place all input CSV files in the `0_input` directory
- Files should contain mosquito wing measurement data
- Expected format: Each file represents measurements from a specific source

## Processing Steps
1. Reads all CSV files from the input directory
2. Extracts metadata from filenames and file paths
3. Processes wing measurements:
   - Identifies left (L) and right (R) wings based on numbering
   - Groups wings into mosquito pairs
   - Reshapes data into wide format (one row per mosquito)
4. Saves processed data to output directory with timestamp

## Output
- Processed data is saved as a CSV file in the `2_output` directory
- Filename format: `processed_mosquito_wings_YYYY-MM-DD.csv`
- Output columns:
  - `source`: Original filename (without .csv extension)
  - `trap_id`: Extracted from file path
  - `mosquito_number`: Unique identifier for each mosquito
  - `L`: Measurement for left wing
  - `R`: Measurement for right wing

## Usage
1. Place input files in `0_input` directory
2. Run the script
3. Check `2_output` directory for results

## Notes
- The script handles case-insensitive matching for "Wing" in wing identification
- Odd-numbered wings are considered left (L), even-numbered right (R)
- Each mosquito is assumed to have two wings (one odd, one even numbered)