//! Append-only run logs under `~/.claude/logs/`, one file per binary.

use std::fs;
use std::path::PathBuf;

/// `~/.claude/logs/<name>.log`, creating the directory on first use.
pub fn path(name: &str) -> PathBuf {
    let home = std::env::var_os("HOME").map(PathBuf::from).unwrap_or_else(|| PathBuf::from("/"));
    let dir = home.join(".claude").join("logs");
    let _ = fs::create_dir_all(&dir);
    dir.join(format!("{name}.log"))
}

/// Append `[<ISO-8601 UTC>] <line>`; when `keep` is set, retain only the last `keep` lines.
pub fn append(name: &str, line: &str, keep: Option<usize>) {
    let path = path(name);
    let stamp = chrono::Utc::now().to_rfc3339_opts(chrono::SecondsFormat::Millis, true);
    let entry = format!("[{stamp}] {line}");
    let body = match keep {
        Some(n) => {
            let prev = fs::read_to_string(&path).unwrap_or_default();
            let mut lines: Vec<&str> = prev.lines().filter(|l| !l.is_empty()).collect();
            lines.push(&entry);
            let start = lines.len().saturating_sub(n);
            lines[start..].join("\n") + "\n"
        }
        None => {
            let prev = fs::read_to_string(&path).unwrap_or_default();
            prev + &entry + "\n"
        }
    };
    let _ = fs::write(&path, body);
}
