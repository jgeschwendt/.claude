#!/usr/bin/env bun
// @ts-check

/** Append a timestamped entry to `<script>.log`. */
const log = async (/** @type {string} */ message) => {
  const file = Bun.file(`${import.meta.filename}.log`);
  const prev = (await file.exists()) ? await file.text() : "";
  await Bun.write(file, `${prev}[${new Date().toISOString()}] ${message}\n`);
};

try {
  const data = await Bun.stdin.json();
  await log(JSON.stringify(data, undefined, 2));
} catch (error) {
  if (error instanceof Error) {
    await log(`${error.name}: ${error.message}\n${error.stack}`);
  } else {
    await log(`Error: ${String(error)}`);
  }
}
