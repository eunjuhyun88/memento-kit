#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const rootDir = process.cwd();
const configPath = path.join(rootDir, 'runtime-config.json');

function fail(message) {
  console.error(`[runtime:check] fail: ${message}`);
  process.exitCode = 1;
}

function ok(message) {
  console.log(`[runtime:check] ok: ${message}`);
}

if (!fs.existsSync(configPath)) {
  fail('runtime-config.json missing');
  process.exit(process.exitCode ?? 1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const coreRepo = path.resolve(rootDir, config.paths?.coreRepo ?? '');
const memoryWorkspace = path.resolve(rootDir, config.paths?.memoryWorkspace ?? '');
const generatedDir = path.resolve(rootDir, config.paths?.generatedDir ?? 'generated');

for (const [label, target] of [
  ['core repo', coreRepo],
  ['memory workspace', memoryWorkspace],
]) {
  if (fs.existsSync(target)) ok(`${label} exists: ${target}`);
  else fail(`${label} missing: ${target}`);
}

for (const rel of ['README.md', 'AGENTS.md', 'docs/README.md']) {
  const full = path.join(coreRepo, rel);
  if (fs.existsSync(full)) ok(`core doc exists: ${rel}`);
  else fail(`core doc missing: ${rel}`);
}

for (const rel of ['SOUL.md', 'USER.md', 'AGENTS.md', 'MEMORY.md', 'compound/lessons.md']) {
  const full = path.join(memoryWorkspace, rel);
  if (fs.existsSync(full)) ok(`memory file exists: ${rel}`);
  else fail(`memory file missing: ${rel}`);
}

fs.mkdirSync(generatedDir, { recursive: true });
ok(`generated dir ready: ${path.relative(rootDir, generatedDir)}`);

if (process.exitCode) {
  console.error('[runtime:check] runtime config validation failed.');
  process.exit(process.exitCode);
}

console.log('[runtime:check] runtime config validation passed.');
