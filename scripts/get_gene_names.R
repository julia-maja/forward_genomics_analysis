### get lists of gene names of interest for analyzing forward genomics output
## run this script from the output/ directory 

library(dplyr)

# read myOputput_with_FDR.txt
results <- "myOutput_with_FDR.txt"


# genes where all trait-loss species have %intact values lower than all trait-preserving species
perfect_match_genes <- results %>% filter(PerfectMatchMargin > 0)
# which of these have significant GLS values
sig_perf_match_genes <- perfect_match_genes %>% filter(GLS_FDR < 0.05)


# genes that are almost perfect-match 
#(some trait-loss species have the same % intact valeus as some trait-preserving species)
boundary_genes <- results %>% filter(PerfectMatchMargin == 0)
# which of these have significant GLS values
sig_boundary_genes <- boundary_genes %>% filter(GLS_FDR < 0.05)


# all genes that have significant GLS values
sig_genes <- results %>% filter(GLS_FDR < 0.05)


## output save as files, one gene ID per row
gene_lists <- list(
  perfect_match_genes = perfect_match_genes,
  sig_perf_match_genes = sig_perf_match_genes,
  boundary_genes = boundary_genes,
  sig_boundary_genes = sig_boundary_genes,
  sig_genes = sig_genes
)

list_names <- names(gene_lists)

for (name in list_names) {
    first_column <- gene_lists[[name]][, 1]
    file_path <- paste0(name, ".txt")
    write.table(first_column, 
              file = file_path, 
              row.names = FALSE, 
              col.names = FALSE, 
              quote = FALSE)
}


