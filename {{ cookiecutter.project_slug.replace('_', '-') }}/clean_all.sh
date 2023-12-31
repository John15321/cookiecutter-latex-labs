#!/bin/bash

# Clean up generated files by latexmk
for dir in lab*/report/; do
    if [ -d "$dir" ]; then
        (cd "$dir" && latexmk -c)
    fi
done

# Optional: Remove the entire build directories
# Uncomment the following lines if you also want to remove the build directories entirely
#for dir in lab*/report/build/; do
#    if [ -d "$dir" ]; then
#        rm -r "$dir"
#    fi
#done
