#!/bin/bash
#
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
ml java-sun 

###########################
# DOWNLOAD REFERENCE DATA #
###########################


######################
# PREPARE INPUT JSON #
######################

input=$(realpath "input_templates/star.json")

# R1
input_r1=$(for i in example_data/*_1*fastq.gz; do echo \"$(realpath $i)\",; done)
input_r1=${input_r1::-1}
input_r1=$(echo $input_r1 | sed "s#\ ##g")

# R2
input_r2=$(for i in example_data/*_2*fastq.gz; do echo \"$(realpath $i)\",; done)
input_r2=${input_r2::-1}
input_r2=$(echo $input_r2 | sed "s#\ ##g")

# group
sample='"S1","S2","S3","S4","S5","S6","S7","S8","S9"'
group='"LPS","LPS","LPS","PAL","PAL","PAL","UN","UN","UN"'

sed "s#flagForCurrentDir#$PWD#g" $input > input_test.json
sed -i 's#"flagForR1Files"#'$input_r1'#g' input_test.json
sed -i 's#"flagForR2Files"#'$input_r2'#g' input_test.json
sed -i 's#"flagForSample"#'$sample'#g' input_test.json
sed -i 's#"flagForGroup"#'$group'#g' input_test.json

###################
# LAUNCH CROMWELL #
###################

cromwell_jar="/mnt/lustre/scratch/CBRA/research/pipelines/rna_seq_pipeline/cromwell_jars/cromwell-47.jar"
config="$PWD/configs/SlurmAndSingularityCallCaching.conf"
workflow="$PWD/wdl/MIGNON.wdl"
input="$PWD/input_test.json"

java -Dconfig.file=$config -jar $cromwell_jar run $workflow -i $input