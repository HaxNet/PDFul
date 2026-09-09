# PDFul

**PDFul** (pronounced "beautiful") is a standalone PDF editor for Linux.

Continuous scroll, find in document, freehand and highlighter annotation, shapes and arrows,
threaded comments saved as real PDF sticky notes, e-signatures that persist between sessions,
stamps, scan import, and local OCR that turns scans into searchable PDFs.

Everything runs on your machine. Nothing is uploaded anywhere.

## Install

    git clone https://github.com/YOURNAME/pdful.git
    cd pdful
    ./install.sh

That is the whole thing. The installer detects your distro (Arch, Debian/Ubuntu, Fedora, openSUSE),
installs the build dependencies, downloads the JS libraries and English OCR data, compiles, and
installs PDFul to `~/.local/bin` with an application-menu entry. First build takes 5 to 10 minutes.

Then run `pdful`, or `pdful invoice.pdf`, or open PDFul from your application menu.
PDFul also registers as a handler for PDF files, so "Open with" works.

Uninstall with `./install.sh --uninstall`.

### Arch users who prefer pacman to manage it

    makepkg -si

Removes cleanly with `sudo pacman -R pdful`.

### Requirements

Rust 1.77+ and WebKitGTK 4.1. The installer handles both. If your distro ships an older Rust,
install the current toolchain from https://rustup.rs and re-run.

## Features

| | |
|---|---|
| **Tabs** | Several PDFs open at once, each with its own tab, close button and scroll position |
| **View** | Continuous scroll with page virtualization, mixed page sizes, zoom, fit width, fit page |
| **Find** | Ctrl+F, match count, next/previous, match case, whole words, highlights across all pages |
| **Edit text** | Click existing PDF text to change it. Choose Helvetica, Times or Courier, bold and italic. Replacement text is written as real, selectable PDF text |
| **Draw** | Pen, highlighter (true multiply blend), eraser, rectangle, ellipse, line, arrow, text |
| **Comment** | Numbered pins with threaded replies, written as native PDF sticky notes |
| **Sign** | Draw, type, or upload a signature. Saved signatures persist between sessions |
| **Stamp** | APPROVED, PAID, REVIEWED, DRAFT, CONFIDENTIAL, VOID, RECEIVED, FINAL |
| **Scan** | Import phone photos or scanner images as a PDF |
| **OCR** | Local Tesseract. Embeds an invisible text layer so scans become searchable |
| **Pages** | Thumbnails, insert blank, delete, rotate, append from another PDF or images |

## Keyboard

`Ctrl+O` / `Ctrl+T` open in a new tab · `Ctrl+W` close tab · `Ctrl+Tab` next tab · `Ctrl+S` save ·
`Ctrl+F` find · `F3` find next · `Ctrl+Z` / `Ctrl+Y` undo and redo · `Ctrl+scroll` zoom ·
`Delete` remove selection · `Esc` back to select

Tools: `V` select · `H` pan · `P` pen · `M` highlighter · `E` eraser · `T` text · `R` rectangle ·
`X` edit text · `O` ellipse · `L` line · `A` arrow · `N` comment · `S` signature · `K` stamp

## OCR languages

English is bundled and works offline. Spanish, French, German and Chinese download automatically
the first time you select them, then stay cached.

## Where your data lives

    ~/.local/share/pdful/signatures.json    saved signatures

Saving always writes a new file through the native save dialog. Your original is never modified.

## Project layout

    frontend/index.html    the entire editor UI
    frontend/vendor/       libraries, downloaded by fetch-vendor.sh (gitignored)
    src-tauri/src/main.rs  Rust shell: window, native dialogs, file and signature storage
    fetch-vendor.sh        downloads pdf.js, Fabric, pdf-lib, Tesseract and OCR data
    install.sh             one-command install
    PKGBUILD               Arch package

## Wayland and tiling compositors

Works on Wayland. Under niri, Sway, Hyprland or River, PDFul detects the tiling compositor and
hides the minimize and maximize buttons, since your compositor owns sizing. Window sizing,
snapping and closing come from your keybinds as usual.

If the window renders black on Wayland (common with some Nvidia drivers), launch with:

    WEBKIT_DISABLE_DMABUF_RENDERER=1 pdful

## How text editing works, and its limits

Clicking text with the Edit tool covers the original run with a patch colour-sampled from the page
background, then puts an editable box on top. Your replacement is written into the saved PDF as
real text, so it stays selectable and searchable.

This handles the common jobs well: fixing a name, an amount, a date, an address. It has real limits:

- One text run at a time. It does not reflow paragraphs.
- The patch is a solid rectangle, so it is invisible on plain backgrounds and visible over
  gradients, images or patterns.
- Replacement uses Helvetica, Times or Courier, not the document's original embedded font.
- Scanned pages have no text to click. Run OCR first, and even then the underlying image stays.

## Other known limits

Comments are written as native PDF annotations. Drawings, shapes and signatures are flattened
into the page on save, so they are not re-editable in Adobe or Foxit afterwards.
PDFul does not fill existing form fields.

## Built with

[Tauri](https://tauri.app) · [pdf.js](https://mozilla.github.io/pdf.js/) ·
[Fabric.js](http://fabricjs.com) · [pdf-lib](https://pdf-lib.js.org) ·
[Tesseract.js](https://tesseract.projectnaptha.com)

MIT licensed.
