#!/bin/bash

INPUT="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/changes_and_stars/socials_3.tsv"
OUT="target_orthogroups.txt"

# Find kolonnen med FamilyID og print den (uden header)
awk -F'\t' '
NR==1 {
    for (i=1; i<=NF; i++) {
        if ($i=="FamilyID") col=i
    }
}
NR>1 {
    print $col
}
' "$INPUT" > "$OUT"