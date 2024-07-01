configfile: "config.yaml"

import os
from glob import glob
import yaml

# Load the configuration file
with open("config.yaml") as file:
    config = yaml.safe_load(file)

# Define directories from the config
working_dir = config["working_dir"]
log_directory = config["log_directory"].format(working_dir=working_dir)
input_dir = config["input_dir"].format(working_dir=working_dir)
output_dir = config["output_dir"].format(working_dir=working_dir)

genomad_output_dir = config["genomad_output_dir"].format(output_dir=output_dir)
checkv_output_dir = config["checkv_output_dir"].format(output_dir=output_dir)
pharokka_output_dir = config["pharokka_output_dir"].format(output_dir=output_dir)

database_dir = config["database_dir"]
genomad_database = config["genomad_database"].format(database_dir=database_dir)
checkv_database = config["checkv_database"].format(database_dir=database_dir)
pharokka_database = config["pharokka_database"].format(database_dir=database_dir)

# Get all input files
input_files = [os.path.splitext(os.path.basename(f))[0] for f in glob(os.path.join(input_dir, "*.fasta"))]
print("Detected input files:", input_files)

# Main rule to request all outputs
rule all:
    input:
        expand("{output_dir}/{sample}", output_dir=[genomad_output_dir, checkv_output_dir, pharokka_output_dir], sample=input_files)

rule genomad:
    input:
        genome=os.path.join(input_dir, "{sample}.fasta")
    output:
        directory=directory(os.path.join(genomad_output_dir, "{sample}"))
    log:
        os.path.join(log_directory, "{sample}", "genomad.log")
    threads: 90
    resources:
        mem_mb=240000
    shell:
        """
        mkdir -p {output.directory}
        source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh && conda activate genNomad_v20230721
        genomad end-to-end --cleanup --threads {threads} {input.genome} {output.directory} {genomad_database} > {log} 2>&1
        """

rule checkv:
    input:
        genome=os.path.join(input_dir, "{sample}.fasta")
    output:
        directory=directory(os.path.join(checkv_output_dir, "{sample}"))
    log:
        os.path.join(log_directory, "{sample}", "checkv.log")
    threads: 90
    resources:
        mem_mb=240000
    shell:
        """
        mkdir -p {output.directory}
        source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh && conda activate checkv_v1.0.1
        checkv end_to_end {input.genome} {output.directory} -t {threads} -d {checkv_database} > {log} 2>&1
        """

rule pharokka:
    input:
        genome=os.path.join(input_dir, "{sample}.fasta")
    output:
        directory=directory(os.path.join(pharokka_output_dir, "{sample}"))
    log:
        os.path.join(log_directory, "{sample}", "pharokka.log")
    threads: 90
    resources:
        mem_mb=240000
    shell:
        """
        mkdir -p {output.directory}
        source /vast/groups/VEO/tools/anaconda3/etc/profile.d/conda.sh && conda activate pharokka_v1.7.1
        pharokka.py -i {input.genome} -o {output.directory} -f -d {pharokka_database} -t {threads} -g prodigal-gv > {log} 2>&1

        pharokka_plotter.py -i {input.genome} -n pharokka_plot -o {output.directory} -t "{wildcards.sample}" >> {log} 2>&1
        pharokka_multiplotter.py -g {output.directory}/pharokka.gbk -o {output.directory}/pharokka_plots -t "{wildcards.sample}" >> {log} 2>&1
        """

