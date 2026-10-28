
library(dplyr)
library(ggplot2)
library(ggrepel)

species <- "fish" 
species <- "mammal"

matrix_path <- file.path(
  "input/matrices",
  paste0(species, "_matrix.tsv")
)
gene_data <- read.delim(matrix_path)
rownames(gene_data) <- gene_data[[1]]
gene_data <- gene_data %>% select(-"element")


dataset_name <- "sv.1"
FG_output_path <- file.path("output",paste0(dataset_name, "/myOutput_with_FDR.txt"))

genes <- read.delim(FG_output_path, sep = "")

pheno_file <- "input/sv.1/SV_phenotypes.txt" # the phenotype files don't all have the same name so it's a bit annoying
FG_species <- (read.delim(pheno_file, sep = "")
            %>% select(species)
            %>% unlist()
            %>% as.vector
            )
foreground_species <- (read.delim(pheno_file, sep = "")
                       %>% filter(pheno == 0)
                       %>% select(species)
                       %>% unlist()
                       %>% as.vector
                       )
background_species <- (read.delim(pheno_file, sep = "")
                       %>% filter(pheno == 1)
                       %>% select(species)
                       %>% unlist()
                       %>% as.vector
)
background_species <- background_species[!background_species %in% "Gasterosteus_aculeatus"]


foreground_avg_intactness <- gene_data %>% select(foreground_species) %>% rowMeans(na.rm = TRUE) 
background_avg_intactness <- gene_data %>% select(background_species) %>% rowMeans(na.rm = TRUE) 

avg_intactness <- merge(foreground_avg_intactness, background_avg_intactness, by = 0)
avg_intactness <- (avg_intactness %>% rename("elementID" = "Row.names")
                   %>% rename("foreground_avg_intactness" = "x")
                   %>% rename("background_avg_intactness" = "y")
                   )
avg_intactness <- merge(avg_intactness, genes, by = "elementID")
avg_intactness["ratio"] <- avg_intactness$foreground_avg_intactness/avg_intactness$background_avg_intactness
avg_intactness["outliers"] <- case_when(
  avg_intactness$GLS_FDR <= 0.05 ~ avg_intactness$elementID
)

plot <- ggplot(data = avg_intactness) +
               aes(x = log10(ratio), y = -log10(GLS_FDR)) +
  geom_point() +
  geom_hline(yintercept = -log10(0.05), linetype = "dotted", color = "blue", linewidth = 1) +
  geom_text_repel(aes(label = outliers))
plot               


#################################################################################

# boxplots





