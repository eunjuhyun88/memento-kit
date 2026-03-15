#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {
  currentBranch,
  loadConfig,
  normalizeRepoPath,
  readClaims,
  resolveRootDir,
  run,
  sanitize,
  validateSurfaceId,
} from './coordination-lib.mjs';
import {
  orchestrationConfig,
  readWorkItems,
  resolveDependencyState,
} from './orchestration-lib.mjs';

const PRIORITY_ORDER = { p0: 0, p1: 1, p2: 2, p3: 3 };

function usage() {
  console.log('Usage: node scripts/dev/autopilot-work.mjs --mode <start|sync> [options]');
  console.log('');
  console.log('Start options:');
  console.log('  --work-id <id>         explicit work item or claim id');
  console.log('  --pick ready           claim the highest-priority ready work item');
  console.log('  --agent <name>         agent id for the claim/save flow');
  console.log('  --surface <surface>    override or fill missing surface');
  console.log('  --summary <text>       override claim summary');
  console.log('  --objective <text>     checkpoint objective override');
  console.log('  --path <prefix>        extra owned path prefix for coord:claim');
  console.log('  --doc <path>           extra canonical doc reference');
  console.log('  --depends-on <id>      extra dependency id when creating a claim');
  console.log('  --lease-minutes <n>    override coordination lease length');
  console.log('  --force                allow starting work that is not currently ready');
  console.log('');
  console.log('Sync options:');
  console.log('  --work-id <id>         sync a specific work id or use the current pointer');
  console.log('');
  console.log('Shared options:');
  console.log('  --skip-checkpoint      skip ctx:checkpoint during start');
  console.log('  --skip-resume          skip ctx:resume during start');
  console.log('  --skip-save            skip ctx:save');
  console.log('  --skip-compact         skip ctx:compact');
  console.log('  --skip-check           skip orch:check');
  console.log('  --dry-run              print commands without executing them');
}

function unique(items) {
  return [...new Set((items ?? []).filter(Boolean))];
}

function sortReadyQueue(items) {
  return [...items].sort((left, right) => {
    const priorityDelta = (PRIORITY_ORDER[left.priority] ?? 99) - (PRIORITY_ORDER[right.priority] ?? 99);
    if (priorityDelta !== 0) return priorityDelta;
    const leftUpdated = Date.parse(left.updatedAt ?? left.createdAt ?? '') || 0;
    const rightUpdated = Date.parse(right.updatedAt ?? right.createdAt ?? '') || 0;
    if (leftUpdated !== rightUpdated) return leftUpdated - rightUpdated;
    return String(left.workId ?? '').localeCompare(String(right.workId ?? ''));
  });
}

function shellQuote(value) {
  const raw = String(value ?? '');
  if (raw === '') return "''";
  return `'${raw.replaceAll("'", `'\\''`)}'`;
}

function pointerPaths(rootDir, branch) {
  const branchSafe = sanitize(String(branch ?? '').replaceAll('/', '-'));
  const baseDir = path.join(rootDir, '.agent-context');
  return {
    branchPointer: path.join(baseDir, 'coordination', 'branches', `${branchSafe}.json`),
    latestWorkId: path.join(baseDir, 'runtime', `${branchSafe}.latest-work-id`),
    legacyWorkId: path.join(baseDir, 'runtime', `${branchSafe}.work-id`),
  };
}

function readBranchPointerWorkId(rootDir, branch) {
  const files = pointerPaths(rootDir, branch);
  if (fs.existsSync(files.branchPointer)) {
    try {
      const value = JSON.parse(fs.readFileSync(files.branchPointer, 'utf8'));
      if (value?.workId) {
        return String(value.workId);
      }
    } catch {
      // Ignore malformed runtime pointers.
    }
  }
  for (const filePath of [files.latestWorkId, files.legacyWorkId]) {
    if (!fs.existsSync(filePath)) continue;
    const value = fs.readFileSync(filePath, 'utf8').trim();
    if (value) return value;
  }
  return '';
}

function autopilotConfig(config) {
  return {
    enabled: config.autopilot?.enabled ?? true,
    allowReadyQueuePickup: config.autopilot?.allowReadyQueuePickup ?? true,
    defaultAgent: String(config.autopilot?.defaultAgent ?? process.env.USER ?? 'agent').trim() || 'agent',
    runSaveAfterStart: config.autopilot?.runSaveAfterStart ?? true,
    runCompactAfterStart: config.autopilot?.runCompactAfterStart ?? true,
    runCompactAfterSync: config.autopilot?.runCompactAfterSync ?? true,
    runOrchestrationCheck: config.autopilot?.runOrchestrationCheck ?? true,
  };
}

function execStep(rootDir, options, command, args) {
  const printable = [command, ...args].map(shellQuote).join(' ');
  console.log(options.dryRun ? `[pilot] dry-run: ${printable}` : `[pilot] run: ${printable}`);
  if (options.dryRun) return;
  const result = run(command, args, { cwd: rootDir, stdio: 'inherit' });
  if (result.status !== 0) {
    throw new Error(`[pilot] step failed: ${command} ${args.join(' ')}`);
  }
}

function parseArgs(argv) {
  const options = {
    mode: '',
    workId: '',
    pick: '',
    agent: '',
    surface: '',
    summary: '',
    objective: '',
    leaseMinutes: '',
    paths: [],
    docs: [],
    dependsOn: [],
    force: false,
    skipCheckpoint: false,
    skipResume: false,
    skipSave: false,
    skipCompact: false,
    skipCheck: false,
    dryRun: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const current = argv[index];
    const next = argv[index + 1];
    if (current === '--mode') {
      options.mode = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--work-id') {
      options.workId = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--pick') {
      options.pick = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--agent') {
      options.agent = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--surface') {
      options.surface = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--summary') {
      options.summary = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--objective') {
      options.objective = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--lease-minutes') {
      options.leaseMinutes = next ?? '';
      index += 1;
      continue;
    }
    if (current === '--path') {
      options.paths.push(normalizeRepoPath(next ?? ''));
      index += 1;
      continue;
    }
    if (current === '--doc') {
      options.docs.push(normalizeRepoPath(next ?? ''));
      index += 1;
      continue;
    }
    if (current === '--depends-on') {
      options.dependsOn.push(next ?? '');
      index += 1;
      continue;
    }
    if (current === '--force') {
      options.force = true;
      continue;
    }
    if (current === '--skip-checkpoint') {
      options.skipCheckpoint = true;
      continue;
    }
    if (current === '--skip-resume') {
      options.skipResume = true;
      continue;
    }
    if (current === '--skip-save') {
      options.skipSave = true;
      continue;
    }
    if (current === '--skip-compact') {
      options.skipCompact = true;
      continue;
    }
    if (current === '--skip-check') {
      options.skipCheck = true;
      continue;
    }
    if (current === '--dry-run') {
      options.dryRun = true;
      continue;
    }
    if (current === '-h' || current === '--help') {
      usage();
      process.exit(0);
    }
    throw new Error(`[pilot] unknown option: ${current}`);
  }

  return options;
}

function resolveSelection(rootDir, config, options) {
  const orchestration = orchestrationConfig(config);
  const branch = currentBranch(rootDir);
  const claims = readClaims(rootDir);
  const branchClaim = claims.find((claim) => claim.branch === branch) ?? null;
  const pointerWorkId = readBranchPointerWorkId(rootDir, branch);
  const rawItems = readWorkItems(rootDir, config);
  const items = rawItems.map((item) => ({
    ...item,
    ...resolveDependencyState(item, rawItems, orchestration),
  }));

  let source = 'explicit';
  let resolvedWorkId = options.workId;

  if (!resolvedWorkId && branchClaim?.workId) {
    resolvedWorkId = branchClaim.workId;
    source = 'branch-claim';
  } else if (!resolvedWorkId && pointerWorkId) {
    resolvedWorkId = pointerWorkId;
    source = 'branch-pointer';
  } else if (!resolvedWorkId && options.pick === 'ready') {
    if (!autopilotConfig(config).allowReadyQueuePickup) {
      throw new Error('[pilot] ready-queue pickup is disabled in context-kit.json');
    }
    const claimedWorkIds = new Set(claims.map((claim) => claim.workId));
    const candidate = sortReadyQueue(
      items
        .filter((item) => item.readyNow)
        .filter((item) => !claimedWorkIds.has(item.workId))
        .filter((item) => !options.surface || item.surface === options.surface),
    )[0];
    if (!candidate) {
      throw new Error('[pilot] no ready orchestration item is available to start');
    }
    resolvedWorkId = candidate.workId;
    source = 'ready-queue';
  }

  if (!resolvedWorkId) {
    throw new Error('[pilot] resolve a work item with --work-id, an active branch pointer, or --pick ready');
  }

  const workItem = items.find((item) => item.workId === resolvedWorkId) ?? null;
  const matchingClaim = claims.find((claim) => claim.workId === resolvedWorkId) ?? null;
  const otherBranchClaim = matchingClaim && matchingClaim.branch !== branch ? matchingClaim : null;

  const selection = {
    source,
    branch,
    branchClaim,
    workId: resolvedWorkId,
    workItem,
    claim: matchingClaim,
    otherBranchClaim,
    summary: options.summary || workItem?.summary || matchingClaim?.summary || resolvedWorkId,
    surface: options.surface || workItem?.surface || matchingClaim?.surface || '',
    paths: unique([...(workItem?.paths ?? []), ...(matchingClaim?.paths ?? []), ...options.paths]),
    docs: unique([...(workItem?.docs ?? []), ...options.docs]),
    dependsOn: unique([...(workItem?.dependsOn ?? []), ...(matchingClaim?.dependsOn ?? []), ...options.dependsOn]),
  };

  if (selection.surface) {
    validateSurfaceId(config, selection.surface);
  }

  return selection;
}

function assertStartable(selection, options) {
  if (selection.otherBranchClaim) {
    throw new Error(`[pilot] work \`${selection.workId}\` is already claimed on branch \`${selection.otherBranchClaim.branch}\``);
  }

  if (
    selection.branchClaim &&
    selection.branchClaim.workId !== selection.workId
  ) {
    throw new Error(`[pilot] branch \`${selection.branch}\` already owns \`${selection.branchClaim.workId}\`; release it before starting \`${selection.workId}\``);
  }

  if (!selection.surface) {
    throw new Error(`[pilot] work \`${selection.workId}\` needs a surface; add one with orch:work or --surface`);
  }

  if (!selection.summary) {
    throw new Error(`[pilot] work \`${selection.workId}\` needs a summary; add one with orch:work or --summary`);
  }

  const item = selection.workItem;
  if (!item || options.force) return;
  if (item.missingDependencies.length > 0) {
    throw new Error(`[pilot] work \`${selection.workId}\` is missing dependencies: ${item.missingDependencies.join(', ')}`);
  }
  if (item.openDependencies.length > 0) {
    throw new Error(`[pilot] work \`${selection.workId}\` is still blocked by: ${item.openDependencies.join(', ')}`);
  }
  if (!selection.claim && !['ready', 'active'].includes(item.status)) {
    throw new Error(`[pilot] work \`${selection.workId}\` is \`${item.status}\`; use --force only if you intentionally want to bypass queue state`);
  }
}

function startWork(rootDir, config, autopilot, options, selection) {
  assertStartable(selection, options);

  const agent = options.agent || autopilot.defaultAgent;
  const objective = options.objective || selection.summary;
  const hasClaim = selection.claim && selection.claim.branch === selection.branch;

  if (!hasClaim) {
    const claimArgs = [
      'scripts/dev/claim-work.mjs',
      '--work-id', selection.workId,
      '--agent', agent,
      '--surface', selection.surface,
      '--summary', selection.summary,
    ];
    for (const value of selection.paths) {
      claimArgs.push('--path', value);
    }
    for (const value of selection.docs) {
      claimArgs.push('--doc', value);
    }
    for (const value of selection.dependsOn) {
      claimArgs.push('--depends-on', value);
    }
    if (options.leaseMinutes) {
      claimArgs.push('--lease-minutes', options.leaseMinutes);
    }
    execStep(rootDir, options, 'node', claimArgs);
  }

  if (!options.skipCheckpoint) {
    const checkpointArgs = [
      'scripts/dev/context-checkpoint.sh',
      '--work-id', selection.workId,
      '--surface', selection.surface,
      '--objective', objective,
    ];
    for (const value of selection.docs) {
      checkpointArgs.push('--doc', value);
    }
    for (const value of selection.paths) {
      checkpointArgs.push('--file', value);
    }
    execStep(rootDir, options, 'bash', checkpointArgs);
  }

  if (!options.skipSave && autopilot.runSaveAfterStart) {
    execStep(rootDir, options, 'bash', [
      'scripts/dev/context-save.sh',
      '--title', `pilot-start:${selection.workId}`,
      '--work-id', selection.workId,
      '--agent', agent,
      '--notes', `Autopilot start from ${selection.source}.`,
    ]);
  }

  if (!options.skipResume) {
    execStep(rootDir, options, 'bash', ['scripts/dev/context-restore.sh', '--mode', 'resume']);
  }

  if (!options.skipCompact && autopilot.runCompactAfterStart) {
    execStep(rootDir, options, 'bash', ['scripts/dev/context-compact.sh', '--work-id', selection.workId]);
  }

  if (!options.skipCheck && autopilot.runOrchestrationCheck && orchestrationConfig(config).enabled) {
    execStep(rootDir, options, 'node', ['scripts/dev/check-orchestration-work.mjs']);
  }

  console.log(`[pilot] started: ${selection.workId}`);
}

function syncWork(rootDir, config, autopilot, options, selection) {
  const agent = options.agent || autopilot.defaultAgent;

  if (!options.skipSave) {
    execStep(rootDir, options, 'bash', [
      'scripts/dev/context-save.sh',
      '--title', `pilot-sync:${selection.workId}`,
      '--work-id', selection.workId,
      '--agent', agent,
      '--notes', `Autopilot sync from ${selection.source}.`,
    ]);
  }

  if (!options.skipCompact && autopilot.runCompactAfterSync) {
    execStep(rootDir, options, 'bash', ['scripts/dev/context-compact.sh', '--work-id', selection.workId]);
  }

  if (!options.skipCheck && autopilot.runOrchestrationCheck && orchestrationConfig(config).enabled) {
    execStep(rootDir, options, 'node', ['scripts/dev/check-orchestration-work.mjs']);
  }

  console.log(`[pilot] synced: ${selection.workId}`);
}

const rootDir = resolveRootDir();
const config = loadConfig(rootDir);
const autopilot = autopilotConfig(config);
if (!autopilot.enabled) {
  console.log('[pilot] autopilot disabled in context-kit.json');
  process.exit(0);
}

const options = parseArgs(process.argv.slice(2));
if (!['start', 'sync'].includes(options.mode)) {
  usage();
  process.exit(1);
}
if (options.pick && options.pick !== 'ready') {
  throw new Error(`[pilot] unsupported --pick value: ${options.pick}`);
}
if (options.mode === 'start' && !options.workId && !options.pick) {
  // Resume-first behavior is allowed, but make the resolution source explicit in user output.
  console.log('[pilot] no explicit work-id supplied; resolving from the current branch pointer first');
}

const selection = resolveSelection(rootDir, config, options);

if (options.mode === 'start') {
  startWork(rootDir, config, autopilot, options, selection);
} else {
  syncWork(rootDir, config, autopilot, options, selection);
}
