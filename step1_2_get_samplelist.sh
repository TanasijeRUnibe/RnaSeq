#!/usr/bin/env bash
#SBATCH --array=1-12
#SBATCH --time=00:10:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=slurm_array
#SBATCH --output=array_%J.out
#SBATCH --error=array_%J.err
#SBATCH --partition=pibu_el8

# Directory containing FASTQ files (provided as an argument when running the script)
FASTQ_FOLDER=$1

# Loop through all FASTQ files that end with "_1.fastq.gz"
for FILE in $FASTQ_FOLDER/*_*1.fastq.gz
do 
    # Extract the sample prefix (remove _1.fastq.gz or _2.fastq.gz)
    PREFIX="${FILE%_*.fastq.gz}"
    SAMPLE=`basename $PREFIX`  # Get only the sample name

    # Print the sample name, Read 1 file, and Read 2 file in tab-separated format
    echo -e "${SAMPLE}\t$FILE\t${FILE%?_1.fastq.gz}_2.fastq.gz" 
done > samplelist.tsv  # Save the output to samplelist.tsv
