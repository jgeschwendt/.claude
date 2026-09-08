//! Claude Code home tooling. Each binary in `src/bin/` is a thin `main` over a module here so the
//! logic is unit-testable without spawning a process.

pub mod format;
pub mod log;
pub mod statusline;
