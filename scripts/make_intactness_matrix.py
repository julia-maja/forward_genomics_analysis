#!/usr/bin/env python3

import argparse
import csv
import re
from pathlib import Path


def sanitize_id(element_id):
    """
    Make an element ID safe for use as an R variable/name.

    Rules:
    1. Replace anything other than letters, numbers, or underscores with '_'.
    2. If the resulting ID starts with a number, prepend 'x'.
    """
    # Replace invalid characters
    sanitized = re.sub(r"[^A-Za-z0-9_]", "_", element_id)

    # R does not like names beginning with a number
    if sanitized and sanitized[0].isdigit():
        sanitized = "x" + sanitized

    return sanitized


def get_species_name(directory_name):
    """
    Extract species name from a directory name.

    Example:
    Trachurus_trachurus__Atlantic_horse_mackerel__HLFtraTrac1__GCA_905171665.2

    -> Trachurus_trachurus
    """
    return directory_name.split("__")[0]


def process_species(species_dir):
    """Read transcript_meta.tsv and return max intactness per gene."""
    meta_file = species_dir / "meta" / "transcript_meta.tsv"

    if not meta_file.exists():
        print(f"WARNING: Missing {meta_file}")
        return {}

    gene_values = {}

    with open(meta_file, "r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t")

        required_columns = {
            "projection",
            "longest_intact_fraction"
        }

        missing = required_columns - set(reader.fieldnames or [])

        if missing:
            raise ValueError(
                f"{meta_file} is missing required columns: "
                + ", ".join(sorted(missing))
            )

        for row in reader:
            projection = row["projection"]
            value = row["longest_intact_fraction"]

            if not projection or value in ("", None):
                continue

            # Expected format:
            # transcript#gene#chain
            parts = projection.split("#")

            if len(parts) < 2:
                print(
                    f"WARNING: Could not parse projection '{projection}' "
                    f"in {meta_file}"
                )
                continue

            gene = parts[1]

            try:
                intactness = float(value)
            except ValueError:
                print(
                    f"WARNING: Invalid intactness value '{value}' "
                    f"for {projection} in {meta_file}"
                )
                continue

            # Keep the highest value for each gene
            if gene not in gene_values or intactness > gene_values[gene]:
                gene_values[gene] = intactness

    return gene_values


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Create a species x element matrix of maximum "
            "longest_intact_fraction values."
        )
    )

    parser.add_argument(
        "input_directory",
        type=Path,
        help="Directory containing the species subdirectories",
    )

    parser.add_argument(
        "-o",
        "--output-prefix",
        type=str,
        default="intactness",
        help="Output file prefix (default: intactness)",
    )

    args = parser.parse_args()

    input_dir = args.input_directory

    if not input_dir.is_dir():
        raise SystemExit(f"ERROR: Not a directory: {input_dir}")

    # Find species directories
    species_dirs = sorted(
        d for d in input_dir.iterdir()
        if d.is_dir()
    )

    if not species_dirs:
        raise SystemExit(
            f"ERROR: No species subdirectories found in {input_dir}"
        )

    species_data = {}
    all_genes = set()

    print(f"Found {len(species_dirs)} species directories.")

    for species_dir in species_dirs:
        species = get_species_name(species_dir.name)

        print(f"Processing: {species}")

        gene_values = process_species(species_dir)

        species_data[species] = gene_values
        all_genes.update(gene_values.keys())

        print(f"  Found {len(gene_values)} genes")

    # Sort genes for reproducibility
    genes = sorted(all_genes)

    # ------------------------------------------------------------
    # Sanitize element IDs
    # ------------------------------------------------------------

    sanitized_to_original = {}

    for gene in genes:
        sanitized = sanitize_id(gene)

        # Detect collisions caused by sanitization.
        if sanitized in sanitized_to_original:
            previous = sanitized_to_original[sanitized]

            if previous != gene:
                raise SystemExit(
                    "ERROR: Two different element IDs become identical "
                    "after sanitization:\n"
                    f"  {previous} -> {sanitized}\n"
                    f"  {gene} -> {sanitized}\n"
                    "Please resolve this ambiguity before creating "
                    "the matrix."
                )

        sanitized_to_original[sanitized] = gene

    # ------------------------------------------------------------
    # Output filenames
    # ------------------------------------------------------------

    matrix_file = Path(
        f"{args.output_prefix}_matrix.tsv"
    )

    element_file = Path(
        f"{args.output_prefix}_element_ids.tsv"
    )

    # ------------------------------------------------------------
    # Write matrix
    # ------------------------------------------------------------

    with open(
        matrix_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as f:

        writer = csv.writer(
            f,
            delimiter="\t",
            lineterminator="\n"
        )

        # Header
        writer.writerow(
            ["element"] + list(species_data.keys())
        )

        # Rows
        for gene in genes:

            row = [sanitize_id(gene)]

            for species in species_data:

                value = species_data[species].get(gene)

                if value is None:
                    row.append("NA")
                else:
                    row.append(value)

            writer.writerow(row)

    # ------------------------------------------------------------
    # Write element ID file
    # ------------------------------------------------------------

    with open(
        element_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as f:

        writer = csv.writer(
            f,
            delimiter="\t",
            lineterminator="\n"
        )

        for gene in genes:
            writer.writerow([sanitize_id(gene)])

    print()
    print("Done.")
    print(f"Matrix:     {matrix_file}")
    print(f"Element ID: {element_file}")
    print(f"Elements:   {len(genes)}")
    print(f"Species:    {len(species_data)}")


if __name__ == "__main__":
    main()

