#!/usr/bin/env bash
#SBATCH --time=00:10:00
#SBATCH --mem=10M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=extract_alignment_rate
#SBATCH --output=/data/users/trakic/rnaseq/log/extract_concordant_alignment_rate_%J.out
#SBATCH --error=/data/users/trakic/rnaseq/log/extract_concordant_alignment_rate_%J.err
#SBATCH --partition=pibu_el8

# Set the working directories
WORKDIR="/data/users/${USER}/rnaseq"
INPUT_DIR="$WORKDIR/mapping"
SAMPLELIST="$WORKDIR/FASTQ/metadata/sample_list.txt"
OUTPUT_FILE="$WORKDIR/concordant_alignment_summary.txt"

# Create the header of the output table
echo -e "Sample\tReads\tc.a 1x\t%c.a 1x\tc.a >1x\t%c.a >1x" > $OUTPUT_FILE

# Loop through each sample and extract the relevant alignment information
NUM_SAMPLES=$(wc -l < $SAMPLELIST)
for SLURM_ARRAY_TASK_ID in $(seq 1 $NUM_SAMPLES); do
  # Get the sample name
  SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
  
  # Path to the summary file for the current sample
  SUMMARY_FILE="$INPUT_DIR/${SAMPLE}mapping_summary.txt"

  # Extract values from the HISAT2 summary file
  if [ -f "$SUMMARY_FILE" ]; then
    READS=$(awk '/reads; of these:/{print $1}' "$SUMMARY_FILE")
    CONCORDANT_1=$(awk '/aligned concordantly exactly 1 time/{print $1}' "$SUMMARY_FILE")
    CONCORDANT_GT1=$(awk '/aligned concordantly >1 times/{print $1}' "$SUMMARY_FILE")

    # Calculate the percentages
    PERCENT_CONCORDANT_1=$(echo "scale=2; ($CONCORDANT_1 / $READS) * 100" | bc)
    PERCENT_CONCORDANT_GT1=$(echo "scale=2; ($CONCORDANT_GT1 / $READS) * 100" | bc)

    # Append the information to the output file
    echo -e "$SAMPLE\t$READS\t$CONCORDANT_1\t$PERCENT_CONCORDANT_1\t$CONCORDANT_GT1\t$PERCENT_CONCORDANT_GT1" >> $OUTPUT_FILE
  else
    echo "Summary file for sample $SAMPLE not found." >&2
  fi
done

# Print completion message
echo "Concordant alignment summary table generated: $OUTPUT_FILE"
