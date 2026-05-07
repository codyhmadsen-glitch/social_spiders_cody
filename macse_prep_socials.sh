#!/bin/bash
#SBATCH --job-name=build_OG_fastas
#SBATCH --output=build_OG_fastas.out
#SBATCH --error=build_OG_fastas.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --account=spider2

# --- PATHS ---
ORTHO_LIST_DIR="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/orthogroup_lists"
FASTA_DIR="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/MACSE/dna_subsets"
OUTDIR="orthogroup_fastas"

mkdir -p "$OUTDIR"

echo "Indlæser alle art-fasta filer..."
declare -A FASTA_FILES

# Define the list of species to process
SPECIES_LIST=("DUM" "SARA" "MIM")

# Find alle <SPECIES>_subset.fa i arbejdsdir for the specified species
 for f in ${FASTA_DIR}/*_subset.fa; do
     species=$(basename "$f" | sed 's/_subset.fa//')
    if [[ " ${SPECIES_LIST[@]} " =~ " $species " ]]; then
        FASTA_FILES[$species]="$f"
        echo "Fundet: $species --> $f"
    fi
 done

echo "Starter behandling af ortogrupper..."

# Loop over alle ortogruppe txt-filer
for ogfile in ${ORTHO_LIST_DIR}/*.txt; do
    og=$(basename "$ogfile" .txt)
    outfile="${OUTDIR}/${og}.fa"

    echo "Behandler $ogfile → $outfile"

    # Tøm outputfil
    > "$outfile"

    # Læs generne i ortogruppen
    while read -r gene; do
        [ -z "$gene" ] && continue  # skip tomme linjer

         # For hvert species: søg efter geneID
        for species in "${SPECIES_LIST[@]}"; do
             fasta="${FASTA_FILES[$species]}"

            # Grep header + sekvens (samlet)
            seq=$(awk -v id="$gene" '
                BEGIN{RS=">"; ORS=""}
                $0 ~ "^"id"[[:space:]]" || $0 ~ "^"id"$" {
                    print ">"$0
                }
            ' "$fasta")

            if [[ ! -z "$seq" ]]; then
                echo "$seq" >> "$outfile"
            fi
        done
    done < "$ogfile"
done

echo "FÆRDIG! Alle ortogruppe FASTA filer findes i: $OUTDIR"