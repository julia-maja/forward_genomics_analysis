
## preparing input for forward genomics with fish diel data


# phenotype files ---------------------------------------------------------

diel_data <- readRDS("~/Desktop/trait_data_fish_expanded.RDS")
diel_data <- diel_data %>% mutate(species = str_replace_all(species, " ", "_"))

## diurnal as the focal phenotype
diurnality_data <- diel_data %>% select(species, diel)
diurnality_data <- diurnality_data %>% mutate(diel = ifelse(grepl("diurnal", diel), 1, 0))
diurnality_data <- diurnality_data %>% rename(species = species) %>% rename(pheno = diel)

## nocturnal as the focal phenotype
nocturnality_data <- diel_data %>% select(species, diel)
nocturnality_data <- nocturnality_data %>% mutate(diel = ifelse(grepl("nocturnal", diel), 1, 0))
nocturnality_data <- nocturnality_data %>% rename(species = species) %>% rename(pheno = diel)


## crepuscular as the focal phenotype
crepuscularity_data <- diel_data %>% select(species, diel)
crepuscularity_data <- crepuscularity_data %>% mutate(diel = ifelse(grepl("crepuscular", diel), 1, 0))
crepuscularity_data <- crepuscularity_data %>% rename(species = species) %>% rename(pheno = diel)


#write.table(diurnality_data, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/fish_diel/diurnality_data.csv", sep = " ", row.names = FALSE, quote = FALSE)
#write.table(nocturnality_data, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/fish_diel/nocturnality_data.csv", sep = " ", row.names = FALSE, quote = FALSE)
#write.table(crepuscularity_data, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/fish_diel/crepuscularity_data.csv", sep = " ", row.names = FALSE, quote = FALSE)


# species overlap with TOGA -----------------------------------------------

# TOGA2 output species ----------------------------------------------------
TOGA2_output <- c("Acanthochromis_polyacanthus",
                 "Amphiprion_ocellaris",
                 "Anabas_testudineus",
                 "Anableps_anableps",
                 "Anisarchus_medius",
                 "Anoplopoma_fimbria",
                 "Antennarius_maculatus",
                 "Anthias_anthias",
                 "Apeltes_quadracus",
                 "Apogon_imberbis",
                 "Archocentrus_centrarchus",
                 "Aulostomus_maculatus",
                 "Bassozetus_sp._2_HX-2024",
                 "Betta_splendens",
                 "Bostrychus_sinensis",
                 "Centropristis_striata",
                 "Cephalopholis_sonnerati",
                 "Chaetodon_auriga",
                 "Chaetodon_trifascialis",
                 "Channa_argus",
                 "Channa_asiatica",
                 "Channa_maculata",
                 "Channa_striata",
                 "Cheilinus_undulatus",
                 "Chelidonichthys_spinosus",
                 "Chelmon_rostratus",
                 "Choerodon_schoenleinii",
                 "Chromidotilapia_guntheri",
                 "Cololabis_saira",
                 "Corythoichthys_intestinalis",
                 "Cottus_gobio",
                 "Cromileptes_altivelis",
                 "Cyclopterus_lumpus",
                 "Cyprinodon_diabolis",
                 "Cyprinodon_nevadensis_mionectes",
                 "Datnioides_polota",
                 "Decapterus_maruadsi",
                 "Doryrhamphus_excisus",
                 "Dunckerocampus_dactyliophorus",
                 "Echeneis_naucrates",
                 "Eleginops_maclovinus",
                 "Eleutheronema_tetradactylum",
                 "Enoplosus_armatus",
                 "Entelurus_aequoreus",
                 "Epinephelus_awoara",
                 "Epinephelus_bruneus",
                 "Epinephelus_cyanopodus",
                 "Epinephelus_fuscoguttatus",
                 "Epinephelus_polyphekadion",
                 "Epinephelus_tukula",
                 "Euthynnus_affinis",
                 "Fistularia_commersonii",
                 "Fundulus_diaphanus",
                 "Gambusia_affinis",
                 "Girardinichthys_multiradiatus",
                 "Gymnocephalus_cernua",
                 "Haplochromis_burtoni",
                 "Hippocampus_abdominalis",
                 "Hippocampus_trimaculatus",
                 "Hippocampus_zosterae",
                 "Hippoglossus_hippoglossus",
                 "Hippoglossus_stenolepis",
                 "Hyperoplus_lanceolatus",
                 "Istiophorus_platypterus",
                 "Katsuwonus_pelamis",
                 "Labeotropheus_trewavasae",
                 "Labroides_dimidiatus",
                 "Labrus_bergylta",
                 "Labrus_mixtus",
                 "Lateolabrax_maculatus",
                 "Lates_calcarifer",
                 "Lepturacanthus_savala",
                 "Limanda_limanda",
                 "Liparis_tanakae",
                 "Lycodopsis_pacificus",
                 "Macropodus_opercularis",
                 "Mastacembelus_armatus",
                 "Melanotaenia_boesemani",
                 "Micropterus_dolomieu",
                 "Mugil_cephalus",
                 "Mullus_barbatus",
                 "Myoxocephalus_scorpius",
                 "Nematolebias_whitei",
                 "Neolamprologus_multifasciatus",
                 "Neostethus_bicornis",
                 "Nerophis_ophidion",
                 "Nothobranchius_furzeri",
                 "Nothobranchius_furzeri",
                 "Notolabrus_celidotus",
                 "Odontamblyopus_lacepedii",
                 "Odontamblyopus_rebecca",
                 "Odontesthes_bonariensis",
                 "Opsanus_beta",
                 "Oxyeleotris_marmorata",
                 "Pampus_argenteus",
                 "Parachromis_managuensis",
                 "Paralichthys_olivaceus",
                 "Parambassis_ranga",
                 "Parupeneus_biaculeatus",
                 "Pelmatolapia_mariae",
                 "Pempheris_schomburgkii",
                 "Periophthalmus_magnuspinnatus",
                 "Petenia_splendida",
                 "Pholidichthys_leucotaenia",
                 "Phycodurus_eques",
                 "Phyllopteryx_taeniolatus",
                 "Platichthys_flesus",
                 "Platichthys_stellatus",
                 "Pleuronectes_platessa",
                 "Poecilia_picta",
                 "Polydactylus_sextarius",
                 "Proterorhinus_semilunaris",
                 "Pseudochaenichthys_georgianus",
                 "Pseudoliparis_swirei",
                 "Pseudopleuronectes_americanus",
                 "Pungitius_pungitius",
                 "Pungitius_sinensis",
                 "Remorina_albescens",
                 "Sander_lucioperca",
                 "Sander_vitreus",
                 "Sarotherodon_galilaeus",
                 "Scomber_japonicus",
                 "Scomber_scombrus",
                 "Scomberomorus_guttatus",
                 "Scophthalmus_maximus",
                 "Sebastes_fasciatus",
                 "Sebastes_mentella",
                 "Sebastes_schlegelii",
                 "Sebastes_umbrosus",
                 "Seriola_aureovittata",
                 "Siniperca_chuatsi",
                 "Siniperca_roulei",
                 "Siniperca_scherzeri",
                 "Solea_senegalensis",
                 "Solea_solea",
                 "Spinachia_spinachia",
                 "Spinachia_spinachia",
                 "Synanceia_verrucosa",
                 "Synchiropus_picturatus",
                 "Synchiropus_splendidus",
                 "Syngnathoides_biaculeatus",
                 "Syngnathus_acus",
                 "Syngnathus_scovelli",
                 "Syngnathus_typhle",
                 "Taurulus_bubalis",
                 "Tautogolabrus_adspersus",
                 "Thalassoma_bifasciatum",
                 "Thunnus_albacares",
                 "Thunnus_maccoyii",
                 "Thunnus_thynnus",
                 "Toxotes_chatareus",
                 "Toxotes_jaculatrix",
                 "Trachinotus_ovatus",
                 "Trachurus_trachurus",
                 "Trichiurus_japonicus",
                 "Valencia_hispanica",
                 "Verasper_variegatus",
                 "Xenentodon_cancila",
                 "Xiphias_gladius",
                 "Xiphophorus_birchmanni",
                 "Xiphophorus_cortezi",
                 "Xiphophorus_couchianus",
                 "Xiphophorus_hellerii",
                 "Xiphophorus_maculatus",
                 "Xiphophorus_malinche",
                 "Xyrichtys_novacula",
                 "Zingel_zingel",
                 "Zoarces_viviparus")


# overlap with TOGA -------------------------------------------------------

diurn_species <- diurnality_data %>% filter(species %in% TOGA2_output) 
nocturn_species <- nocturnality_data %>% filter(species %in% TOGA2_output)
crep_species <- crepuscularity_data %>% filter(species %in% TOGA2_output)

write.table(diurn_species, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/fish_diel/diurn_species.csv", sep = " ", row.names = FALSE, quote = FALSE)
write.table(nocturn_species, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/fish_diel/nocturn_species.csv", sep = " ", row.names = FALSE, quote = FALSE)
write.table(crep_species, "/Users/juliamaja/Desktop/forward_genomics_analysis/input/fish_diel/crep_species.csv", sep = " ", row.names = FALSE, quote = FALSE)


