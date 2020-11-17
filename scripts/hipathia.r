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
  
  inputFilteredVcfs <- strsplit(inputFilteredVcfs, ",")[[1]]
  
  # read vcfs
  genesBySample <- lapply(inputFilteredVcfs, function(x) {
    # try to read vcf
    vcf <- try(read.table(file = x, header = FALSE, sep = "\t", stringsAsFactors = FALSE, ))
    # return NA if error, otherwise return unique genes
    if(inherits(vcf, "try-error")) {
      return(NA)
    } else {
      genes <- unique(vcf[,4])
      return(genes)
    }
  })
  
  # set names using filename
  names(genesBySample) <- gsub(pattern = ".txt", replacement = "",  basename(inputFilteredVcfs))
  
  # remove empty files and genes not in the matrix
  genesBySample <- genesBySample[!is.na(genesBySample)]
  genesBySample <- lapply(genesBySample, function(x) x[x %in% rownames(normMatrix)])

  # create koMatrix
  koMatrix <- matrix(1, nrow = nrow(normMatrix), ncol = ncol(normMatrix))
  rownames(koMatrix) <- rownames(normMatrix)
  colnames(koMatrix) <- colnames(normMatrix)

  # sub 1 by 0.01 in altered genes
  for( sample in names(genesBySample) ) {
    koMatrix[ genesBySample[[sample]] , sample ] <- koFactor
  }
  
  # use koMatrix to perform insilico ko
  normMatrix <- normMatrix * koMatrix

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
  compTable <- data.frame(pathId = rownames(compTable), compTable, stringsAsFactors = FALSE)
  return(compTable)
  
})

message("Preparing output...")

# set list names
names(dsList) <- paste0(combinations[2,], "-", combinations[1,])

# bind rows to get individual Df
df <- Reduce(rbind, dsList)
df$comparison <- rep(names(dsList), unlist(lapply(dsList, nrow)))

# add path names to differential signaling output
df <- cbind("path_name" = hipathia::get_path_names(metaginfo = pathways, names = as.character(df$pathId)), df)

#### OUTPUT ####

message("Writting output...")

# output logCPM matrix
write.table(x = pathValues, file = "path_values.tsv", sep = "\t", row.names = TRUE, quote = FALSE)
write.table(x = df, file = "differential_signaling.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(x = normMatrix, file = "scaled_matrix.tsv", sep = "\t", row.names = TRUE, quote = FALSE)
if(doVc) write.table(x = koMatrix, file = "ko_matrix.tsv", sep = "\t", row.names = TRUE, quote = FALSE)
saveRDS(pathways, "hipathia_metaginfo.rds")

message("Done!")