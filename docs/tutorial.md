# MIGNON TUTORIAL

MIGNON is a bioinformatic workflow for the mechanistic integrative analysis of rna-seq data. It is written using the [Workflow Description Language (WDL)](https://github.com/openwdl/wdl) and can be executed using [Cromwell](https://github.com/broadinstitute/cromwell). It implements a novel way of analyzing RNA-Seq data, extracting the transcriptomic and genomic information obtainable from RNA-Seq reads. By using a *in-silico* knockdown strategy, it estimates the cellular signaling circuits activities through the application of the [hipathia](http://hipathia.babelomics.org/) model, using gene expression as a proxy of protein signaling activity.

## Installation

In order to execute the workflow, the user needs to have the required software to launch the [Cromwell](https://github.com/broadinstitute/cromwell) engine. We recommend reading the [Five Minutes Intro](https://cromwell.readthedocs.io/en/stable/tutorials/FiveMinuteIntro/) created by the Broad Institute team to their software, as they give a walkthrough to the basic operations that can be performed using this tool. Additionally, as the tools employed by the workflow are used as [docker](https://www.docker.com/) containers, the system where the pipeline is deployed should have an engine to run such containers. Particularly, we have tested the workflow both locally with [docker](https://www.docker.com/) and in a High Performance Computing (HPC) environment, executing the containers as [Singularity](https://sylabs.io/guides/3.5/user-guide/) images.

## Execution modes

Regarding the execution of the workflow, as explained in the **tool manuscript**, we have designed 5 modes of execution that make use of different tools in crucial steps of the workflow. 

| Execution mode  | Description                                                                                                                                                                                      |   |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---|
| "salmon-hisat2" | Alignment with HISAT2. Count table obtained from Salmon quantifications. Deals with multi-mapping reads. Allows variant calling. Low memory consumption during alignment, but slower than STAR.  |   |
| "salmon-star"   | Alignment with STAR. Count table obtained from Salmon quantifications. Deals with multi-mapping reads. Allows variant calling. High memory consumption during alignment, but faster than HISAT2. |   |
| "hisat2"        | Alignment with HISAT2. Count table obtained with featureCounts. Does not deal with multi-mapping reads. Allows variant calling. Low memory consumption during alignment, but slower than STAR.   |   |
| "star"          | Alignment with STAR. Count table obtained with featureCounts. Does not deal with multi-mapping reads. Allows variant calling. High memory consumption during alignment, but faster than HISAT2.  |   |
| "salmon"        | Count table obtained from Salmon quantifications. Deals with multi-mapping reads. Does not allow variant calling.                                                                                |   |

We strongly recommend to use the combined execution strategies “salmon-star” or “salmon-hisat2”, as they use the pseudo-alignment strategy to quantify gene expression dealing with multi-mapping reads, and star or hisat2 to obtain the alignments for the variant calling sub-workflow.

## Preparing the input

As explained by [WDL authors](https://github.com/openwdl/wdl/blob/master/versions/development/SPEC.md#specifying-workflow-inputs-in-json), cromwell uses a [JSON](https://www.json.org/) formatted file as input. We have prepared a list of JSON files with the minimum required inputs for each execution mode. They can be found at the [input_templates](https://github.com/babelomics/MIGNON/input_templates/) folder. A [generic skeleton file]() with all available inputs can also be found in the same folder. In the following table, 

## Containers

The following table contains the list of containers used during the execution of the workflow:

| Tool     | Version  | Docker container                                                                                                                                                                                        |
|----------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| fastp    | v0.20.0  | quay.io/biocontainers/fastp:0.20.0                                                                                                                                                                      |
| fastqc   | v0.11.5  | [biocontainers/fastqc:v0.11.5_cv4](https://hub.docker.com/layers/biocontainers/fastqc/v0.11.5_cv4/images/sha256-387748462c7fc280b7959ceda0f6251190d2e4b9ebc0585d24e7bcb58bdcf2bf?context=explore)       |
| samtools | v1.9     | quay.io/biocontainers/samtools:1.9                                                                                                                                                                      |
| HISAT2   | v2.1.0   | quay.io/biocontainers/hisat2:2.1.0                                                                                                                                                                      |
| STAR     | v.2.7.2b | quay.io/biocontainers/star:2.7.2b                                                                                                                                                                       |
| salmon   | v.0.13.0 | quay.io/biocontainers/salmon:0.13.0                                                                                                                                                                     |
| GATK     | v4.1.3.0 | [broadinstitute/gatk:4.1.3.0](https://hub.docker.com/layers/broadinstitute/gatk/4.1.3.0/images/sha256-e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50?context=explore)                 |
| picard   | v2.20.7  | [broadinstitute/picard:2.20.7](https://hub.docker.com/layers/broadinstitute/picard/2.20.7/images/sha256-a8aee5af2e485b23c2498b6e9271133ab355a1e5e3c62a7e2b96f84ba60978ee?context=explore)               |
| VeP      | v99      | [ensemblorg/ensembl-vep:release_99.1](https://hub.docker.com/layers/ensemblorg/ensembl-vep/release_99.1/images/sha256-ca890d3d06d8ebddfb6126a1e4e257aa516f0522e75513994e797d97dca7c9af?context=explore) |
| txImport | v1.10.0  | quay.io/biocontainers/bioconductor-tximport:1.10.0                                                                                                                                                      |
| edgeR    | v3.28.0  | quay.io/biocontainers/bioconductor-edger:3.28.0                                                                                                                                                         |
| hipathia | v2.2.0   | quay.io/biocontainers/bioconductor-hipathia:2.2.0                                                                                                                                                       |
