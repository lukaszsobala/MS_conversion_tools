#!/bin/bash

# Simple Mass Spec Anonymization Script
# Usage: ./simple_anonymize.sh input_file [anonymous_name]

INPUT_FILE="$1"
ANONYMOUS_NAME="${2:-anonymous_sample}"

if [[ -z "$INPUT_FILE" ]]; then
    echo "Usage: $0 input_file [anonymous_name]"
    exit 1
fi

OUTPUT_FILE="$ANONYMOUS_NAME.${INPUT_FILE##*.}"

# Check file type and anonymize accordingly
if grep -q "<mzXML" "$INPUT_FILE"; then
    # mzXML: Replace fileName attribute
    sed 's/fileName="[^"]*"/fileName="'"$ANONYMOUS_NAME"'"/g' "$INPUT_FILE" > "$OUTPUT_FILE"
elif grep -q "<mSD" "$INPUT_FILE"; then
    # mSD: Replace title content
    sed 's|<title>[^<]*</title>|<title>'"$ANONYMOUS_NAME"' </title>|g' "$INPUT_FILE" > "$OUTPUT_FILE"
elif grep -q "<mzML" "$INPUT_FILE"; then
    # mzML: Replace only the id attribute within the mzML tag
    sed -e 's/\(<mzML[^>]*id=\)"[^"]*"/\1"'"$ANONYMOUS_NAME"'"/g' \
        -e 's/ location="[^"]*"/ location="'"$ANONYMOUS_NAME"'"/g' \
        -e 's/spotID="[^"]*"/spotID="'"$ANONYMOUS_NAME"'"/g' \
        "$INPUT_FILE" > "$OUTPUT_FILE"
else
    echo "Error: File type not supported (mzXML, mSD, or mzML only)"
    exit 1
fi

echo "Anonymized: $INPUT_FILE -> $OUTPUT_FILE"
