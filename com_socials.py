#!/usr/bin/env python3
import csv

# --- Konfigurer arter ---
social_arter = ["DUM_proteins<2>", "MIM_proteins<7>", "SARA_proteins<5>"]
subsocial_arter = ["LIN_proteins<1>", "TENT_proteins<3>", "BI_proteins<4>", "AFR_proteins<6>"]

input_file = "all_bases_sig.tsv"
output_file = "socials_3.tsv"

with open(input_file) as fin, open(output_file, "w", newline="") as fout:
    reader = csv.DictReader(fin, delimiter="\t")
    writer = csv.DictWriter(fout, fieldnames=reader.fieldnames, delimiter="\t")
    writer.writeheader()

    for row in reader:
        # --- Sociale arter ---
        social_vals = [row[a].strip() for a in social_arter if a in row]
        # Kun værdier med signifikans (*)
        social_vals_sig = [v for v in social_vals if "*" in v]

        if len(social_vals_sig) < 2:
            continue  # Mindst 2 sociale arter med signifikant ændring

        # Find flertal i retning (+ eller -)
        plus_count = sum(1 for v in social_vals_sig if v.startswith("+"))
        minus_count = sum(1 for v in social_vals_sig if v.startswith("-"))

        if plus_count >= 3:
        #if plus_count >= 2:
            social_direction = "+"
        elif minus_count >= 3:
        #elif minus_count >= 2:
            social_direction = "-"
        else:
            continue  # Ingen klar flertal

        # --- Subsocial arter ---
        subsocial_vals = [row[a].strip() for a in subsocial_arter if a in row]
        subsocial_vals_sig = [v for v in subsocial_vals if v.startswith(social_direction) and "*" in v]

        # Max 1 subsocial art i samme retning
        if len(subsocial_vals_sig) <= 1:
            writer.writerow(row)

print(f"Done! Filtered genfamilier gemt i {output_file}")