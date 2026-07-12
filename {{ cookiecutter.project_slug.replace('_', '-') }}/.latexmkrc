$pdf_mode = 1; # Use pdflatex
$recorder = 1;
$out_dir = 'build'; # Output directory

# Enable shell escape (needed for packages like minted, svg, etc.)
$pdflatex = 'pdflatex -shell-escape %O %S';

# Run bibtex when needed
$bibtex_use = 2;

# Clean up extra files
$clean_ext = 'aux fdb_latexmk fls log out toc lof lot bbl blg run.xml bcf figlist makefile fignums figaux pygtex pygstyle listing';

# Custom dependency for the svg package (requires inkscape, pre-installed in
# the Containerfile). Remove this block if your document has no SVG figures.
add_cus_dep('svg', 'pdf', 0, 'svg2pdf');
sub svg2pdf {
    # Use modern Inkscape syntax (works with both old and new versions)
    my $ret = system("inkscape", "--export-type=pdf", "--export-latex", "$_[0].svg");
    if ($ret != 0) {
        # Fallback to older syntax if new syntax fails
        $ret = system("inkscape", "-D", "-z", "--file=$_[0].svg", "--export-pdf=$_[0].pdf", "--export-latex");
    }
    return $ret;
}

# Support for .pdf_tex files (from Inkscape)
add_cus_dep('pdf_tex', 'pdf', 0, 'pdftex2pdf');
sub pdftex2pdf {
    return system("touch \"$_[0].pdf\"");
}
