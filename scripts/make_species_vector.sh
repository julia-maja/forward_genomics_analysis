#!/bin/bash
for input_file in ./*.txt; do
    [[ -f "$input_file" ]] || continue
    trait=$(basename "$input_file" .txt)
    mkdir -p "$trait"
    output_file="$trait/${trait}_species.txt"

    {
        printf '%s_species <- c(' "$trait"
        awk 'NR>1 {entry=substr($1,1,length($1)); if(NR>2) printf ", "; printf "\"%s\"", entry} END {print ")"}' "$input_file"
    } > "$output_file"
done

# make pruned trees for each sub-dir:
Rscript ../../../scripts/prune_trees.R

# copy element ID file to each sub-dir:
for dir in */; do (cp element_ids.tsv "$dir") done

# move pheno files to their respective sub_dirs:
for dir in */; do [ -f "${dir%/}.txt" ] && mv "${dir%/}.txt" "$dir"; done
