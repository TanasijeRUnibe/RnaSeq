# Load necessary libraries
library(clusterProfiler)
library(org.Mm.eg.db)
library(enrichplot)
library(ggplot2)

# Create output directory
output_dir <- "GO_Overrepresentation_Results"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Define file paths
comparisons <- list(
  "Blood" = "Top_20_Genes_Group_Blood_WT_Control_Blood_WT_Case.csv",
  "Lung"  = "Top_20_Genes_Group_Lung_WT_Control_Lung_WT_Case.csv"
)

for (comparison in names(comparisons)) {
  cat("\n--- Processing:", comparison, "---\n")
  
  # Load DE genes
  de_genes <- read.csv(file.path("Volcano_Plots_Results", comparisons[[comparison]]))
  
  # Convert Gene Symbols to ENSEMBL IDs
  gene_mapping <- bitr(de_genes$GeneSymbol, fromType = "SYMBOL", toType = "ENSEMBL", OrgDb = org.Mm.eg.db)
  gene_ids <- gene_mapping$ENSEMBL  # Use converted IDs
  
  # Define universe genes based on DESeq2 dataset
  universe_genes <- rownames(dds)  # Use genes from DESeq2 analysis
  
  # Run GO enrichment with stricter cutoffs
  go_results <- enrichGO(
    gene          = gene_ids,
    universe      = universe_genes,
    OrgDb         = org.Mm.eg.db,
    keyType       = "ENSEMBL",
    ont           = "ALL",
    pAdjustMethod = "BH",
    pvalueCutoff  = 0.05,  # Strict cutoff
    qvalueCutoff  = 0.2    # Original cutoff
  )
  
  # Check if results are empty
  if (is.null(go_results) || nrow(as.data.frame(go_results)) == 0) {
    cat("No significant GO terms found for", comparison, "\n")
    next
  }
  
  # Save results
  write.csv(as.data.frame(go_results), file.path(output_dir, paste0("GO_Results_", comparison, ".csv")), row.names = FALSE)
  
  # Generate Bar and Dot plots
  ggsave(file.path(output_dir, paste0("GO_Barplot_", comparison, ".png")), barplot(go_results, showCategory = 10), width = 12, height = 8)
  ggsave(file.path(output_dir, paste0("GO_Dotplot_", comparison, ".png")), dotplot(go_results, showCategory = 10), width = 12, height = 8)
  
  cat("GO enrichment completed for", comparison, "Results saved in", output_dir, "\n")
}
