#!/bin/bash

#SBATCH --job-name=snakemake_genomad
#SBATCH --output=/home/zo49sog/crassvirales/veo_phage_genome_analysis/slurm_logs/result_%x.%j.txt
#SBATCH --time=3:00:00  # This will be overwritten by the script
#SBATCH --partition=short  # This will be overwritten by the script
#SBATCH --nodes=1  # This will be overwritten by the script
#SBATCH --ntasks=1  # This will be overwritten by the script
#SBATCH --cpus-per-task=90
#SBATCH --mem=240GB

date; hostname; pwd

# Load Snakemake environment or module
source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh

# Load the configuration file
CONFIG_FILE="/home/zo49sog/crassvirales/veo_phage_genome_analysis/config.yaml"
working_dir=$(grep 'working_dir:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
input_dir=$(grep 'input_dir:' $CONFIG_FILE | awk '{print $2}' | sed "s/{working_dir}/$(echo $working_dir | sed 's/\//\\\//g')/" | tr -d '\r' | tr -d '"')
slurm_output_dir=$(grep 'slurm_output_dir:' $CONFIG_FILE | awk '{print $2}' | sed "s/{working_dir}/$(echo $working_dir | sed 's/\//\\\//g')/" | tr -d '\r' | tr -d '"')
slurm_time=$(grep 'slurm_time:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
slurm_partition=$(grep 'slurm_partition:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
slurm_nodes=$(grep 'slurm_nodes:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
slurm_ntasks=$(grep 'slurm_ntasks:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
jobs=$(grep 'jobs:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')
snakefile=$(grep 'snakefile:' $CONFIG_FILE | awk '{print $2}' | sed "s/{working_dir}/$(echo $working_dir | sed 's/\//\\\//g')/" | tr -d '\r' | tr -d '"')
latency_wait=$(grep 'latency_wait:' $CONFIG_FILE | awk '{print $2}' | tr -d '\r' | tr -d '"')

# Print paths and settings to verify
echo "Working directory: ${working_dir}"
echo "Input directory: ${input_dir}"
echo "SLURM output directory: ${slurm_output_dir}"
echo "SLURM time: ${slurm_time}"
echo "SLURM partition: ${slurm_partition}"
echo "SLURM nodes: ${slurm_nodes}"
echo "SLURM ntasks: ${slurm_ntasks}"
echo "Number of jobs: ${jobs}"
echo "Snakefile: ${snakefile}"
echo "Latency wait: ${latency_wait}"

# Change to the working directory
cd ${working_dir}

# Run Snakemake with SLURM cluster submission
snakemake --snakefile "${snakefile}" --jobs ${jobs} --cluster "sbatch --output=${slurm_output_dir}/{rule}_%x_%j.out --time=${slurm_time} --partition=${slurm_partition} --nodes=${slurm_nodes} --ntasks=${slurm_ntasks} --cpus-per-task={threads} --mem={resources.mem_mb}MB" --latency-wait ${latency_wait}

date
