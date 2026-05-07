#!/bin/bash
#SBATCH --job-name=ortho
#SBATCH --output=orthofinder_%j.out
#SBATCH --error=error_%j.txt
#SBATCH --time=10:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --account=spider2

protein_path="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/data/protein_sequences"

orthofinder -f "$protein_path" -S diamond -t 16 -a 16