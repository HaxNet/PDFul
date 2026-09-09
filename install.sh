#!/usr/bin/env bash
# PDFul installer. Detects your distro, installs build dependencies, compiles, and installs.
#   ./install.sh              build and install for the current user
#   ./install.sh --uninstall  remove it
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"; APPS="$HOME/.local/share/applications"; ICONS="$HOME/.local/share/icons/hicolor"

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$BIN/pdful" "$APPS/pdful.desktop" "$ICONS"/*/apps/pdful.png
  command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" 2>/dev/null || true
  echo "PDFul removed. Your signatures in ~/.local/share/pdful were kept."; exit 0
fi

say(){ printf '\n\033[1m==> %s\033[0m\n' "$*"; }
have(){ command -v "$1" >/dev/null 2>&1; }
SUDO=""; [ "$(id -u)" -ne 0 ] && have sudo && SUDO=sudo

say "Checking dependencies"
missing=""
have cargo || missing="rust"
pkg-config --exists webkit2gtk-4.1 2>/dev/null || missing="$missing webkit"
if [ -n "$missing" ]; then
  if have pacman; then
    echo "Installing: rust webkit2gtk-4.1 gtk3 librsvg curl"
    $SUDO pacman -S --needed --noconfirm rust webkit2gtk-4.1 gtk3 librsvg curl base-devel
  elif have apt-get; then
    echo "Installing build dependencies with apt"
    $SUDO apt-get update
    $SUDO apt-get install -y build-essential curl pkg-config libwebkit2gtk-4.1-dev libgtk-3-dev librsvg2-dev rustc cargo
  elif have dnf; then
    $SUDO dnf install -y rust cargo curl webkit2gtk4.1-devel gtk3-devel librsvg2-devel
  elif have zypper; then
    $SUDO zypper install -y rust cargo curl webkit2gtk3-soup2-devel gtk3-devel librsvg-devel
  else
    echo "Could not detect your package manager."
    echo "Install these yourself, then re-run: rust/cargo, webkit2gtk-4.1 dev headers, gtk3 dev headers, librsvg, curl"
    exit 1
  fi
fi
have cargo || { echo "cargo still not found. Install Rust from https://rustup.rs and re-run."; exit 1; }

if [ ! -f "$HERE/frontend/vendor/fabric.min.js" ]; then
  say "Downloading libraries and OCR data (about 25 MB, once)"
  "$HERE/fetch-vendor.sh"
fi

say "Building (first build takes 5 to 10 minutes)"
( cd "$HERE/src-tauri" && cargo build --release )

say "Installing"
install -Dm755 "$HERE/src-tauri/target/release/pdful" "$BIN/pdful"
install -Dm644 "$HERE/pdful.desktop" "$APPS/pdful.desktop"
for s in 512:icon 128:128x128 32:32x32; do
  install -Dm644 "$HERE/src-tauri/icons/${s#*:}.png" "$ICONS/${s%%:*}x${s%%:*}/apps/pdful.png"
done
command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q "$ICONS" 2>/dev/null || true

say "Done"
echo "Run:  pdful           or open PDFul from your application menu"
case ":$PATH:" in *":$BIN:"*) ;; *) echo
  echo "Add ~/.local/bin to your PATH first:"
  echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc";; esac
