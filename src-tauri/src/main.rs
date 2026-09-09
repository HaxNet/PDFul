#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use percent_encoding::percent_decode_str;
use std::sync::Mutex;
use tauri::{ipc::InvokeBody, ipc::Request, ipc::Response, State, WebviewUrl, WebviewWindowBuilder};

/// Path given on the command line (from `pdf-studio file.pdf` or "Open with").
struct Initial(Mutex<Option<String>>);

#[tauri::command]
fn initial_file(state: State<Initial>) -> Option<String> {
    state.0.lock().ok()?.take()
}

/// Returns the raw bytes of a file the user chose (native dialog or CLI argument).
#[tauri::command]
fn read_file(path: String) -> Result<Response, String> {
    std::fs::read(&path).map(Response::new).map_err(|e| format!("{}: {}", path, e))
}

/// Writes a PDF the app produced. Bytes arrive as the raw IPC body, the path as a header.
#[tauri::command]
fn save_file(request: Request<'_>) -> Result<(), String> {
    let path = request
        .headers()
        .get("path")
        .ok_or("missing path header")?
        .to_str()
        .map_err(|e| e.to_string())?;
    let path = percent_decode_str(path).decode_utf8().map_err(|e| e.to_string())?.to_string();
    match request.body() {
        InvokeBody::Raw(bytes) => std::fs::write(&path, bytes).map_err(|e| format!("{}: {}", path, e)),
        _ => Err("expected binary body".into()),
    }
}

/// Tiling Wayland compositors have no minimize and manage sizing themselves.
#[tauri::command]
fn is_tiling() -> bool {
    ["NIRI_SOCKET", "SWAYSOCK", "HYPRLAND_INSTANCE_SIGNATURE", "RIVER_SOCKET"]
        .iter().any(|k| std::env::var_os(k).is_some())
}

fn data_dir() -> std::path::PathBuf {
    let base = std::env::var_os("XDG_DATA_HOME").map(std::path::PathBuf::from)
        .or_else(|| std::env::var_os("HOME").map(|h| std::path::PathBuf::from(h).join(".local/share")))
        .unwrap_or_else(std::env::temp_dir);
    base.join("pdful")
}

/// Saved signatures (PNG data URLs) persist across sessions.
#[tauri::command]
fn load_sigs() -> Vec<String> {
    std::fs::read_to_string(data_dir().join("signatures.json")).ok()
        .and_then(|s| serde_json::from_str(&s).ok()).unwrap_or_default()
}

#[tauri::command]
fn save_sigs(sigs: Vec<String>) -> Result<(), String> {
    let d = data_dir();
    std::fs::create_dir_all(&d).map_err(|e| e.to_string())?;
    std::fs::write(d.join("signatures.json"), serde_json::to_string(&sigs).map_err(|e| e.to_string())?).map_err(|e| e.to_string())
}

fn main() {
    let port = std::net::TcpListener::bind("127.0.0.1:0").and_then(|l| l.local_addr()).map(|a| a.port()).expect("no free localhost port");
    let initial = std::env::args().nth(1).filter(|a| !a.starts_with('-')).and_then(|a| {
        std::fs::canonicalize(&a).ok().map(|p| p.to_string_lossy().to_string())
    });

    tauri::Builder::default()
        .manage(Initial(Mutex::new(initial)))
        .plugin(tauri_plugin_localhost::Builder::new(port).build())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![initial_file, read_file, save_file, load_sigs, save_sigs, is_tiling])
        .setup(move |app| {
            let url = format!("http://localhost:{}/", port).parse().unwrap();
            WebviewWindowBuilder::new(app, "main", WebviewUrl::External(url))
                .title("PDFul")
                .inner_size(1380.0, 860.0)
                .decorations(false)
                .min_inner_size(900.0, 600.0)
                .build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running PDFul");
}
