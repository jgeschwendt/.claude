#!/usr/bin/env bun
// @ts-check

/** Append a timestamped line to `<script>.log`, keeping only the last 50. */
const log = async (/** @type {string} */ line) => {
  const file = Bun.file(`${import.meta.filename}.log`);
  const prev = (await file.exists()) ? (await file.text()).split("\n").filter(Boolean) : [];
  await Bun.write(
    file,
    [...prev, `[${new Date().toISOString()}] ${line}`].slice(-50).join("\n") + "\n",
  );
};

/** @typedef {{ tool_input?: { file_path?: string }; tool_response?: { filePath?: string } }} HookInput */

const dirname = (/** @type {string} */ path) => path.replace(/\/[^/]*$/, "") || "/";

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

const exists = (/** @type {string} */ path) => Bun.file(path).exists();
const any = async (/** @type {string} */ dir, /** @type {string[]} */ names) =>
  (await Promise.all(names.map((name) => exists(`${dir}/${name}`)))).some(Boolean);

/**
 * Walk up from the edited file to the nearest project that opts into a formatter.
 * oxfmt wins ties; a Prettier config (file or package.json key) selects Prettier.
 * @returns {Promise<"oxfmt" | "prettier" | null>}
 */
const detect = async (/** @type {string} */ from) => {
  for (let dir = from, prev = ""; dir !== prev; prev = dir, dir = dirname(dir)) {
    if (await any(dir, OXFMT)) return "oxfmt";
    if (await any(dir, PRETTIER)) return "prettier";
    const pkg = Bun.file(`${dir}/package.json`);
    if (await pkg.exists()) {
      try {
        if ("prettier" in (await pkg.json())) return "prettier";
      } catch {}
    }
  }
  return null;
};

const data = /** @type {HookInput} */ (await Bun.stdin.json().catch(() => ({})));
const file = data.tool_input?.file_path ?? data.tool_response?.filePath;
const tool = file ? await detect(dirname(file)) : null;

if (file && tool) {
  const args = tool === "oxfmt" ? ["oxfmt", file] : ["prettier", "--write", file];
  const { exitCode } = Bun.spawnSync(["bunx", ...args], {
    cwd: dirname(file),
    stdout: "ignore",
    stderr: "ignore",
  });
  await log(`${tool} exit=${exitCode} ${file}`);
}
