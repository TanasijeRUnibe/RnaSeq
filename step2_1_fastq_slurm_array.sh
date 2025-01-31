#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:30:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=slurm_array
#SBATCH --partition=pibu_el8

# define variables
CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"
WORKDIR="/data/users/trakic/RnaSeq/Step2Reads/toxoplasma_de/reads"
OUTDIR="$WORKDIR/results"
SAMPLELIST="samplelist.tsv"

SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

OUTFILE="$OUTDIR/${SAMPLE}.txt"

############################


mkdir -p $OUTDIR

echo "Run task for $SAMPLE with $READ1 and $READ2 ..." > $OUTFILE
#Running the fastqc command for each sample
apptainer exec $CONTAINER fastqc -o $OUTDIR -t 2 $READ1 $READ2 >> $OUTFILE 2>&1
