#!/usr/bin/env python3
"""
Script: stars.py
Formål: Tilføj stjerner i all_bases.tsv baseret på Base_asr.tre
Brug: python3 stars.py all_bases.tsv
Output: all_bases_sig.tsv
"""

import sys
import csv
import re

if len(sys.argv) < 2:
    print("Usage: python3 stars.py <all_bases.tsv>")
    sys.exit(1)

tsv_file = sys.argv[1]
output_file = tsv_file.replace(".tsv", "_sig.tsv")
asr_tree_file = "/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/results_CAFE/Base_asr.tre"

# --- 1. Læs Base_asr.tre og gem signifikante taxa pr. genfamilie ---
fam_to_signif_taxa = dict()

with open(asr_tree_file) as f:
    for line in f:
        line = line.strip()
        if line.startswith("TREE") and "=" in line:
            # Hent GenfamilieID
            parts = line.split("=", 1)
            fam_id = parts[0].split()[1].strip()
            newick = parts[1].strip().rstrip(";")
            
            # Split tokens på komma og parentes
            tokens = re.split(r'[(),]', newick)
            signif_taxa = set()
            for t in tokens:
                t = t.strip()
                if "*" in t:
                    # tag navnet før *
                    taxa_name = t.split("*")[0]
                    # fjern branch length efter kolon, hvis nogen
                    taxa_name = taxa_name.split(":")[0]
                    signif_taxa.add(taxa_name)
            
            fam_to_signif_taxa[fam_id] = signif_taxa

print(f"Loaded {len(fam_to_signif_taxa)} families from Base_asr.tre")

# --- 2. Læs all_bases.tsv og tilføj stjerner ---
with open(tsv_file) as fin, open(output_file, "w", newline="") as fout:
    reader = csv.reader(fin, delimiter="\t")
    writer = csv.writer(fout, delimiter="\t")

    header = next(reader)
    writer.writerow(header)

    for row in reader:
        fam_id = row[0]
        new_row = [fam_id]

        signif_taxa = fam_to_signif_taxa.get(fam_id, set())

        for i, val in enumerate(row[1:], start=1):
            col = header[i]
            # Tilføj stjerne kun hvis taxa/noden er signifikant
            if col in signif_taxa:
                val = val + "*"
            new_row.append(val)
        
        writer.writerow(new_row)

print(f"Done! Output written to {output_file}")