task IndexBam {
    
    File input_bam

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"

    String base_name = basename(input_bam)

    command {

        samtools index -@ ${cpu} ${input_bam} ${base_name}.bai
        
    }

    runtime {

        docker: "quay.io/biocontainers/samtools:1.9--h8571acd_11"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {

        File bai_index = "${base_name}.bai"

    }

}

task ReorderBam {
    
    File input_bam
    File? input_bam_index

    File? ref_fasta
    File? ref_dict
    File? ref_fasta_index

    String base_name
    String sampleName

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"

    command {

        java -jar /usr/picard/picard.jar ReorderSam \
                INPUT=${input_bam} \
                OUTPUT=${base_name}.bam \
                SEQUENCE_DICTIONARY=${ref_dict} \
                CREATE_INDEX=true

    }

    runtime {

        docker: "broadinstitute/picard:2.20.7"   
        cpu: cpu
        requested_memory: mem
        
    }

    output {

        File output_bam = "${base_name}.bam"
        File output_bam_index = "${base_name}.bai"

    }

}

task AddReadGroup {
    
    File input_bam
    File input_bam_index
    String base_name
    String sampleName
    String platform
    String center

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"

    command {

        java -jar /usr/picard/picard.jar AddOrReplaceReadGroups \
                INPUT=${input_bam} \
                OUTPUT=${base_name}.bam \
                SORT_ORDER=coordinate \
                CREATE_INDEX=true \
                RGID=${sampleName} \
                RGSM=${sampleName} \
                RGLB=Fragment \
                RGPL=${platform} \
                RGCN=${center} \
                RGPU=${sampleName}


    }

    runtime {
        docker: "broadinstitute/picard:2.20.7"   
        cpu: cpu
        requested_memory: mem
        
    }

    output {
        File output_bam = "${base_name}.bam"
        File output_bam_index = "${base_name}.bai"
    }

}

task MarkDuplicates {

    File input_bam
    File input_bam_index
    String base_name

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"

    command {

        java -jar /usr/picard/picard.jar MarkDuplicates \
                INPUT=${input_bam} \
                OUTPUT=${base_name}.bam \
                CREATE_INDEX=true \
                VALIDATION_STRINGENCY=SILENT \
                METRICS_FILE=${base_name}.metrics

    }

    runtime {

        docker: "broadinstitute/picard:2.20.7"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {
        File output_bam = "${base_name}.bam"
        File output_bam_index = "${base_name}.bai"
        File metrics_file = "${base_name}.metrics"
    }

}

task SplitNCigarReads {

    File input_bam
    File input_bam_index
    String base_name

    File? ref_fasta
    File? ref_fasta_index
    File? ref_dict
    File? ref_gzi

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"
    

    command {

        gatk SplitNCigarReads \
            -R ${ref_fasta} \
            -I ${input_bam} \
            -O ${base_name}.bam 
    }

    runtime {
        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: cpu
        requested_memory: mem
        

    }

    output {
        File output_bam = "${base_name}.bam"
        File output_bam_index = "${base_name}.bai"
    }

}

task BaseRecalibrator {

    File input_bam
    File input_bam_index
    String recal_output_file

    File? dbSNP_vcf
    File? dbSNP_vcf_index
    Array[File?] known_indels_sites_VCFs
    Array[File?] known_indels_sites_indices

    File? ref_dict
    File? ref_fasta
    File? ref_fasta_index
    File? ref_gzi

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"
    

    command {

        gatk BaseRecalibrator \
            -R ${ref_fasta} \
            -I ${input_bam} \
            --use-original-qualities \
            -O ${recal_output_file} \
            -known-sites ${dbSNP_vcf} \
            -known-sites ${sep=" --known-sites " known_indels_sites_VCFs}

    }

    runtime {
        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {
        File recalibration_report = recal_output_file
    }

}

task ApplyBQSR {

    File input_bam
    File input_bam_index
    String base_name
    File recalibration_report

    File? ref_dict
    File? ref_fasta
    File? ref_fasta_index
    File? ref_gzi

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"
    

    command {

        gatk ApplyBQSR \
            --add-output-sam-program-record \
            -R ${ref_fasta} \
            -I ${input_bam} \
            --use-original-qualities \
            -O ${base_name}.bam \
            --bqsr-recal-file ${recalibration_report} 
    }

    runtime {
        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {
        File output_bam = "${base_name}.bam"
        File output_bam_index = "${base_name}.bai"
    }

}

task SplitIntervals {
    
    # inputs
    File? intervals
    File? ref_fasta
    File? ref_fai
    File? ref_dict
    File? ref_gzi

    Int scatter_count
    String? split_intervals_extra_args

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "16G"
    

    command {

        mkdir interval-files
        gatk SplitIntervals \
            -R ${ref_fasta} \
            ${"-L " + intervals} \
            -scatter ${scatter_count} \
            -O interval-files \
            --subdivision-mode BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW \
            ${split_intervals_extra_args}
        cp interval-files/*.interval_list .

    }

    runtime {

        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {

        Array[File] interval_files = glob("*.interval_list")
    }
}

task HaplotypeCaller {

    File input_bam
    File input_bam_index
    String base_name

    File interval_list

    File? ref_dict
    File? ref_fasta
    File? ref_fasta_index
    File? ref_gzi

    File? dbSNP_vcf
    File? dbSNP_vcf_index

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"
    
    Int? stand_call_conf

    command {

        gatk HaplotypeCaller \
            -R ${ref_fasta} \
            -I ${input_bam} \
            -L ${interval_list} \
            -O ${base_name}.vcf.gz \
            -dont-use-soft-clipped-bases \
            --standard-min-confidence-threshold-for-calling ${default=20 stand_call_conf} \
            --dbsnp ${dbSNP_vcf}
    }

    runtime {
        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: select_first([cpu, 1])
        requested_memory: mem
        
    }

    output {
        File output_vcf = "${base_name}.vcf.gz"
        File output_vcf_index = "${base_name}.vcf.gz.tbi"
    }
}

task MergeVCFs {
    
    Array[File] input_vcfs
    Array[File] input_vcfs_indexes
    String output_vcf_name

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"
    
    # Using MergeVcfs instead of GatherVcfs so we can create indices
    # See https://github.com/broadinstitute/picard/issues/789 for relevant GatherVcfs ticket
    command {

        gatk MergeVcfs \
            --INPUT ${sep=' --INPUT=' input_vcfs} \
            --OUTPUT ${output_vcf_name}
            
    }

    runtime {

        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {

        File output_vcf = output_vcf_name
        File output_vcf_index = "${output_vcf_name}.tbi"
    }

}

task VariantFiltration {

    File input_vcf
    File input_vcf_index
    String base_name

    File? ref_dict
    File? ref_fasta
    File? ref_fasta_index
    File? ref_gzi

    # runtime
    Int? max_retries
    Int? cpu = 1
    String mem = "32G"

    command {

        gatk VariantFiltration \
            --R ${ref_fasta} \
            --V ${input_vcf} \
            --window 35 \
            --cluster 3 \
            --filter-name "FS" \
            --filter "FS > 30.0" \
            --filter-name "QD" \
            --filter "QD < 2.0" \
            -O ${base_name}

    }

    runtime {

        docker: "broadinstitute/gatk:4.1.3.0"    
        cpu: cpu
        requested_memory: mem
        
    }

    output {

        File output_vcf = "${base_name}"
        File output_vcf_index = "${base_name}.tbi"
        
    }

}