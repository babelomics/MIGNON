---
layout: default
title: Execution modes
nav_order: 4
---

# Execution modes

Regarding the execution of the workflow, as explained in the **tool manuscript**, we have designed 5 execution modes that make use of different tools in crucial steps of the workflow: 

| Execution mode  | Alignment | Quantification | Allows variant calling | Computational profile                        |
|-----------------|-----------|----------------|------------------------|----------------------------------------------|
| "salmon-hisat2" | HISAT2    | Salmon         | Yes                    | Low memory consumption. Slower than STAR.    |
| "salmon-star"   | STAR      | Salmon         | Yes                    | High memory consumption. Faster than HISAT2. |
| "hisat2"        | HISAT2    | featureCounts  | Yes                    | Low memory consumption. Slower than STAR.    |
| "star"          | STAR      | featureCounts  | Yes                    | High memory consumption. Faster than HISAT2. |
| "salmon"        | -         | Salmon         | No                     | Low memory consumption and fast.             |

We strongly recommend to use the combined execution modes “salmon-star” or “salmon-hisat2”, as they use the pseudo-alignment strategy to quantify gene expression dealing with the multi-mapping reads problem, and star or hisat2 to obtain the alignments for the variant calling sub-workflow. 

The following figure exemplifies the different execution modes, as well as the tools used in each of them, being: 1) “salmon”, 2) “salmon-hisat2”, 3) “salmon-star”, 4) “hisat2”, 5) “star”.

![execution_modes](pics/execution_modes.png)