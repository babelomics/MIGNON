library(tximport)

# capture script arguments
args <- commandArgs(trailingOnly = FALSE)

# extract variables
txGene <- args[grep("--tx2gene",args)+1]
quantFiles <- args[grep("--quantFiles",args)+1]
sampleIds <- args[grep("--sampleIds",args)+1]
outFile <- args[grep("--outFile",args)+1]

# read tx2gene
tx2gene <- read.csv(txGene)

# capture quant sf files and sample Ids
quantFiles <- strsplit(quantFiles, ",")[[1]]
sampleIds <- strsplit(sampleIds, ",")[[1]]

# tximport
txi <- tximport(files = quantFiles, tx2gene = tx2gene, type = "salmon", ignoreTxVersion = TRUE, dropInfReps=TRUE, countsFromAbundance = "lengthScaledTPM")
counts <- txi$counts

# colnames using sample ids
colnames(counts) <- sampleIds

# output tsv
write.table(counts, file = outFile, sep = "\t", row.names = TRUE, col.names = NA, quote = FALSE)

