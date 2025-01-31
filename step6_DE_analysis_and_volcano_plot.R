# Load necessary libraries
library(DESeq2)
library(ggplot2)
library(ggrepel)
library(org.Mm.eg.db)
library(clusterProfiler)

# Create a new directory for results
output_dir <- "Volcano_Plots_Results"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Load the DESeqDataSet object
dds <- readRDS("DESeqDataSet.rds")

# Update the design to model all groups explicitly
dds <- DESeqDataSetFromMatrix(
  countData = counts(dds),
  colData = colData(dds),
  design = ~ 0 + Group  # Zero-sum design
)

# Re-run DESeq2
dds <- DESeq(dds)

# Check updated contrasts
resultsNames(dds)

# Define contrasts
contrasts <- list(
  c("Group", "Blood_WT_Control", "Blood_WT_Case"),
  c("Group", "Lung_WT_Control", "Lung_WT_Case")
)

# Initialize summary file
summary_file <- file.path(output_dir, "DEG_Analysis_Summary.txt")
sink(summary_file)  # Redirect output to file

for (contrast in contrasts) {
  cat("\nProcessing contrast:", paste(contrast, collapse = " "), "\n")
  
  # Extract results
  res <- results(dds, contrast = contrast)
  
  # Remove NA values
  res <- res[!is.na(res$padj), ]
  
  # Convert Ensembl IDs to gene symbols
  gene_mapping <- bitr(rownames(res), fromType = "ENSEMBL", toType = "SYMBOL", OrgDb = org.Mm.eg.db)
  
  # Merge gene symbols into the results dataframe
  res$GeneSymbol <- gene_mapping$SYMBOL[match(rownames(res), gene_mapping$ENSEMBL)]
  
  # Filter significant DE genes
  de_genes <- res[res$padj < 0.05, ]
  
  # Separate upregulated and downregulated genes
  upregulated <- de_genes[de_genes$log2FoldChange > 0, ]
  downregulated <- de_genes[de_genes$log2FoldChange < 0, ]
  
  # Select the top 2-3 genes of interest (highest fold change & lowest p-value)
  top_interest_genes <- head(de_genes[order(-abs(de_genes$log2FoldChange), de_genes$padj), ], 3)
  
  # Save answers to text file
  cat("\n==============================\n")
  cat("Results for", paste(contrast, collapse = " "), "\n")
  cat("==============================\n")
  
  cat("Total DE genes (padj < 0.05):", nrow(de_genes), "\n")
  cat("Upregulated genes:", nrow(upregulated), "\n")
  cat("Downregulated genes:", nrow(downregulated), "\n")
  cat("Top 2-3 genes of interest:\n")
  print(top_interest_genes[, c("GeneSymbol", "log2FoldChange", "padj")])
  
  # Save top 20 DE genes to CSV
  write.csv(de_genes, file.path(output_dir, paste0("DE_genes_", paste(contrast, collapse = "_"), ".csv")), row.names = TRUE)
  
  # Generate and save Volcano Plot
  volcano_data <- as.data.frame(res)
  volcano_data$Significance <- ifelse(volcano_data$padj < 0.05, "Significant", "Not Significant")
  
  volcano_plot <- ggplot(volcano_data, aes(x = log2FoldChange, y = -log10(padj), color = Significance)) +
    geom_point(alpha = 0.7) +
    theme_minimal() +
    labs(
      title = paste("Volcano Plot for", paste(contrast, collapse = " ")),
      x = "Log2 Fold Change",
      y = "-Log10 Adjusted P-value"
    ) +
    geom_text_repel(
      data = subset(volcano_data, rownames(volcano_data) %in% rownames(top_interest_genes)),
      aes(label = GeneSymbol),
      size = 3,
      box.padding = 0.5,
      max.overlaps = Inf
    )
  
  # Save volcano plot
  ggsave(file.path(output_dir, paste0("Volcano_Plot_", paste(contrast, collapse = "_"), ".png")), plot = volcano_plot, width = 10, height = 6)
}

sink()  # Stop writing to file

cat("\nAll results saved in", output_dir, "\n")
