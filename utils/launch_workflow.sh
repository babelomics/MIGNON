#!/bin/bash
#
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G

ml java-sun

cromwell_jar="/mnt/lustre/scratch/CBRA/research/pipelines/rna_seq_pipeline/cromwell_jars/cromwell-47.jar"
config="$PWD/configs/SlurmAndSingularityCallCaching.conf"
workflow="$PWD/wdl/MIGNON.wdl"
input="$PWD/input_test.json"

java -Dconfig.file=$config -jar $cromwell_jar run $workflow -i $input


