#!/bin/bash
#SBATCH --job-name=cafe_1
#SBATCH --output=cafe_%j.txt
#SBATCH --error=error_%j.txt
#SBATCH --time=08:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1
#SBATCH --account=spider2

#activate cafe environment

cafe5 -i /home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/cafe_input.tsv -t /home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/data/protein_sequences/OrthoFinder/Results_Mar02/Species_Tree/SpeciesTree_rooted.txt