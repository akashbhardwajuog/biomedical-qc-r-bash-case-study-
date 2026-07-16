# Project: Biomedical Data Quality-Control Case Study 
# Author: Akash Bhardwaj 
# Purpose: Compare biomarker values between Control and Treatment groups 

library(tidyverse) 
library(here) 

# Load the cleaned dataset created by 01_r_data_qc.R 
patient_data_clean <- read_csv( 
  here("data_processed", "patient_measurements_clean.csv"), 
  show_col_types = FALSE 
) 

# Check how many patients are in each study group 
group_sizes <- patient_data_clean %>% 
  count(group, name = "number_of_patients") 

print(group_sizes) 

# Perform an exploratory Welch two-sample t-test. 
# This is a workflow demonstration only because the dataset is very small: 
# Control = 2 patients; Treatment = 3 patients. 
biomarker_t_test <- t.test( 
  biomarker ~ group, 
  data = patient_data_clean, 
  var.equal = FALSE 
) 

print(biomarker_t_test) 

# Calculate mean biomarker values separately for each group 
control_mean <- mean( 
  patient_data_clean$biomarker[ 
    patient_data_clean$group == "Control" 
  ] 
) 

treatment_mean <- mean( 
  patient_data_clean$biomarker[ 
    patient_data_clean$group == "Treatment" 
  ] 
) 

# Create a one-row summary table of the t-test results. 
# selects the lower confidence-interval value. 
# selects the upper confidence-interval value. 
t_test_summary <- tibble( 
  comparison = "Treatment versus Control", 
  test = "Welch two-sample t-test", 
  control_mean = control_mean, 
  treatment_mean = treatment_mean, 
  mean_difference = treatment_mean - control_mean, 
  p_value = biomarker_t_test$p.value, 
  confidence_interval_lower = min(biomarker_t_test$conf.int), 
  confidence_interval_upper = max(biomarker_t_test$conf.int) 
) 

print(t_test_summary) 

# Save the summary table 
write_csv( 
  t_test_summary, 
  here("outputs", "tables", "biomarker_t_test_summary.csv") 
) 
