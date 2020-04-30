library(edgeR)

#### INPUT ####

message("Reading input...")

# capture script arguments
args <- commandArgs(trailingOnly = FALSE)

# extract variables
countsFile <- args[grep("--counts",args)+1]
samples <- args[grep("--samples",args)+1]
group <- args[grep("--group",args)+1]
minCounts <- as.numeric(args[grep("--minCounts",args)+1])

# read count table
counts <- read.table(file = countsFile, header = TRUE, sep = "\t", stringsAsFactors = FALSE, quote = "", row.names = 1)

# prepare data frame with sample information
idToDf <- strsplit(samples, ",")[[1]]
groupToDf <- factor(strsplit(group, ",")[[1]])
sampleInfo <- data.frame(id = idToDf, group = groupToDf)

#### TMM NORMALIZATION TO HIPATHIA ####

message("Normalizing expression for hipathia...")

# create dgeList
countsHi <- counts[ , sampleInfo$id ]

# create DGEList object
dgeListHi <- DGEList(counts = as.matrix(countsHi), group = sampleInfo$group)

# calc TMM norm factors
dgeListHi <- calcNormFactors(object = dgeListHi, method = "TMM")

# get logCPM matrix normalized using TMMs
logCpmHi <- cpm(dgeListHi, log = TRUE, prior.count = 3)

#### TMM NORMALIZATION TO DE ####

message("Normalizing expression for DE...")

# create dgeList
counts <- counts[ , sampleInfo$id ]

# remove not expressed genes
counts <- counts[ rowSums(counts) >= minCounts , ]

# create DGEList object
dgeList <- DGEList(counts = as.matrix(counts), group = sampleInfo$group)

# calc TMM norm factors
dgeList <- calcNormFactors(object = dgeList, method = "TMM")

# get logCPM matrix normalized using TMMs
logCpm <- cpm(dgeList, log = TRUE, prior.count = 3)
logCpm <- data.frame(geneId = rownames(logCpm), logCpm)

#### DESIGN AND CONTRASTS ####

message("Creating design and pairwise comparisons...")

# create design matrix using group factor
design <- model.matrix( ~ 0 + group, data = sampleInfo)

# create all possible pairwise contrasts of group factor levels
combinations <- combn(colnames(design), 2)
contrasts <- paste0(combinations[2,], "-", combinations[1,])
cMatrix <- makeContrasts(contrasts = contrasts, levels = colnames(design))

#### PERFORM DE ANALYSIS ####

message("Performing DE analysis...")

# estimate dispersions
dgeList <- estimateDisp(dgeList, design)

# fit quasi-likelihood F-Tests
fit <- glmFit(dgeList, design)

# get list of topTags tables for every contrast
deList <- apply(cMatrix, 2, function(x) {
  
  test <- glmLRT(fit, contrast = x)
  table <- topTags(test, n = Inf)$table
  table <- data.frame(geneId = rownames(table), table)
  return(table)
  
})

# bind rows to get individual Df
df <- Reduce(rbind, deList)
df$comparison <- rep(names(deList), unlist(lapply(deList, nrow)))

#### OUTPUT ####

message("Writting output...")

# output logCPM matrix to hipathia
saveRDS(object = logCpmHi, file = "logCPMs_hipathia.rds")

# output logCPM matrix
write.table(x = logCpm, file = "logCPMs.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

# output logCPM matrix
write.table(x = df, file = "differential_expression.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

message("Done!")