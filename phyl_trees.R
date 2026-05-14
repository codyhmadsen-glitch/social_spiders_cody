options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("ape")
library(ape)

tree_dir <- "/home/codymadsen/spider2/faststorage/social_spiders_2020/people/cody/scripts/trees"
output_dir <- "tree_pdfs"

dir.create(output_dir, showWarnings = FALSE)

# Find alle træfiler
files <- list.files(
  tree_dir,
  pattern="\\.treefile$",
  full.names = TRUE
)

# Find unikke orthogroups
ogs <- unique(sub("_.*", "", basename(files)))

for (og in ogs) {

  og_files <- files[grepl(paste0("^", og, "_"), basename(files))]

  n_trees <- length(og_files)

  # Lav PDF
    pdf(file.path(output_dir, paste0(og, ".pdf")),
        width = 12, height = 10)

    # Side-by-side layout
    par(
        mfrow = c(1, n_trees),
        mar = c(2, 1, 4, 1)
    ) 

  for (f in og_files) {

    tree <- read.tree(f)

    fname <- basename(f)

    species <- sub(paste0(og, "_"), "", fname)
    species <- sub("\\..*", "", species)

    plot(
      tree,
      main = species,
      cex = 0.7
    )
  }
    # FÆLLES OVERSKRIFT
    #title(main = og, cex.main = 1.5, line = -0.5)
    mtext(og, outer = TRUE, cex = 1.2, line = -1.5)

  dev.off()

  cat("Saved:", og, "\n")
}