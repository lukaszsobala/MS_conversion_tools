#!/usr/bin/env Rscript

# Load the required libraries
library(MALDIquant)
library(MALDIquantForeign)

# Function to anonymize a file based on its format
anonymize_file <- function(input_file, anonymous_name) {
  # Read the file content
  file_content <- readLines(input_file, warn = FALSE)
  file_text <- paste(file_content, collapse = "\n")
  
  # Determine file type and apply appropriate anonymization
  if (grepl("<mzXML", file_text)) {
    # mzXML: Replace fileName attribute
    file_text <- gsub('fileName="[^"]*"', paste0('fileName="', anonymous_name, '"'), file_text)
  } else if (grepl("<mSD", file_text)) {
    # mSD: Replace title content
    file_text <- gsub('<title>[^<]*</title>', paste0('<title>', anonymous_name, '</title>'), file_text)
  } else if (grepl("<mzML", file_text)) {
    # mzML: Replace id attribute within mzML tag, location, and spotID
    file_text <- gsub('(<mzML[^>]*id=)"[^"]*"', paste0('\\1"', anonymous_name, '"'), file_text)
    file_text <- gsub(' location="[^"]*"', paste0(' location="', anonymous_name, '"'), file_text)
    file_text <- gsub('spotID="[^"]*"', paste0('spotID="', anonymous_name, '"'), file_text)
  } else {
    cat("Warning: Unknown file format for anonymization:", input_file, "\n")
    return(FALSE)
  }
  
  # Write the anonymized content back to the file
  writeLines(strsplit(file_text, "\n")[[1]], input_file)
  return(TRUE)
}

# Function to anonymize all files in a directory with specific extensions
anonymize_directory <- function(output_dir, anonymous_name) {
  # Find all msd, mzML files in the output directory
  msd_files <- list.files(output_dir, pattern = "\\.msd$", full.names = TRUE, recursive = TRUE)
  mzml_files <- list.files(output_dir, pattern = "\\.mzML$", full.names = TRUE, recursive = TRUE)
  
  all_files <- c(msd_files, mzml_files)
  
  if (length(all_files) > 0) {
    cat("Anonymizing", length(all_files), "output files...\n")
    for (file in all_files) {
      if (anonymize_file(file, anonymous_name)) {
        cat("Anonymized:", basename(file), "\n")
      }
    }
  }
}

# Get command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript convertMS.R /path/to/input [output_directory] [anonymous_name]")
}

# Parse arguments
input_path <- args[1]
output_dir <- if (length(args) >= 2) args[2] else getwd()
anonymous_name <- if (length(args) >= 3) args[3] else "anonymous_sample"

cat("=== Mass Spectrometry Conversion and Anonymization Tool ===\n")
cat("Input:", input_path, "\n")
cat("Output directory:", output_dir, "\n")
cat("Anonymous name:", anonymous_name, "\n\n")

# Check if the input is an mzXML file
if (tolower(substr(input_path, nchar(input_path) - 5, nchar(input_path))) == ".mzxml") {
  # Import the spectra from the mzXML file using importMzXml()
  cat("Importing mzXML file:", input_path, "\n")
  spectra <- importMzXml(input_path)
} else {
  # Import the spectra from the Bruker Flex directory using importBrukerFlex()
  cat("Importing Bruker Flex directory:", input_path, "\n")
  spectra <- importBrukerFlex(input_path)
}

# Create output directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  cat("Created output directory:", output_dir, "\n")
}

# Export the spectra in msd format
cat("Exporting to msd format...\n")
exportMsd(spectra, file = output_dir)
cat("Data exported to", output_dir, "in msd format\n")

# Export the spectra in mzML format
cat("Exporting to mzML format...\n")
exportMzMl(spectra, file = output_dir)
cat("Data exported to", output_dir, "in mzML format\n")

# Anonymize the output files
cat("\n=== Anonymization Phase ===\n")
anonymize_directory(output_dir, anonymous_name)

cat("\n=== Conversion and Anonymization Complete ===\n")
cat("All files have been converted and anonymized in:", output_dir, "\n")
