# MS Conversion Tools

This repository provides tools for converting mass spectrometry data between different formats using R and shell scripts.

## Script: `convertToOpenMS.R`

A script to convert Bruker Flex directories or mzXML files to both MSD and mzML formats using the MALDIquant and MALDIquantForeign R packages.

### Usage

```sh
Rscript convertToOpenMS.R <input_path> [output_directory]
```

- `<input_path>`: Path to a Bruker Flex directory **or** an mzXML file.
- `[output_directory]` (optional): Directory to save the output files. Defaults to the current working directory if not specified.

### Example

Convert a Bruker Flex directory:

```sh
Rscript convertToOpenMS.R /path/to/BrukerFlexDirectory /path/to/output
```

Convert an mzXML file:

```sh
Rscript convertToOpenMS.R /path/to/file.mzXML /path/to/output
```

### Output

- The script will export the spectra in both MSD and mzML formats to the specified output directory.

### Requirements

- R (>= 3.0)
- R packages: `MALDIquant`, `MALDIquantForeign`

Install required R packages:

```r
install.packages(c("MALDIquant", "MALDIquantForeign"))
```

---

## Other Files

- `simple_anonymize.sh`: Shell script for anonymizing data (see script for details).

---

For questions or issues, please contact the repository maintainer.
