#!/bin/bash
#SBATCH --job-name=forward_genomics
#SBATCH --array=0-6
#SBATCH --time=2-00:00:00
#SBATCH --mem=8G
#SBATCH --output=/home/majaj/projects/def-mshafer/majaj/forward_genomics/logs/job_%A_%a.out
#SBATCH --error=/home/majaj/projects/def-mshafer/majaj/forward_genomics/logs/job_%A_%a.err

module load StdEnv/2023
module load r/4.5.0 
export PATH="/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx512/Core/phast/1.6/bin:$PATH"

base_dir="/home/majaj/projects/def-mshafer/majaj/forward_genomics"
r_script_dir="/home/majaj/projects/def-mshafer/programs/ForwardGenomics/forwardGenomics.R"

#taxa_list=("mam_nc")
trait_list=("nocturn_vs_diurn" "nocturn_vs_all" "diurn_vs_nocturn" "diurn_vs_all" "crep_vs_all" "cathem_vs_all" "all_vs_cathem")

task_id=$SLURM_ARRAY_TASK_ID
#taxa=${taxa_list[$task_id]}
taxa="artio_nc"
trait=${trait_list[$task_id]}

input_dir="$base_dir/input/$taxa/$trait"
output_dir="$base_dir/output/$taxa/$trait"

globalPid="$base_dir/input/matrices/mammal_matrix.tsv"

mkdir -p "$output_dir"

echo "Array task: $SLURM_ARRAY_TASK_ID"
echo "Taxa: $taxa"
echo "Trait: $trait"
echo "Input directory: $input_dir"
echo "Output directory: $output_dir"

cd "$output_dir" || exit 1

Rscript "$r_script_dir" \
    --tree="$input_dir/tree.nwk" \
    --elementIDs="$input_dir/element_ids.tsv" \
    --listPheno="$input_dir/$trait.txt" \
    --globalPid="$globalPid" \
    --method=GLS \
    --outFile="$output_dir/myOutput.txt"
