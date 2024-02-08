# Section 1: Install necessary packages
install.packages(c("data.table", "dplyr"))

# Section 2: Load packages
library(data.table)
library(dplyr)

# Section 3: Point to sppIDer output directory and make a list of needed files
sppIDer_output_dir <- "/path/to/output/dir"
file_list <- list.files(sppIDer_output_dir, pattern = "_covBinsSummary.txt$|_speciesAvgDepth-d.txt$", full.names = TRUE)

# Import and process data
data_list <- lapply(file_list, function(file_path) {
  file_name <- tools::file_path_sans_ext(basename(file_path))
  file_data <- fread(file_path, header = TRUE)  # Read text files as tables
  
  # Extract necessary columns
  if (grepl("_covBinsSummary.txt$", file_path)) {
    file_data <- file_data[, c("species", "perAboveCutoff"), with = FALSE]
    file_data$perAboveCutoff <- as.numeric(sub("%", "", file_data$perAboveCutoff))  # Remove % character and convert to numeric
  } else {
    file_data <- file_data[, c("species", "log2mean"), with = FALSE]
  }
  
  # Rename columns to ensure consistency
  colnames(file_data) <- c("species", file_name)
  
  return(file_data)
})

# Merge data frames by species
merged_data <- Reduce(function(x, y) merge(x, y, by = "species", all = TRUE), data_list)

# Write merged data to CSV
write.csv(merged_data, file = "sppIDer_folder_summary.csv", row.names = FALSE)
