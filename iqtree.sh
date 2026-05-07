#!/bin/bash
#SBATCH --job-name=phylo_trees
#SBATCH --output=trees_%A_%a.out
#SBATCH --error=trees_%A_%a.err
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --account=spider2
#SBATCH --array=1-24

#conda activate IQtree

FILES=(/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/scripts/macse_alignments_species/*_NT.aln.fa)
FILE=${FILES[$SLURM_ARRAY_TASK_ID-1]}
BASENAME=$(basename "$FILE" _NT.aln.fa)

mkdir -p trees

# job-specifikke filer (VIGTIGT)

TMP="tmp_${SLURM_ARRAY_TASK_ID}.fa"
#TRIM="trimmed_${SLURM_ARRAY_TASK_ID}.fa"

# cleanup + trim

sed 's/!/-/g' "$FILE" > "$TMP"
# clipkit "$TMP" -o "$TRIM" -m kpic -co

# IQ-TREE

# Replace "$TMP" with "$TRIM" if you want to use the trimmed alignments instead
iqtree \
    -s "$TMP" \
    --seqtype CODON \
    -m MFP \
    -B 1000 \
    -T AUTO \
    --prefix trees/"$BASENAME" \
    --redo
