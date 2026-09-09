#!/usr/bin/env bash
# Downloads the JS libraries and OCR engine into frontend/vendor (run once before building).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; V="$HERE/frontend/vendor"; T="$(mktemp -d)"
mkdir -p "$V/tesseract-core" "$V/tessdata"
while read -r name url; do
  [ -z "$name" ] && continue; echo "  $name"; curl -fsSL "$url" -o "$T/$name"
done < "$HERE/vendor-urls.txt"
x(){ mkdir -p "$T/$1"; tar xzf "$T/$1.tgz" -C "$T/$1" --strip-components=1; }
x pdfjs-dist-3.11.174;  cp "$T/pdfjs-dist-3.11.174/build/pdf.min.js" "$T/pdfjs-dist-3.11.174/build/pdf.worker.min.js" "$V/"
x pdf-lib-1.17.1;       cp "$T/pdf-lib-1.17.1/dist/pdf-lib.min.js" "$V/"
x fabric-5.5.2;         cp "$T/fabric-5.5.2/dist/fabric.min.js" "$V/"
x tesseract.js-5.0.4;   cp "$T/tesseract.js-5.0.4/dist/tesseract.min.js" "$T/tesseract.js-5.0.4/dist/worker.min.js" "$V/"
x tesseract.js-core-5.1.1; cp "$T/tesseract.js-core-5.1.1/tesseract-core-lstm.wasm.js" "$T/tesseract.js-core-5.1.1/tesseract-core-simd-lstm.wasm.js" "$V/tesseract-core/"
cp "$T/eng.traineddata.gz" "$V/tessdata/"
rm -rf "$T"; echo "vendor ready: $V"
