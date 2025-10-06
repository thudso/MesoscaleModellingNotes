#!/bin/sh
set -e
set -u

echo "Starting TikZ build process..."

FIGS=$(find tikz -name "*.tex")

if [ -z "$FIGS" ]; then
    echo "No .tex files found in tikz/. Nothing to do."
    exit 0
fi

for texfile in $FIGS; do
    pdffile="${texfile%.tex}.pdf"
    svgfile="${texfile%.tex}.svg"

    echo "--------------------------------------------------"
    echo "Processing: $texfile"

    rebuild_pdf=false
    rebuild_svg=false

    # Check if PDF needs to be rebuilt
    if [ ! -f "$pdffile" ] || [ "$texfile" -nt "$pdffile" ]; then
        echo "PDF is missing or outdated. Compiling..."
        xelatex -interaction=nonstopmode -halt-on-error -output-directory=$(dirname "$pdffile") "$texfile"
        echo "PDF created: $pdffile"
        rebuild_svg=true
    else
        echo "PDF is up to date."
        # Check if SVG needs to be rebuilt
        if [ ! -f "$svgfile" ] || [ "$pdffile" -nt "$svgfile" ]; then
            rebuild_svg=true
        fi
    fi

    # Convert PDF to SVG if needed
    if [ "$rebuild_svg" = true ]; then
        echo "Converting PDF to SVG..."
        pdf2svg "$pdffile" "$svgfile"
        echo "SVG created: $svgfile"
    else
        echo "SVG is up to date."
    fi
done

echo "Cleaning up LaTeX temporary files..."
rm -f tikz/*.aux tikz/*.log tikz/*.out tikz/*.toc tikz/*.tex~ tikz/*.fls tikz/*.fdb_latexmk tikz/*.synctex.gz
echo "Cleanup complete."

echo "All TikZ figures built successfully!"
# End of script