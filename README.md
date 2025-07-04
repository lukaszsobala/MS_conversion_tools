# MS Conversion Tools

This repository provides tools for converting mass spectrometry data between different formats using R and shell scripts.

## Script: `convertToOpenMS.R`

A script to convert Bruker Flex directories or mzXML files to both MSD and mzML formats using the `MALDIquant` and `MALDIquantForeign` R packages.

### Usage

```sh
Rscript convertToOpenMS.R <input_path> [output_directory]
```

- `<input_path>`: Path to a Bruker Flex directory **or** an mzXML file.
- `[output_directory]` (optional): Directory to save the output files. Defaults to the current working directory if not specified.

### Example

Convert a Bruker Flex directory (only MS1, fragmentation spectra will **not** work):

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
BiocManager::install(c("MALDIquant", "MALDIquantForeign"))
```

---

## Other Files

- `simple_anonymize.sh`: Shell script for anonymizing data (see script for details).

Usage: `./simple_anonymize.sh input_file [anonymous_name]`. It works with msd, mzML and mzXML files and clears all identifiable info that is usually present in the files.

---

For questions or issues, please contact me at lukasz.sobala@hirszfeld.pl, or submit an issue.
The scripts were made with the help of LLMs.
