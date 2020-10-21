import "MIGNON_tasks.wdl" as Mignon
import "MIGNON_calling.wdl" as MignonVariantCalling

workflow MIGNON {

    ######################
    # WORKFLOW VARIABLES #
    ######################

    # required inputs
    Array[File] input_fastq_r1
    Array[File] input_fastq_r2
    Array[String] sample_id
    Array[String] group
    Boolean is_paired_end
    Boolean use_gz = true
    String execution_mode
    Boolean do_vc
    File gtf_file
    String? hisat2_index_path
    String? hisat2_index_prefix
    String? hisat2_sample_id
    String? star_index_path
    String? salmon_index_path
    File? edger_script
    File? ensemblTx_script
    File? tximport_script
    File? hipathia_script
    String? vep_cache_dir
    File? ref_fasta
    File? ref_fasta_index
    File? ref_dict
    File? db_snp_vcf
    File? db_snp_vcf_index
    Array[File?] known_vcfs 
    Array[File?] known_vcfs_indices 

    # execution inputs
    Int? fastp_cpu = 1
    String? fastp_mem = "16G"
    Int? fastqc_cpu = 1
    String? fastqc_mem = "16G"
    Int? hisat2_cpu = 1
    String? hisat2_mem = "16G"
    Int? sam2bam_cpu = 1
    String? sam2bam_mem = "16G"
    Int? star_cpu = 1
    String? star_mem = "32G"
    Int? salmon_cpu = 1
    String?  salmon_mem = "16G"
    Int? featureCounts_cpu = 1
    String? featureCounts_mem = "16G"
    Int? vep_cpu = 1
    String? vep_mem = "16G"
    Int? haplotype_scatter_count = 1

    # other inputs 
    Int fastp_windows_size = 4
    Int fastp_mean_quality = 15
    Int fastp_required_length = 20
    String? salmon_library_type = "A"
    File? tx2gene_file    
    Int? edger_min_counts = 15  
    Boolean? hipathia_normalize = true
    Float? hipathia_ko_factor = 0.01    
    Float vep_sift_cutoff = 0.05
    Float vep_polyphen_cutoff = 0.95    

    # required defaults
    Int? ensemblTx_cpu = 1
    String? ensemblTx_mem = "16G"
    Int? edger_cpu = 1
    String? edger_mem = "16G"
    Int? tximport_cpu = 1
    String? tximport_mem = "16G"
    Int? hipathia_cpu = 1
    String? hipathia_mem = "16G"
    String? rg_platform = "Unknown"
    String? rg_center = "Unknown"
    Int? min_confidence_for_variant_calling 
    File? ref_gz_index
    File? intervals
    File? input_bai

    ############################
    # TASK CALLER
    ############################

    Int len_fastq = length(input_fastq_r1)

    scatter (idx in range(len_fastq)) {
        
        String sample = sample_id[idx]
        File fastq_r1 = input_fastq_r1[idx]

        String compression = if (use_gz) then ".gz" else ""

        if (is_paired_end) { 

            File fastq_r2 = input_fastq_r2[idx] 
            String output_fastp_r2 = sample + "_2.fastq" + compression
            String output_fastqc_r2 = sub(output_fastp_r2, ".fastq.*", "_fastqc.html")

        }

        # fastp
        call Mignon.fastp as fastp {

            input:
                input_fastq_r1 = fastq_r1,
                input_fastq_r2 = fastq_r2,
                output_fastq_r1 = sample + "_1.fastq" + compression,
                output_fastq_r2 = output_fastp_r2,
                output_json = sample + "_fastp.json",
                output_html = sample + "_fastp.html",
                window_size = fastp_windows_size,
                mean_quality = fastp_mean_quality,
                required_length = fastp_required_length,
                cpu = fastp_cpu,
                mem = fastp_mem

        }

        # fastqc
        call Mignon.fastqc as fastqc {

            input:
                input_fastq_r1 = fastp.trimmed_fastq_r1,
                input_fastq_r2 = fastp.trimmed_fastq_r2,
                out_report_r1 = sample + "_1_fastqc.html",
                out_report_r2 = output_fastqc_r2,
                cpu = fastqc_cpu,
                mem = fastqc_mem

        }

        if (execution_mode == "hisat2" || execution_mode == "salmon-hisat2") {
            
            # hisat2
            call Mignon.hisat2 as hisat2 {

                input:
                    input_fastq_r1 = fastp.trimmed_fastq_r1,
                    input_fastq_r2 = fastp.trimmed_fastq_r2,
                    is_paired_end = is_paired_end,
                    index_path = hisat2_index_path,
                    index_prefix = hisat2_index_prefix,
                    sample_id = sample,
                    output_sam = sample + ".sam",
                    output_summary = sample + "_summary.txt",
                    center = rg_center,
                    platform = rg_platform,
                    cpu = hisat2_cpu,
                    mem = hisat2_mem

            }

            # sam2bam
            call Mignon.sam2bam as bamHisat2 {

                input:
                    input_sam = hisat2.sam,
                    output_bam = sample + ".bam",
                    cpu = sam2bam_cpu,
                    mem = sam2bam_mem

            }

            String hisat2Aligner = "hisat2"        

        }

        if (execution_mode == "star" || execution_mode == "salmon-star") {
            
            # star
            call Mignon.star as star {

                input:
                    input_fastq_r1 = fastp.trimmed_fastq_r1,
                    input_fastq_r2 = fastp.trimmed_fastq_r2,
                    compression = compression,
                    index_path = star_index_path,
                    output_prefix = sample,
                    cpu = star_cpu,
                    mem = star_mem

            }

            String starAligner = "star"  

        }

        if (execution_mode == "salmon" || execution_mode == "salmon-star" || execution_mode == "salmon-hisat2") {
            
            # salmon
            call Mignon.salmon as salmon {

                input:
                    input_fastq_r1 = fastp.trimmed_fastq_r1,
                    input_fastq_r2 = fastp.trimmed_fastq_r2,
                    is_paired_end = is_paired_end,
                    library_type = salmon_library_type,
                    index_path = salmon_index_path,
                    output_dir = sample,
                    cpu = salmon_cpu,
                    mem = salmon_mem

            }  

        }

        if (do_vc) {

            # gatk variant calling
            call MignonVariantCalling.VariantCalling as VariantCalling {

                input:
                    input_bam = select_first([bamHisat2.bam, star.bam]),
                    sampleName = sample,
                    alignment_method = select_first([hisat2Aligner, starAligner]),
                    rg_center = rg_center,
                    rg_platform = rg_platform,
                    input_bai = input_bai,
                    intervals = intervals,
                    refFasta = ref_fasta,
                    refFastaIndex = ref_fasta_index,
                    refDict = ref_dict,
                    refGZIndex = ref_gz_index,
                    dbSnpVcf = db_snp_vcf,
                    dbSnpVcfIndex = db_snp_vcf_index,
                    knownVcfs = known_vcfs,
                    knownVcfsIndices = known_vcfs_indices,
                    minConfidenceForVariantCalling = min_confidence_for_variant_calling,
                    haplotypeScatterCount = haplotype_scatter_count,
                    sample_id = sample
                    
            }

            # annotate and filter variants
            call Mignon.vep as vep {

                input:
                    vcf_file = VariantCalling.variant_filtered_vcf,
                    output_file = sample + ".txt",
                    cache_dir = vep_cache_dir,
                    sift_cutoff = vep_sift_cutoff,
                    polyphen_cutoff = vep_polyphen_cutoff,
                    cpu = vep_cpu,
                    mem = vep_mem
                    
            }
                    
        }

    }

    if (execution_mode == "hisat2" || execution_mode == "star") {

        # hisat2 - featureCounts
        call Mignon.featureCounts as featureCounts {
            
            input:
                input_alignments = select_all(flatten([bamHisat2.bam, star.bam])),
                gtf = gtf_file,
                output_counts = "counts.tsv",
                cpu = featureCounts_cpu,
                mem = featureCounts_mem

        }

    }


    # ensemble gtf to tx2gene
    if (execution_mode == "salmon" || execution_mode == "salmon-hisat2" || execution_mode == "salmon-star") {

        if (!defined(tx2gene_file)) {
            
            call Mignon.ensemblTx2Gene as ensembldb {

                input:
                    ensembldb_script = ensemblTx_script,
                    gtf = gtf_file,
                    output_tx2gene = "tx2gene.tsv",
                    cpu = ensemblTx_cpu,
                    mem = ensemblTx_mem

            }

        }

        # select first tx2gene occurrence
        File tx2gene = select_first([tx2gene_file, ensembldb.tx2gene])

        # salmon - tximport
        call Mignon.tximport as txImport {

            input:
                tx2gene = tx2gene,
                output_counts = "salmon_counts.tsv",
                quant_files = salmon.quant,
                quant_tool = "salmon",
                sample_ids = sample_id,
                tximport_script = tximport_script,
                cpu = tximport_cpu,
                mem = tximport_mem            

        }

    }

    # edgeR
    call Mignon.edgeR as edgeR {
        
        input:
            counts = select_first([txImport.counts, featureCounts.counts]),
            edger_script = edger_script,
            samples = sample_id,
            group = group,
            min_counts = edger_min_counts,
            cpu = edger_cpu,
            mem = edger_mem

    }

    # hipathia
    call Mignon.hipathia as hipathia {
        
        input:
            cpm_file = edgeR.logcpms_hipathia,
            hipathia_script = hipathia_script,
            samples = sample_id,
            group = group,
            normalize_by_length = hipathia_normalize,
            do_vc = do_vc,
            input_vcfs = vep.output_vcf,
            ko_factor = hipathia_ko_factor,
            cpu = hipathia_cpu,
            mem = hipathia_mem

    }

    output {

        File signaling_matrix = hipathia.path_values
        File differential_signaling = hipathia.diff_signaling
        
    }




}