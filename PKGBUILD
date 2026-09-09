# Maintainer: HaxNet <haxnet@tekniq.xyz>
pkgname=pdful # pronounced Beautiful
pkgver=1.2.1
pkgrel=1
pkgdesc="Standalone PDF editor: annotate, comment, draw, sign, scan and OCR (Tauri/WebKitGTK)"
arch=('x86_64' 'aarch64')
license=('MIT')
depends=('webkit2gtk-4.1' 'gtk3' 'libayatana-appindicator' 'librsvg')
makedepends=('rust' 'cargo' 'curl')
optdepends=('ttf-ibm-plex: intended UI typeface')
source=()
sha256sums=()

prepare() {
  cd "$startdir"
  [ -f frontend/vendor/fabric.min.js ] || ./fetch-vendor.sh
  cd src-tauri && cargo fetch --target "$(rustc -vV | sed -n 's/host: //p')"
}

build() {
  cd "$startdir/src-tauri"
  export CARGO_TARGET_DIR=target
  cargo build --release
}

package() {
  cd "$startdir"
  install -Dm755 src-tauri/target/release/pdful "$pkgdir/usr/bin/pdful"
  install -Dm644 pdful.desktop "$pkgdir/usr/share/applications/pdful.desktop"
  install -Dm644 src-tauri/icons/icon.png "$pkgdir/usr/share/icons/hicolor/512x512/apps/pdful.png"
  install -Dm644 "src-tauri/icons/128x128@2x.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/pdful.png"
  install -Dm644 src-tauri/icons/128x128.png "$pkgdir/usr/share/icons/hicolor/128x128/apps/pdful.png"
  install -Dm644 src-tauri/icons/32x32.png "$pkgdir/usr/share/icons/hicolor/32x32/apps/pdful.png"
}
