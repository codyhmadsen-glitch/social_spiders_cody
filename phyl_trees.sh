#!/bin/bash
#SBATCH --job-name=phyl_trees
#SBATCH --output=phyl_trees.out
#SBATCH --error=phyl_trees.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --account=spider2

#conda activate pyt

Rscript phyl_trees.R