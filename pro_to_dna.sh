#!/bin/bash
#SBATCH --job-name=agat_subset
#SBATCH --output=agat_subset_%j.out
#SBATCH --error=agat_subset_%j.err
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --account=spider2

set -euo pipefail

# --- FORBEREDELSE: aktivér agat environment manuelt i terminal før sbatch ---
# conda activate agat_env

# --- INPUTS ---
GENOME_DIR="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/data/genomes"
GFF_DIR="$GENOME_DIR"
MAP="gene2og.tsv"                 # Din fil med alle gene -> orthogroup mapping
RELEVANT_OG="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/changes_and_stars/socials_3.tsv"      # De 13 genfamilier, header: FamilyID
WORKDIR="agat_work"
OUTDIR="orthogroup_sequences"

mkdir -p "$WORKDIR" "$OUTDIR"

echo "Starting AGAT subset extraction pipeline..."


# --- LOOP OVER FASTA-FILER (én art ad gangen) ---
for GENOME in "$GENOME_DIR"/*_ncbi_chromosome.fa; do
    SPECIES=$(basename "$GENOME" _ncbi_chromosome.fa)
    GFF="$GFF_DIR/${SPECIES}_lifted.gff3"

    echo "--------------------------------------------"
    echo "Processing species: $SPECIES"
    echo "GFF: $GFF"
    echo "FASTA: $GENOME"

    # --- Tjek filer ---
    [ ! -f "$GFF" ] && echo "ERROR: GFF missing for $SPECIES" && continue
    [ ! -f "$GENOME" ] && echo "ERROR: FASTA missing for $SPECIES" && continue

    mkdir -p "$WORKDIR/$SPECIES"

    # --- STEP 1: lav liste over alle gener i de 13 orthogroups ---
    awk 'NR>1{print $1}' "$RELEVANT_OG" > "$WORKDIR/$SPECIES/relevant_ogs.txt"

    awk -v OFS="\t" 'NR==FNR{ogs[$1]; next} ($2 in ogs){print $1}' \
        "$WORKDIR/$SPECIES/relevant_ogs.txt" "$MAP" > "$WORKDIR/$SPECIES/relevant_genes.txt"

    IDCOUNT=$(wc -l < "$WORKDIR/$SPECIES/relevant_genes.txt")
    echo "Number of gene IDs for $SPECIES: $IDCOUNT"
    [ "$IDCOUNT" -eq 0 ] && echo "No relevant genes, skipping..." && continue

    # --- STEP 2: subset GFF kun for relevante gener ---
    SUBSET_GFF="$WORKDIR/$SPECIES/${SPECIES}_subset.gff3"

    agat_sp_filter_feature_from_keep_list.pl \
    --gff "$GFF" \
    --keep_list "$WORKDIR/$SPECIES/relevant_genes.txt" \
    --output "$SUBSET_GFF"

    # --- STEP 2b: fix index / index.pag problem for AGAT ---
# --- LAV INDEX HVIS DEN IKKE FINDES ---
    if [[ ! -f "${GENOME}.index" || ! -f "${GENOME}.index.pag" ]]; then
        echo "Index missing or incomplete for $SPECIES → creating index..."
        # output til /dev/null, vi vil kun lave index
        agat_sp_extract_sequences.pl \
            --f "$GENOME" \
            --g "$GFF"\
            --type cds \
            --output /dev/null
        echo "Index created for $SPECIES"
    fi

    # --- STEP 3: ekstrakt CDS med AGAT ---
    SUBSET_FA="$WORKDIR/$SPECIES/${SPECIES}_subset.fa"

    agat_sp_extract_sequences.pl \
        --gff "$SUBSET_GFF" \
        --fasta "$GENOME" \
        --type cds \
        --output "$SUBSET_FA"

    # --- STEP 4: split til orthogroups og tilføj OG i header ---
    awk -v mapfile="$MAP" -v outdir="$OUTDIR" '
    BEGIN{
        while((getline<mapfile)>0){ gene2og[$1]=$2 }
    }
    /^>/{
        split($0,a," ")
        gene=a[1]
        sub(/^>/,"",gene)
        og=gene2og[gene]
        if(og!=""){ outfile=outdir"/"og".fa"; print ">"gene"|"og > outfile; next }
        else { outfile="" }
    }
    {
        if(outfile!="") print >> outfile
    }
    ' "$SUBSET_FA"

done

echo "All done!"