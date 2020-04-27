require(ggplot2)
require(dplyr)
library(cowplot)

## function to convert sizes - created by Dani
convert_size <- function(x) {
  ## if all numbers
  if(grepl('^[0-9]{1,}$', x)) return(x)
  ## convert when not
  prefix <- substr(x, nchar(x), nchar(x))
  n <- substr(x, 1, nchar(x)-1)
  fct <- dplyr::case_when(
    prefix == 'K' ~ 1024,
    prefix == 'M' ~ 1024^2,
    prefix == 'G' ~ 1024^3,
    prefix == 'T' ~ 1024^4,
  )
  xx <- as.numeric(n)*fct
  # return Gigabytes
  xx <- xx / 1024^3
  return(xx)
}

#########################
# MULTI-THREADING TASKS #
#########################
results <- read.csv("performance_parallel.csv", sep="|", stringsAsFactors=FALSE, header = TRUE)

tidyRes <- transmute(results, 
                     task = case_when(call == "fast" ~ "Fastp",
                                      call == "fastq" ~ "FastQC",
                                      call == "bamHisat" ~ "samToBam",
                                      call == "hisat" ~ "HISAT2",
                                      call == "sta" ~ "STAR", 
                                      call == "ve" ~ "VeP",
                                      call == "salmo" ~ "Salmon"),
                     cpu = factor(AllocCPUS, levels = c("1","2","4","8","16","24")),
                     # memory as gigabytes
                     maxmemory = lapply(MaxRSS, convert_size) %>% unlist(),
                     # time as minutes
                     time = as.numeric(as.difftime(Elapsed, format = "%H:%M:%S", units = "mins"))) %>%
  # remove fastqc
  subset(task != "FastQC") %>%
  # reorder tasks
  mutate(task = factor(task, levels = c("Fastp","HISAT2", "STAR","Salmon", "samToBam", "VeP")))

# time plot
timeP <- ggplot(data = tidyRes, mapping = aes(x = cpu, y = time, fill = cpu)) + 
  geom_boxplot() +
  facet_wrap(facets =  vars(task), nrow = 3) +
  theme_bw() +
  xlab("Number of CPUs") +
  ylab("Time (minutes)") +
  geom_hline(yintercept = c(30,60,120,240), lty = 2) +
  theme(legend.position = "none")

# memory plot
memoryP <- ggplot(data = tidyRes, mapping = aes(x = cpu, y = maxmemory, fill = cpu)) + 
  geom_boxplot() +
  facet_wrap(facets =  vars(task), nrow = 3) +
  theme_bw() +
  xlab("Number of CPUs") +
  ylab("Max. Memory (Gb)") +
  geom_hline(yintercept = c(4,8,16,32), lty = 2) +
  theme(legend.position = "none")

# memory plot
png(filename = "../figures/Supplementary_1.png", width = 9, height = 5, units = "in", res = 300)
plot_grid(memoryP, timeP, labels = c("A","B"))
dev.off()

# output tidy data
write.table(tidyRes, file = "Supplementary_table_4.tsv", sep = "\t", row.names = FALSE)

#########################
# VARIANT CALLING TASKS #
#########################

results <- read.csv("performance_variant_calling.tsv", sep="|", stringsAsFactors=FALSE, header = TRUE)
results <- results[5:nrow(results),]

tidyRes <- subset(results, State == "COMPLETED") %>%
  mutate(jobEdited = gsub(".batch", "", JobID)) %>%
  group_by(jobEdited) %>%
  summarise(Name = JobName[JobName != "batch"],
            Elapsed = unique(Elapsed),
            MaxRSS = MaxRSS[MaxRSS != ""]) %>%
  ungroup() %>%
  transmute(task = Name,
            maxmemory = lapply(MaxRSS, convert_size) %>% unlist(),
            time = as.numeric(as.difftime(Elapsed, format = "%H:%M:%S", units = "mins"))) %>%
  mutate(task = lapply(task, function(x) strsplit(x, "_")[[1]][3]) %>% unlist()) %>%
  subset(task %in% c( "AddReadGroup","ApplyBQSR", "BaseRecalibrator",
                      "HaplotypeCaller","IndexBam","MarkDuplicates","MergeVCFs"  ,
                      "SplitIntervals","SplitNCigarReads",
                      "VariantFiltration")) 

# time Plot
timeP <- ggplot(data = tidyRes, mapping = aes(x = task, y = time, fill = task)) + 
  geom_boxplot() +
  theme_bw() +
  xlab("Task") +
  ylab("Time (minutes)") +
  geom_hline(yintercept = c(30,60,120,240), lty = 2) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 60, hjust = 1, vjust = 1),
        plot.title = element_text(hjust = 0.5))

# memory plot
memoryP <- ggplot(data = tidyRes, mapping = aes(x = task, y = maxmemory, fill = task)) + 
  geom_boxplot() +
  theme_bw() +
  xlab("Task") +
  ylab("Max. Memory (Gb)") +
  geom_hline(yintercept = c(4,8,16,32), lty = 2) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 60, hjust = 1, vjust = 1),
        plot.title = element_text(hjust = 0.5))


# memory plot
png(filename = "../figures/Supplementary_2.png", width = 9, height = 5, units = "in", res = 300)
plot_grid(memoryP, timeP, labels = c("A","B"))
dev.off()

# output tidy data
write.table(tidyRes, file = "../data/Supplementary_table_5.tsv", sep = "\t", row.names = FALSE)
