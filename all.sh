#!/bin/bash
#SBATCH --job-name=basechange_matrix
#SBATCH --output=all_bases.out
#SBATCH --error=all_bases.err
#SBATCH --time=00:15:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --account=spider2


INPUT="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/results_CAFE/Base_change.tab"
OUTPUT="Base_change_signs.tsv"

awk 'BEGIN {FS=OFS="\t"}
NR==1 {print; next}  # Bevar headeren uændret
{
    # Behold første kolonne uændret
    first = $1
    for (i=2; i<=NF; i++) {
        if ($i > 0) {
            $i = "+"
        } else if ($i < 0) {
            $i = "-"
        } else {
            $i = ""
        }
    }
    print first, $2, $3, $4, $5, $6, $7, $8, $9, $10  # Tilpas efter antal kolonner
}' "$INPUT" > "$OUTPUT"

echo "Færdig! Første kolonne er bevaret, resten konverteret til +/−/tom"