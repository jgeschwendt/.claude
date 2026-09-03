// @ts-check

import { afterEach, expect, test } from "bun:test";

const TMP = (Bun.env.TMPDIR ?? "/tmp").replace(/\/$/, "");
const UNFORMATTED = '{"a":1,\n"b":[1,2]}';
const FORMATTED = '{ "a": 1, "b": [1, 2] }';

/** @type {string[]} */
const dirs = [];

/**
 * Fresh temp dir holding a copy of the hook — running the copy keeps its
 * `<script>.log` inside the dir, and keeps formatter detection off this repo's tree.
 */
const setup = async () => {
  const dir = `${TMP}/claude-test-${crypto.randomUUID()}`;
  dirs.push(dir);
  await Bun.write(`${dir}/format.js`, Bun.file(`${import.meta.dir}/format.js`));
  return dir;
};

const run = (
  /** @type {string} */ dir,
  /** @type {string} */ stdin,
  /** @type {Record<string, string | undefined>} */ env = { ...Bun.env },
) =>
  Bun.spawnSync(["bun", `${dir}/format.js`], {
    cwd: dir,
    env,
    stderr: "pipe",
    stdin: new TextEncoder().encode(stdin),
    stdout: "pipe",
  });

const logLines = async (/** @type {string} */ dir) =>
  (await Bun.file(`${dir}/format.js.log`).text()).split("\n").filter(Boolean);

afterEach(() => {
  const { rmSync } = process.getBuiltinModule("fs");
  for (const dir of dirs.splice(0)) rmSync(dir, { force: true, recursive: true });
});

test("caps the log at 50 lines", async () => {
  const dir = await setup();
  await Bun.write(`${dir}/.oxfmtrc.json`, "{}");
  await Bun.write(`${dir}/probe.json`, UNFORMATTED);
  await Bun.write(
    `${dir}/format.js.log`,
    Array.from({ length: 60 }, (_, i) => `[old] entry ${i}`).join("\n") + "\n",
  );

  expect(
    run(dir, JSON.stringify({ tool_input: { file_path: `${dir}/probe.json` } })).exitCode,
  ).toBe(0);

  const lines = await logLines(dir);
  expect(lines).toHaveLength(50);
  expect(lines[49]).toMatch(/oxfmt exit=0 .*probe\.json$/);
});

// Prettier is never invoked end-to-end (`bunx prettier` would download the package). A stub
// `bunx` earlier on PATH records the argv instead, so this covers detection + the command shape.
test("detects a package.json prettier key without invoking prettier", async () => {
  const dir = await setup();
  await Bun.write(`${dir}/package.json`, JSON.stringify({ name: "probe", prettier: {} }));
  await Bun.write(`${dir}/probe.json`, UNFORMATTED);
  await Bun.write(`${dir}/bin/bunx`, '#!/bin/sh\nprintf "%s\\n" "$@" > "$0.argv"\n');
  Bun.spawnSync(["chmod", "+x", `${dir}/bin/bunx`]);

  const { exitCode } = run(
    dir,
    JSON.stringify({ tool_input: { file_path: `${dir}/probe.json` } }),
    {
      ...Bun.env,
      PATH: `${dir}/bin:${Bun.env.PATH}`,
    },
  );

  expect(exitCode).toBe(0);
  expect(await Bun.file(`${dir}/bin/bunx.argv`).text()).toBe(
    `prettier\n--write\n${dir}/probe.json\n`,
  );
  expect(await logLines(dir)).toEqual([expect.stringMatching(/prettier exit=0 .*probe\.json$/)]);
});

test("formats via oxfmt from tool_input.file_path", async () => {
  const dir = await setup();
  await Bun.write(`${dir}/.oxfmtrc.json`, "{}");
  await Bun.write(`${dir}/probe.json`, UNFORMATTED);

  const { exitCode } = run(dir, JSON.stringify({ tool_input: { file_path: `${dir}/probe.json` } }));

  expect(exitCode).toBe(0);
  const text = await Bun.file(`${dir}/probe.json`).text();
  expect(text).not.toBe(UNFORMATTED);
  expect(text.trim()).toBe(FORMATTED);
  expect(await Bun.file(`${dir}/probe.json`).json()).toEqual({ a: 1, b: [1, 2] });
  expect(await logLines(dir)).toEqual([expect.stringMatching(/oxfmt exit=0 .*probe\.json$/)]);
});

test("formats via oxfmt from tool_response.filePath", async () => {
  const dir = await setup();
  await Bun.write(`${dir}/.oxfmtrc.json`, "{}");
  await Bun.write(`${dir}/probe.json`, UNFORMATTED);

  const { exitCode } = run(
    dir,
    JSON.stringify({ tool_response: { filePath: `${dir}/probe.json` } }),
  );

  expect(exitCode).toBe(0);
  const text = await Bun.file(`${dir}/probe.json`).text();
  expect(text).not.toBe(UNFORMATTED);
  expect(text.trim()).toBe(FORMATTED);
  expect(await Bun.file(`${dir}/probe.json`).json()).toEqual({ a: 1, b: [1, 2] });
  expect(await logLines(dir)).toEqual([expect.stringMatching(/oxfmt exit=0 .*probe\.json$/)]);
});

test("ignores empty stdin", async () => {
  const dir = await setup();

  expect(run(dir, "").exitCode).toBe(0);
  expect(await Bun.file(`${dir}/format.js.log`).exists()).toBe(false);
});

test("ignores malformed stdin", async () => {
  const dir = await setup();

  expect(run(dir, "not json").exitCode).toBe(0);
  expect(await Bun.file(`${dir}/format.js.log`).exists()).toBe(false);
});

test("leaves files untouched with no formatter config", async () => {
  const dir = await setup();
  await Bun.write(`${dir}/probe.json`, UNFORMATTED);

  const { exitCode } = run(dir, JSON.stringify({ tool_input: { file_path: `${dir}/probe.json` } }));

  expect(exitCode).toBe(0);
  expect(await Bun.file(`${dir}/probe.json`).text()).toBe(UNFORMATTED);
  expect(await Bun.file(`${dir}/format.js.log`).exists()).toBe(false);
});
