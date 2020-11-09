library(ensembldb)

# capture script arguments
args <- commandArgs(trailingOnly = FALSE)
# extract variables
gtfFile <- args[grep("--gtf",args)+1]
outFile <- args[grep("--outFile",args)+1]
# create sql db from gtf
DB <- ensDbFromGtf(gtf = gtfFile)
# create tx2gene
eDB <- EnsDb(DB)
txs <- keys(x = eDB, keytype = "TXID")
tx2gene <- select(x = eDB, 
                  keys = txs, 
                  keytype = "TXID", 
                  columns = "GENEID")

write.csv(tx2gene, outFile, row.names=FALSE)

# remove sql file
file.remove(DB)