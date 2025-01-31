#!/usr/bin/env bash
#SBATCH --time=00:10:00
#SBATCH --mem=10M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=extract_alignment_rate
#SBATCH --output=/data/users/trakic/rnaseq/log/extract_alignment_rate_%J.out
#SBATCH --error=/data/users/trakic/rnaseq/log/extract_alignment_rate_%J.err
#SBATCH --partition=pibu_el8

# Variables
WORKDIR="/data/users/${USER}/rnaseq"
INPUT_DIR="$WORKDIR/mapping"       # Path to the directory containing mapping_summary.txt files
OUTPUT_FILE="$WORKDIR/mapping/00_alignment_rate_all.txt" # Path to the output file

# Initialize the output file with a header
echo -e "Sample\tAlignment Rate" > $OUTPUT_FILE

# Loop through each mapping_summary.txt file in the input directory
for FILE in "$INPUT_DIR"/*mapping_summary.txt; do
  # Extract the sample name (remove "mapping_summary.txt" from the filename)
  SAMPLE=$(basename "$FILE" | sed 's/mapping_summary.txt//')
  
  # Extract the alignment rate line and retrieve the percentage
  ALIGNMENT_RATE=$(grep "overall alignment rate" "$FILE" | awk '{print $1}')

  # Append the sample name and alignment rate to the output file
  echo -e "$SAMPLE\t$ALIGNMENT_RATE" >> $OUTPUT_FILE
done

echo "Alignment rates have been saved to $OUTPUT_FILE"
