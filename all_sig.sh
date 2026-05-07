#!/bin/bash
#SBATCH --job-name=add_stars
#SBATCH --output=add_stars.out
#SBATCH --error=add_stars.err
#SBATCH --time=00:15:00
#SBATCH --cpus-per-task=1
#SBATCH --account=spider2

#output: all_bases_sig.tsv

python3 stars.py all_bases.tsv