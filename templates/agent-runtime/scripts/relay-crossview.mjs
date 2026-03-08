#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const rootDir = process.cwd();
const config = JSON.parse(fs.readFileSync(path.join(rootDir, 'runtime-config.json'), 'utf8'));

function usage() {
  console.log('Usage: node scripts/relay-crossview.mjs --from <agent> --to <a,b,c> --message <text> [--channel <id>] [--json]');
}

const args = process.argv.slice(2);
let from = '';
let to = '';
let message = '';
let channel = 'group';
let json = false;

for (let i = 0; i < args.length; i += 1) {
  const arg = args[i];
  if (arg === '--from') from = args[++i] ?? '';
  else if (arg === '--to') to = args[++i] ?? '';
  else if (arg === '--message') message = args[++i] ?? '';
  else if (arg === '--channel') channel = args[++i] ?? '';
  else if (arg === '--json') json = true;
  else if (arg === '-h' || arg === '--help') {
    usage();
    process.exit(0);
  }
}

if (!from || !to || !message) {
  usage();
  process.exit(1);
}

const prefix = config.crossview?.prefix ?? '[group crossview]';
const noRelayPrefix = config.crossview?.noRelayPrefix ?? prefix;
if (message.startsWith(noRelayPrefix)) {
  console.error('[runtime:relay] message already has no-relay prefix; refusing to rebroadcast.');
  process.exit(1);
}

const recipients = to.split(',').map((item) => item.trim()).filter(Boolean);
const payload = {
  from,
  to: recipients,
  channel,
  prefix,
  body: message,
  rendered: `${prefix} ${from}: ${message}`,
};

if (json) {
  process.stdout.write(`${JSON.stringify(payload, null, 2)}\n`);
} else {
  process.stdout.write(`${payload.rendered}\n`);
}
