
# VEO Phage Genome Analysis Pipeline

This pipeline is designed to analyze phage genomes using various bioinformatics tools. Follow the steps below to set up and run the pipeline.

## Prerequisites

Before you begin, ensure you have the following installed:
- Git
- Snakemake
- SLURM (for job scheduling)
- Conda (for managing environments)

### Verify Installations
Ensure that Git, Conda, and Snakemake are installed correctly:

```
git --version
conda --version
snakemake --version
```


### Installing Miniconda, Git, and Snakemake

If you do not have Miniconda, Git, or Snakemake installed, follow these steps:

#### 1. Install Miniconda

Download and install Miniconda from the [official website](https://docs.conda.io/en/latest/miniconda.html).

For Linux:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

#### 2. Install Git
To install Git, use the following command based on your operating system:

For Ubuntu:
```commandline
conda install -c conda-forge git
```

#### 3. Install Snakemake
With the Conda environment activated, install Snakemake:

```
conda install -c bioconda -c conda-forge snakemake
```

## Setup

### 1. Create a Working Directory

Navigate to the directory where you want to install this pipeline. In this example, we will create and use a directory named 'test':

```bash
mkdir test
cd test
```

### 2. Clone the Repository
Clone the project from GitHub into the 'test' directory:
```
git clone https://github.com/MVFofanov/veo_phage_genome_analysis.git
```

### 3. Navigate to the Project Directory
Change into the project directory:

```
cd veo_phage_genome_analysis/
```

### 4. Project Structure
The project directory contains the following files and directories:

```
tree
.
├── config.yaml
├── genomes
│   ├── S22.fasta
│   ├── S23.fasta
│   ├── S24.fasta
│   └── S25.fasta
├── Snakefile
└── submit_phage_genome_analysis.sh
```

Explanation of Files and Directories:
- config.yaml: Configuration file containing paths and parameters used by the pipeline.
- genomes/: Directory containing sample genome files (in FASTA format) to be analyzed.
- Snakefile: The Snakemake workflow file that defines the steps of the analysis pipeline.
- submit_phage_genome_analysis.sh: SLURM batch script to submit the Snakemake job to the cluster.

### 5. Update Configuration Paths
Before running the pipeline, you need to update the working directory paths in the config.yaml and submit_phage_genome_analysis.sh files.

#### Edit config.yaml:
Change the working_dir path to your current project directory:

```
working_dir: /path/to/your/test/veo_phage_genome_analysis
output_dir: "{working_dir}/results"
```
#### Edit submit_phage_genome_analysis.sh:
Update the --output path in the SLURM directives:

```
#SBATCH --output=/path/to/your/test/veo_phage_genome_analysis/slurm_logs/result_%x.%j.txt
```
Also, update the CONFIG_FILE path:

```
# Load the configuration file
CONFIG_FILE="/path/to/your/test/veo_phage_genome_analysis/config.yaml"
```
Replace /path/to/your with the actual path to your 'test' directory.

## Running the Pipeline
### 1. Submit the Job
Submit the Snakemake job to the SLURM cluster by running the submit_phage_genome_analysis.sh script:

```
sbatch submit_phage_genome_analysis.sh
```
### 2. Monitor the Job
You can monitor the job status using SLURM commands such as squeue:

```
squeue -u your_username
```
### 3. Check the Output
The results of the analysis will be stored in the 'output_dir' directory specified in the config.yaml file

## Detailed Explanation of the Pipeline
### Snakefile
The Snakefile defines the workflow of the pipeline, specifying how input files are processed through various rules. Each rule corresponds to a different tool or analysis step:

- genomad: Performs taxonomy assignment using the GeNomad tool.
- checkv: Conducts quality control using CheckV.
- pharokka: Annotates the genomes using Pharokka. 
### config.yaml
This file contains configuration settings such as directory paths and database locations. It allows for easy adjustment of the pipeline settings without modifying the workflow script.

### submit_phage_genome_analysis.sh
This SLURM batch script sets up the environment and submits the Snakemake job to the cluster. It ensures that the necessary resources (e.g., CPUs, memory) are allocated for the job.

### Genomes Directory
This directory contains the input genome files (in FASTA format) that will be analyzed by the pipeline. You can add or replace files in this directory as needed.

## Troubleshooting
- Path Issues: Ensure all paths in config.yaml and submit_phage_genome_analysis.sh are correct and absolute.
- Permissions: Verify that you have the necessary permissions to read/write in the specified directories.
- Environment Setup: Make sure Conda and the required environments are properly set up.
## Contact
For further assistance, please contact Mikhail Fofanov
