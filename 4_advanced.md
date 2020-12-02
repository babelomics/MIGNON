---
layout: default
title: Advanced
---

# Advanced configurations

**Disclaimer**: In this section, users can find information about how to modify or improve MIGNON performance by tweaking its code or the default inputs. We do not recommend users to alter the MIGNON code unless they are completely sure about all the conflicts that a change can generate. Because of the dependency between the inputs and outputs of each task, errors can be hard to trace back. 

# Modularity 

Because of the underlying design of MIGNON, the different tools that make up the pipeline can be conceived as black boxes that receive an input and generate an output that is used as input for the next tool. As all the executions occur within docker containers, the tools can be easily replaced if the new tool input/output match the workflow schema. By making small changes to the MIGNON WDL code (in terms of lines of code), users can replace a particular tool with little effort. To demonstrate this, we created a new version of the workflow where we changed the 
featureCounts tool for [HT-Seq](https://htseq.readthedocs.io/en/master/), which is an alternative tool to obtain the number of counts per gene used in the [Genomic Data Commons mRNA analysis pipeline](https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/).

The first step to include or substitute a tool is identifying the inputs and outputs that it requires and produces, respectively. In a very similar fashion to featureCounts, HT-Seq takes as input an alignment file (SAM or BAM) together with a genome annotation file (GTF) and outputs a tab-separated text file with the number of counts per gene in the GTF file. In this sense, we are going to replace featureCounts with a tool that performs the same task in the workflow. **However, unlike featureCounts, HT-Seq cannot be applied to several samples at the same time**. This creates a conflict because in MIGNON, featureCounts has a double purpose: it counts the number of reads per feature and **summarizes the output of the alignments into a single output, taking as input the array of alignment files**. To address this problem, we will start creating two different WDL tasks to perform the same steps that are carried out on the featureCounts execution: one that will run HT-Seq in a single sample manner and another one that will merge all the individual count tables. 

```
# 1 - HTSEQ
task htseq {
  
    File? input_alignment
    String sample_id
    File gtf
    String output_counts
    Int? cpu 
    String? mem 

    command {
      htseq-count -f bam ${input_alignment} ${gtf} > ${output_counts}
      # add sample Id
      sed -i "1s/^/${sample_id}\n/" ${output_counts}
    }

    runtime {
      docker: "quay.io/biocontainers/htseq:0.6.1.post1--py27h76bc9d7_5"
      cpu: cpu
      requested_memory: mem
    }

    output {
      File counts = output_counts
    }
}

# 2 - MERGE COUNTS
task mergeCounts {

    Array[File?] count_files
    String output_counts
    Int? cpu 
    String? mem 

    command {
      Rscript -e "
        input_files <- '${sep=',' count_files}'; \
        file_list <- strsplit(input_files, ','); \
        table_list <- lapply(file_list[[1]], function(x) read.table(x, sep = '\t', row.names = 1)); \
        out_table <- Reduce(cbind, table_list); \
        write.table(out_table, file = '${output_counts}', sep = '\t', quote = FALSE)"
    }

    runtime {
      docker: "r-base:4.0.3"
      cpu: cpu
      requested_memory: mem
    }

    output {
      File counts = output_counts
    }
}
```

As it can be observed, the first task will use a container with the HT-Seq software: `docker: "quay.io/biocontainers/htseq:0.6.1.post1--py27h76bc9d7_5"`. The second one will use a container with the base R language to merge the different count tables `docker: "r-base:4.0.3"`. Once the WDL tasks are prepared, we can import them into the main workflow code by adding:

```
import "MIGNON_htseq_tasks.wdl" as MignonHtSeq
```

Then, we can place the task calls in the proper parts of the workflow. As HT-Seq will be executed in a single-sample manner, we can include the task in the loop that iterates through samples. In addition, as it will only be executed when salmon is not used, we will restrict the execution to the task to the "hista2" and "star" modes.

```
scatter (idx in range(len_fastq)) {
	
	(...)

	if (execution_mode == "hisat2" || execution_mode == "star") {

		# htseq
		call MignonHtSeq.htseq as htseq {
			
			input:
				input_alignment = select_first([star.bam, bamHisat2.bam]),
				gtf = gtf_file,
				sample_id = sample,
				output_counts = sample + "_counts.tsv",
				cpu = 1,
				mem = "16G"
        
		}

	}

	(...)

}
```

In a second step, we can insert the mergeCounts task that will gather and summarize the output of the different HT-Seq executions. As it can be observed, the main input for this task will be the array of files generated in the loop over samples. Similar to the previous task, this step should only be executed if using the "star" or "hisat2" execution modes:

```
(...)

if (execution_mode == "hisat2" || execution_mode == "star") {

	# merge individual counts
	call MignonHtSeq.mergeCounts as mergeCounts {
		
		input:
			count_files = htseq.counts,
			output_counts = "counts.tsv",
			cpu = 1,
			mem = "16G"

	}

}

(...)
```

Finally, we can merge the output of this final task with MIGNON by connecting its main output (the counts table) with edgeR:

```
# edgeR
call Mignon.edgeR as edgeR {
	
	input:
		counts = select_first([txImport.counts, mergeCounts.counts]),
		edger_script = edger_script,
		samples = sample_id,
		group = group,
		min_counts = edger_min_counts,
		cpu = edger_cpu,
		mem = edger_mem

}
```
And voilá! We have changed one of the core tool of MIGNON by other without altering the behavior of the pipeline. We have included this parallel workflow in the repo within the following files:

Task file: [**MIGNON_htseq_tasks.wdl**](https://github.com/babelomics/MIGNON/blob/master/wdl/MIGNON_htseq_tasks.wdl)
WDL file: [**MIGNON_htseq.wdl**](https://github.com/babelomics/MIGNON/blob/master/wdl/MIGNON_htseq.wdl)

# Parallelization

MIGNON  relies on the intrinsic ability of each tool to use multi-threading and in the ability of [cromwell](https://github.com/broadinstitute/cromwell) to launch a number of parallel jobs through the **concurrent-job-limit** parameter of the [config file](https://github.com/babelomics/MIGNON/tree/master/configs). We encourage users to read [cromwell multithreading post](Parallelism-Multithreading-Scatter-Gather), as it depicts the levels at which the execution of a workflow can be done in parallel. In brief, there are two levels at which MIGNON allows the use of parallel executions:

## Parallel jobs

### Sample-level

This is, the number of parallel tasks that can be executed using the task dependency tree created by cromwell. For example, the **fastp** processing of each sample is a task that can be easily executed in parallel. Multiple samples can be processed at the same time as they do not depend on each other's outputs. On the other hand, tasks as **featureCounts** require a bunch of outputs and will not start until all the alignments finish successfully. This parallelization at sample level, when allowed, is controlled through the **concurrent-job-limit** parameter in the cromwell configuration file. As calculating the number of concurrent jobs is not a straightforward task, and will depend entirely on the workflow structure, **we recommend to limit this parallelization level to one when deploying the workflow in machine with limited computational resources** (i.e 32 Gb of memory). On the other hand, if using HPC or Cloud Computing, this level allows to significantly reduce the workflow execution time.

### Scatter-gather strategy for HaplotypeCaller

As explained in the **input** section, there is an input parameter (**haplotype_scatter_count**) that allows using the [scatter and gather strategy](https://gatk.broadinstitute.org/hc/en-us/articles/360035532012-Parallelism-Multithreading-Scatter-Gather) for the **GATK HaplotypeCaller** sub-task. This parameter can be used to speed up the variant calling process and will split the single-sample variant calling into a number of parallel processes. As the variant calling is carried out at sample-level, if this parameter is set to 5, MIGNON will create 5 sub-tasks for each sample that will considerably speed up the HaplotypeCaller execution time.

## Multi-thread tools

For those tools that allow multi-threading, we have included workflow-level inputs that are directly passed to the tool parameter that control such multi-threading. Additionally, for those tasks, we have performed a study of the performance of the tools under 6 different CPU configurations, which are depicted in the **workflow manuscript**. In brief, tools that allow multi-threading considerably speed up in correlation with the the number of CPUs. However, in our opinion, from 8 CPUs up, the reduction on execution time is not worth for the number of CPUs used.