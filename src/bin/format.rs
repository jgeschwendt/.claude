//! PostToolUse format hook entry point: reads the hook JSON on stdin and hands it to
//! [`claude_home::format::run`]. Always exits 0 — a formatter must never fail the tool call.

use std::io::Read;

fn main() {
    let mut input = String::new();
    let _ = std::io::stdin().read_to_string(&mut input);
    claude_home::format::run(&input);
}
