#!/usr/bin/env Rscript

# Load the required library
library(MALDIquantForeign)

# Get command-line arguments; the first argument should be the folder path
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript convertBrukerFlex.R /path/to/BrukerFlexDirectory [output_directory]")
}

# Directory containing Bruker Flex data
input_dir <- args[1]

# Import the spectra from the Bruker Flex directory using importBrukerFlex()
spectra <- importBrukerFlex(input_dir)

# Set output directory - use second argument if provided, otherwise current working directory
output_dir <- if (length(args) >= 2) args[2] else getwd()
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Export the spectra in msd format
exportMsd(spectra, file = output_dir)
cat("Data exported to", output_dir, "in msd format\n")

# Export the spectra in mzML format
exportMzMl(spectra, file = output_dir)
cat("Data exported to", output_dir, "in mzML format\n")
