#!/bin/bash

#SBATCH --job-name=snakemake_genomad
#SBATCH --output=/home/zo49sog/crassvirales/veo_phages_natia/slurm_logs/result_%x.%j.txt
#SBATCH --time=3:00:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=90
#SBATCH --mem=240GB

date; hostname; pwd

# Load Snakemake environment or module
source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh

# Load the configuration file
CONFIG_FILE="/home/zo49sog/crassvirales/veo_phages_natia/config.yaml"
working_dir=$(grep 'working_dir:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
slurm_output_dir=$(grep 'slurm_output_dir:' $CONFIG_FILE | awk '{print $2}' | sed "s/{working_dir}/$(echo $working_dir | sed 's/\//\\\//g')/" | tr -d '\r' | tr -d '"')

# Print paths to verify
echo "Working directory: ${working_dir}"
echo "SLURM output directory: ${slurm_output_dir}"

# Change to the working directory
cd ${working_dir}

# Run Snakemake with SLURM cluster submission
snakemake --snakefile "${working_dir}/Snakefile" --jobs 5 --cluster "sbatch --output=${slurm_output_dir}/{rule}_%x_%j.out --time=3:00:00 --partition=short --nodes=1 --ntasks=1 --cpus-per-task={threads} --mem={resources.mem_mb}MB" --latency-wait 60

date