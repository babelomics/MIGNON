# exit when any command fails
set -e

# store current directory for further executions
mignonDir=$PWD

# create MIGNON_example directory
if [ ! -d "MIGNON_example" ]; then mkdir -p MIGNON_example; fi
cd MIGNON_example

#### REFERENCE DATA ####
echo "Downloading reference data and example reads..."

cromwellJar="https://github.com/broadinstitute/cromwell/releases/download/47/cromwell-47.jar"
refGenome="ftp://ftp.ensembl.org/pub/release-99/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna_rm.primary_assembly.fa.gz"
refGtf="ftp://ftp.ensembl.org/pub/release-99/gtf/homo_sapiens/Homo_sapiens.GRCh38.99.chr.gtf.gz"
refCDna="ftp://ftp.ensembl.org/pub/release-99/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
vepCache="ftp://ftp.ensembl.org/pub/release-99/variation/indexed_vep_cache/homo_sapiens_vep_99_GRCh38.tar.gz"
refDbSnp="https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/All_20170710.vcf.gz"
refDbSnpIndex="https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/All_20170710.vcf.gz.tbi"

#### EXAMPLE READS ####
control1="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR376/006/ERR3761156/ERR3761156.fastq.gz"
control2="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR376/007/ERR3761157/ERR3761157.fastq.gz"
control3="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR376/008/ERR3761158/ERR3761158.fastq.gz"
problem1="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR376/009/ERR3761159/ERR3761159.fastq.gz"
problem2="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR376/000/ERR3761160/ERR3761160.fastq.gz"
problem3="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR376/001/ERR3761161/ERR3761161.fastq.gz"

#### DOWNLOAD ####
urls=(
    $cromwellJar
    $refGenome
    $refGtf
    $refCDna
    $vepCache
    $refDbSnp
    $refDbSnpIndex
    $control1
    $control2
    $control3
    $problem1
    $problem2
    $problem3
)
names=(
    "cromwell-47.jar"
    "genome.fa.gz"
    "Homo_sapiens.GRCh38.99.chr.gtf.gz"
    "cdna.fa.gz"
    "vepCache.tar.gz"
    "dbSnp.vcf.gz"
    "dbSnp.vcf.gz.tbi"
    "c1.fastq.gz"
    "c2.fastq.gz"
    "c3.fastq.gz"
    "p1.fastq.gz"
    "p2.fastq.gz"
    "p3.fastq.gz"
)

l=$((${#urls[@]}-1))

for i in $(seq 0 $l); do 
    u=${urls[$i]}
    f=${names[$i]}
    if [ ! -f $f ]; then 
        echo "========================"
        echo "Downloading $f ..."
        echo "From URL $u..."
        echo "========================"
        curl -L --retry 10 --ftp-method nocwd -o $f $u
    else
        echo "$f found in this directory, skipping to the next file..."
    fi
done

#### DECOMPRESS ####
if [ ! -f "genome.fa" ]; then 
    echo "========================"
    echo "Decompressing genome..."
    echo "========================"    
    gzip -kd genome.fa.gz
fi

if [ ! -f "Homo_sapiens.GRCh38.99.chr.gtf" ]; then

    echo "========================"
    echo "Decompressing genome annotation..."
    echo "========================"
    gzip -kd Homo_sapiens.GRCh38.99.chr.gtf.gz
fi

if [ ! -d "homo_sapiens" ]; then 

    echo "========================"
    echo "Decompressing variant annotation..."
    echo "========================"
    tar -zxvf vepCache.tar.gz
fi

#### THREADS ####
threads=6

#### INDEX REFERENCE FA ####
samtoolsDocker="quay.io/biocontainers/samtools:1.9--h8571acd_11"

if [ ! -f "genome.fa.fai" ]; then 
    echo "========================"
    echo "Indexing genome Fasta with samtools.."
    echo "========================"
    docker run --rm -v $PWD:$PWD -w $PWD $samtoolsDocker samtools faidx genome.fa
    echo "Ok"
else
    echo "Fasta index found in this directory, skipping to the next step..."
fi

if [ ! -f "genome.dict" ]; then 
    echo "========================"
    echo "Creating genome dictionary with samtools.."
    echo "========================"
    docker run --rm -v $PWD:$PWD -w $PWD $samtoolsDocker samtools dict genome.fa > genome.dict
    echo "Ok"
else
    echo "Fasta dict found in this directory, skipping to the next step..."
fi

#### SALMON INDEX ####
cdna="cdna.fa.gz"
salmonDocker="quay.io/biocontainers/salmon:0.13.0--h86b0361_2"
script=$(echo "salmon index -p $threads -t $cdna -i salmon_index")

if [ ! -d "salmon_index" ]; then 

    echo "========================"
    echo "Indexing cDNA with salmon.."
    echo "Preparing index with $threads threads..."
    echo "========================"
    docker run --rm -v $PWD:$PWD -w $PWD $salmonDocker $script
else
    echo "Salmon index found in this directory, skipping to the next step..."
fi

#### HISAT2 INDEX ####
genome="genome.fa"
hisatDocker="quay.io/biocontainers/hisat2:2.1.0--py27h6bb024c_3"
script=$(echo "hisat2-build -p $threads $genome hisat_index/genome")

if [ ! -d "hisat_index" ]; then
    echo "========================"
    echo "Indexing genome with HISAT2..."
    echo "Preparing index with $threads threads..."
    echo "========================"
    mkdir "hisat_index"
    docker run --rm -v $PWD:$PWD -w $PWD $hisatDocker $script
else
    echo "HISAT2 index found in this directory, skipping to the next step..."
fi

#### PREPARE INPUT JSON ####

template="$mignonDir/generic_input.json"

inputJson='{\n
    "MIGNON.execution_mode": "salmon-hisat2",\n
    "MIGNON.is_paired_end": false,\n
    "MIGNON.do_vc": true,\n
    "MIGNON.input_fastq_r1": ["'$PWD'/c1.fastq.gz", "'$PWD'/c2.fastq.gz", "'$PWD'/c3.fastq.gz",\n
                              "'$PWD'/p1.fastq.gz", "'$PWD'/p2.fastq.gz", "'$PWD'/p3.fastq.gz"],\n
    "MIGNON.input_fastq_r2": [],\n
    "MIGNON.sample_id": ["Control_1", "Control_2", "Control_3", "Problem_1", "Problem_2", "Problem_3"],\n
    "MIGNON.group": ["Control", "Control", "Control", "Problem", "Problem", "Problem"],\n
    "MIGNON.gtf_file": "'$PWD'/Homo_sapiens.GRCh38.99.chr.gtf",\n
    "MIGNON.star_index_path": "'$PWD'/star_index",\n
    "MIGNON.salmon_index_path": "'$PWD'/salmon_index",\n
    "MIGNON.hisat2_index_path": "'$PWD'/hisat_index",\n
    "MIGNON.hisat2_index_prefix": "genome",\n
    "MIGNON.vep_cache_dir": "'$PWD'/homo_sapiens/",\n
    "MIGNON.ref_fasta": "'$PWD'/genome.fa",\n
    "MIGNON.ref_fasta_index": "'$PWD'/genome.fa.fai",\n
    "MIGNON.ref_dict": "'$PWD'/genome.dict",\n
    "MIGNON.db_snp_vcf": "'$PWD'/dbSnp.vcf.gz",\n
    "MIGNON.db_snp_vcf_index": "'$PWD'/dbSnp.vcf.gz.tbi",\n
    "MIGNON.known_vcfs":["'$PWD'/dbSnp.vcf.gz"],\n
    "MIGNON.known_vcfs_indices": ["'$PWD'/dbSnp.vcf.gz.tbi"],\n
    "MIGNON.edger_script": "'$mignonDir'/scripts/edgeR.r",\n
    "MIGNON.tximport_script": "'$mignonDir'/scripts/tximport.r",\n
    "MIGNON.hipathia_script": "'$mignonDir'/scripts/hipathia.r",\n
    "MIGNON.ensemblTx_script": "'$mignonDir'/scripts/ensembldb.r"\n
}'

echo -e $inputJson > input.json

#### RUN MIGNON ####
config="$mignonDir/configs/LocalWithDocker.conf"
cromwell="$PWD/cromwell-47.jar"
workflow="$mignonDir/wdl/MIGNON.wdl"
input="$PWD/input.json"

echo "========================"
echo "Running MIGNON with example data..."
echo "Logs can be checked at ./MIGNON_example/MIGNON_example.log"
echo "Config: $config"
echo "Cromwell: $cromwell"
echo "Workflow: $workflow"
echo "Input: $input"
echo "========================"

java -Dconfig.file=$config -jar $cromwell run $workflow -i $input > MIGNON_example.log