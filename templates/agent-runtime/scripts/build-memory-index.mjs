#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const rootDir = process.cwd();
const config = JSON.parse(fs.readFileSync(path.join(rootDir, 'runtime-config.json'), 'utf8'));
const memoryWorkspace = path.resolve(rootDir, config.paths.memoryWorkspace);
const generatedDir = path.resolve(rootDir, config.paths.generatedDir ?? 'generated');
const outputJson = path.join(generatedDir, 'memory-index.json');
const outputMd = path.join(generatedDir, 'memory-index.md');

function read(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
}

function listMarkdown(dir) {
  if (!fs.existsSync(dir)) return [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...listMarkdown(full));
    else if (entry.name.endsWith('.md')) files.push(full);
  }
  return files;
}

function chunkWords(text, chunkWords = 120, overlap = 30) {
  const words = text.trim().split(/\s+/).filter(Boolean);
  if (!words.length) return [];
  const chunks = [];
  let index = 0;
  while (index < words.length) {
    const slice = words.slice(index, index + chunkWords);
    chunks.push(slice.join(' '));
    if (index + chunkWords >= words.length) break;
    index += Math.max(1, chunkWords - overlap);
  }
  return chunks;
}

const sourceFiles = [
  path.join(memoryWorkspace, 'SOUL.md'),
  path.join(memoryWorkspace, 'USER.md'),
  path.join(memoryWorkspace, 'AGENTS.md'),
  path.join(memoryWorkspace, 'MEMORY.md'),
  ...listMarkdown(path.join(memoryWorkspace, 'compound')),
  ...listMarkdown(path.join(memoryWorkspace, 'memory')),
].filter((filePath) => fs.existsSync(filePath));

const index = [];
for (const filePath of sourceFiles) {
  const rel = path.relative(memoryWorkspace, filePath).split(path.sep).join('/');
  const chunks = chunkWords(read(filePath), config.retrieval?.chunkWords ?? 120, config.retrieval?.overlapWords ?? 30);
  chunks.forEach((chunk, i) => {
    index.push({
      source: rel,
      chunkId: `${rel}#${i + 1}`,
      text: chunk,
      approxTokens: chunk.split(/\s+/).filter(Boolean).length,
    });
  });
}

fs.mkdirSync(generatedDir, { recursive: true });
fs.writeFileSync(outputJson, `${JSON.stringify({ version: 1, chunkCount: index.length, sources: sourceFiles.length, chunks: index }, null, 2)}\n`);

const markdown = [
  '# Memory Index',
  '',
  `- Sources: \`${sourceFiles.length}\``,
  `- Chunks: \`${index.length}\``,
  '',
  '## Sources',
  '',
  ...sourceFiles.map((filePath) => `- \`${path.relative(memoryWorkspace, filePath).split(path.sep).join('/')}\``),
  '',
];
fs.writeFileSync(outputMd, `${markdown.join('\n')}\n`);
console.log(`[runtime:index] wrote ${path.relative(rootDir, outputJson)}`);
console.log(`[runtime:index] wrote ${path.relative(rootDir, outputMd)}`);
