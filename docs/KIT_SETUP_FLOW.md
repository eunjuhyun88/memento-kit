# Kit Setup Flow

## Purpose

This document explains exactly what happens when someone runs:

```bash
bash setup.sh --target <repo> --project-name <name> [options]
```

It also notes where the optional `setup-memory.sh` and `setup-runtime.sh` flows begin once the core repo exists.

## Inputs

Accepted setup inputs:

- `--target`
- `--project-name`
- `--summary`
- `--stack`
- `--phase`
- `--deadline`
- `--surfaces`
- `--main-branch`
- `--force`

## Output Shape

After setup, the target repository should have:

- root collaboration docs
- Claude-native `.claude/` layer
- `.github/workflows/`
- structured `docs/`
- `scripts/dev/`
- `.githooks/`
- `prompts/`
- `lint/`
- `context-kit.json`
- injected npm scripts in `package.json`
- initial generated docs

## Setup Sequence

### 1. Copy template tree

`setup.sh` copies `templates/repo/` into the target.

Files are not overwritten unless `--force` is supplied.

### 2. Render markdown placeholders

Only markdown files are placeholder-rendered.

Rendered values:

- `__PROJECT_NAME__`
- `__PROJECT_SUMMARY__`
- `__PROJECT_STACK__`
- `__PROJECT_PHASE__`
- `__PROJECT_DEADLINE__`
- `__MAIN_BRANCH__`
- `__TODAY__`

The script intentionally does not rewrite `.sh`, `.mjs`, or `.json` files with these placeholders because doing so would corrupt internal checker logic.

### 3. Write `context-kit.json`

`setup.sh` creates a repo-local configuration file that defines:

- project metadata
- main branch name
- discovery paths
- surfaces
- harness defaults
- coordination defaults
- optional project command integration

This file is the primary target-specific input to the generic scripts.

### 4. Write initial product spec files

The `--surfaces` list is expanded into:

- `docs/product-specs/<surface>.md`
- `docs/product-specs/index.md`

Each surface file contains:

- purpose
- done means
- context contracts for routes, stores, APIs

### 5. Extend `.gitignore`

The setup appends:

- `.agent-context/`
- `context-kit.local.json`
- `.codex/`

### 6. Inject npm scripts

If Node is available, setup updates or creates `package.json` and injects:

- `docs:*`
- `safe:*`
- `ctx:*`
- `coord:*`
- `claude:*`
- `ci:*`
- `harness:*`

The script only adds missing keys. It does not overwrite existing matching script names.

### 7. Generate initial derived docs and Claude compatibility bootstrap

If Node is available, setup runs:

```bash
node scripts/dev/refresh-generated-context.mjs
node scripts/dev/refresh-doc-governance.mjs
node scripts/dev/bootstrap-project-truth.mjs
node scripts/dev/bootstrap-claude-compat.mjs
```

This creates the first generated docs so `docs:check` has a stable baseline immediately after setup.

### 8. Configure git hooks path

If the target is already a git repository, setup configures:

```bash
git config core.hooksPath .githooks
```

## Resulting State

The target repository is expected to be immediately ready for:

- `npm run docs:check`
- `npm run safe:hooks`
- `npm run claude:bootstrap`
- `npm run ctx:save`
- `npm run ctx:checkpoint`
- `npm run ctx:compact`

## First Human Tasks After Setup

Setup is intentionally not the end of the process.

The human owner should then:

1. review `context-kit.json`
2. fill in `docs/SYSTEM_INTENT.md`
3. fill in `ARCHITECTURE.md`
4. replace generic `docs/product-specs/*.md` text with real product truth
5. wire real `commands.check`, `commands.build`, and optionally `commands.gate`

Until that happens, the repo has structure and enforcement, but the semantic content is still skeletal.

## Optional Follow-On Bootstraps

After the core repo exists, you can add:

- `setup-memory.sh`
  - for agent identity, layered memory, heartbeat, lessons, and daily memory
- `setup-runtime.sh`
  - for platform-specific boot injection, nightly distill, memory indexing, and cross-agent relay

Those are separate on purpose:

- core repo = project truth
- memory workspace = agent identity and long-term memory
- runtime workspace = operational wiring
