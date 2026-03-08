# Memory Layer

This document describes the optional `memento-memory` layer that sits next to the repo-local core.

It is not the same thing as the installed repository context system.

## Core Distinction

Memento has three different layers:

1. Core
   - repo-local project truth
   - canonical docs, generated maps, gates, and git workflow
2. Memory
   - agent-local identity, relationship context, lessons, daily logs, and layered long-term memory
3. Runtime
   - orchestration platform integration, scheduled distillation, vector retrieval, and cross-agent message wiring

The most important rule is:

- do not mix project truth with agent psyche

Project truth belongs in the repository.
Agent identity and personal memory belong in an agent workspace.

## What The Memory Layer Is For

Use the memory layer when the same agent needs to:

- resume work across many sessions
- preserve relationship or persona context
- accumulate lessons from repeated mistakes
- keep daily journals or operator notes
- run nightly memory distillation

Do not use the memory layer just to avoid writing canonical project docs.

## Workspace Shape

The optional memory workspace uses this structure:

```text
agent-workspace/
├── SOUL.md
├── USER.md
├── AGENTS.md
├── MEMORY.md
├── HEARTBEAT.md
├── TOOLS.md
├── compound/
│   ├── lessons.md
│   └── context.md
├── memory/
│   └── YYYY-MM-DD.md
└── drafts/
```

## File Roles

- `SOUL.md`
  - identity, persona, tone, non-negotiable traits
- `USER.md`
  - who the agent is serving and important preference context
- `AGENTS.md`
  - operating rules for the agent itself
  - keep this short and tiered
- `MEMORY.md`
  - layered long-term memory such as M0/M30/M90/M365
- `HEARTBEAT.md`
  - pending background checks or periodic duties
- `TOOLS.md`
  - what tools exist and how the agent should use them
- `compound/lessons.md`
  - distilled lessons and anti-patterns
- `compound/context.md`
  - current high-level context summary or working thread
- `memory/YYYY-MM-DD.md`
  - daily journal or session log

## Layering Model

The default memory template uses four tiers:

- `M0`
  - durable identity and critical invariants
- `M30`
  - recent working memory with a roughly 30-day horizon
- `M90`
  - medium-lived project or relationship memory
- `M365`
  - long-lived but not truly permanent memory

The kit does not force a specific promotion algorithm.
It only makes the layer visible and versionable.

## Why This Is Separate From Core

Core and memory solve different problems.

Core answers:

- what is true about the project?
- what should any agent read first?
- what boundaries are canonical?

Memory answers:

- who am I?
- who am I working with?
- what happened recently?
- what patterns have I learned?

If those are mixed, both degrade.

## Bootstrap

To create an agent memory workspace:

```bash
bash /path/to/memento-kit/setup-memory.sh \
  --target ./zeon-workspace \
  --agent-name Zeon \
  --agent-role "orchestrator" \
  --user-name "Simon"
```

This creates the memory workspace skeleton and initializes git if needed.

## What It Does Not Do

The memory layer intentionally does not include:

- vector retrieval infrastructure
- cron scheduling
- platform-specific project-context injection
- cross-agent relay wiring

Those belong to the runtime layer, not to the portable memory layer.

## Recommended Adoption Order

1. Install the repo-local core with `setup.sh`
2. Fill the canonical docs until `docs:check` is meaningful
3. Create one agent memory workspace with `setup-memory.sh`
4. Only then add runtime integrations like nightly distill or vector retrieval
