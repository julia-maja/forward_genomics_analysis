
### plot trees showing trait presence/ absence alongside gene presence/ absence

library(dplyr)
library(tibble)
library(ape)
library(ggnewscale)
library(ggtree)
library(ggplot2)

# fish, artio, SV, mammal, etc.
dataset_name <- "SV" # variable ##################################################################

# get the tree
tree_path <- file.path(
  "/input",
  dataset_name,
  paste0("tree", ".nwk")
)
tree <- read.tree(tree_path)

# get the binary trait data
trait_data <- "SV_phenotypes" # variable ##################################################################
trait_path <- file.path(
  "/input",
  dataset_name,
  paste0(trait_data, ".txt")
)
trait <- read.delim(trait_path, header = TRUE, sep = " ")

# get the % intactness of the gene of interest across species

species <- "fish" # variable ##################################################################################
matrix_path <- file.path(
  "/input/matrices",
  paste0(species, ".txt")
)
gene_data <- read.delim("/Users/juliamaja/Downloads/fish_matrix.tsv") ### placeholder for now ############
# gene_data <- read.delim(matrix_path)
gene_name <- "sirt6" # variable ##################################################################################


gene_intactness <- (gene_data 
                    %>% filter(element == gene_name) 
                    %>% t() 
                    %>% as.data.frame()
                    %>% rownames_to_column(var = "a")
                    %>% rename(!!gene_name := 2, species = 1)
                    %>% filter(species != "element")
                    )
gene_intactness[[gene_name]] <- as.numeric(gene_intactness[[gene_name]])

# combine trait and gene data and color tip labels by taxonomic order

SV_data_avg <- read.csv("/Users/juliamaja/Desktop/SV/SV_data_avg.csv")

df <- trait %>% full_join(gene_intactness, by = "species")
df <- df %>% full_join(SV_data_avg, by = c("species" = "tips"))

plot <- ggtree(tree, layout="circular") %<+% df[, c("species", "pheno", gene_name, "Order")]

plot <- plot +
  
  geom_tile(
    data = plot$data[1:length(tree$tip.label), ],
    aes(x = x, y = y, fill = pheno),
    inherit.aes = FALSE,
    color = "transparent",
    width = 3
  ) +
  scale_fill_gradient(
    low = "red",
    high = "green"
  ) +
  ggnewscale::new_scale_fill() +
  geom_tile(
    data = plot$data[1:length(tree$tip.label), ],
    aes(x = x+2, y = y, fill = .data[[gene_name]]),
    inherit.aes = FALSE,
    color = "transparent",
    width = 3
  ) +
  scale_fill_gradient(
    low = "red",
    high = "green"
  ) +
  geom_tiplab(aes(color = Order), size = 2, offset = 5, show.legend = FALSE) +
  # add invisible points just for legend
  geom_point(aes(x = 0, y = 0, color = Order), shape = 15, size = 4, alpha = 0) +
  scale_color_manual(values = order_colors, guide = guide_legend(override.aes = list(alpha = 1))) 

plot



