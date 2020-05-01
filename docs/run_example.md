---
layout: default
title: Run MIGNON example
nav_order: 2
---

# MIGNON example

The *runMignonExample.sh* bash script can be used to carry out an example run of MIGNON:

```
$ git clone https://github.com/babelomics/MIGNON.git
$ cd MIGNON
$ bash runMignonExample.sh
```

This script will:

1. Download and decompress all the neccesary reference material and the cromwell jar file from the different sources using [curl](https://curl.haxx.se/) and [gzip](https://www.gnu.org/software/gzip/).
2. Download and tag raw reads from the [PRJEB35799](https://www.ebi.ac.uk/ena/data/view/PRJEB35799) project.
3. Index the reference genome fasta for the alignment with the [HISAT2 container](quay.io/biocontainers/hisat2:2.1.0).
4. Index the reference genome for the variant calling with the [samtools container](quay.io/biocontainers/samtools:1.9--h8571acd_11).
5. Index the reference coding DNA for the quantification with the [salmon container](quay.io/biocontainers/salmon:0.13.0--h86b0361_2).
6. Prepare the MIGNON input JSON.
7. Launch MIGNON usingIo the "salmon-hisat2" execution mode.