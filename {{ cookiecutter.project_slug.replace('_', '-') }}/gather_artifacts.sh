#!/bin/bash

# Directory where all PDFs will be gathered
artifacts_dir="artifacts"
mkdir -p "$artifacts_dir"

# Iterate over each lab report build directory
for pdf in lab*/report/build/*.pdf; do
    if [ -f "$pdf" ]; then
        # Copy the PDF to the artifacts directory
        cp "$pdf" "$artifacts_dir/"
    fi
done