# Project: Biomedical Data Quality-Control Case Study 
# Author: Akash Bhardwaj 
# Purpose: Inspect, clean, summarise, and visualise a small biomedical dataset 

library(tidyverse) 
library(janitor) 
library(here) 

# Load raw data 
patient_data_raw <- read_csv( 
  here("data_raw", "patient_measurements.csv"), 
  show_col_types = FALSE 
) 

# Inspect raw data 
print(patient_data_raw) 
glimpse(patient_data_raw) 

# Count missing values in each column 
missing_values_summary <- patient_data_raw %>% 
  summarise( 
    across( 
      everything(), 
      ~ sum(is.na(.x)) 
    ) 
  ) %>% 
  pivot_longer( 
    cols = everything(), 
    names_to = "variable", 
    values_to = "missing_values" 
  ) 

print(missing_values_summary) 

# Identify duplicate patient IDs 
duplicate_patient_ids <- patient_data_raw %>% 
  get_dupes(patient_id) 

print(duplicate_patient_ids) 

# Create cleaned data: 
# - Remove duplicate patient IDs, keeping the first occurrence 
# - Remove rows with missing age 
patient_data_clean <- patient_data_raw %>% 
  distinct(patient_id, .keep_all = TRUE) %>% 
  drop_na(age) 

print(patient_data_clean) 

# Save cleaned data 
write_csv( 
  patient_data_clean, 
  here("data_processed", "patient_measurements_clean.csv") 
) 

# Create a data-cleaning summary 
cleaning_summary <- tibble( 
  raw_rows = nrow(patient_data_raw), 
  duplicate_rows_identified = nrow(duplicate_patient_ids), 
  rows_after_removing_duplicates = nrow( 
    patient_data_raw %>% distinct(patient_id, .keep_all = TRUE) 
  ), 
  rows_after_removing_missing_age = nrow(patient_data_clean) 
) 

print(cleaning_summary) 

write_csv( 
  cleaning_summary, 
  here("outputs", "tables", "data_cleaning_summary.csv") 
) 

# Summarise cleaned data by group 
group_summary <- patient_data_clean %>% 
  group_by(group) %>% 
  summarise( 
    number_of_patients = n(), 
    mean_age = mean(age), 
    mean_biomarker = mean(biomarker), 
    median_biomarker = median(biomarker), 
    .groups = "drop" 
  ) 

print(group_summary) 

write_csv( 
  group_summary, 
  here("outputs", "tables", "biomarker_group_summary.csv") 
) 

# Create a biomarker plot 
biomarker_plot <- ggplot( 
  patient_data_clean, 
  aes(x = group, y = biomarker, fill = group) 
) + 
  geom_boxplot(alpha = 0.7, width = 0.6) + 
  geom_jitter(width = 0.1, size = 3) + 
  labs( 
    title = "Biomarker Measurements by Study Group", 
    x = "Study group", 
    y = "Biomarker value" 
  ) + 
  theme_minimal(base_size = 12) + 
  theme(legend.position = "none") 

print(biomarker_plot) 

ggsave( 
  here("outputs", "figures", "biomarker_by_group_boxplot.png"), 
  plot = biomarker_plot, 
  width = 7, 
  height = 5, 
  dpi = 300 
) 
