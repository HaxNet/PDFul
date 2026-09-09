fn main() {
    tauri_build::try_build(
        tauri_build::Attributes::new()
            .app_manifest(tauri_build::AppManifest::new().commands(&["initial_file", "read_file", "save_file", "load_sigs", "save_sigs", "is_tiling"])),
    )
    .expect("tauri build");
}
