#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const rootDir = process.cwd();
const config = JSON.parse(fs.readFileSync(path.join(rootDir, 'runtime-config.json'), 'utf8'));
const memoryWorkspace = path.resolve(rootDir, config.paths.memoryWorkspace);
const generatedDir = path.resolve(rootDir, config.paths.generatedDir ?? 'generated');
const outputPath = path.resolve(rootDir, config.distill?.reportPath ?? 'generated/nightly-distill-report.md');

function read(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
}

function listDaily(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir)
    .filter((name) => /^\d{4}-\d{2}-\d{2}\.md$/.test(name))
    .sort()
    .map((name) => path.join(dir, name));
}

function countLayerItems(text, heading) {
  const lines = text.split('\n');
  let inSection = false;
  let count = 0;
  for (const line of lines) {
    if (line.trim() === `## ${heading}`) {
      inSection = true;
      continue;
    }
    if (inSection && line.startsWith('## ')) break;
    if (inSection && line.trim().startsWith('- ')) count += 1;
  }
  return count;
}

function expiringItems(text) {
  const results = [];
  for (const line of text.split('\n')) {
    const match = /expires:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})/i.exec(line);
    if (match) results.push({ line: line.trim(), expires: match[1] });
  }
  return results;
}

const memoryText = read(path.join(memoryWorkspace, 'MEMORY.md'));
const lessonText = read(path.join(memoryWorkspace, 'compound/lessons.md'));
const dailyFiles = listDaily(path.join(memoryWorkspace, 'memory'));
const recentDaily = dailyFiles.slice(-3);
const expiring = expiringItems(memoryText);

const report = [
  '# Nightly Distill Report',
  '',
  `- Agent: \`${config.agent.name}\``,
  `- Platform: \`${config.platform.name}\``,
  `- Reviewed daily files: \`${recentDaily.length}\``,
  '',
  '## Memory Layers',
  '',
  `- M0 items: \`${countLayerItems(memoryText, 'M0 : Core Memory')}\``,
  `- M30 items: \`${countLayerItems(memoryText, 'M30 : 30-Day Memory')}\``,
  `- M90 items: \`${countLayerItems(memoryText, 'M90 : 90-Day Memory')}\``,
  `- M365 items: \`${countLayerItems(memoryText, 'M365 : 1-Year Memory')}\``,
  '',
  '## Expiring Items',
  '',
  ...(expiring.length ? expiring.map((item) => `- ${item.line}`) : ['- none']),
  '',
  '## Recent Daily Files',
  '',
  ...(recentDaily.length ? recentDaily.map((filePath) => `- \`${path.relative(memoryWorkspace, filePath).split(path.sep).join('/')}\``) : ['- none']),
  '',
  '## Lesson Signals',
  '',
  ...(lessonText.trim() ? ['- lessons file is present and should be reviewed for promotion or pruning'] : ['- no lessons recorded yet']),
  '',
  '## Recommended Actions',
  '',
  '- promote repeated recent themes manually from daily logs into M30/M90/M365',
  '- convert repeated failures into `compound/lessons.md`',
  '- remove or rewrite expiring entries that are no longer useful',
  '- keep mutation separate from this report unless explicitly approved',
  '',
];

fs.mkdirSync(generatedDir, { recursive: true });
fs.writeFileSync(outputPath, `${report.join('\n')}\n`);
console.log(`[runtime:distill] wrote ${path.relative(rootDir, outputPath)}`);
