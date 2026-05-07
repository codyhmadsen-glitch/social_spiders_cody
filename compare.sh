#!/bin/bash
#SBATCH --job-name=comparison
#SBATCH --output=comp_socials.out
#SBATCH --error=comp_socials.err
#SBATCH --time=00:20:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --account=spider2

#Comparing pairs:
## -- Orthogroups expanded in one pair, but not the others)

#Comparing social spiders:
## -- Orthogroups expanded in all ; in some ; in one.<<---

#Comparing subsocial spiders:
## -- Orthogroups expanded in all ; in some ; in one.


#This code compares the genefamilies which has significantly expanded or 
#contracted in social species, but not in sub social species (in less or one sub species).

#output: social_filtered.tsv

python3 com_socials.py all_bases_sig.tsv