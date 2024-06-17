import os
from glob import glob

# Define directories
working_dir = "/home/zo49sog/crassvirales/veo_phages_natia"
log_directory = f"{working_dir}/logs"

input_dir = f"{working_dir}/genomes"

genomad_output_dir = f"{working_dir}/genomad_taxonomy"
checkv_output_dir = f"{working_dir}/checkv_qc"
pharokka_output_dir = f"{working_dir}/pharokka_annotation"

database_dir = "/work/groups/VEO/databases"

genomad_database = f"{database_dir}/geNomad/v1.3"
checkv_database = f"{database_dir}/checkv/v1.5"
pharokka_database = f"{database_dir}/pharokka/v1.7.1"

# Ensure output directory exists
if not os.path.exists(genomad_output_dir):
    os.makedirs(genomad_output_dir)

if not os.path.exists(checkv_output_dir):
    os.makedirs(checkv_output_dir)

if not os.path.exists(pharokka_output_dir):
    os.makedirs(pharokka_output_dir)

if not os.path.exists(log_directory):
    os.makedirs(log_directory)

# Get all input files
input_files = [os.path.splitext(os.path.basename(f))[0] for f in glob(os.path.join(input_dir, "*.fasta"))]
#input_files = [os.path.basename(f)[:-6] for f in glob(os.path.join(input_dir, "*.fasta"))]
print("Detected input files:", input_files)

rule all:
    input:
        expand([
            os.path.join(genomad_output_dir, "{sample}"),
            os.path.join(checkv_output_dir, "{sample}"),
            os.path.join(pharokka_output_dir, "{sample}")
        ], sample=input_files)

# Calculate the log directory paths outside the rules and use them within the rule.
log_paths = {sample: os.path.join(log_directory, sample, "logs.log") for sample in input_files}

rule run_genomad:
    input:
        genome=os.path.join(input_dir, "{sample}.fasta")
    output:
        directory = directory(os.path.join(genomad_output_dir, "{sample}"))
    resources:
        cpus=90,
        mem_mb=240000
    params:
        cpus = 90,
        log=os.path.join(log_directory, "{sample}", "genomad.log")
    shell:
        """
        mkdir -p {output.directory}
        source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh && conda activate genNomad_v20230721
        genomad end-to-end --cleanup --threads {params.cpus} {input.genome} {output.directory} {genomad_database} >> {params.log} 2>&1
        """

rule run_checkv:
    input:
        genome=os.path.join(input_dir, "{sample}.fasta")
    output:
        directory = directory(os.path.join(checkv_output_dir, "{sample}"))
    params:
        cpus = 90,
        log=os.path.join(log_directory, "{sample}", "checkv.log")
    resources:
        cpus=90,
        mem_mb=240000
    shell:
        """
        mkdir -p {output.directory}
        source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh && conda activate checkv_v1.0.1
        checkv end_to_end {input.genome} {output.directory} -t {params.cpus} -d {checkv_database} >> {params.log} 2>&1
        """

rule run_pharokka:
    input:
        genome=os.path.join(input_dir, "{sample}.fasta")
    output:
        directory = directory(os.path.join(pharokka_output_dir, "{sample}"))
    params:
        name = "{sample}",
        cpus = 90,
        log=os.path.join(log_directory, "{sample}", "pharokka.log")
    resources:
        cpus=90,
        mem_mb=240000
    shell:
        """
        mkdir -p {output.directory}
        source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh && conda activate pharokka_v1.7.1
        pharokka.py -i {input.genome} -o {output.directory} -f -d {pharokka_database} -t {params.cpus} -g prodigal-gv >> {params.log} 2>&1
        
        pharokka_plotter.py -i {input.genome} -n pharokka_plot -o {output.directory} -t "{params.name}" >> {params.log} 2>&1
        pharokka_multiplotter.py -g {output.directory}/pharokka.gbk -o {output.directory}/pharokka_plots -t "{params.name}" >> {params.log} 2>&1
        """

