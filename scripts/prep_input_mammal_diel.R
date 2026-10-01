
#prep forward genomic input data for mammal diel data

# read in mammal diel data that overlaps with TOGA2 output
diel_data <- read.csv("~/Desktop/artiodactyla_activity_patterns.csv")
diel_data <- diel_data %>% mutate(species = str_replace_all(species, " ", "_"))

## diurnal as the focal phenotype
diurnality_data <- diel_data %>% mutate(pheno = ifelse(grepl("diurnal", diel), 1, 0))
diurnality_data <- diurnality_data %>% select(species, pheno)

## nocturnal as the focal phenotype
nocturnality_data <- diel_data %>% mutate(pheno = ifelse(grepl("nocturnal", diel), 1, 0))
nocturnality_data <- nocturnality_data %>% select(species, pheno)

## crepuscular as the focal phenotype
crepuscularity_data <- diel_data %>% mutate(pheno = ifelse(grepl("crepuscular", diel), 1, 0))
crepuscularity_data <- crepuscularity_data %>% select(species, pheno)

write.table(diurnality_data, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/mammal_diel/diurn_species.csv", sep = " ", row.names = FALSE, quote = FALSE)
write.table(nocturnality_data, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/mammal_diel/nocturn_species.csv", sep = " ", row.names = FALSE, quote = FALSE)
write.table(crepuscularity_data, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/mammal_diel/nocturn_species.csv", sep = " ", row.names = FALSE, quote = FALSE)


