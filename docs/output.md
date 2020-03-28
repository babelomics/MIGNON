# Output

As described in the **tool manuscript**, the main output of the workflow consists mainly on two files, which can be found in the **call-hipathia** task directory, created by [Cromwell](https://github.com/broadinstitute/cromwell).

## Circuit activity matrix 

**path_values.tsv**

This matrix contain the results of the circuit activity estimation performed by hiPathia after applying the *in-silico knockdown* strategy and contain a value for each circuit (row) and sample (column).

|               | ERR3481954 | ERR3481955 | ERR3481956 | ERR3481957 |
|---------------|------------|------------|------------|------------|
| P-hsa03320-37 | 0.0000     | 0.0000     | 0.0123     | 0.0000     |
| P-hsa03320-61 | 0.0320     | 0.0286     | 0.0123     | 0.0485     |
| P-hsa03320-46 | 0.0000     | 0.0000     | 0.0000     | 0.0000     |
| P-hsa03320-57 | 0.0000     | 0.0000     | 0.0123     | 0.0000     |
| P-hsa03320-64 | 0.0000     | 0.0000     | 0.0000     | 0.0000     |
| P-hsa03320-47 | 0.0808     | 0.0768     | 0.0301     | 0.0693     |
| P-hsa03320-65 | 0.2524     | 0.2466     | 0.2550     | 0.2727     |
| P-hsa03320-55 | 0.3917     | 0.3999     | 0.4006     | 0.4027     |
| P-hsa03320-56 | 0.2252     | 0.2238     | 0.2306     | 0.2976     |

## Differential signaling activity analysis

The following data frame contains the results of making all the possible pairwise comparisons between the circuit activity values of the sample groups specified by the **group** input. The group contrast is indicated in the "comparison" column.

**differential_signaling.tsv**

| pathId         | UP.DOWN | statistic | p.value | FDRp.value | comparison        |
|----------------|---------|-----------|---------|------------|-------------------|
| P-hsa03320-37  | DOWN    | -1.5275   | 0.2000  | 0.7026     | 16_weeks-12_weeks |
| P-hsa03320-61  | DOWN    | -0.2182   | 1.0000  | 1.0000     | 16_weeks-12_weeks |
| P-hsa03320-46  | DOWN    | -1.9640   | 0.1000  | 0.6091     | 16_weeks-12_weeks |
| P-hsa03320-57  | DOWN    | -1.9640   | 0.1000  | 0.6091     | 16_weeks-12_weeks |
| P-hsa03320-64  | UP      | 1.0911    | 0.3537  | 0.8566     | 16_weeks-12_weeks |
| P-hsa03320-47  | DOWN    | -1.0911   | 0.4000  | 0.8566     | 16_weeks-12_weeks |
| P-hsa03320-65  | UP      | 0.2182    | 1.0000  | 1.0000     | 16_weeks-12_weeks |
| P-hsa03320-55  | UP      | 0.6547    | 0.7000  | 0.9215     | 16_weeks-12_weeks |
| P-hsa03320-56  | DOWN    | -1.0911   | 0.4000  | 0.8566     | 16_weeks-12_weeks |
| …              | …       | …         | …       | …          | …                 |
| P-hsa05321-94  | DOWN    | -1.3093   | 0.1967  | 0.5469     | 9_weeks-16_weeks  |
| P-hsa05321-95  | UP      | 1.9640    | 0.1000  | 0.4000     | 9_weeks-16_weeks  |
| P-hsa05321-122 | UP      | 1.9640    | 0.0765  | 0.4000     | 9_weeks-16_weeks  |
| P-hsa05321-123 | UP      | 0.2182    | 1.0000  | 1.0000     | 9_weeks-16_weeks  |
| P-hsa05321-55  | UP      | 1.9640    | 0.1000  | 0.4000     | 9_weeks-16_weeks  |
| P-hsa05321-74  | UP      | 1.3093    | 0.1967  | 0.5469     | 9_weeks-16_weeks  |
| P-hsa05321-81  | UP      | 1.3093    | 0.1967  | 0.5469     | 9_weeks-16_weeks  |
| P-hsa05321-138 | DOWN    | -1.0911   | 0.3537  | 0.7966     | 9_weeks-16_weeks  |
| P-hsa05321-75  | UP      | 1.9640    | 0.1000  | 0.4000     | 9_weeks-16_weeks  |
| P-hsa05321-152 | UP      | 1.0911    | 0.4000  | 0.7966     | 9_weeks-16_weeks  |

## Pathway viewer

The above results can be visualized using the [hiPathia package](https://bioconductor.org/packages/release/bioc/html/hipathia.html), by subsetting the table to the comparison of interest and using the `create_report()` function. 

![Viewer](https://github.com/babelomics/hipathia/blob/master/vignettes/pics/hipathia_report_1.png?raw=true)

## Other outputs

### Knockdown matrix

**ko_matrix.tsv**

This matrix contains the gene table that is used to perform the in-silico knockdown of genes that present a Loss of Function (LoF) variant and that therefore, can not propagate the signal across the circuits. 

|                 | ERR2704712 | ERR2704713 | ERR2704714 | ERR2704715 |
|-----------------|------------|------------|------------|------------|
| ENSG00000128342 | 1          | 1          | 1          | 1          |
| ENSG00000187860 | 0.01       | 1          | 1          | 1          |
| ENSG00000100003 | 1          | 1          | 1          | 1          |
| ENSG00000100012 | 1          | 1          | 1          | 1          |
| ENSG00000181123 | 1          | 1          | 1          | 1          |
| ENSG00000133488 | 1          | 1          | 0.01       | 1          |
| ENSG00000128242 | 1          | 0.01       | 1          | 1          |
| ENSG00000100029 | 1          | 1          | 1          | 1          |
| ENSG00000185339 | 1          | 1          | 1          | 1          |

### Inner tools outputs

Apart from the outputs derived directly from the MIGNON strategy, some of the tools employed during the raw reads processing generate intermediate output reports which can be explored in its corresponding call directories. Additionally, we strongly recommend to use the [MultiQC](https://multiqc.info/) tool to summarize all those intermediate outputs in a single html report.

