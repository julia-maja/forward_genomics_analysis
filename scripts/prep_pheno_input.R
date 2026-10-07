
#prep forward genomic input data 


#########################
### artio + cetaceans ###
#########################
# read in artio diel data that overlaps with TOGA2 output
artio <- read.csv("~/Desktop/artiodactyla_activity_patterns.csv")
artio <- diel_data %>% mutate(species = str_replace_all(species, " ", "_"))

#########################
### artio - cetateans ###
#########################
artio_nc <- 

###############################
### all mammals - cetateans ###
###############################
mammal_nc <- 

#################
### fish diel ###
#################
# read in fish data 
fish <- readRDS("~/Desktop/trait_data_fish_expanded.RDS")
fish <- fish %>% mutate(species = str_replace_all(species, " ", "_"))


diel_data <- artio #user specifies which dataset
diel_data_name <- "artio"

## diurnal vs all else
diurn_vs_all <- diel_data %>% mutate(pheno = ifelse(grepl("diurnal", diel), 1, 0))
diurn_vs_all <- diurn_vs_all %>% select(species, pheno)

## nocturnal vs all else
nocturn_vs_all <- diel_data %>% mutate(pheno = ifelse(grepl("nocturnal", diel), 1, 0))
nocturn_vs_all <- nocturn_vs_all %>% select(species, pheno)

## crepuscular vs all else
crep_vs_all <- diel_data %>% mutate(pheno = ifelse(grepl("crepuscular", diel), 1, 0))
crep_vs_all <- crep_vs_all %>% select(species, pheno)

## cathemeral vs all else
cathem_vs_all <- diel_data %>% mutate(pheno = ifelse(grepl("cathemeral", diel), 1, 0))
cathem_vs_all <- cathem_vs_all %>% select(species, pheno)

## all else vs cathemeral
all_vs_cathem <- diel_data %>% mutate(pheno = ifelse(!grepl("cathemeral", diel), 1, 0))
all_vs_cathem <- all_vs_cathem %>% select(species, pheno)


# diurnal vs nocturnal
diurn_vs_nocturn <- diel_data %>% filter(diel == "diurnal" | diel == "nocturnal")
diurn_vs_nocturn <- diurn_vs_nocturn %>% mutate(pheno = ifelse(grepl("diurnal", diel), 1, 0))
diurn_vs_nocturn <- diurn_vs_nocturn %>% select(species, pheno)

# nocturnal vs diurnal
nocturn_vs_diurn <- diel_data %>% filter(diel == "diurnal" | diel == "nocturnal")
nocturn_vs_diurn <- nocturn_vs_diurn %>% mutate(pheno = ifelse(grepl("nocturnal", diel), 1, 0))
nocturn_vs_diurn <- nocturn_vs_diurn %>% select(species, pheno)


data_list <- list(diurn_vs_all = diurn_vs_all, 
                  nocturn_vs_all = nocturn_vs_all, 
                  crep_vs_all = crep_vs_all, 
                  cathem_vs_all = cathem_vs_all, 
                  all_vs_cathem = all_vs_cathem,
                  diurn_vs_nocturn = diurn_vs_nocturn, 
                  nocturn_vs_diurn = nocturn_vs_diurn)
data_names <- names(data_list)


for (name in names(data_list)) {
  
  file_path <- file.path(
    "/Users/juliamaja/Desktop/forward_genomics_analysis/input",
    diel_data_name,
    paste0(name, ".txt")
  )
  
  write.table(
    data_list[[name]],
    file_path,
    sep = " ",
    row.names = FALSE,
    quote = FALSE
  )
}


