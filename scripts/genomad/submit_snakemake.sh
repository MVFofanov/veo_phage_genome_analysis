#!/bin/bash

#SBATCH --job-name=snakemake_genomad
#SBATCH --output=/home/zo49sog/crassvirales/veo_phages_natia/slurm_logs/result_%x.%j.txt
#SBATCH --time=3:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=90
#SBATCH --mem=240GB

date;hostname;pwd

# Load Snakemake environment or module
source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh

# Change to the working directory
working_dir="/home/zo49sog/crassvirales/veo_phages_natia"
cd "${working_dir}"

# Run Snakemake with SLURM cluster submission
snakemake --snakefile "${working_dir}/Snakefile" --jobs 5 --cluster "sbatch --output={log_directory}/{rule}/%x_%j.out --time=3:00:00 --partition=short --nodes=1 --ntasks=1 --cpus-per-task={resources.cpus} --mem={resources.mem_mb}MB" --latency-wait 60

date
