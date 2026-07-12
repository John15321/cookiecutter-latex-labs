# Makefile for {{ cookiecutter.project_full_name }} — works with Podman (preferred) or Docker.

.PHONY: all build clean artifacts help test ci-build ci-artifacts setup \
        native-build native-clean native-artifacts shell \
        image image-rebuild nuke

# Configuration
SCRIPTS_DIR = scripts
# Container engine auto-detect: podman first, then docker. Override with:
#   make build ENGINE=docker
ENGINE     ?= $(shell command -v podman > /dev/null 2>&1 && echo podman || (command -v docker > /dev/null 2>&1 && echo docker))
# Compose follows the engine. Both `podman compose` and `docker compose` invoke
# a v2 compose plugin. Override if needed with:
#   make build COMPOSE="podman-compose"   or   COMPOSE="docker-compose"
COMPOSE    ?= $(ENGINE) compose

# Detect whether we're already inside the build container (skip wrapping).
CONTAINER_ENV := $(shell [ -f /run/.containerenv ] || [ -f /.dockerenv ] && echo true || echo false)

# Function: run a command inside the document-builder container (or natively
# if we're already inside it). Bails out with install instructions if no
# container engine is available.
# Usage: $(call run-in-container,command,description)
define run-in-container
	@if [ "$(CONTAINER_ENV)" = "true" ]; then \
		echo "$(2) (inside container)..."; \
		$(1); \
	elif [ -z "$(ENGINE)" ]; then \
		echo "❌ Error: no container engine found (looked for podman, docker)."; \
		echo ""; \
		echo "On Fedora:  sudo dnf install -y podman podman-compose"; \
		echo "On Ubuntu:  sudo apt install -y podman podman-compose"; \
		echo "            (or: sudo apt install -y docker.io docker-compose-plugin)"; \
		echo "On macOS:   brew install podman  (or install Docker Desktop)"; \
		echo "Then:       make setup && make build"; \
		echo ""; \
		echo "Or to build without a container (requires a local TeX Live install):"; \
		echo "  make native-build"; \
		exit 1; \
	else \
		echo "📦 $(2) (using $(COMPOSE))..."; \
		$(COMPOSE) run --rm document-builder bash -c "$(1)"; \
	fi
endef

# Default target
all: build

# First-time setup: verify the engine is usable and build the image.
setup:
	@echo "📦 Setting up container build environment..."
	@if [ -z "$(ENGINE)" ]; then \
		echo "❌ Error: no container engine found (looked for podman, docker)."; \
		echo "On Fedora: sudo dnf install -y podman podman-compose"; \
		echo "On Ubuntu: sudo apt install -y podman podman-compose"; \
		echo "           (or: sudo apt install -y docker.io docker-compose-plugin)"; \
		exit 1; \
	fi
	@if ! $(ENGINE) info > /dev/null 2>&1; then \
		echo "❌ Error: $(ENGINE) is installed but not usable."; \
		echo "Try running '$(ENGINE) info' once interactively, then re-run 'make setup'."; \
		exit 1; \
	fi
	@echo "Engine : $(ENGINE)"
	@echo "Compose: $(COMPOSE)"
	@echo "Building document-builder image (TeX Live + Inkscape pre-installed)..."
	@echo "(One-time build; subsequent builds reuse the cached layers.)"
	@$(COMPOSE) build
	@echo "✅ Container environment ready. Try 'make build'."

# Build the document PDF (containerised by default).
build:
	$(call run-in-container,$(SCRIPTS_DIR)/build.sh,Building document)

# Clean build outputs.
clean:
	$(call run-in-container,$(SCRIPTS_DIR)/clean.sh,Cleaning all build files)

# Gather artifacts for distribution.
artifacts: build
	$(call run-in-container,$(SCRIPTS_DIR)/gather-artifacts.sh,Gathering artifacts)

# Build + verify the PDF was produced.
test: build
	@echo "✅ Testing build..."
	@test -f build/{{ cookiecutter.project_slug.replace('_', '-') }}.pdf && echo "✅ PDF generated successfully" || (echo "❌ PDF generation failed" && exit 1)

# CI pipelines.
ci-build: clean build test
	@echo "🚀 CI build completed successfully"

ci-artifacts: ci-build artifacts
	@echo "📦 CI artifacts prepared"

# Open an interactive shell in the build container.
shell:
	@$(COMPOSE) run --rm document-builder bash

# Container lifecycle ---------------------------------------------------------

# Build (or rebuild incrementally) the document-builder image.
image:
	@echo "📦 Building document-builder image ($(COMPOSE))..."
	@$(COMPOSE) build

# Full rebuild: ignore cache, re-pull the base image, then prune dangling layers.
image-rebuild:
	@echo "♻️  Forcing full rebuild of document-builder image ($(COMPOSE))..."
	@$(COMPOSE) build --no-cache --pull
	@-$(ENGINE) image prune -f > /dev/null 2>&1 || true
	@echo "✅ Image rebuilt."

# Wipe the container + image so the next 'make setup' starts clean.
nuke:
	@echo "💣 Removing document-builder container, image, and volumes..."
	@-$(COMPOSE) down --rmi all -v 2> /dev/null || true
	@-$(ENGINE) rmi -f document-builder:local localhost/document-builder:local 2> /dev/null || true
	@echo "✅ Container environment removed. Run 'make setup' to recreate."

# Native builds (without a container) - for advanced users with LaTeX installed.
native-build:
	@echo "📚 Building document (native)..."
	@$(SCRIPTS_DIR)/build.sh

native-clean:
	@echo "🧹 Cleaning all build files (native)..."
	@$(SCRIPTS_DIR)/clean.sh

native-artifacts: native-build
	@echo "📦 Gathering artifacts (native)..."
	@$(SCRIPTS_DIR)/gather-artifacts.sh

# Show available targets
help:
	@echo "{{ cookiecutter.project_full_name }} Build System (Podman or Docker)"
	@echo "==========================================="
	@echo ""
	@echo "Engine : $(ENGINE)"
	@echo "Compose: $(COMPOSE)"
	@echo ""
	@echo "🚀 Quick Start:"
	@echo "  make setup    - First-time setup (build the container image)"
	@echo "  make build    - Build the PDF (inside container)"
	@echo "  make clean    - Clean build artifacts (inside container)"
	@echo ""
	@echo "📋 Main Targets (containerised, auto-detects podman/docker):"
	@echo "  build         - Build the document PDF"
	@echo "  clean         - Clean all build files and directories"
	@echo "  artifacts     - Gather build artifacts for distribution"
	@echo "  test          - Build and verify the document"
	@echo "  ci-build      - Full CI build pipeline"
	@echo "  ci-artifacts  - Full CI pipeline with artifacts"
	@echo "  shell         - Open an interactive shell in the build container"
	@echo ""
	@echo "🐳 Container lifecycle:"
	@echo "  image         - (Re)build document-builder image (uses cache)"
	@echo "  image-rebuild - Full rebuild (--no-cache --pull + prune)"
	@echo "  nuke          - Remove the container + image"
	@echo ""
	@echo "🔧 Native (no container, requires a local TeX Live install):"
	@echo "  native-build      - Build without a container"
	@echo "  native-clean      - Clean without a container"
	@echo "  native-artifacts  - Gather artifacts without a container"
	@echo ""
	@echo "💡 Override the engine or compose runtime if needed:"
	@echo "      make build ENGINE=docker"
	@echo "      make build COMPOSE=\"podman-compose\""
