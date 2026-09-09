#!/usr/bin/env bash
# Publish PDFul to GitHub. Run this inside the pdful folder.
set -euo pipefail
REPO="${1:-}"
[ -z "$REPO" ] && { echo "usage: ./setup-git.sh git@github.com:YOURNAME/pdful.git"; exit 1; }
git init -b main
git add -A
git commit -m "PDFul: standalone Linux PDF editor with annotation, comments, signatures and OCR"
git remote add origin "$REPO"
git push -u origin main
echo "Pushed. Anyone can now run:  git clone $REPO && cd pdful && ./install.sh"
