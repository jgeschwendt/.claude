#!/usr/bin/env bun
// @ts-check

import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { json } from "node:stream/consumers";

/** Append a timestamped line to `<script>.log`, keeping only the last 50. */
const log = (/** @type {string} */ line) => {
  const path = `${import.meta.filename}.log`;
  const prev = existsSync(path) ? readFileSync(path, "utf8").split("\n").filter(Boolean) : [];
  writeFileSync(
    path,
    [...prev, `[${new Date().toISOString()}] ${line}`].slice(-50).join("\n") + "\n",
  );
};

/** @typedef {{ tool_input?: { file_path?: string }; tool_response?: { filePath?: string } }} HookInput */

const OXFMT = [".oxfmtrc.json", ".oxfmtrc"];
// prettier.io config discovery order, minus the package.json `prettier` key (checked separately)
const PRETTIER = [
  ".prettierrc",
  ".prettierrc.cjs",
  ".prettierrc.cts",
  ".prettierrc.js",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.mjs",
  ".prettierrc.mts",
  ".prettierrc.toml",
  ".prettierrc.ts",
  ".prettierrc.yaml",
  ".prettierrc.yml",
  "prettier.config.cjs",
  "prettier.config.cts",
  "prettier.config.js",
  "prettier.config.mjs",
  "prettier.config.mts",
  "prettier.config.ts",
];

/**
 * Walk up from the edited file to the nearest project that opts into a formatter.
 * oxfmt wins ties; a Prettier config (file or package.json key) selects Prettier.
 * @returns {"oxfmt" | "prettier" | null}
 */
const detect = (/** @type {string} */ from) => {
  for (let dir = from, prev = ""; dir !== prev; prev = dir, dir = dirname(dir)) {
    if (OXFMT.some((name) => existsSync(`${dir}/${name}`))) return "oxfmt";
    if (PRETTIER.some((name) => existsSync(`${dir}/${name}`))) return "prettier";
    const pkg = `${dir}/package.json`;
    if (existsSync(pkg)) {
      try {
        if ("prettier" in JSON.parse(readFileSync(pkg, "utf8"))) return "prettier";
      } catch {}
    }
  }
  return null;
};

const data = /** @type {HookInput} */ (await json(process.stdin).catch(() => ({})));
const file = data.tool_input?.file_path ?? data.tool_response?.filePath;
const tool = file ? detect(dirname(file)) : null;

if (file && tool) {
  const args = tool === "oxfmt" ? ["oxfmt", file] : ["prettier", "--write", file];
  const { status } = spawnSync("bunx", args, { cwd: dirname(file), stdio: "ignore" });
  log(`${tool} exit=${status} ${file}`);
}
