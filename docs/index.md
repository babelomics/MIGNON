# Home

Welcome to MIGNON's documentation!

1. [Installation](1_installation.md)
2. [Run MIGNON example](2_run_example.md)
3. [Input](3_input.md)
4. [Execution modes](4_execution_modes.md)
5. [Output](5_output.md)
6. [Parallelization](6_parallelization.md)

# About

<img src="pics/icon.png" width="100">

[![Build Status](https://travis-ci.com/babelomics/MIGNON.svg?branch=master)](https://travis-ci.com/babelomics/MIGNON)

MIGNON is a bioinformatic workflow for the analysis of RNA-Seq capable of integrating genomic and transcriptomic data into mechanistic signaling circuits. It covers the whole process using state-of-the-art tools and is deployable in under different computational environments. By using an *in-silico* knockdown strategy, it calculates the signaling circuit activities from gene expression and loss-of-function variants using raw reads as input. It is written using the [Workflow Description Language (WDL)](https://github.com/openwdl/wdl) and can be executed using [cromwell](https://github.com/broadinstitute/cromwell) and [docker](https://www.docker.com/) (or other engine able to run docker containers).
