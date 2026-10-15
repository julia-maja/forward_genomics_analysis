# make artio no cetaceans dataset

artio <- read.csv("input/artio/artiodactyla_activity_patterns.csv")
mam_nc <- readRDS("input/mam_nc/mammal_activity_patterns_no_cetaceans.rds")


artio_nc <- left_join(artio, mam_nc, by = "species")
artio_nc <- (artio_nc %>% filter(species %in% intersect(artio$species, mam_nc$species))
             %>% rename(diel = diel.x)
             %>% select(species, diel)
             )
write.csv(artio_nc, "input/artio_nc/artiodactyla_no_cetaceans_activity_patterns.csv")

# check:
cetaceans <- setdiff(artio$species, mam_nc$species)
