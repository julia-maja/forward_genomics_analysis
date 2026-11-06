
library(dplyr)
library(ggplot2)
library(ggrepel)
library(phytools)

species <- "fish" 
#species <- "mammal"

matrix_path <- file.path(
  "input/matrices",
  paste0(species, "_matrix.tsv")
)
gene_data <- read.delim(matrix_path)
rownames(gene_data) <- gene_data[[1]]
gene_data <- gene_data %>% dplyr::select(-"element")


dataset_name <- "sv"
FG_output_path <- file.path("output",paste0(dataset_name, "/myOutput_with_FDR.txt"))

genes <- read.delim(FG_output_path, sep = "")

pheno_file <- "input/sv.1/SV_phenotypes.txt" 
FG_species <- (read.delim(pheno_file, sep = "")
            %>% dplyr::select(species)
            %>% unlist()
            %>% as.vector
            )
foreground_species <- (read.delim(pheno_file, sep = "")
                       %>% filter(pheno == 0)
                       %>% dplyr::select(species)
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


foreground_avg_intactness <- gene_data %>% dplyr::select(foreground_species) %>% rowMeans(na.rm = TRUE) 
background_avg_intactness <- gene_data %>% dplyr::select(background_species) %>% rowMeans(na.rm = TRUE) 

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
gene_name <- "drc2"

foreground_intactness <- (gene_data 
                          %>% dplyr::select(foreground_species) 
                          %>% filter(rownames(.) == gene_name)
                          %>% t()
                          %>% as.data.frame()
                          %>% mutate(group = "sv absent species")
                          )
background_intactness <- (gene_data 
                          %>% dplyr::select(background_species) 
                          %>% filter(rownames(.) == gene_name)
                          %>% t()
                          %>% as.data.frame()
                          %>% mutate(group = "sv present species")
                          )

df <- bind_rows(foreground_intactness, background_intactness) 
names(df)[1] <- "intactness"

ggplot(df, aes(x = group, y = intactness, fille = group)) +
  geom_boxplot() +
  geom_jitter(width = 0.15, size = 2, alpha = 0.7) +
  labs(title = gene_name, y = "%intact") +
  theme_minimal()


t.test(Value ~ Group, data = df)

# 
tree <- read.tree("input/sv.1/tree.nwk")
phyl.pairedttest(tree, x1=foreground_intactness, x2=background_intactness, se1=NULL, se2=NULL, lambda=1.0, h0=0.0,
                 fixed=FALSE)







