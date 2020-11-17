---
layout: default
title: Input
---

# Main inputs

## JSON

As explained by [the Workflow Description Language (WDL) authors](https://github.com/openwdl/wdl/blob/master/versions/development/SPEC.md#specifying-workflow-inputs-in-json), cromwell uses a [JSON](https://www.json.org/) formatted file as main input. In MIGNON, this file contains **absolute** paths to the files that are used during the analysis, **decision variables** to control which workflow steps are carried out (e.g. wether to perform or not the variant calling) and **arguments** to control each task execution (e.g. the amount of threads to use for the alignment).

As an example, here you can find the content of a MIGNON input JSON file:

```
{
    "MIGNON.execution_mode": "hisat2",
    "MIGNON.is_paired_end": true,
    "MIGNON.do_vc": true,
	"MIGNON.input_fastq_r1": [
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615222_1.fastq.gz",
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615223_1.fastq.gz",
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615224_1.fastq.gz",
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615225_1.fastq.gz"
	],
    "MIGNON.input_fastq_r2": [
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615222_2.fastq.gz",
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615223_2.fastq.gz",
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615224_2.fastq.gz",
		"/home/user/Desktop/MIGNON/mignon_test_data/subset_fastq/SRR8615225_2.fastq.gz"
	],
    "MIGNON.sample_id": ["Control_1", "Control_2", "Problem_1", "Problem_2"],
    "MIGNON.group": ["Control", "Control", "Problem", "Problem"],
    "MIGNON.gtf_file": "/home/user/Desktop/MIGNON/mignon_test_data/Homo_sapiens.GRCh38.99.chr.gtf",
    "MIGNON.hisat2_index_path": "/home/user/Desktop/MIGNON/mignon_test_data/hisat_index",
    "MIGNON.hisat2_index_prefix": "genome",
    "MIGNON.vep_cache_dir": "/home/user/Desktop/MIGNON/mignon_test_data/subset_vep_cache",
    "MIGNON.ref_fasta": "/home/user/Desktop/MIGNON/mignon_test_data/subset_genome.fa",
    "MIGNON.ref_fasta_index": "/home/user/Desktop/MIGNON/mignon_test_data/subset_genome.fa.fai",
    "MIGNON.ref_dict": "/home/user/Desktop/MIGNON/mignon_test_data/subset_genome.dict",
    "MIGNON.db_snp_vcf": "/home/user/Desktop/MIGNON/mignon_test_data/subset_variants.vcf.gz",
    "MIGNON.db_snp_vcf_index": "/home/user/Desktop/MIGNON/mignon_test_data/subset_variants.vcf.gz.tbi",
    "MIGNON.known_vcfs":["/home/user/Desktop/MIGNON/mignon_test_data/subset_variants.vcf.gz"],
    "MIGNON.known_vcfs_indices": ["/home/user/Desktop/MIGNON/mignon_test_data/subset_variants.vcf.gz.tbi"],
    "MIGNON.edger_script": "/home/user/Desktop/MIGNON/scripts/edgeR.r",
    "MIGNON.hipathia_script": "/home/user/Desktop/MIGNON/scripts/hipathia.r"

}
```

## Cromwell conf file

The configuration file tells cromwell how to handle and launch the jobs that make up the workflow. When executing a single job, it places the values from the WDL file in the appropiated position within the container engine command. For example, the `requested_memory` runtime input, which controls the memory that is allocated for the execution of the task, is passed to the `--memory` argument when using `docker run` with the `LocalWithDocker.conf` file. On the other hand, when executing the workflow on a HPC environment, as SLURM and Singularity are used to run the jobs with the `SlurmAndSingularity.conf` file, the `requested_memory` runime input is used in the submission of the job with `sbatch --mem`. In a nuthsell, 

appropiated container software to run the  the  how the docker containers are run by placing the execution parameters in the appropiated

You can find more information about the possible backends in the [cromwell documentation](https://cromwell.readthedocs.io/en/stable/Configuring/)


## Required inputs

The inputs detailed in this section are mandatory and will vary depending on the execution mode. Apart from those as the input reads or the sample ids, it is important to pay attention to the different reference material that is required to perform the alignment, pseudo-alignment or variant calling. On the "Preferred source" column, we included the sources that we used for testing the workflow.

### Table

| Input               | Required at                                     | Variable type | File format | Preferred source                                                                                                      |
|---------------------|-------------------------------------------------|---------------|-------------|-----------------------------------------------------------------------------------------------------------------------|
| is_paired_end       | All                                             | Boolean       | -           | -                                                                                                                     |
| input_fastq_r1      | All                                             | Array[File]   | fastq       | -                                                                                                                     |
| input_fastq_r2      | All                                             | Array[File]   | fastq       | -                                                                                                                     |
| sample_id           | All                                             | Array[String] | -           | -                                                                                                                     |
| group               | All                                             | Array[String] | -           | -                                                                                                                     |
| execution_mode      | -                                               | String        | -           | -                                                                                                                     |
| do_vc               | "salmon-star", "salmon-hisat", "hisat2", "star" | Boolean       | -           | -                                                                                                                     |
| gtf_file            | All                                             | File          | gtf         | [ENSEMBL](ftp://ftp.ensembl.org/pub/release-99/gtf/homo_sapiens/Homo_sapiens.GRCh38.99.gtf.gz)                        |
| ref_fasta           | "salmon-star", "salmon-hisat", "hisat2", "star" | File          | fasta       | [ENSEMBL](ftp://ftp.ensembl.org/pub/release-99/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz) |
| ref_fasta_index     | "salmon-star", "salmon-hisat", "hisat2", "star" | File          | fai         | Created from ref_fasta with samtools.                                                                                 |
| ref_dict            | "salmon-star", "salmon-hisat", "hisat2", "star" | File          | dict        | Created from ref_fasta with samtools.                                                                                 |
| db_snp_vcf          | "salmon-star", "salmon-hisat", "hisat2", "star" | File          | vcf         | [NCBI](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/All_20170710.vcf.gz)                       |
| db_snp_vcf_index    | "salmon-star", "salmon-hisat", "hisat2", "star" | File          | tbi         | [NCBI](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/00-common_all.vcf.gz.tbi)                  |
| known_vcfs          | "salmon-star", "salmon-hisat", "hisat2", "star" | Array[File]   | vcf         | [NCBI](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/All_20170710.vcf.gz)                       |
| known_vcfs_indices  | "salmon-star", "salmon-hisat", "hisat2", "star" | Array[File]   | tbi         | [NCBI](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/00-common_all.vcf.gz.tbi)                  |
| vep_cache_dir       | "salmon-star", "salmon-hisat", "hisat2", "star" | String        | -           | [ENSEMBL](ftp://ftp.ensembl.org/pub/release-99/variation/indexed_vep_cache/)                                          |
| hisat2_index_path   | "salmon-hisat", "hisat2"                        | String        | -           | Created from ref_fasta with HISAT2.                                                                                   |
| hisat2_index_prefix | "salmon-hisat", "hisat2"                        | String        | -           | -                                                                                                                     |
| star_index_path     | "salmon-star", "star"                           | String        | -           | Created from ref_fasta with STAR.                                                                                     |
| salmon_index_path   | "salmon", "salmon-star", "salmon-hisat2"        | String        | -           | Created from ref_fasta with STAR.                                                                                     |
| edger_script        | All                                             | File          | -           | Included in MIGNON.                                                                                                   |
| tximport_script     | "salmon", "salmon-star", "salmon-hisat2"        | File          | -           | Included in MIGNON.                                                                                                   |
| hipathia_script     | All                                             | File          | -           | Included in MIGNON.                                                                                                   |
| ensemblTx_script    | "salmon", "salmon-star", "salmon-hisat2"        | File          | -           | Included in MIGNON.                                                                                                   |


### Description

* **is_paired_end**: Are input reads paired-end?
* **input_fastq_r1**: Array of paths indicating the location of the fastq files to be processed. If paired-end, the path to the (_1) files.
* **input_fastq_r2**: If paired-end, the path to the (_2) files. The position of each element in the array should match its pair in the input_fastq_r1 variable.
* **sample_id**: Array of sample identifiers. Those identifiers will be used across the different tasks to the pipeline to identify each input sample. The position of each element in the array should match its pair in the input_fastq_r1 variable.
* **group**: Array of string indicating the group of samples for each read file. Those groups will be used to perform the differential expression and signaling analyses. The position of each element in the array should match its pair in the input_fastq_r1 variable.
* **execution_mode**: String indicating the execution mode to be used.
* **do_vc**: Perform the variant calling? Only in case users do not want to extract and use variants from RNA-Seq data.
* **gtf_file**: Annotation file for the genome used at alignment and variant calling. It is also the input to create the transcript-to-gene file neccesary for the salmon quantifications.
* **ref_fasta**: Reference genome used to perform the variant calling.
* **ref_fasta_index**: Reference genome index used to perform the variant calling.
* **ref_dict**: Reference genome dictionary used to perform the variant calling.
* **db_snp_vcf**: Database of SNPs used to perform the variant calling.
* **db_snp_vcf_index**: SNP database index.
* **known_vcfs**: Databases of INDELs used to perform the variant calling.
* **known_vcfs_indices**: INDEL databases indices.
* **vep_cache_dir**: Path to the vep cache directory containing the variant annotations to be used. Should contain the SIFT and PolyPhen scores.
* **hisat2_index_path**: Path to the directory where the HISAT2 index is stored. 
* **hisat2_index_prefix**: HISAT2 index prefix.
* **star_index_path**: Path to the directory where the STAR index is stored.
* **salmon_index_path**: Path to the directory where the Salmon index is stored.
* **edger_script**: Script executed in the EdgeR task.
* **tximport_script**: Script executed in the TxImport task.
* **hipathia_script**: Script executed in the hiPathia task.
* **ensemblTx_script**: Script executed in the ensembldb task. It transforms the provided GTF into a Tx2Gene file used by tximport.

## Execution parameters

The following list contains the input parameters that can be used to control the number of CPUs and memory assigned to the container and the process where the task is executed. We will only list parameters that **really have an impact on the task execution**, that is, those parameters that are actually passed not only to the runtime of the WDL task, but also to the command that runs the operation.

### Table

| Input                   | Variable type | Default value |
|-------------------------|---------------|---------------|
| fastp_cpu               | Int           | 4             |
| fastp_mem               | String        | 16G           |
| fastqc_cpu              | Int           | 2             |
| fastqc_mem              | String        | 16G           |
| hisat2_cpu              | Int           | 4             |
| hisat2_mem              | String        | 16G           |
| sam2bam_cpu             | Int           | 4             |
| sam2bam_mem             | String        | 16G           |
| star_cpu                | Int           | 4             |
| star_mem                | String        | 32G           |
| salmon_cpu              | Int           | 4             |
| salmon_mem              | String        | 16G           |
| featureCounts_cpu       | Int           | 4             |
| featureCounts_mem       | String        | 16G           |
| vep_cpu                 | Int           | 4             |
| vep_mem                 | String        | 16G           |
| haplotype_scatter_count | Int           | 1             |

### Description

For all the above inputs, the **cpu** and **mem** parameters are directly passed to the container that executes each task. On the other hand, the **cpu** parameter is also passed to the argument that control the multi-threading on each tool. Before modifying any of this parameters, please check the parallelization section.

The **haplotype_scatter_count** input requires a special mention. As explained in the parallelization section, this parameter allows to apply the [scatter and gather strategy](https://gatk.broadinstitute.org/hc/en-us/articles/360035532012-Parallelism-Multithreading-Scatter-Gather) to parallelize the **GATK HaplotypeCaller** sub-task. This input will determine the number of chunks in which the reference genome is divide to perform the variant calling from aligned reads.

## Other inputs

In this section, users can find inputs which are not required or used to control the workflow execution, but that can notably affect the final circuit signaling activity values.

### Table

| Input                 | Variable type | Default value |
|-----------------------|---------------|---------------|
| fastp_windows_size    | Int           | 4             |
| fastp_mean_quality    | Int           | 15            |
| fastp_required_length | Int           | 20            |
| salmon_library_type   | String        | A             |
| tx2gene_file          | File          | -             |
| edger_min_counts      | Int           | 15            |
| hipathia_normalize    | Boolean       | "true"        |
| hipathia_ko_factor    | Float         | 0.01          |
| vep_sift_cutoff       | Float         | 0.05          |
| vep_polyphen_cutoff   | Float         | 0.95          |

### Description

* **fastp_windows_size**: Sliding windows size used by fastp to evaluate the quality of the sequences.
* **fastp_mean_quality**: Required mean quality for a sequence to pass the fastp filter.
* **fastp_required_length**: Reads shorter than this parameter will be discarded.
* **salmon_library_type**: Library type for salmon quantification. Defaults to "A" (automatic detection).
* **tx2gene_file**: Transcript to gene table. This parameter can be used to avoid the GTF to Tx2Gene task (ensembldb). This file must contain a two columns table indicating the mapping between the regions quantified by salmon and the features that will be used to perform the subsequent analyses (genes). This is specially important if using a GTF file that does not come from from ENSEMBL.
* **edger_min_counts**: Minimum counts per gene. This parameter will be used to filter the count matrix before the differential expression analysis. By default, all those genes with less than 15 counts across all samples will be filtered.
* **hipathia_normalize**: Normalize circuit pathway activity by length? HiPathia applies a signal propagation algorithm across the different receptor-effector circuits in the pathways to calculate the signaling circuit activity. The topology and diameter of such circuits influence the resulting circuit activity values, so this normalization is recommended.
* **hipathia_ko_factor**: LoF variants knockdown factor. This parameter control the number by which the normalized expression values are multiplied when a loss of function (LoF) variant is detected for a gene/sample.
* **vep_sift_cutoff**: Sift cutoff value. In combination with **vep_polyphen_cutoff**, it is used to filter variants that will be considered as deleterious (LoF).
* **vep_polyphen_cutoff**: Polyphen cutoff value. In combination with **vep_sift_cutoff**, it is used to filter variants that will be considered as deleterious (LoF).

## Defaults

Apart from the inputs above described, there are other inputs which are required for the workflow to be executed. Those are set as defaults, and can be changed directly in the [MIGNON wdl code](https://github.com/babelomics/MIGNON/blob/master/wdl/MIGNON.wdl) and the [MIGNON variant calling sub-workflow](https://github.com/babelomics/MIGNON/blob/master/wdl/MIGNON_calling.wdl).