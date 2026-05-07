#!/bin/bash
#SBATCH --job-name=gene2og
#SBATCH --output=gene2og.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --account=spider2

ORTHO="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/OrthoFinder/Results_Mar02/Orthogroups/Orthogroups.tsv"
TARGETS="target_orthogroups.txt"  # liste med FamilyIDs

OUT="gene2og.tsv"

awk -F'\t' '
NR==FNR {target[$1]; next}
FNR==1 {next}
($1 in target){
    og=$1
    for(i=2;i<=NF;i++){
        n=split($i,a,",")
        for(j=1;j<=n;j++){
            if(a[j]!=""){
                print a[j]"\t"og
            }
        }
    }
}
' "$TARGETS" "$ORTHO" > "$OUT"