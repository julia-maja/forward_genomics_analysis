
import pandas as pd
import argparse
from pathlib import Path

# --------------------------------------------------
# 1. Define command-line arguments
# --------------------------------------------------

parser = argparse.ArgumentParser(
    description="Update gene matrix using TOGA2 loss summaries."
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


# --------------------------------------------------
# 3. Iterate through each species
# --------------------------------------------------

for species in matrix.columns:

    print(f"Processing {species}...")

    # Scan ALL genes in the matrix
    all_genes = matrix.index.tolist()

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

    loss_summary = pd.read_csv(
        species_folder / "loss_summary.tsv",
        sep="\t"
    )

    loss_dict = dict(zip(
        loss_summary[gene_column],
        loss_summary[status_column]
    ))

    # --------------------------------------------------
    # 6. Update matrix based on loss status
    # --------------------------------------------------

    updated_count = 0

    for gene in all_genes:

        loss_status = loss_dict.get(gene)

        if loss_status == "M":
            matrix.loc[gene, species] = pd.NA
            updated_count += 1

    print(f"  Updated {updated_count} genes")


# --------------------------------------------------
# 7. Save updated matrix
# --------------------------------------------------

matrix.to_csv(output_file, sep="\t", na_rep="NA")

print("\nDone!")
print(f"Updated matrix saved to: {output_file}")

