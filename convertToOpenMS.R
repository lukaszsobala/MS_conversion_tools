#!/usr/bin/env Rscript

# Load the required library
library(MALDIquant)
library(MALDIquantForeign)

# Get command-line arguments; the first argument should be the folder path
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop(paste(
    "Usage: Rscript convertToOpenMS.R <input_path> [output_directory]",
    "",
    "<input_path>: Path to a Bruker Flex directory or an mzXML file.",
    "[output_directory]: (Optional) Directory to save the output files. Defaults to current working directory.",
    sep = "\n"
  ))
}

# Directory containing Bruker Flex data or mzXML file
input_dir <- args[1]

# Check if the input is an mzXML file
if (tolower(substr(input_dir, nchar(input_dir) - 5, nchar(input_dir))) == ".mzxml") { # nolint: line_length_linter.
  # Import the spectra from the mzXML file using importMzXml()
  spectra <- importMzXml(input_dir)
  cat("Imported mzXML file:", input_dir, "\n")
} else {
  # Import the spectra from the Bruker Flex directory using importBrukerFlex()
  spectra <- importBrukerFlex(input_dir)
  cat("Imported Bruker Flex directory:", input_dir, "\n")
}

# Set output directory - use second argument if provided,
# otherwise current working directory
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
