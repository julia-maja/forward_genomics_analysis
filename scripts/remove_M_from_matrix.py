
import pandas as pd
import argparse
from pathlib import Path

# --------------------------------------------------
# 1. Define command-line arguments
# --------------------------------------------------

parser = argparse.ArgumentParser(
    description="Remove genes with M loss status from gene matrix using TOGA2 loss summaries."
)

parser.add_argument(
    "--matrix",
    required=True,
    help="Path to the input gene matrix TSV file"
)

parser.add_argument(
    "--toga",
    required=True,
    help="Path to the directory containing TOGA2_* species folders"
)

parser.add_argument(
    "--output",
    default=None,
    help="Path for the output matrix (optional)"
)

args = parser.parse_args()

matrix_file = Path(args.matrix)
toga_dir = Path(args.toga)

# If no output is specified, create a new filename automatically
if args.output:
    output_file = Path(args.output)
else:
    output_file = matrix_file.with_name(
        matrix_file.stem + "_updated" + matrix_file.suffix
    )

# Column names in loss_summary.tsv
gene_column = "entry"
status_column = "status"


# --------------------------------------------------
# 2. Read the gene matrix
# --------------------------------------------------

matrix = pd.read_csv(
    matrix_file,
    sep="\t",
    index_col=0,
    na_values=["NA"]
)


# Keep track of genes to remove
genes_to_remove = set()


# --------------------------------------------------
# 3. Iterate through each species
# --------------------------------------------------

for species in matrix.columns:

    print(f"Processing {species}...")

    # --------------------------------------------------
    # 4. Find corresponding TOGA2 folder
    # --------------------------------------------------

    matching_folders = [
        folder for folder in toga_dir.iterdir()
        if folder.is_dir() and species in folder.name
    ]

    if not matching_folders:
        print(f"  WARNING: No folder found containing '{species}'")
        continue

    if len(matching_folders) > 1:
        print(f"  WARNING: Multiple folders found for '{species}':")
        for folder in matching_folders:
            print(f"    {folder.name}")
        continue

    species_folder = matching_folders[0]

    # --------------------------------------------------
    # 5. Read loss summary
    # --------------------------------------------------

    loss_file = species_folder / "loss_summary.tsv"

    if not loss_file.exists():
        print(f"  WARNING: No loss_summary.tsv found for {species}")
        continue

    loss_summary = pd.read_csv(loss_file, sep="\t")

    # --------------------------------------------------
    # 6. Check ALL genes for loss status
    # --------------------------------------------------

    loss_dict = dict(zip(
        loss_summary[gene_column],
        loss_summary[status_column]
    ))

    # Identify all genes with M status
    m_genes = {
        gene for gene, status in loss_dict.items()
        if status == "M" and gene in matrix.index
    }

    genes_to_remove.update(m_genes)

    print(f"  Genes with M status: {len(m_genes)}")


# --------------------------------------------------
# 7. Remove genes with M status from the matrix
# --------------------------------------------------

print(f"\nTotal unique genes to remove: {len(genes_to_remove)}")

matrix = matrix.drop(index=list(genes_to_remove))

print(f"Remaining genes: {len(matrix)}")


# --------------------------------------------------
# 8. Save updated matrix
# --------------------------------------------------

matrix.to_csv(output_file, sep="\t", na_rep="NA")

print("\nDone!")
print(f"Updated matrix saved to: {output_file}")

