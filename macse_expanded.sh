#!/bin/bash
#SBATCH --job-name=macse_expanded
#SBATCH --output=macse_%A_%a.out
#SBATCH --error=macse_%A_%a.err
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --array=1-8   # justér efter behov
#SBATCH --account=spider2

# ------------------------------
#   0.  GÅ TIL SUBMIT-DIR
# ------------------------------
cd "$SLURM_SUBMIT_DIR"

# ------------------------------
#   1.  INPUT & OUTPUT
# ------------------------------
INDIR="orthogroup_fastas_expanded"             # dine orthogroup-filer
SPLITDIR="orthogroups_by_species_min2"         # mellem-output
ALIGNDIR="macse_alignments_species"            # endeligt alignment-output

mkdir -p "$SPLITDIR"
mkdir -p "$ALIGNDIR"

# ------------------------------
#   2.  FIND DEN ORTHOGROUP DER HØRER TIL ARRAY-ID
# ------------------------------
FILE=$(ls "$INDIR"/*.fa | sed -n "${SLURM_ARRAY_TASK_ID}p")

if [[ -z "$FILE" ]]; then
    echo "[SLURM $SLURM_ARRAY_TASK_ID] Ingen orthogroup – stopper."
    exit 0
fi

OG=$(basename "$FILE" .fa)
OGDIR="$SPLITDIR/$OG"
mkdir -p "$OGDIR"

echo "[INFO] Bearbejder orthogroup: $OG"

# ------------------------------
#   3.  SPLIT TIL ART-FILER (kun ≥2 gener)
# ------------------------------

declare -A count

# Første pass: tæl gener per art
while read -r line; do
    if [[ "$line" =~ ^\> ]]; then
        h="${line:1}"
        species="${h%%.*}"
        count["$species"]=$(( count["$species"] + 1 ))
    fi
done < "$FILE"

# Skriv counts til rigtig temp-fil
TMP_COUNTS="$OGDIR/counts.tmp"
rm -f "$TMP_COUNTS"
for sp in "${!count[@]}"; do
    echo "$sp ${count[$sp]}" >> "$TMP_COUNTS"
done

# Andet pass: skriv fasta'er kun for arter med ≥2 gener
awk -v ogdir="$OGDIR" -v cnt="$TMP_COUNTS" '
    BEGIN {
        # importer counts
        while ((getline < cnt) > 0) {
            split($0, a)
            species=a[1]; n=a[2]
            if (n >= 2) keep[species]=1
        }
        close(cnt)
    }

    /^>/ {
        h = substr($0, 2)
        split(h, a, ".")
        species = a[1]
        outfile = ogdir "/" species ".fa"
    }

    {
        if (species in keep)
            print >> outfile
    }
' "$FILE"


# ------------------------------
#   4.  MACSE ALIGNMENT AF ALLE ART-FILER
# ------------------------------
for species_file in "$OGDIR"/*.fa; do
    [[ -e "$species_file" ]] || continue

    SPECIES=$(basename "$species_file" .fa)

    echo "[INFO] MACSE: $OG / $SPECIES"

    macse \
        -prog alignSequences \
        -seq "$species_file" \
        -out_NT "${ALIGNDIR}/${OG}_${SPECIES}_NT.aln.fa" \
        -out_AA "${ALIGNDIR}/${OG}_${SPECIES}_AA.aln.fa"
done

echo "[INFO] Færdig med orthogroup $OG"