#!/bin/bash
#SBATCH --job-name=agat
#SBATCH --output=output_%j.txt
#SBATCH --error=error_%j.txt
#SBATCH --time=08:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1
#SBATCH --account=spider2

#finding data folder:
genome_path="/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/data"

#for loop for all species:
for gff in "$genome_path"/*_lifted.gff3 #gff for each file with this directory.
do
    base=$(basename "$gff" _lifted.gff3) #takes out species name.
    genome="$genome_path/${base}_ncbi_chromosome.fa" #directory to each FASTA file.

    agat_sp_extract_sequences.pl --gff "$gff" --fasta "$genome" --protein --type cds --output ${base}_proteins.fa #output file name depends on base (species name)
done