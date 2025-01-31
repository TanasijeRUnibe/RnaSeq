#Convert feature count output into DEseq format

#install pasilla package
if (!require("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install("pasilla")

library("pasilla")
library("DESeq2")

#load data, row.names: sets the first col as row names 
data_count <- read.delim("gene_count.txt", header = T, row.names = 1)

#clean column names to just have the sample names
colnames(data_count) <- gsub(".*mapping\\.|sorted.bam.*", "", colnames(data_count))
#rm chr, start, end etc columns
data_count <- data_count[ -c(1:5) ]

#load group data
data_col <- read.csv("Groups.csv", header = T, row.names = 1)
data_col$Group <- as.factor(data_col$Group) #sets groups as categorical variables

#check if rows and col are the same
all(rownames(data_col) == colnames(data_count))

#data frame for anaylsis 
dds <- DESeqDataSetFromMatrix(countData = data_count,
                              colData = data_col,
                              design = ~ Group)

result_DEseq <- DESeq(dds)

#remove dependence of variance on mean, to stabilise the variance across gene counts
#This ensure more accurate results
result_DEseq_nodep <- vst(result_DEseq, blind = T) #normalizes results

#Make PCA plot 
plotPCA(result_DEseq_nodep, intgroup = "Group")

#save the results for the next step
saveRDS(result_DEseq, file = "DESeqDataSet.rds")
