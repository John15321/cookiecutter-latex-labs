#!/bin/bash

# Build the document.
# Exit on any error
set -e

# Configuration
TEX_FILE="main.tex"
BASE_NAME=$(basename "$TEX_FILE" .tex)
PDF_NAME="{{ cookiecutter.project_slug.replace('_', '-') }}"
BUILD_DIR="build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 Building document...${NC}"
echo -e "${BLUE}📄 Source file: $TEX_FILE${NC}"
echo -e "${BLUE}📁 Build directory: $BUILD_DIR${NC}"
echo -e "${BLUE}📋 Output PDF: ${PDF_NAME}.pdf${NC}"

# Check if main.tex exists
if [ ! -f "$TEX_FILE" ]; then
    echo -e "${RED}❌ Error: $TEX_FILE not found${NC}"
    exit 1
fi

# Create build directory
echo -e "${YELLOW}📁 Creating build directory...${NC}"
mkdir -p "$BUILD_DIR"

# latexmk caches state in .fdb_latexmk; after a failed run it may keep returning
# a non-zero status with "gave an error in previous invocation" even when the
# document is otherwise up-to-date. Clear the cached state to make builds
# deterministic, especially in containers/CI where the build directory is
# volume-mounted.
rm -f "${BUILD_DIR}/${BASE_NAME}.fdb_latexmk" "${BUILD_DIR}/${BASE_NAME}.fls"

# Run latexmk with proper options
echo -e "${YELLOW}🔨 Compiling LaTeX document...${NC}"
echo "Command: latexmk -pdf -shell-escape -interaction=nonstopmode -outdir='$BUILD_DIR' '$TEX_FILE'"

# Set up environment for better LaTeX compilation
export TEXMFHOME="$PWD"
export TEXMFLOCAL="$PWD"

# Run latexmk - it will automatically handle multiple passes for cross-references.
# Note: pdflatex/latexmk may return code 1 even when a PDF is produced (e.g.,
# undefined refs on first pass, overfull boxes). For this project we treat the
# build as successful if the PDF artifact is generated.
set +e
latexmk -pdf -shell-escape -interaction=nonstopmode -f -outdir="$BUILD_DIR" "$TEX_FILE"
LATEXMK_RC=$?
set -e

# Check if PDF was generated (latexmk -f might still fail hard and not produce it)
if [ ! -f "${BUILD_DIR}/${BASE_NAME}.pdf" ]; then
    echo -e "${RED}❌ PDF was not generated${NC}"
    echo -e "${YELLOW}📋 Check the log file at: ${BUILD_DIR}/${BASE_NAME}.log${NC}"
    exit 1
fi

if [ "$LATEXMK_RC" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  LaTeX finished with warnings (exit code: $LATEXMK_RC)${NC}"
    echo -e "${YELLOW}📋 Check the log file at: ${BUILD_DIR}/${BASE_NAME}.log${NC}"
else
    echo -e "${GREEN}✅ LaTeX compilation completed${NC}"
fi

# Rename the output PDF
if [ -f "${BUILD_DIR}/${BASE_NAME}.pdf" ]; then
    mv "${BUILD_DIR}/${BASE_NAME}.pdf" "${BUILD_DIR}/${PDF_NAME}.pdf"

    # Get file size for verification
    FILE_SIZE=$(du -h "${BUILD_DIR}/${PDF_NAME}.pdf" | cut -f1)

    echo -e "${GREEN}🎉 Successfully built: ${BUILD_DIR}/${PDF_NAME}.pdf${NC}"
    echo -e "${GREEN}📊 File size: $FILE_SIZE${NC}"

    # Verify PDF is not corrupted
    if command -v pdfinfo &> /dev/null; then
        PAGE_COUNT=$(pdfinfo "${BUILD_DIR}/${PDF_NAME}.pdf" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "unknown")
        echo -e "${GREEN}📄 Pages: $PAGE_COUNT${NC}"
    fi
else
    echo -e "${RED}❌ Error: PDF was not generated at expected location${NC}"
    echo -e "${YELLOW}📋 Available files in build directory:${NC}"
    ls -la "$BUILD_DIR"
    exit 1
fi
