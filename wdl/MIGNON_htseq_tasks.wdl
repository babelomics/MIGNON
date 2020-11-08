# HTSEQ
task htseq {
  
    File? input_alignment
    String sample_id

    File gtf

    String output_counts
    
    Int? cpu 
    String? mem 

    String? additional_parameters

    command {

      htseq-count -f bam ${input_alignment} ${gtf} ${additional_parameters} > ${output_counts}

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

# MERGE COUNTS
task mergeCounts {
  
    Array[File?] count_files

    String output_counts

    Int? cpu 
    String? mem 

    command {

      Rscript -e "
        input_files <- '${sep=',' count_files}'; \
        file_list <- strsplit(input_files, ','); \
        table_list <- lapply(file_list[[1]], function(x) read.table(x, sep = '\t', row.names = 1))
        out_table <- Reduce(cbind, table_list)
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