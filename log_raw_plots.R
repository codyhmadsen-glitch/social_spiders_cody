install.packages("ape", repos="http://cran.r-project.org")
library(ape)

args <- commandArgs(trailingOnly=TRUE)
input_dir <- args[1]
output_prefix <- args[2]

files <- list.files(input_dir,
                    pattern="\\.treefile$",
                    full.names=TRUE)

family_ids <- sub("_.*", "", basename(files))
families <- split(files, family_ids)

# <= terminal branches
# > internal branches
get_branches <- function(tree) {
  tree$edge.length[tree$edge[,2] <= Ntip(tree)]
}

make_facet_plot <- function(use_log, outfile) {

  all_values <- c()
  family_data <- list()

  # --------------------------------------------------
  # Read data
  # --------------------------------------------------
  for (fam in names(families)) {

    fam_files <- families[[fam]]
    fam_list <- list()

    for (file in fam_files) {

      tree <- read.tree(file)

      if (is.null(tree$edge.length)) next

      vals <- get_branches(tree)
      vals <- vals[!is.na(vals)]

      if (use_log) {
        vals <- vals[vals > 0]
        vals <- log10(vals)
      }

      if (length(vals) < 2) next

      art_name <- sub("^[^_]+_", "", basename(file))
      art_name <- sub("\\.treefile$", "", art_name)

      fam_list[[art_name]] <- vals
      all_values <- c(all_values, vals)
    }

    if (length(fam_list) >= 2) {
      family_data[[fam]] <- fam_list
    }
  }

  if (length(all_values) < 2) return(NULL)

  # --------------------------------------------------
  # Auto-clipping of outliers
  # --------------------------------------------------
  lower_q <- 0.01
  upper_q <- 0.99

  q <- quantile(all_values,
                probs=c(lower_q, upper_q),
                na.rm=TRUE)

  x_limits <- as.numeric(q)

  breaks <- seq(x_limits[1],
                x_limits[2],
                length.out=40)

  n_fam <- length(family_data)

  # --------------------------------------------------
  # PNG
  # --------------------------------------------------
  png(outfile,
      width=1000,
      height=250 * n_fam)

  par(mfrow=c(n_fam, 1),
      mar=c(2,5,2,2),
      oma=c(4,4,1,1),
      cex.axis=1.3,
      cex.lab=1.4,
      cex.main=2)

  colors <- c(
    adjustcolor("#D55E00", alpha.f=0.5),
    adjustcolor("#009E73", alpha.f=0.5),
    adjustcolor("#0072B2", alpha.f=0.5)
  )

  panel_index <- 1

  # --------------------------------------------------
  # Plot panels
  # --------------------------------------------------
  for (fam in names(family_data)) {

    ymax <- 0
    hist_list <- list()

    # histograms
    for (name in names(family_data[[fam]])) {

      vals <- family_data[[fam]][[name]]

      # clip data
      vals <- vals[
        vals >= x_limits[1] &
        vals <= x_limits[2]
      ]

      if (length(vals) < 2) next
      d <- density(vals,
              from=x_limits[1],
              to=x_limits[2])

      hist_list[[name]] <- d
      ymax <- max(ymax, d$y)

    }

    # empty plot
    plot(NULL,
         xlim=x_limits,
         ylim=c(0, ymax),
         xlab="",
         ylab="",
         main=fam,
         axes=FALSE)

    axis(2)

    # draw distribution curves
    i <- 1

    for (name in names(hist_list)) {

      d <- hist_list[[name]]

      polygon(c(d$x, rev(d$x)),
             c(d$y, rep(0, length(d$y))),
             col=colors[i],
              border=NA)

      lines(d$x,
           d$y,
           col=colors[i],
          lwd=2)

      i <- i + 1
    }

    # legend only on top
    if (panel_index == 1) {

      legend("topright",
             legend=names(hist_list),
             col=colors,
             lwd=2,
             bty="n",
             cex=2)
    }

    box()

    # x-axis only on bottom
    if (panel_index == n_fam) {

      axis(1,
           at=pretty(x_limits))
    }

    panel_index <- panel_index + 1
  }

  # --------------------------------------------------
  # Common labels
  # --------------------------------------------------

  # common y-label
  mtext("Density",
        side=2,
        outer=TRUE,
        line=2.2,
        cex=1.5)

  # common x-label
  if (use_log) {

    mtext("Branch length log10",
          side=1,
          outer=TRUE,
          line=2.2,
          cex=1.5)

  } else {

    mtext("Branch length",
          side=1,
          outer=TRUE,
          line=2.2,
          cex=1.5)
  }

  dev.off()
}

# --------------------------------------------------
# Create both plots
# --------------------------------------------------

make_facet_plot(TRUE,
                paste0(output_prefix, "_log.png"))

make_facet_plot(FALSE,
                paste0(output_prefix, "_raw.png"))