#!/bin/bash

# Clean all build files and directories
set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Cleaning all document build files...${NC}"

# Remove build directory
if [ -d "build" ]; then
    echo -e "${YELLOW}📁 Removing build directory...${NC}"
    rm -rf "build"
    echo -e "${GREEN}✅ Build directory removed${NC}"
else
    echo -e "${YELLOW}ℹ️  No build directory found${NC}"
fi

# Remove artifacts directory
if [ -d "artifacts" ]; then
    echo -e "${YELLOW}📦 Removing artifacts directory...${NC}"
    rm -rf "artifacts"
    echo -e "${GREEN}✅ Artifacts directory removed${NC}"
else
    echo -e "${YELLOW}ℹ️  No artifacts directory found${NC}"
fi

# Clean auxiliary files in root directory
echo -e "${YELLOW}🧽 Cleaning root directory auxiliary files...${NC}"

# Define file patterns to clean
CLEAN_PATTERNS=(
    "*.aux"
    "*.log"
    "*.out"
    "*.toc"
    "*.lof"
    "*.lot"
    "*.bbl"
    "*.blg"
    "*.fls"
    "*.fdb_latexmk"
    "*.synctex.gz"
    "*.synctex(busy)"
    "*.run.xml"
    "*.bcf"
    "*.pyg"
    "*.figlist"
    "*.makefile"
    "*.fignums"
    "*.figaux"
    "*.tdo"
)

FILES_REMOVED=false
for pattern in "${CLEAN_PATTERNS[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        echo "  Removing $pattern files..."
        rm -f $pattern
        FILES_REMOVED=true
    fi
done

if [ "$FILES_REMOVED" = true ]; then
    echo -e "${GREEN}✅ Auxiliary files cleaned${NC}"
else
    echo -e "${YELLOW}ℹ️  No auxiliary files to clean${NC}"
fi

echo -e "${GREEN}🎉 Complete cleanup finished${NC}"
