# MIGNON

[![Build Status](https://travis-ci.com/martingarridorc/MIGNON.svg?branch=master)](https://travis-ci.com/babelomics/MIGNON)

_**M**echanistic **I**nte**G**rative a**N**alysis **O**f r**N**a-seq data_

This repository contains all the necessary code to execute **MIGNON**, a bioinformatic workflow for the analysis of RNA-Seq data capable of integrating genomic and transcriptomic information into mechanistic signaling circuits. It covers the whole process using state-of-the-art tools and is deployable in under different computational environments. By using an in-silico knockdown strategy, it calculates the signaling circuit activities from gene expression and genomic variants using raw reads as input. It is written using the [Workflow Description Language (WDL)](https://github.com/openwdl/wdl) and can be executed using [Cromwell](https://github.com/broadinstitute/cromwell) and [Docker](https://www.docker.com/).

## Dependencies

1. [Docker](https://www.docker.com/).
2. [Java (v1.8.0)](https://java.com/en/download/help/download_options.xml).
3. [Cromwell](https://github.com/broadinstitute/cromwell/releases).

## Quick Start

```
$ git clone https://github.com/babelomics/MIGNON.git
$ cd MIGNON
$ java -Dconfig.file=configs/LocalWithDocker.conf -jar /path/to/cromwell.jar run wdl/MIGNON.wdl /path/to/input.json
```

For more information about **MIGNON**, please visit the [**documentation**](https://babelomics.github.io/MIGNON/).