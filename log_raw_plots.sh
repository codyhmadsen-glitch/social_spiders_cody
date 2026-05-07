#!/bin/bash
#SBATCH --job-name=log_raw_plots
#SBATCH --output=log_raw_plots.out
#SBATCH --error=log_raw_plots.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --account=spider2

#module load R

Rscript log_raw_plots.R /home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/scripts/trees/ /home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/output_intermediates/plots/logged_raw_plots