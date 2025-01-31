#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=6GB
#SBATCH --time=03:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=Copying

#Copying the provided experimental data for further analysis
cp -r /data/courses/rnaseq_course/toxoplasma_de /data/users/trakic/RnaSeq/Step2Reads/toxoplasma_de
