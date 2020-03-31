---
layout: default
title: Installation
nav_order: 1
---

# Installation

In order to execute the workflow, the user needs to be able of launching the [Cromwell](https://github.com/broadinstitute/cromwell) engine, regardless of where it is deployed. It is recommended to read the [Five Minutes Intro](https://cromwell.readthedocs.io/en/stable/tutorials/FiveMinuteIntro/) created by the Broad Institute team, which explain the basic operations that can be performed using their software. Additionally, as the tools employed by the workflow are used as [docker](https://www.docker.com/) containers, the system where the pipeline is deployed should have an engine to work with containerized software. We have tested the workflow both locally with [Docker](https://www.docker.com/) and in a High Performance Computing (HPC) environment, executing the containers as [Singularity](https://sylabs.io/guides/3.5/user-guide/) images. Theoretically, it is also deployable within the [Terra](https://terra.bio/) platform, which makes use of cloud computing services to execute the WDL workflows.

**Key links**:

* [Java](https://www.java.com/es/download/)
* [Cromwell releases](https://github.com/broadinstitute/cromwell/releases)
* [Docker](https://www.docker.com/)
* [Singularity](https://sylabs.io/docs/)


In order to execute MIGNON with Cromwell, we have prepared two configuration files to run the workflow both locally and in a Slurm + Singularity HPC environment. They can be found at the [config directory](https://github.com/babelomics/MIGNON/tree/master/configs). After preparing the input and downloading the Cromwell jar, users can clone the repository:

```
$ git clone https://github.com/babelomics/MIGNON.git
$ cd MIGNON
```

And execute MIGNON locally with docker:

```
$ java -Dconfig.file=configs/LocalWithDocker.conf -jar /path/to/cromwell.jar run wdl/MIGNON.wdl /path/to/input.json
```

Or in HPC environments with Slurm and Singularity:

```
$ java -Dconfig.file=configs/SlurmAndSingularity.conf -jar /path/to/cromwell.jar run wdl/MIGNON.wdl /path/to/input.json
```

## List of containers

The following containers are used during the execution of the workflow:

| Tool     | Version  | Docker container                                                                                                                                                                                        |
|----------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| fastp    | v0.20.0  | [quay.io/biocontainers/fastp:0.20.0](quay.io/biocontainers/fastp:0.20.0)                                                                                                                                |
| fastqc   | v0.11.5  | [biocontainers/fastqc:v0.11.5_cv4](https://hub.docker.com/layers/biocontainers/fastqc/v0.11.5_cv4/images/sha256-387748462c7fc280b7959ceda0f6251190d2e4b9ebc0585d24e7bcb58bdcf2bf?context=explore)       |
| samtools | v1.9     | [quay.io/biocontainers/samtools:1.9](quay.io/biocontainers/samtools:1.9)                                                                                                                                |
| HISAT2   | v2.1.0   | [quay.io/biocontainers/hisat2:2.1.0](quay.io/biocontainers/hisat2:2.1.0)                                                                                                                                |
| STAR     | v.2.7.2b | [quay.io/biocontainers/star:2.7.2b](quay.io/biocontainers/star:2.7.2b)                                                                                                                                  |
| salmon   | v.0.13.0 | [quay.io/biocontainers/salmon:0.13.0](quay.io/biocontainers/salmon:0.13.0)                                                                                                                              |
| GATK     | v4.1.3.0 | [broadinstitute/gatk:4.1.3.0](https://hub.docker.com/layers/broadinstitute/gatk/4.1.3.0/images/sha256-e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50?context=explore)                 |
| picard   | v2.20.7  | [broadinstitute/picard:2.20.7](https://hub.docker.com/layers/broadinstitute/picard/2.20.7/images/sha256-a8aee5af2e485b23c2498b6e9271133ab355a1e5e3c62a7e2b96f84ba60978ee?context=explore)               |
| VeP      | v99      | [ensemblorg/ensembl-vep:release_99.1](https://hub.docker.com/layers/ensemblorg/ensembl-vep/release_99.1/images/sha256-ca890d3d06d8ebddfb6126a1e4e257aa516f0522e75513994e797d97dca7c9af?context=explore) |
| txImport | v1.10.0  | [quay.io/biocontainers/bioconductor-tximport:1.10.0](quay.io/biocontainers/bioconductor-tximport:1.10.0)                                                                                                |
| edgeR    | v3.28.0  | [quay.io/biocontainers/bioconductor-edger:3.28.0](quay.io/biocontainers/bioconductor-edger:3.28.0)                                                                                                      |
| hipathia | v2.2.0   | [quay.io/biocontainers/bioconductor-hipathia:2.2.0](quay.io/biocontainers/bioconductor-hipathia:2.2.0)                                                                                                  |