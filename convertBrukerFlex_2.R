#!/usr/bin/env Rscript

# Load the required library
library(MALDIquantForeign)

# Get command-line arguments; the first argument should be the folder path
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript convertBrukerFlex.R /path/to/BrukerFlexDirectory")
}

# Directory containing Bruker Flex data
input_dir <- args[1]

# Import the spectra from the Bruker Flex directory using importBrukerFlex()
spectra <- importBrukerFlex(input_dir)

# Create output directory if it doesn't exist
output_dir <- "output"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Export the spectra in msd format
exportMsd(spectra, file = output_dir)
cat("Data exported to", output_dir, "in msd format\n")

# Export the spectra in mzML format
exportMzMl(spectra, file = output_dir)
cat("Data exported to", output_dir, "in mzML format\n")
