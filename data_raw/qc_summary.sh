#!/usr/bin/env bash 
 
input_file="data_raw/patient_measurements.csv" 
output_file="outputs/tables/qc_summary.txt" 
 
if [ ! -f "$input_file" ]; then 
 echo "Error: input file not found: $input_file" 
 exit 1 
fi 
 
{ 
 echo "Biomedical Data QC Summary" 
 echo "==========================" 
 echo "" 
 echo "Input file: $input_file" 
 echo "Total data rows: $(( $(wc -l < "$input_file") - 1 ))" 
 echo "" 
 
 echo "Duplicate patient IDs:" 
 cut -d',' -f1 "$input_file" | tail -n +2 | sort | uniq -d 
 
 echo "" 
 echo "Rows containing missing values:" 
 grep ',,' "$input_file" || echo "None found" 
} > "$output_file" 
 
echo "QC summary saved to: $output_file" 
 