
### plot trees showing trait presence/ absence alongside gene presence/ absence

library(dplyr)
library(tibble)
library(ape)
library(ggnewscale)
library(ggtree)
library(ggplot2)

# fish, artio, SV, mam_nc, etc.
dataset_name <- "sv.1" # variable ##################################################################

# get the tree
tree_path <- file.path(
  "input",
  dataset_name,
  paste0("tree", ".nwk")
)
tree <- read.tree(tree_path)

# get the binary trait data
trait_data <- "SV_phenotypes" # variable ##################################################################
trait_path <- file.path(
  "input",
  dataset_name,
  paste0(trait_data, ".txt")
)
trait <- read.delim(trait_path, header = TRUE, sep = " ")

# get the % intactness of the gene of interest across species

species <- "fish" # variable ##################################################################################
matrix_path <- file.path(
  "input/matrices",
  paste0(species, "_matrix.tsv")
)
gene_data <- read.delim(matrix_path)

# top 20 sig genes for sv.1:
genes <- c("LOC120828872",
"LOC120820186",
"LOC120814343",
"mcm3ap",
"pcnx4",
"LOC144390213",
"ptges",
"LOC120819019",
"marchf3",
"si_dkey_3k24_8",
"dusp3a",
"etnppl",
"chtf18",
"adamts14",
"LOC120827732",
"LOC120809572",
"LOC120833445",
"itprid1",
"clmnb",
"col20a1")


gene_name <- "LOC144390213" # variable ##################################################################################


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

SV_data_avg <- read.csv("/Users/juliamaja/Desktop/SV/SV_data_eco.csv")

df <- trait %>% full_join(gene_intactness, by = "species")
df <- df %>% full_join(SV_data_avg, by = c("species" = "tips"))

sv_plot <- ggtree(tree, layout="circular") %<+% df[, c("species", "pheno", gene_name, "Order", "salinity", "seasonal_spawning")]

plot <- sv_plot +
  
  geom_tile(
    data = plot$data[1:length(tree$tip.label), ],
    aes(x = x, y = y, fill = pheno),
    inherit.aes = FALSE,
    color = "transparent",
    width = 3
  ) +
  scale_fill_gradient(
    low = "tomato",
    high = "green3"
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
    low = "tomato",
    high = "green3"
  ) +
  # ggnewscale::new_scale_fill() +
  # geom_tile(
  #   data = plot$data[1:length(tree$tip.label), ],
  #   aes(x = x+4, y = y, fill = as.factor(salinity)),
  #   inherit.aes = FALSE,
  #   color = "transparent",
  #   width = 3
  # ) +
  # scale_fill_manual(
  #   values = c(
  #     "freshwater" = "steelblue",
  #     "saltwater" = "aquamarine"
  #   ),
  #   na.value = "grey90"
  # ) +
  # geom_tile(
  #   data = plot$data[1:length(tree$tip.label), ],
  #   aes(x = x+6, y = y, fill = seasonal_spawning),
  #   inherit.aes = FALSE,
  #   color = "transparent",
  #   width = 3
  # ) +
  # scale_fill_gradient(
  #   low = "tomato",
  #   high = "green3",
  #   na.value = "white"
  # ) +
  # geom_tiplab(aes(color = Order), size = 2, offset = 6, show.legend = FALSE) +
  # add invisible points just for legend
  # geom_point(aes(x = 0, y = 0, color = Order), shape = 15, size = 4, alpha = 0) +
  # scale_color_manual(values = order_colors, guide = guide_legend(override.aes = list(alpha = 1))) 
  geom_tiplab(aes(color = "black"), size = 2, offset = 6, show.legend = FALSE)
plot



