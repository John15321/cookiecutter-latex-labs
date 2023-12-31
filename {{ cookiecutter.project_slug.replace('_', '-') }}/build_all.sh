#!/bin/bash

for dir in lab*/report/; do
    if [ -d "$dir" ]; then
        echo "Building in '$dir'..."
        for texfile in "$dir"*.tex; do
            echo "  Building '$texfile'..."
            # Extract the base name of the file (without extension)
            base_name=$(basename "$texfile" .tex)

            # If the file is named main.tex, use the folder name for the PDF
            if [ "$base_name" == "main" ]; then
                folder_name=$(basename "$(dirname "$dir")")
                pdf_name="${folder_name}_report"
                echo "folder name $folder_name"
            else
                pdf_name="$base_name"
            fi
            build_dir="${dir}build"

            # Create a build directory if it doesn't exist
            mkdir -p $build_dir

            # Compile the LaTeX document and specify the output directory
            latex_make_cmd="latexmk -pdf -outdir='$build_dir' '$texfile'"

            echo "Running: ${latex_make_cmd}"
            eval "$latex_make_cmd"

            mv "${build_dir}/${base_name}.pdf" "${build_dir}/${pdf_name}.pdf"

        done
    fi
done