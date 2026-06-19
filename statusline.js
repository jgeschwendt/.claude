#!/usr/bin/env bun
// @ts-check

import { execSync } from "node:child_process";
import { writeFile } from "node:fs/promises";
import { json } from "node:stream/consumers";

/**
 * @typedef {{
 *   context_window?: { used_percentage?: number };
 *   model: { display_name: string };
 * }} StatusInput
 */

const sh = (/** @type {string} */ cmd) => execSync(cmd, { encoding: "utf8" }).trim();

/**
 * Columns of the controlling PTY. Claude Code pipes our stdout, so `process.stdout.columns` is undefined — walk up to
 * the shell that owns the real tty and ask `stty`, mirroring ccstatusline.
 */
const columns = (/** @type {number} */ fallback = 80) => {
  const flag = process.platform === "darwin" ? "-f" : "-F";
  try {
    for (let pid = process.pid, i = 0; pid > 1 && i < 8; i++) {
      const tty = sh(`ps -o tty= -p ${pid}`);
      if (tty && tty !== "??")
        return Number(sh(`stty ${flag} /dev/${tty} size`).split(" ")[1]) || fallback;
      pid = Number(sh(`ps -o ppid= -p ${pid}`));
    }
  } catch {}
  return fallback;
};

const log = (/** @type {string} */ message) =>
  writeFile(`${import.meta.filename}.log`, `[${new Date().toISOString()}] ${message}\n`);

try {
  const data = /** @type {StatusInput} */ (await json(process.stdin));

  const model = data.model.display_name;
  const pct = Math.floor(data.context_window?.used_percentage || 0);

  const head = `[${model}] `;
  const tail = ` ${pct}%`;
  // Claude Code indents the statusline ~2 cols and keeps a right margin, so the printable region is narrower than the PTY width 
  // reserve MARGIN or it clips with "…".
  const MARGIN = 4;
  const width = Math.max(0, columns() - MARGIN - head.length - tail.length);
  const filled = Math.round((pct / 100) * width);
  const bar = "▓".repeat(filled) + "░".repeat(width - filled);

  console.log(head + bar + tail);

  await log(JSON.stringify(data, undefined, 2));
} catch (error) {
  if (error instanceof Error) {
    await log(`${error.name}: ${error.message}\n${error.stack}`);
  } else {
    await log(`Error: ${String(error)}`);
  }
}
