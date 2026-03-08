#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const rootDir = process.cwd();
const config = JSON.parse(fs.readFileSync(path.join(rootDir, 'runtime-config.json'), 'utf8'));
const coreRepo = path.resolve(rootDir, config.paths.coreRepo);
const memoryWorkspace = path.resolve(rootDir, config.paths.memoryWorkspace);
const generatedDir = path.resolve(rootDir, config.paths.generatedDir ?? 'generated');
const outputPath = path.join(generatedDir, 'project-context-bundle.md');

function readSafe(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
}

function latestDailyFile(memoryDir) {
  if (!fs.existsSync(memoryDir)) return null;
  const candidates = fs.readdirSync(memoryDir)
    .filter((name) => /^\d{4}-\d{2}-\d{2}\.md$/.test(name))
    .sort();
  if (!candidates.length) return null;
  return path.join(memoryDir, candidates[candidates.length - 1]);
}

const dailyPath = latestDailyFile(path.join(memoryWorkspace, 'memory'));
const sections = [
  '# Project Context Bundle',
  '',
  `- Agent: \`${config.agent.name}\``,
  `- Platform: \`${config.platform.name}\``,
  `- Core repo: \`${coreRepo}\``,
  `- Memory workspace: \`${memoryWorkspace}\``,
  '',
  '## Core Collaboration Surface',
  '',
  'Start here:',
  '- `README.md`',
  '- `AGENTS.md`',
  '- `docs/README.md`',
  '',
  '## Identity',
  '',
  readSafe(path.join(memoryWorkspace, 'SOUL.md')).trim() || '_missing SOUL.md_',
  '',
  '## User Context',
  '',
  readSafe(path.join(memoryWorkspace, 'USER.md')).trim() || '_missing USER.md_',
  '',
  '## Agent Rules',
  '',
  readSafe(path.join(memoryWorkspace, 'AGENTS.md')).trim() || '_missing AGENTS.md_',
  '',
  '## Long-Term Memory',
  '',
  readSafe(path.join(memoryWorkspace, 'MEMORY.md')).trim() || '_missing MEMORY.md_',
  '',
  '## Lessons',
  '',
  readSafe(path.join(memoryWorkspace, 'compound/lessons.md')).trim() || '_missing lessons.md_',
  '',
  '## Latest Daily Memory',
  '',
  dailyPath ? readSafe(dailyPath).trim() : '_no daily memory file found_',
  '',
];

fs.mkdirSync(generatedDir, { recursive: true });
fs.writeFileSync(outputPath, `${sections.join('\n')}\n`);
console.log(`[runtime:bundle] wrote ${path.relative(rootDir, outputPath)}`);
