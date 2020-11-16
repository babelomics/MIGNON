---
layout: default
title: MIGNON
---

# Welcome to MIGNON’s documentation!

## **M**echanistic **I**nte**G**rative a**N**alysis **O**f r**N**a-seq data

[![MIGNON](img/MIGNON_logo_horizontal.svg)](https://github.com/babelomics/MIGNON/)

[![Build Status](https://travis-ci.com/babelomics/MIGNON.svg?branch=master)](https://travis-ci.com/babelomics/MIGNON)


## What is MIGNON?

**MIGNON** is a bioinformatic workflow for the analysis of RNA-Seq experiments, which not only efficiently manages the estimation of gene expression levels from raw reads, but also calls genomic variants present in the transcripts analyzed. Moreover, this is the first workflow that provides a framework for the integration of transcriptomic and genomic data based on a mechanistic model of signaling pathway activities. The main output of MIGNON are the predicted activity values of this model, that allows a detailed biological interpretation of the results, including a comprehensive functional profiling of cell activity. MIGNON covers the whole process, from reads to signaling circuit activity estimations, using state-of-the-art tools, it is easy to use and it is deployable in different computational environments, allowing an optimized use of the resources available. 

## What can I get from MIGNON?

**MIGNON** can help you to get the most out of your RNA-Seq data. Its main objective is to squeeze all the gene-level information that can be found in raw reads, delivering an integrated output that is directly interpretable by researchers in a very intuitive manner. With MIGNON, you can answer some questions as:

* Which pathways are up or down regulated in response to my stimulus?
* Does the **gene X** have a loss of function variant in the **sample Y** at the RNA level?
* Is the expression of **gene X** altered in response to my stimulus?
* How do the pathway level results change if I do not include the genomic information?

## Who can use MIGNON?

Everyone! MIGNON is freely available in the following repository under the MIT license:

* [**Link to MIGNON repository**](https://github.com/babelomics/MIGNON/)

To install and use MIGNON, please visit the [installation page](1_installation.md).
