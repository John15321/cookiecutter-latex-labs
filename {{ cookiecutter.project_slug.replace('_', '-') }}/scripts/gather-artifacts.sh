#!/bin/bash

# Gather build artifacts for distribution
set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ARTIFACTS_DIR="artifacts"
DOCUMENT_PDF="build/{{ cookiecutter.project_slug.replace('_', '-') }}.pdf"

echo -e "${BLUE}📦 Gathering document artifacts...${NC}"

# Create artifacts directory
echo -e "${YELLOW}📁 Creating artifacts directory...${NC}"
mkdir -p "$ARTIFACTS_DIR"

# Check if the document PDF exists
if [ ! -f "$DOCUMENT_PDF" ]; then
    echo -e "${RED}❌ Error: Document PDF not found at $DOCUMENT_PDF${NC}"
    echo -e "${YELLOW}📋 Available files in build directory:${NC}"
    if [ -d "build" ]; then
        ls -la build/
    else
        echo "  Build directory does not exist"
    fi
    exit 1
fi

# Verify PDF is not corrupted
echo -e "${YELLOW}🔍 Verifying PDF integrity...${NC}"
if command -v pdfinfo &> /dev/null; then
    if pdfinfo "$DOCUMENT_PDF" &> /dev/null; then
        PAGE_COUNT=$(pdfinfo "$DOCUMENT_PDF" 2>/dev/null | grep "Pages:" | awk '{print $2}' || echo "unknown")
        echo -e "${GREEN}✅ PDF verification passed (Pages: $PAGE_COUNT)${NC}"
    else
        echo -e "${RED}❌ Error: PDF appears to be corrupted${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  pdfinfo not available, skipping PDF verification${NC}"
fi

# Copy the document PDF
echo -e "${YELLOW}📄 Copying document PDF...${NC}"
cp "$DOCUMENT_PDF" "$ARTIFACTS_DIR/"

# Create a timestamp file
echo -e "${YELLOW}🕒 Creating build metadata...${NC}"
cat > "$ARTIFACTS_DIR/build-info.txt" << EOF
{{ cookiecutter.project_full_name }} Build Information
=================================
Build Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Hostname: $(hostname)
User: $(whoami)
Git Branch: $(git branch --show-current 2>/dev/null || echo "unknown")
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "unknown")
Git Commit Short: $(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
PDF Size: $(du -h "$DOCUMENT_PDF" | cut -f1)
EOF

# List artifacts
echo -e "${GREEN}📋 Artifacts gathered:${NC}"
ls -lah "$ARTIFACTS_DIR"

echo -e "${GREEN}🎉 Artifacts gathering completed successfully${NC}"
