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

# System information

This section contain the system and software information of the computer where the example run of MIGNON was tested:

About the system OS, CPUs and memory:

```
$ uname -v
#44~18.04.2-Ubuntu SMP Thu Apr 23 14:27:18 UTC 2020

$ cat /proc/cpuinfo | head -n 20 | grep "model name\|cpu cores"
model name	: Intel(R) Core(TM) i7-9700 CPU @ 3.00GHz
cpu cores	: 8

$ free -h
              total        used        free      shared  buff/cache   available
Mem:            31G        3,8G         23G        491M        4,0G         26G
Swap:          2,0G          0B        2,0G
```

About Java:

```
$ java -version
openjdk version "1.8.0_252"
OpenJDK Runtime Environment (build 1.8.0_252-8u252-b09-1~18.04-b09)
OpenJDK 64-Bit Server VM (build 25.252-b09, mixed mode)
```

About docker:

```
$ docker version 
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b7f0
 Built:             Wed Mar 11 01:25:46 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b7f0
  Built:            Wed Mar 11 01:24:19 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```
