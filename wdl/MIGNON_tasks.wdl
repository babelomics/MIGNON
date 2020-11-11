task fastp {

    File input_fastq_r1
    File? input_fastq_r2

    String output_fastq_r1
    String? output_fastq_r2

    String output_json
    String output_html

    Int? cpu 
    String? mem 

    String? additional_parameters

    command {

    fastp -i ${input_fastq_r1} \
          -o ${output_fastq_r1} \
          ${"-I " + input_fastq_r2} \
          ${"-O " + output_fastq_r2} \
          -j ${output_json} \
          -h ${output_html} \
          --thread ${cpu} \
          ${additional_parameters}

    }

    runtime {

      docker: "quay.io/biocontainers/fastp:0.20.0--hdbcaa40_0"    
      cpu: cpu
      requested_memory: mem

    }

    output {

      File json = output_json
      File html = output_html
      File trimmed_fastq_r1 = output_fastq_r1
      File? trimmed_fastq_r2 = output_fastq_r2

    }  

}

# FASTQC
task fastqc {
  
    File input_fastq_r1
    File? input_fastq_r2

    String out_report_r1
    String? out_report_r2 

    Int? cpu 
    String? mem 

    String? additional_parameters

    command {

      fastqc -t ${cpu} -o . \
             ${additional_parameters} \
             ${input_fastq_r1} ${input_fastq_r2} 

    }

    runtime {

      docker: "biocontainers/fastqc:v0.11.5_cv4"    
      cpu: cpu
      requested_memory: mem

    }

    output {

      File report_r1 = out_report_r1
      File? report_r2 = out_report_r2

    }

}

# HISAT2
task hisat2 {
  
    File input_fastq_r1
    File? input_fastq_r2
    Boolean is_paired_end

    String index_path
    String index_prefix

    String output_sam
    String output_summary

    String? sample_id
    String? platform 
    String? center 

    Int? cpu 
    String? mem 

    String? additional_parameters
    
    String opt_fastq_r1 = if (is_paired_end) then "-1" else "-U"

    command {

      hisat2 -p ${cpu} -x ${index_path}/${index_prefix} \
             ${additional_parameters} \
             --new-summary --summary-file ${output_summary} \
             ${opt_fastq_r1} ${input_fastq_r1} \
             ${"-2 " + input_fastq_r2} \
             --rg-id ${sample_id} --rg SM:${sample_id} \
             --rg LB:Fragment --rg PL:${platform} \
             --rg CN:${center} --rg PU:${sample_id} > ${output_sam}

    }

    runtime {

      docker: "quay.io/biocontainers/hisat2:2.1.0--py27h6bb024c_3"    
      cpu: cpu
      requested_memory: mem
      docker_volume: index_path

    }

    output {

      File summary = output_summary
      File sam = output_sam

    }

}

# SAM2BAM
task sam2bam {
  
    File input_sam
    String output_bam

    Int? cpu 
    String? mem 

    String? additional_parameters

    command {

      samtools sort ${input_sam} ${additional_parameters} --threads ${cpu} -O BAM -o ${output_bam}

    }

    runtime {

      docker: "quay.io/biocontainers/samtools:1.9--h8571acd_11"    
      cpu: cpu
      requested_memory: mem

    }

    output {

      File bam = output_bam

    }

}

# STAR
task star {
  
    File input_fastq_r1
    File? input_fastq_r2
    String? compression

    String index_path

    String output_prefix

    Int? cpu 
    String? mem 

    String? additional_parameters

    String opt_compression = if (compression == ".gz") then "--readFilesCommand zcat" else ""

    command {

      STAR --runThreadN ${cpu} \
           --genomeDir ${index_path} \
           --readFilesIn ${input_fastq_r1} ${input_fastq_r2} \
           ${opt_compression} \
           --outSAMtype BAM SortedByCoordinate \
           --outFileNamePrefix ${output_prefix} \
           ${additional_parameters}

    }

    runtime {

      docker: "quay.io/biocontainers/star:2.7.2b--0"  
      cpu: cpu
      requested_memory: mem
      docker_volume: index_path

    }

    output {

      File summary = "${output_prefix}Log.final.out"
      File bam = "${output_prefix}Aligned.sortedByCoord.out.bam"

    }

}

# SALMON
task salmon {
  
    File input_fastq_r1
    File? input_fastq_r2
    Boolean is_paired_end

    String index_path

    String? library_type

    String output_dir

    Int? cpu 
    String? mem 

    String? additional_parameters

    String opt_fastq_r1 = if (is_paired_end) then "-1" else "-r"

    command {

      salmon quant -p ${cpu} -i ${index_path} -l ${library_type} \
                       ${opt_fastq_r1} ${input_fastq_r1} \
                       ${"-2 " + input_fastq_r2} \
                       -o ${output_dir} \
                       ${additional_parameters}

    }

    runtime {

      docker: "quay.io/biocontainers/salmon:0.13.0--h86b0361_2"
      cpu: cpu
      requested_memory: mem
      docker_volume: index_path

    }

    output {

      File quant = "${output_dir}/quant.sf"

    }

}

# FEATURECOUNTS
task featureCounts {
  
    Array[File?] input_alignments

    File gtf

    String output_counts

    Int? cpu 
    String? mem 

    String? additional_parameters

    command {

      featureCounts ${additional_parameters} \
                    -T ${cpu} -a ${gtf} -o ${output_counts}.raw ${sep=' ' input_alignments}
      
      # format count matrix
      sed -r 's#[^\t]+/([^\/\t]+)\.[bs]am#\1#g' ${output_counts}.raw | sed -r 's#Aligned\.sortedByCoord\.out##g' | sed '1d' | cut -f 1,7- > ${output_counts}

    }

    runtime {

      docker: "quay.io/biocontainers/subread:1.6.4--h84994c4_1"
      cpu: cpu
      requested_memory: mem

    }

    output {

      File counts = output_counts
      File summary = "${output_counts}.raw.summary"

    }

}

# ENSEMBLDB TX2GENE
task ensemblTx2Gene {

    File ensembldb_script
  
    File gtf   
    String output_tx2gene

    String? job_id
    Int? cpu 
    String? mem 
    
    command {

      Rscript ${ensembldb_script} --gtf ${gtf} \
      --outFile ${output_tx2gene}

    }

    runtime {

      docker: "quay.io/biocontainers/bioconductor-ensembldb:2.6.3--r351_0"    
      cpu: cpu
      requested_memory: mem

    }

    output {

      File tx2gene = output_tx2gene

    }

}

# TXIMPORT
task tximport {

    Array[File?] quant_files
    File? tx2gene 
    String output_counts
    String quant_tool
    Array[String] sample_ids
    File tximport_script

    Int? cpu 
    String? mem 
    
    command {

      Rscript ${tximport_script} --tx2gene ${tx2gene} \
      --quantFiles ${sep=',' quant_files} \
      --sampleIds ${sep=',' sample_ids} \
      --outFile ${output_counts} 
    
    }

    runtime {

      docker: "quay.io/biocontainers/bioconductor-tximport:1.10.0--r351_0"  
      cpu: cpu
      requested_memory: mem

    }

    output {

      File counts = output_counts

    }

}

# EDGER
task edgeR {
  
    File? counts
    Array[String] samples
    Array[String] group
    Int? min_counts
    
    File edger_script

    Int? cpu 
    String? mem 

    command {

      Rscript ${edger_script} --counts ${counts} \
      --samples ${sep=',' samples} \
      --group ${sep=',' group} \
      --minCounts ${min_counts} 
    
    }

    runtime {

      docker: "quay.io/biocontainers/bioconductor-edger:3.28.0--r36he1b5a44_0"    
      cpu: cpu
      requested_memory: mem

    }

    output {

        File diff_expr = "differential_expression.tsv"
        File logcpms = "logCPMs.tsv"
        File logcpms_hipathia = "logCPMs_hipathia.rds"

    }


}

# HIPATHIA
task hipathia {
  
    File? cpm_file
    Array[String] samples
    Array[String] group
    
    Boolean normalize_by_length
    Boolean do_vc

    File? filtered_variants
    Float? ko_factor
    
    File hipathia_script

    Int? cpu 
    String? mem 

    command {
      
      Rscript ${hipathia_script} --cpmFile ${cpm_file} \
      --samples ${sep=',' samples} \
      --group ${sep=',' group} \
      --normalizeByLength ${normalize_by_length} \
      --doVc ${do_vc} \
      --filteredVariants ${filtered_variants} \
      --koFactor ${ko_factor}
    
    }

    runtime {

      docker: "quay.io/biocontainers/bioconductor-hipathia:2.2.0--r36_0"    
      cpu: cpu
      requested_memory: mem

    }

    output {

        File diff_signaling = "differential_signaling.tsv"
        File path_values = "path_values.tsv"
        File? ko_matrix = "ko_matrix.tsv"

    }

}

# FILTERUNMAPED
task filterBam {
  
    File input_bam
    String output_bam

    Int? cpu 
    String? mem 

    String? additional_parameters

    command {

      samtools view ${additional_parameters} -F 4 --threads ${cpu} -O BAM -o ${output_bam} ${input_bam}

    }

    runtime {

      docker: "quay.io/biocontainers/samtools:1.9--h8571acd_11"    
      cpu: cpu
      requested_memory: mem

    }

    output {

      File bam = output_bam

    }

}

# VEP
task vep {

    File vcf_file

    # [0 most deleterious, 1 least deleterious]
    Float sift_cutoff
    # [1 most damaging, 0 least damaging]
    Float polyphen_cutoff

    String cache_dir
    String output_file

    Int? cpu 
    String? mem 
    
    command {

      /opt/vep/src/ensembl-vep/vep --dir_cache ${cache_dir} --offline --vcf --sift s --polyphen s --fork ${cpu} -i ${vcf_file} -o variants_annotated.vcf

      /opt/vep/src/ensembl-vep/filter_vep -i variants_annotated.vcf --format vcf -o ${output_file} -f "SIFT < ${sift_cutoff} and PolyPhen > ${polyphen_cutoff}"

      sed -i 's/#CHROM/CHROM/g' ${output_file}
    
    }

    runtime {

      docker: "ensemblorg/ensembl-vep:release_99.1" 
      docker_volume: cache_dir
      cpu: cpu
      requested_memory: mem

    }

    output {

      File output_vcf = output_file
      
    }

}

# merge variants
task mergeVariants {

    Array[File?] vcf_files
    Array[File?] vcf_files_index
    String output_file

    Int? cpu 
    String? mem 
    
    command {

      bcftools merge --threads ${cpu} ${sep=' ' vcf_files} | bcftools norm -m +both -O z -o ${output_file}
    
    }

    runtime {

      docker: "biocontainers/bcftools:v1.9-1-deb_cv1" 
      cpu: cpu
      requested_memory: mem

    }

    output {

      File output_vcf = output_file
      
    }

}