# cookiecutter-latex-labs

A [cookiecutter](https://github.com/cookiecutter/cookiecutter) template for a
generic, reproducible LaTeX document (report, paper, book, thesis, etc.).

Builds are containerised with **Podman** (Docker also supported) so the
document compiles identically on every machine and in CI — no local LaTeX
installation required.

## Usage

```bash
pip install cookiecutter
cookiecutter gh:John15321/cookiecutter-latex-labs
cd <your-project-slug>
make setup   # first-time container image build
make build   # compile the PDF
```

See the generated project's `README.md` for the full list of `make` targets.

