# Variant calling for RNASeq
import "MIGNON_calling_tasks.wdl" as Calling

workflow VariantCalling {

    # input bam files
    File input_bam
    File? input_bai
    File? intervals

    File? refFasta
    File? refFastaIndex
    File? refDict
    File? refGZIndex

    String? sample_id

    File? dbSnpVcf
    File? dbSnpVcfIndex
    Array[File?] knownVcfs
    Array[File?] knownVcfsIndices

    Int? minConfidenceForVariantCalling

    String sampleName
    String alignment_method
    String? rg_platform
    String? rg_center

    Int? indexBam_cpu = 1

    Int? haplotypeScatterCount = 1

    if (!defined(input_bai)){

        call Calling.IndexBam as IndexBam{

            input:
                input_bam = input_bam,
                cpu = indexBam_cpu
                
        }
    }

    if(alignment_method == "hisat2") {

        call Calling.ReorderBam as ReorderBam{

            input:
                input_bam = input_bam,
                input_bam_index = input_bai, 
                base_name = sampleName + ".reordered",
                sampleName = sampleName,
                ref_fasta = refFasta,
                ref_fasta_index = refFastaIndex,
                ref_dict = refDict
                
        }
    }

    File reordered_bam = select_first([ReorderBam.output_bam, input_bam])
    File reordered_bai = select_first([ReorderBam.output_bam_index, input_bai, IndexBam.bai_index])

    if(alignment_method == "star") {

        call Calling.AddReadGroup as AddReadGroup{

            input:
                input_bam = reordered_bam,
                input_bam_index = reordered_bai,
                base_name = sampleName + ".reordered.withRG",
                sampleName = sampleName,
                center = rg_center,
                platform = rg_platform
                
        }
    }

    File final_bam = select_first([AddReadGroup.output_bam, ReorderBam.output_bam, input_bam])
    File final_bai = select_first([AddReadGroup.output_bam_index, ReorderBam.output_bam_index, input_bai, IndexBam.bai_index])

    call Calling.MarkDuplicates as MarkDuplicates{

        input:
            input_bam =  final_bam,
            input_bam_index = final_bai,
            base_name = sampleName + ".reordered.dedup",
            
    }

    call Calling.SplitNCigarReads as SplitNCigarReads{

        input:
            input_bam = MarkDuplicates.output_bam,
            input_bam_index = MarkDuplicates.output_bam_index,
            base_name = sampleName + ".reordered.dedup.split",
            ref_fasta = refFasta,
            ref_fasta_index = refFastaIndex,
            ref_dict = refDict,
            ref_gzi = refGZIndex
            
    }

    call Calling.BaseRecalibrator as BaseRecalibrator{

        input:
            input_bam = SplitNCigarReads.output_bam,
            input_bam_index = SplitNCigarReads.output_bam_index,
            recal_output_file = sampleName + ".recal_data.csv",
            dbSNP_vcf = dbSnpVcf,
            dbSNP_vcf_index = dbSnpVcfIndex,
            known_indels_sites_VCFs = knownVcfs,
            known_indels_sites_indices = knownVcfsIndices,
            ref_dict = refDict,
            ref_fasta = refFasta,
            ref_fasta_index = refFastaIndex,
            ref_gzi = refGZIndex

    }

    call Calling.ApplyBQSR as ApplyBQSR{

        input:
            input_bam = SplitNCigarReads.output_bam,
            input_bam_index = SplitNCigarReads.output_bam_index,
            base_name = sampleName + ".reordered.dedup.split.recalibrated",
            ref_fasta = refFasta,
            ref_fasta_index = refFastaIndex,
            ref_dict = refDict,
            ref_gzi = refGZIndex,
            recalibration_report = BaseRecalibrator.recalibration_report
            
    }

    call Calling.SplitIntervals as SplitIntervals{

        input:
            intervals = intervals,
            ref_fasta = refFasta,
            ref_fai = refFastaIndex,
            ref_dict = refDict,
            ref_gzi = refGZIndex,
            scatter_count = haplotypeScatterCount
            
    }
    
    # scatter
    scatter (subintervals in SplitIntervals.interval_files ) {

        call Calling.HaplotypeCaller as HaplotypeCaller{
            
            input:
                input_bam = ApplyBQSR.output_bam,
                input_bam_index = ApplyBQSR.output_bam_index,
                base_name = sampleName + ".hc",
                interval_list = subintervals,
                ref_fasta = refFasta,
                ref_fasta_index = refFastaIndex,
                ref_dict = refDict,
                ref_gzi = refGZIndex,
                dbSNP_vcf = dbSnpVcf,
                dbSNP_vcf_index = dbSnpVcfIndex,
                stand_call_conf = minConfidenceForVariantCalling
                
        }

    }

    # gather
    call Calling.MergeVCFs as MergeVCFs{

        input:
            input_vcfs = HaplotypeCaller.output_vcf,
            input_vcfs_indexes =  HaplotypeCaller.output_vcf_index,
            output_vcf_name = sampleName + ".g.vcf.gz"
            
        }
    
    call Calling.VariantFiltration as VariantFiltration{

        input:
            input_vcf = MergeVCFs.output_vcf,
            input_vcf_index = MergeVCFs.output_vcf_index,
            base_name = sampleName + ".variant_filtered.vcf.gz",
            ref_fasta = refFasta,
            ref_fasta_index = refFastaIndex,
            ref_dict = refDict,
            ref_gzi = refGZIndex
            
    }

    output {

        File recalibrated_bam = ApplyBQSR.output_bam
        File recalibrated_bam_index = ApplyBQSR.output_bam_index
        File merged_vcf = MergeVCFs.output_vcf
        File merged_vcf_index = MergeVCFs.output_vcf_index
        File variant_filtered_vcf = VariantFiltration.output_vcf
        File variant_filtered_vcf_index = VariantFiltration.output_vcf_index

    }

}