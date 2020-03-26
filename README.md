# MIGNON<img src="pics/icon.png" align="right" height="200" />

**Mechanistic InteGrative aNalysis Of rNa-seq data**

This repository contains all the neccesary code to execute **MIGNON**, a bioinformatic workflow for the analysis of RNA-Seq data capable of integrating genomic and transcriptomic information into mechanistic signaling circuits. It covers the whole process using state-of-the-art tools and is deployable in under different computational environments. By using an in-silico knockdown strategy, it calculates the signaling circuit activities from gene expression and genomic variants using raw reads as input.

## Dependencies

1. [Docker](https://www.docker.com/). To execute all the containerized software.
2. [Java (v1.8.0)](https://java.com/en/download/help/download_options.xml). To use cromwell.
3. [Cromwell](https://github.com/broadinstitute/cromwell/releases). To interpret and execute the workflow.

## Execution modes

| Execution mode  | Description                                                                                                                                                                                      |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| "salmon-hisat2" | Alignment with HISAT2. Count table obtained from Salmon quantifications. Deals with multi-mapping reads. Allows variant calling. Low memory consumption during alignment, but slower than STAR.  |
| "salmon-star"   | Alignment with STAR. Count table obtained from Salmon quantifications. Deals with multi-mapping reads. Allows variant calling. High memory consumption during alignment, but faster than HISAT2. |
| "hisat2"        | Alignment with HISAT2. Count table obtained with featureCounts. Does not deal with multi-mapping reads. Allows variant calling. Low memory consumption during alignment, but slower than STAR.   |
| "star"          | Alignment with STAR. Count table obtained with featureCounts. Does not deal with multi-mapping reads. Allows variant calling. High memory consumption during alignment, but faster than HISAT2.  |
| "salmon"        | Count table obtained from Salmon quantifications. Deals with multi-mapping reads. Does not allow variant calling.                                                                                |

We strongly recommend to use the combined execution strategies “salmon-star” or “salmon-hisat2”, as they use the pseudo-alignment strategy to quantify gene expression dealing with multi-mapping reads, and star or hisat2 to obtain the alignments for the variant calling sub-workflow.