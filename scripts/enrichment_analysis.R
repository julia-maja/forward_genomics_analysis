### gene enrichment analysis

library(clusterProfiler)
library(erichplot)
library(org.Dr.eg.db)
library(ggplot2)
library(dplyr)
library(stringr)
library(patchwork)

datasets <- c("sv", "sv.1", "fish", "mam_nc", "artio_nc", "artio")
diel_traits <- c("all_vs_cathem", "cathem_vs_all", "crep_vs_all",
                 "diurn_vs_all", "diurn_vs_nocturn", "diurnal_vs_all", 
                 "nocturn_vs_all",   "nocturn_vs_diurn", "")
  
combinations <- expand.grid(dataset = datasets, diel_trait = diel_traits)
combinations$choice <- paste(
  combinations$dataset,
  combinations$diel_trait,
  sep = "/"
)
combinations$choice
#dataset_name <- combinations$choice[1]
dataset_name <- "sv.1"
FG_output_path <- file.path("output",paste0(dataset_name, "/myOutput_with_FDR.txt"))

genes <- read.delim(FG_output_path, sep = "")


# GSEA using clusterProfiler

# GSEA --------------------------------------------------------------------

# sig_genes <- genes %>% filter(GLS_FDR <= 0.05)
# sig_genes <- sig_genes %>% arrange(desc("GLS_FDR")) 
# sig_genes <- sig_genes$elementID %>% as.vector

# decreasing named numeric vector:
all_genes <- genes$GLS_FDR
names(all_genes) <- genes$elementID
all_genes <- sort(all_genes, decreasing = TRUE)

# in case I need just the sig_genes:
df <- genes %>% filter(GLS_FDR <= 0.05)
sig_genes <- df$GLS_FDR
names(sig_genes) <- df$elementID
sig_genes <- sort(sig_genes, decreasing = TRUE)

gsea_go <- gseGO(
  geneList     = all_genes,
  OrgDb        = org.Dr.eg.db,
  ont          = "BP",
  keyType      = "SYMBOL",
  pvalueCutoff = 0.05,
  verbose      = FALSE
)


# Warning messages:
# 1: In preparePathwaysAndStats(pathways, stats, minSize, maxSize, gseaParam,  :
#   There are ties in the preranked stats (73.07% of the list).
# The order of those tied genes will be arbitrary, which may produce unexpected results.
# 2: In fgseaMultilevel(pathways = pathways, stats = stats, minSize = minSize,  :
#   There were 1 pathways for which P-values were not calculated properly due to unbalanced (positive and negative) gene-level statistic values. For such pathways pval, padj, NES, log2err are set to NA. You can try to increase the value of the argument nPermSimple (for example set it nPermSimple = 10000)
# 3: In fgseaMultilevel(pathways = pathways, stats = stats, minSize = minSize,  :
#   For some of the pathways the P-values were likely overestimated. For such pathways log2err is set to NA.

# GO term plots

dotplot <- dotplot(gsea_go, showCategory = 20) +
  ggtitle("GSEA - GO Biological Processes")
dotplot

barplot <- barplot(gsea_go, showCategory = 20) +
  ggtitle("Top GO Biological Processes")



res <- as.data.frame(gsea_go)
res_top <- res %>%
  arrange(p.adjust) %>%
  slice_head(n = 20)

ggplot(res_top,
       aes(x = NES,
           y = reorder(Description, NES),
           fill = p.adjust)) +
  geom_col() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_gradient(low = "red", high = "blue",
                      name = "Adjusted p-value") +
  labs(
    title = "GO Biological Process GSEA",
    x = "Normalized Enrichment Score (NES)",
    y = NULL
  ) +
  theme_bw()




# GSEA plots for top GO terms ---------------------------------------------

# top 20 GO terms
gsea_top20 <- as.data.frame(gsea_go) %>%
  filter(!is.na(p.adjust)) %>%
  arrange(p.adjust) %>%
  slice_head(n = 20)

# display all the plots
for (i in seq_len(nrow(gsea_top20))) {
  
  p <- enrichplot::gseaplot2(
    gsea_go,
    geneSetID = gsea_top20$ID[i],
    title = paste0(
      gsea_top20$Description[i],
      "\nNES = ", round(gsea_top20$NES[i], 2),
      " | Adjusted p = ", signif(gsea_top20$p.adjust[i], 3)
    )
  )
  
  print(p)
  
  readline(prompt = "press Enter to view the next plot")
}

# GO with clusterProfiler  ---------------------------------------------------------------------

go_results <- enrichGO(
  gene          = names(sig_genes),
  universe      = names(all_genes),
  OrgDb         = org.Dr.eg.db,
  keyType       = "SYMBOL",
  ont           = "ALL",
  pAdjustMethod = "BH",
  pvalueCutoff  = 0.05,
  readable      = TRUE
)

dotplot <- dotplot(go_results, showCategory = 20) +
  ggtitle("GO terms in FG gene candidates")
dotplot


# GO with DAVID results ---------------------------------------------------
FG_output_path <- file.path("output",paste0(dataset_name, "/DAVID/GO_terms_all.csv"))
david_results <- read.csv(FG_output_path)

david_top <- david_results %>%
  filter(!is.na(Benjamini), Benjamini > 0) %>%
  arrange(Benjamini) %>%
  slice_head(n = 20)

ggplot(
  david_top,
  aes(
    x = Fold.Enrichment,
    y = reorder(Term, Fold.Enrichment),
    size = Count,
    color = -log10(Benjamini)
  )
) +
  geom_point() +
  scale_color_gradient(
    low = "steelblue",
    high = "red",
    name = "-log10(Benjamini)"
  ) +
  labs(
    title = "DAVID GO terms",
    x = "Enrichment Score",
    y = NULL,
    size = "Gene count"
  ) +
  theme_bw()

# DAVID functional annotation clustering ----------------------------------

FG_output_path <- file.path("output", paste0(dataset_name, "/DAVID/cluster_low.csv"))
FG_output_path <- file.path("output", paste0(dataset_name, "/DAVID/cluster_med.csv"))
FG_output_path <- file.path("output", paste0(dataset_name, "/DAVID/cluster_high.csv"))

david_results <- read.csv(FG_output_path)

david_top <- david_results %>%
  filter(!is.na(Benjamini), Benjamini > 0) %>%
  arrange(Benjamini) %>%
  slice_head(n = 20)

ggplot(
  david_top,
  aes(
    x = Cluster.Enrichment.Score,
    y = reorder(Term, Cluster.Enrichment.Score),
    size = Count,
    color = -log10(Benjamini)
  )
) +
  geom_point() +
  scale_color_gradient(
    low = "steelblue",
    high = "red",
    name = "-log10(Benjamini)"
  ) +
  labs(
    title = "DAVID Functional Annotation Clusters",
    x = "Enrichment Score",
    y = NULL,
    size = "Gene count"
  ) +
  theme_bw()



# DAVID functional annotation chart plotting ------------------------------
FG_output_path <- file.path("output", paste0(dataset_name, "/DAVID/func_ann_chart.csv"))
FG_output_path <- file.path("output", paste0(dataset_name, "/DAVID/func_ann_chart_threshold_10.csv"))
FG_output_path <- file.path("output", paste0(dataset_name, "/DAVID/func_ann_chart_threshold_100.csv"))

david_results <- read.csv(FG_output_path)

david_top <- david_results %>%
  filter(
    !is.na(Benjamini),
    Benjamini > 0,
    is.finite(Benjamini)
  ) %>%
  arrange(Benjamini) %>%
  slice_head(n = 25) %>%
  mutate(
    Term_label = str_trunc(Term, 75),
    Term_label = reorder(Term_label, Fold.Enrichment)
  )

ggplot(
  david_top,
  aes(
    x = Fold.Enrichment,
    y = Term_label,
    size = Count,
    color = -log10(Benjamini)
  )
) +
  geom_point() +
  scale_color_gradient(
    low = "steelblue",
    high = "red",
    name = "-log10(Benjamini)"
  ) +
  labs(
    title = "DAVID Functional Annotation Results",
    subtitle = "Top 25 annotations ranked by adjusted p-value",
    x = "Fold enrichment",
    y = NULL,
    size = "Gene count"
  ) +
  theme_bw() +
  theme(
    axis.text.y = element_text(size = 9),
    plot.title = element_text(face = "bold")
  )

## pathway and interaction visualization
pathway <- file.path("output", paste0(dataset_name, "/DAVID/pathway.csv"))
interaction <- file.path("output", paste0(dataset_name, "/DAVID/interaction.csv"))

david_results <- bind_rows(pathway, interaction)

ggplot(
  david_results,
  aes(
    x = Fold.Enrichment,
    y = Term,
    size = Count,
    color = -log10(Benjamini)
  )
) +
  geom_point() +
  scale_color_gradient(
    low = "steelblue",
    high = "red",
    name = "-log10(Benjamini)"
  ) +
  labs(
    title = "DAVID Pathway and Interaction Results",
    x = "Fold enrichment",
    y = NULL,
    size = "Number of genes"
  ) +
  theme_bw()


# kegg pathways -----------------------------------------------------------

kegg_paths <- file.path("output", paste0(dataset_name, "/DAVID/pathway.csv"))
length(table(kegg_paths$Gene.Name))
length(table(kegg_paths$Term))

