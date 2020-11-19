---
layout: default
title: Installation
---

# Quick start

Users with experience on workflow managers and containers can directly clone and execute the dry run of the workflow if they already have [Git](https://git-scm.com/), [Java (v1.8.0)](https://www.java.com/es/download/) and [docker](https://www.docker.com/) installed. This can be done by executing the following commands on your terminal:

```
git clone https://github.com/babelomics/MIGNON.git
cd MIGNON
bash runMignonExample.sh
```

After completing the dry runs, the results of the pipeline can be found at the `dry_run/cromwell-executions` directory. 

On the other hand, we encourage users with less experience to fully read the installation guide before executing the workflow.

# Requirements

From a programmatic perspective, MIGNON is a chain of tasks written in the [Workflow Description Language](https://github.com/openwdl/wdl). Users need to install and download the following software to be able to run it:

## [Java](https://www.java.com/es/download/)

Java is used to execute the workflow management software that interprets and launches the different tasks within the pipeline. Once installed, users can check the version with `java -version`:

```
$ java -version
openjdk version "1.8.0_275"
OpenJDK Runtime Environment (build 1.8.0_275-8u275-b01-0ubuntu1~18.04-b01)
OpenJDK 64-Bit Server VM (build 25.275-b01, mixed mode)
```

## [Docker](https://www.docker.com/)

Docker (or any engine able to run docker containers, as [Singularity](https://sylabs.io/docs/) is used to execute all the tasks of the workflow within an isolated unit of containerized software, freeing users to install each of the needed components of the pipeline. Once installed, users should be able to get the following output after executing `docker run hello-world`:

```
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## [Cromwell](https://github.com/broadinstitute/cromwell)

Users need to download the **cromwell-XX.jar** file that can be retrieved from the cromwell releases page. Particularly, MIGNON was tested with the release 47 of cromwell, which can be obtained in the [following link](https://github.com/broadinstitute/cromwell/releases/tag/47). Cromwell is the scientific workflow engine that interprets and executes the pipeline. It is the software why users need to have Java v1.8.0 installed. **Note**: When executing the `runMignonExample.sh` script, a copy of the cromwell binaries is downloaded together with the example data.

## [MIGNON](https://github.com/babelomics/MIGNON/)

Users can download the latest MIGNON code from our Github repository. Users with [git](https://git-scm.com/) can clone the repository using:

```
$ git clone https://github.com/babelomics/MIGNON.git
```
On the other hand, if you are not using git, you can get a zipped version of the code on the following link:

* [----> **Link to the compressed version of MIGNON** <----](https://github.com/babelomics/MIGNON/archive/master.zip).

# Run the workflow

## Dry run

After fulfilling all the requirements, users can test the workflow by performing a *dry run* with example data. This can be done by calling the `runMignonExample.sh` script that is located in the root directory of the repo. To do so, please execute the following command within the MIGNON folder:

```
$ bash runMignonExample.sh
```
This script will:

1. Download all the required data to perform the dry run into the mignon_test_data folder. These data includes:
   * A reduced version of the human reference genome, transcriptome and annotations obtained from [ENSEMBL](https://www.ensembl.org/Homo_sapiens/Info/Index).
   * A subset of the Variant Effect Predictor cache file obtained from [ENSEMBL](ftp://ftp.ensembl.org/pub/release-99/variation/indexed_vep_cache/).
   * A reduced version of the dbSNP database in VCF format obtained from the [NCBI](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/All_20170710.vcf.gz).
   * The HISAT2, STAR and Salmon indexes created from the reduced version of the reference genome and transcriptome.
   * Four reduced paired read files that were obtained after aligning the whole samples to the reference genome and extract the reads that were found in a particular region of the chromosome 9.
   * A copy of the cromwell and womtool binaries. The cromwell license that allow the re-distribution of such binaries can be found in the `LICENSE-cromwell` file in the root directory of MIGNON.


2. Execute a dry run of the workflow, where the different execution modes will be tested. Please take into account that, as MIGNON will execute all the different steps included in the workflow under different configurations, this dry run may take a while. 

3. Once finished, it will print a final message indicating the success of the dry run and the ability of the user to execute MIGNON!

```
MIGNON: Success!! Dry run completed. You are ready to execute MIGNON.
```

## Regular run

Although the dry run is very useful to test that all the MIGNON dependencies were installed successfully, users need to prepare their inputs to perform a regular run of the pipeline. To guide users through the different inputs required by MIGNON, we have prepared the [input section](2_input.md). Once the input is prepared in the JSON format, users can run the workflow by executing the following command in a terminal:

```
$ java -Dconfig.file=/path/to/config_file.conf -jar /path/to/cromwell.jar run /path/to/MIGNON.wdl -i /path/to/input.json
```

## Troubleshooting

If you have any doubt about MIGNON features, inputs and outputs, please contact us on the [issues](https://github.com/babelomics/MIGNON/issues) section! On the other hand, if you have trouble installing or executing Java, Docker or Cromwell, we encourage users to use their respective forums to address their questions. Finally, we strongly recommend to read the [5 minutes introduction](https://cromwell.readthedocs.io/en/stable/tutorials/FiveMinuteIntro/) to cromwell written by the developers of the tool.
