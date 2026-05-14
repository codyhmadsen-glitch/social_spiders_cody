# social_spiders_cody
Scripts and run order for my bachelor's project in social spiders

Run order:

agat.sh
- Translating genes in genome into proteins

ortho.sh
- Using proteins to find orthogroups

cafe.sh
- Comparing gene counts (output from Orthofinder, after being made cafe-safe (Desc header with “null” values, orthogroup_to_cafe.sh)) to tree file SpeciesTree_rooted.txt (from Orthofinder)

all.sh 
- Reading values in Bange_change.tab (output from cafe) and changing them to + when positive (expanded), - when negative (contracted) and removing 0’s (no changes)

all_sig.sh (stars.py)
- Adding stars to significant changes from cafe-output Base_asr.tre using python script

compare.sh (com_socials.py)
- Filtering gene families (orthogroups) by number of socials vs subsocials with significant change (all socials and max 1 subsocial) using python script → socials_3.tsv

list.sh
- Making a list of orthogroup names from socials_3.tsv → target_orthogroups.txt

gene_list.sh 
- Making a list of orthogroup names and annotations of genes (from provided .gff3 files) of all orthogroups → orthogroup_lists.txt

make_gene2og.sh
- Taking the targeted orthogroups from target_orthogroups.txt and finds them in orthogroups.tsv (from orthofinder) and makes an input file for AGAT → gene2og.tsv

pro_to_dna.sh
- Finding coding DNA sequences (CDS) for each gene in each orthogroup using AGAT → agat_work (relevant outputs in folder)

macse_prep_socials.sh
- Creating a fasta file for each orthogroup, with all DNA sequences for each gene in each social species → orthogroup_fastas (folder)

macse_expanded.sh 
- Making a separate folder with only expanded orthogroups from orthogroups_fastas in only social species (orthogroups_fastas_expanded). Aligning genes in each orthogroup of only one species IF there is more than one gene in that gene family → macse_alignments_species (folder)

iqtree.sh
- Taking the alignments from macse_alignments_species and creating Newick trees with branch lengths.

log_raw_plots.sh (log_raw_plots.R)
- Plotting distributions of terminal branch lengths of all three social species in facet plots using ape in R.

phyl_trees.sh (phyl_trees.R)
- Takes orthogroup Newick trees of each species and makes PDFs of each gene family with phylogenetic trees of each species next to one another.
