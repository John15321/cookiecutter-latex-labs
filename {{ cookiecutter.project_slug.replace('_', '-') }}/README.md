# {{ cookiecutter.project_full_name }}

{{ cookiecutter.project_short_description }}

A reproducible LaTeX document built with **Podman** (Docker also supported),
so it compiles identically on every machine and in CI — no local LaTeX
installation required.

## 📋 Quick Start

### Prerequisites

**Podman or Docker (Recommended)**
- [Podman](https://podman.io/getting-started/installation) (preferred) or
  [Docker](https://docs.docker.com/get-docker/), plus their `compose` plugin
- No LaTeX installation needed on your host system

**Alternative: Native Installation (Advanced)**
- A TeX Live distribution, `latexmk`, `bibtex`, and Inkscape (for SVG figures)

### Building the Document

```bash
# First time setup (builds the container image)
make setup

# Build the document
make build

# Other commands
make clean          # Clean build files
make test           # Build and verify
make artifacts      # Gather distribution files
make shell          # Open an interactive shell in the build container
make ci-build       # Full CI pipeline
make help           # Show all commands
```

`make build` runs `scripts/build.sh` inside the container automatically. All
`make` targets are containerised by default and auto-detect Podman or Docker
(override with `make build ENGINE=docker`).

### Native Build (Without a Container)

```bash
make native-build       # Build without a container
make native-clean       # Clean without a container

# Or use scripts directly:
scripts/build.sh
```

#### Using latexmk directly

```bash
latexmk -pdf -shell-escape main.tex
```

### Output

The compiled PDF will be available at:
- `build/{{ cookiecutter.project_slug.replace('_', '-') }}.pdf` — the main document

## 📁 Project Structure

```
├── main.tex             # Main document file
├── sources/              # Individual sections, \input from main.tex
├── figures/               # Images and diagrams (SVG auto-converted via Inkscape)
├── references.bib        # Bibliography
├── .latexmkrc            # LaTeX build configuration
├── Makefile              # Build orchestration (Podman/Docker by default)
├── Containerfile          # Container image definition (TeX Live + Inkscape)
├── compose.yaml           # Container orchestration
└── scripts/               # Pure bash build/clean/artifacts scripts
```

## 🐳 Container Details

- **Base image**: `ghcr.io/xu-cheng/texlive-debian:latest` (full TeX Live)
- **Added tools**: Inkscape (SVG → PDF conversion for figures)
- Built once locally via `make setup`/`make image`; not pushed to any registry

## Adding Content

1. Create a new file under `sources/`, e.g. `sources/01_background.tex`.
2. `\input{sources/01_background}` it from `main.tex`.
3. Add figures to `figures/` and reference them with `\includegraphics` (or
   `\includesvg` for `.svg` files).
4. Add citations to `references.bib` and cite with `\cite{key}`.
