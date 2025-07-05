#!/usr/bin/env bash

# Command file for Sphinx documentation

# Save current directory and switch to the script's directory
pushd "$(dirname "$0")" > /dev/null

# Set SPHINXBUILD to sphinx-build if not already set
: "${SPHINXBUILD:=sphinx-build}"
SOURCEDIR="source"
BUILDDIR="_build"

# Check if sphinx-build is available
if ! command -v "$SPHINXBUILD" >/dev/null 2>&1; then
    echo
    echo "The 'sphinx-build' command was not found. Make sure you have Sphinx"
    echo "installed, then set the SPHINXBUILD environment variable to point"
    echo "to the full path of the 'sphinx-build' executable. Alternatively you"
    echo "may add the Sphinx directory to PATH."
    echo
    echo "If you don't have Sphinx installed, grab it from"
    echo "https://www.sphinx-doc.org/"
    popd > /dev/null
    exit 1
fi

# If no argument is given, show help
if [ $# -eq 0 ]; then
    "$SPHINXBUILD" -M help "$SOURCEDIR" "$BUILDDIR" $SPHINXOPTS $O
    popd > /dev/null
    exit 0
fi

# Run sphinx-build with provided command
"$SPHINXBUILD" -M "$1" "$SOURCEDIR" "$BUILDDIR" $SPHINXOPTS $O

# Restore previous directory
popd > /dev/null
