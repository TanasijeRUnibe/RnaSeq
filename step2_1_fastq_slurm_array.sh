#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:30:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=slurm_array
#SBATCH --partition=pibu_el8

# Define variables
CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"  # FastQC container
WORKDIR="/data/users/trakic/RnaSeq/Step2Reads/toxoplasma_de/reads"  # Working directory
OUTDIR="$WORKDIR/results"  # Output directory for FastQC results
SAMPLELIST="samplelist.tsv"  # File containing the sample list

# Extract the sample name and corresponding read files using SLURM array ID
SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

# Define output file
OUTFILE="$OUTDIR/${SAMPLE}.txt"

############################

# Create output directory if it doesn’t exist
mkdir -p $OUTDIR

# Print task details for logging
echo "Running FastQC for sample: $SAMPLE"
echo "Read 1: $READ1"
echo "Read 2: $READ2"

# Run FastQC using the Singularity (Apptainer) container
apptainer exec $CONTAINER fastqc -o $OUTDIR -t 2 $READ1 $READ2 >> $OUTFILE 2>&1
