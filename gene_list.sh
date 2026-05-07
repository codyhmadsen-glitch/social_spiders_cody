#!/bin/bash
#SBATCH --job-name=gene_lists
#SBATCH --output=gene_lists.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --account=spider2


ORTHO="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/OrthoFinder/Results_Mar02/Orthogroups/Orthogroups.tsv"
TARGETS="target_orthogroups.txt"
OUTDIR="orthogroup_lists"

mkdir -p $OUTDIR

# Loop over target orthogroups
while read OG; do
    # find linjen i Orthogroups.tsv
    grep "^${OG}" "$ORTHO" | \
    cut -f2- | \
    tr '\t' '\n' | \
    tr ',' '\n' | \
    sed '/^$/d' \
    > "$OUTDIR/${OG}.txt"

done < "$TARGETS"