# Runtime Layer

This document describes the optional `memento-runtime` layer.

It is separate from both the repo-local core and the agent-memory workspace.

## Layer Model

Memento has three layers:

1. Core
   - project truth inside the repository
2. Memory
   - agent-local identity and long-term memory workspace
3. Runtime
   - the operating layer that injects, distills, retrieves, schedules, and relays

## What The Runtime Layer Is For

Use the runtime layer when you need:

- a stable session boot bundle
- nightly distillation reports
- retrieval indexes over agent memory
- cross-agent relay formatting and loop control
- adapter-specific configuration for systems like OpenClaw

The runtime layer should consume the core and memory layers.
It should not replace them.

## Workspace Shape

```text
agent-runtime/
├── README.md
├── runtime-config.json
├── adapters/
│   ├── README.md
│   └── openclaw.md
├── prompts/
│   ├── session-boot.md
│   ├── nightly-memory-distill.md
│   └── cross-agent-relay.md
├── jobs/
│   ├── nightly-memory-distill.json
│   ├── session-boot.json
│   └── cross-agent-relay.json
├── scripts/
│   ├── check-runtime-config.mjs
│   ├── build-project-context-bundle.mjs
│   ├── build-memory-index.mjs
│   ├── distill-memory.mjs
│   └── relay-crossview.mjs
└── generated/
```

## What This Layer Generates

- `generated/project-context-bundle.md`
  - the always-inject bundle for session boot
- `generated/memory-index.json`
  - simple chunk index over memory files
- `generated/memory-index.md`
  - human-readable memory index summary
- `generated/nightly-distill-report.md`
  - candidate promotions, expiring items, and daily-log review summary

## Why This Layer Must Stay Separate

Core must stay stable, reviewable, and team-shared.
Memory must stay identity-specific and agent-local.
Runtime must stay platform-adapter aware.

If runtime wiring is pushed into the core repo:

- canonical docs get polluted with scheduler and transport details
- platform-specific logic becomes harder to swap
- agent identity gets mixed with project truth

## Bootstrap

Create a runtime workspace like this:

```bash
bash /path/to/memento-kit/setup-runtime.sh \
  --target ./zeon-runtime \
  --agent-name Zeon \
  --core-repo /path/to/project-repo \
  --memory-workspace /path/to/zeon-workspace \
  --platform openclaw
```

## Verification Flow

After bootstrap:

```bash
node scripts/check-runtime-config.mjs
node scripts/build-project-context-bundle.mjs
node scripts/build-memory-index.mjs
node scripts/distill-memory.mjs
node scripts/relay-crossview.mjs --from sion --to zeon,mion --message "hello"
```

## Scope

The runtime layer in the kit is intentionally generic.

It gives you:

- structure
- prompts
- reports
- config contracts
- working low-risk scripts

It does not try to fully implement:

- a production vector database
- a scheduler daemon
- a full OpenClaw runtime
- direct model API execution

Those stay adapter-specific.
