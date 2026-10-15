library(ape)
tree <- read.tree("tree.nwk")
folders <- list.dirs(".", recursive = FALSE)
for (folder in folders) {
  trait <- basename(folder)
  species_file <- file.path(folder, paste0(trait, "_species.txt"))
  #if (!file.exists(species_file)) next
  source(species_file)
  species_list <- get(paste0(trait, "_species"))
  pruned_tree <- drop.tip(tree, setdiff(tree$tip.label, species_list))
  write.tree(pruned_tree, file.path(folder, "tree.nwk"))
}
