#!/usr/bin/env python3

import argparse
from pathlib import Path

import pandas as pd


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Create a species x element matrix using the maximum "
            "longest_intact_fraction for each transcriptid#geneid."
        )
    )

    parser.add_argument(
        "input_dir",
        help="Directory containing the species subdirectories"
    )

    parser.add_argument(
        "element_ids",
        help="File containing element IDs, one per line"
    )

    parser.add_argument(
        "output",
        help="Output matrix TSV file"
    )

    args = parser.parse_args()

    input_dir = Path(args.input_dir)
    element_ids_file = Path(args.element_ids)
    output_file = Path(args.output)

    # ------------------------------------------------------------
    # Read element IDs
    # ------------------------------------------------------------

    with open(element_ids_file) as f:
        element_ids = [
            line.strip()
            for line in f
            if line.strip()
        ]

    print(f"Found {len(element_ids)} element IDs")

    # Normalize IDs for matching.
    # For example:
    #   ABC123#GENE1#
    # becomes:
    #   ABC123#GENE1
    normalized_element_ids = {
        element_id.rstrip("#"): element_id
        for element_id in element_ids
    }

    # ------------------------------------------------------------
    # Find species directories
    # ------------------------------------------------------------

    species_dirs = sorted(
        d for d in input_dir.iterdir()
        if d.is_dir()
    )

    print(f"Found {len(species_dirs)} species directories")

    # ------------------------------------------------------------
    # Initialize matrix
    #
    # Rows    = element IDs
    # Columns = species
    # Values  = maximum longest_intact_fraction
    # ------------------------------------------------------------

    matrix = pd.DataFrame(
        index=element_ids,
        columns=[d.name for d in species_dirs],
        dtype=float
    )

    # ------------------------------------------------------------
    # Process each species
    # ------------------------------------------------------------

    for species_dir in species_dirs:

        meta_file = species_dir / "meta" / "transcript_meta.tsv"

        if not meta_file.exists():
            print(
                f"WARNING: transcript_meta.tsv not found for "
                f"{species_dir.name}"
            )
            continue

        print(f"Processing: {species_dir.name}")

        try:
            df = pd.read_csv(
                meta_file,
                sep="\t"
            )
        except Exception as e:
            print(
                f"WARNING: could not read {meta_file}: {e}"
            )
            continue

        # --------------------------------------------------------
        # Check required columns
        # --------------------------------------------------------

        required_columns = {
            "projection",
            "longest_intact_fraction"
        }

        missing_columns = required_columns - set(df.columns)

        if missing_columns:
            print(
                f"WARNING: {meta_file} is missing required "
                f"column(s): {', '.join(sorted(missing_columns))}"
            )
            continue

        # --------------------------------------------------------
        # Extract transcriptid#geneid from projection
        #
        # projection is expected to look like:
        #
        # transcriptid#geneid#chainid
        #
        # We remove the final #chainid.
        #
        # Example:
        #
        # ABC123#GENE1#chain1
        #
        # becomes:
        #
        # ABC123#GENE1
        # --------------------------------------------------------

        df["element_id"] = (
            df["projection"]
            .astype(str)
            .str.rsplit("#", n=1)
            .str[0]
            .str.rstrip("#")
        )

        df["gene_id"] = (
            df["element_id"]
            .str.rsplit("#", n=1)
            .str[1]
        )

        # --------------------------------------------------------
        # Convert longest_intact_fraction to numeric
        # --------------------------------------------------------

        df["longest_intact_fraction"] = pd.to_numeric(
            df["longest_intact_fraction"],
            errors="coerce"
        )

        # --------------------------------------------------------
        # For each transcriptid#geneid, find the maximum
        # longest_intact_fraction across all chains.
        # --------------------------------------------------------

        max_values = (
            df.groupby("gene_id")["longest_intact_fraction"]
            .max()
        )

        # --------------------------------------------------------
        # Add values to the matrix
        # --------------------------------------------------------

        for normalized_id, value in max_values.items():

            if normalized_id in normalized_element_ids:

                original_id = normalized_element_ids[normalized_id]

                matrix.loc[
                    original_id,
                    species_dir.name
                ] = value

    # ------------------------------------------------------------
    # Write output
    # ------------------------------------------------------------

    matrix.index.name = "element"

    matrix.to_csv(
        output_file,
        sep="\t",
        na_rep="NA"
    )

    print()
    print(f"Wrote matrix to: {output_file}")
    print(f"Rows:    {len(matrix)}")
    print(f"Columns: {len(matrix.columns)}")


if __name__ == "__main__":
    main()

