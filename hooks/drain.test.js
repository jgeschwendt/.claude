// @ts-check

import { afterEach, expect, test } from "bun:test";

const TMP = (Bun.env.TMPDIR ?? "/tmp").replace(/\/$/, "");

/** @type {string[]} */
const dirs = [];

/** Fresh temp dir holding a copy of the hook, so its `<script>.log` lands inside the dir. */
const setup = async () => {
  const dir = `${TMP}/claude-test-${crypto.randomUUID()}`;
  dirs.push(dir);
  await Bun.write(`${dir}/drain.js`, Bun.file(`${import.meta.dir}/drain.js`));
  return dir;
};

const run = (/** @type {string} */ dir, /** @type {string} */ stdin) =>
  Bun.spawnSync(["bun", `${dir}/drain.js`], {
    cwd: dir,
    stderr: "pipe",
    stdin: new TextEncoder().encode(stdin),
    stdout: "pipe",
  });

const logText = (/** @type {string} */ dir) => Bun.file(`${dir}/drain.js.log`).text();

afterEach(() => {
  const { rmSync } = process.getBuiltinModule("fs");
  for (const dir of dirs.splice(0)) rmSync(dir, { force: true, recursive: true });
});

test("appends across runs", async () => {
  const dir = await setup();

  expect(run(dir, JSON.stringify({ first: 1 })).exitCode).toBe(0);
  expect(run(dir, JSON.stringify({ second: 2 })).exitCode).toBe(0);

  const text = await logText(dir);
  expect(text).toContain('"first": 1');
  expect(text).toContain('"second": 2');
  expect(text.indexOf('"first"')).toBeLessThan(text.indexOf('"second"'));
  expect(text.match(/^\[\d{4}-\d{2}-\d{2}T[\d:.]+Z\] \{$/gm)).toHaveLength(2);
});

test("logs a SyntaxError for malformed stdin", async () => {
  const dir = await setup();

  expect(run(dir, "not json").exitCode).toBe(0);
  expect(await logText(dir)).toContain("SyntaxError");
});

test("logs a timestamped pretty-printed payload", async () => {
  const dir = await setup();
  const payload = { a: 1, b: [1, 2] };

  expect(run(dir, JSON.stringify(payload)).exitCode).toBe(0);

  const text = await logText(dir);
  expect(text).toMatch(/^\[\d{4}-\d{2}-\d{2}T[\d:.]+Z\] /);
  expect(text).toContain(`] ${JSON.stringify(payload, undefined, 2)}\n`);
});
