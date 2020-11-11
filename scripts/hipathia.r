library(hipathia)

#### INPUT ####

message("Reading input...")

# capture script arguments
args <- commandArgs(trailingOnly = FALSE)

# extract variables
cpmFile <- args[grep("--cpmFile",args)+1]
samples <- args[grep("--samples",args)+1]
group <- args[grep("--group",args)+1]
doVc <- args[grep("--doVc",args)+1]
normalizeByLength <- args[grep("--normalizeByLength",args)+1]
noKoChar <- "	./.:.:.:.:."

# if variant calling is performed, then capture the KO parameters
doVc <- as.logical(doVc)
if(doVc) {
  inputFilteredVcfs <- args[grep("--filteredVariants", args)+1]
  koFactor <- as.numeric(args[grep("--koFactor",args)+1])
}

# read cpm table
logCpms <- readRDS(cpmFile)

# prepare data frame with sample information
idToDf <- strsplit(samples, ",")[[1]]
groupToDf <- factor(strsplit(group, ",")[[1]])
sampleInfo <- data.frame(id = idToDf, group = groupToDf)

# transform into matrix
logCpms <- as.matrix(logCpms)

# make sure columns are ordered as in sample information
logCpms <- logCpms[ , sampleInfo$id ]

#### LOAD PATHWAYS OBJECT ####

message("Loading pathways...")

pathways <- load_pathways(species = "hsa")

#### EXPRESSION MATRIX SCALING ####

message("Pre-processing expression matrix...")

# scale to 0-1 interval
normMatrix <- normalize_data(logCpms)

#### IN SILICO KNOCK OUT ####

if(doVc) {
  
  message("Performing in-silico knockout...")
  
  # read vcf
  vcf <- read.table(file = inputFilteredVcfs, sep = "\t", quote = "", header = TRUE, stringsAsFactors = FALSE)

  # extract ko matrix
  geneIds <- unlist(lapply(strsplit(vcf$INFO, "\\|"), function(x) x[5]))
  koMat <- as.matrix(vcf[, 10:ncol(vcf)])
  rownames(koMat) <- geneIds
  koMat <- ifelse(koMat == noKoChar, 1, koFactor)

  # complete ko matrix with missing genes
  notInKoMatrix <- rownames(normMatrix)[!rownames(normMatrix) %in% rownames(koMat)]
  newMat <- matrix(data = 1, nrow = length(notInKoMatrix), ncol = ncol(koMat))
  rownames(newMat) <- notInKoMatrix
  colnames(newMat) <- colnames(koMat)
  koMat <- rbind(koMat, newMat)
  koMat <- koMat[rownames(normMatrix), colnames(normMatrix)]

  # perform in silico ko
  normMatrix <- normMatrix * koMat

}

#### TRANSALTE EXPRESSION MATRIX ####

message("Translating IDs...")

# translate IDs
normTranslatedMatrix <- translate_data(normMatrix, species = "hsa")

#### PERFORM HIPATHIA ANALYSIS ####

message("Performing hipathia analysis...")

# perform analysis
hipathiaRes <- hipathia(normTranslatedMatrix, pathways)

# obtain path values
pathValues <- get_paths_data(hipathiaRes, matrix = TRUE)

# normalize pathways by length if required
if( as.logical(normalizeByLength )) pathValues <- normalize_paths(pathValues, pathways)

#### PERFORM TWO CLASSES COMPARISONS ####

message("Performing comparisons...")

# create all possible pairwise contrasts of group factor levels
combinations <- combn( levels(sampleInfo$group) , 2)

# perform analysis
dsList <- apply(combinations, 2, function(x) {
  
  compTable <- do_wilcoxon(data = pathValues, group = sampleInfo$group, g1 = x[2], g2 = x[1])
  compTable <- data.frame(pathId = rownames(compTable), compTable)
  return(compTable)
  
})

# set list names
names(dsList) <- paste0(combinations[2,], "-", combinations[1,])

# bind rows to get individual Df
df <- Reduce(rbind, dsList)
df$comparison <- rep(names(dsList), unlist(lapply(dsList, nrow)))

#### OUTPUT ####

message("Writting output...")

# output logCPM matrix
write.table(x = pathValues, file = "path_values.tsv", sep = "\t", row.names = TRUE, quote = FALSE)
write.table(x = df, file = "differential_signaling.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(x = normMatrix, file = "scaled_matrix.tsv", sep = "\t", row.names = TRUE, quote = FALSE)
if(doVc) write.table(x = koMat, file = "ko_matrix.tsv", sep = "\t", row.names = TRUE, quote = FALSE)

message("Done!")