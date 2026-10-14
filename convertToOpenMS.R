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
    "[output_directory]: (Optional) Directory to save the output files. \
    Defaults to current working directory.",
    sep = "\n"
  ))
}

# Directory containing Bruker Flex data or mzXML file
input_dir <- args[1]

# Read the ion polarity of a Bruker Flex acquisition from its acqu file.
#
# Returns 1 for positive, -1 for negative, NA when it cannot be determined.
#
# '##$POLARI' (0 = negative, 1 = positive) is the field that actually tracks
# the acquisition. It is deliberately preferred over '##.IONIZATION MODE',
# which flexControl writes as 'LD+' unconditionally -- negative-mode runs
# included -- as can be checked against the polarity of the reference masses
# flexControl embeds in '##$CalStar'.
read_flex_polarity <- function(fid_file) {
  acqu_file <- file.path(dirname(fid_file), "acqu")
  if (!file.exists(acqu_file)) {
    return(NA_integer_)
  }

  lines <- readLines(acqu_file, warn = FALSE)
  hits <- grep("^##\\$POLARI=", lines, value = TRUE)
  if (!length(hits)) {
    return(NA_integer_)
  }

  value <- trimws(sub("^##\\$POLARI=", "", hits[1]))
  if (value == "1") {
    1L
  } else if (value == "0") {
    -1L
  } else {
    NA_integer_
  }
}

# Put the true polarity where MALDIquantForeign's exporters look for it.
#
# readBrukerFlexData fills metaData$ionizationMode from '##.IONIZATION MODE'
# and does not expose ##$POLARI at all, so the imported spectra claim to be
# positive. Rewriting both fields from ##$POLARI corrects that at the source.
fix_flex_polarity <- function(spectra) {
  for (i in seq_along(spectra)) {
    fid_file <- metaData(spectra[[i]])$file
    if (is.null(fid_file)) {
      next
    }

    polarity <- read_flex_polarity(fid_file)
    if (is.na(polarity)) {
      warning("Could not read ##$POLARI for ", fid_file,
              "; leaving the polarity as imported.", call. = FALSE)
      next
    }

    metaData(spectra[[i]])$ionizationMode <- if (polarity > 0) "LD+" else "LD-"
    metaData(spectra[[i]])$polarity <-
      if (polarity > 0) "positive" else "negative"
  }

  spectra
}

# Make exportMsd() write the polarity it was given.
#
# MALDIquantForeign:::.writeMsdSpectrum chooses the exported polarity by
# matching its metadata string against the pattern "+|positive". That leading
# '+' quantifies nothing, so TRE matches the empty string and the pattern comes
# out TRUE for every input -- "" and "negative" included. Every .msd it has
# ever written therefore claims polarity="1", whatever the spectrum was.
# Correcting metaData alone cannot help, so the writer is replaced here with a
# copy that tests the metadata literally instead of by regex.
patch_msd_polarity <- function() {
  ns <- asNamespace("MALDIquantForeign")
  if (!exists(".writeMsdSpectrum", envir = ns, inherits = FALSE)) {
    warning("MALDIquantForeign:::.writeMsdSpectrum is gone; the exported ",
            "polarity may be wrong. Check the package version.", call. = FALSE)
    return(invisible(FALSE))
  }

  # the dotted helpers below live in the MALDIquantForeign namespace, which
  # this function is given as its environment just after being defined
  fixed <- function(x, file) { # nolint start: object_usage_linter.
    described <- paste(metaData(x)$ionizationMode, metaData(x)$polarity)
    is_positive <- grepl("positive", described, fixed = TRUE) ||
      grepl("+", described, fixed = TRUE)
    is_negative <- grepl("negative", described, fixed = TRUE) ||
      grepl("-", described, fixed = TRUE)
    polarity <- if (is_positive) "1" else if (is_negative) "-1" else ""

    .writeXmlTag("spectrum",
                 attrs = c(points = length(x),
                           msLevel = ifelse(is.null(metaData(x)$msLevel), 1,
                                            metaData(x)$msLevel),
                           polarity = polarity),
                 close = FALSE, intend = 1, file = file)
    .writeMsdArray(mass(x), name = "mzArray", file = file)
    .writeMsdArray(intensity(x), name = "intArray", file = file)
    .writeCloseXmlTag("spectrum", intend = 1, file = file)
  } # nolint end
  environment(fixed) <- ns

  assignInNamespace(".writeMsdSpectrum", fixed, ns = "MALDIquantForeign")
  invisible(TRUE)
}

patch_msd_polarity()

# Check if the input is an mzXML file
if (tolower(substr(input_dir, nchar(input_dir) - 5, nchar(input_dir))) == ".mzxml") { # nolint: line_length_linter.
  # Import the spectra from the mzXML file using importMzXml()
  # mzXML carries its own polarity attribute, which is read correctly
  spectra <- importMzXml(input_dir)
  cat("Imported mzXML file:", input_dir, "\n")
} else {
  # Import the spectra from the Bruker Flex directory using importBrukerFlex()
  spectra <- importBrukerFlex(input_dir)
  spectra <- fix_flex_polarity(spectra)
  cat("Imported Bruker Flex directory:", input_dir, "\n")
  cat("Ion polarity:",
      paste(unique(vapply(spectra, function(s) {
        mode <- metaData(s)$polarity
        if (is.null(mode)) "unknown" else mode
      }, character(1))), collapse = ", "), "\n")
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
