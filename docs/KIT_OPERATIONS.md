# Kit Operations

## Purpose

This document describes how a team should operate after the kit is installed in a repository.

## Daily Start Routine

Recommended order:

1. `README.md`
2. `AGENTS.md`
3. `docs/README.md`
4. `docs/SYSTEM_INTENT.md`
5. `ARCHITECTURE.md`
6. relevant surface spec(s)

Then:

```bash
npm run safe:status
```

For non-trivial work:

```bash
npm run ctx:checkpoint -- \
  --work-id "W-YYYYMMDD-HHMM-<repo>-<agent>" \
  --surface "<surface>" \
  --objective "<semantic objective>"
```

For parallel work on a feature branch:

```bash
npm run coord:claim -- \
  --work-id "W-YYYYMMDD-HHMM-<repo>-<agent>" \
  --agent "<agent>" \
  --surface "<surface>" \
  --summary "<owned slice>" \
  --path "<prefix>"
```

## During Work

Use:

- `npm run ctx:save`
- `npm run ctx:checkpoint`
- `npm run ctx:compact`
- `npm run ctx:restore -- --mode brief`
- `npm run agent:new -- --id "<agent-id>" --role "<role>" --surface "<surface>"`
- `npm run agent:start -- --agent "<agent-id>" --surface "<surface>"`
- `npm run agent:event -- --type doc_open --path "<repo-path>"`
- `npm run agent:finish -- --status success --baseline-minutes <n>`
- `npm run agent:report`
- `npm run registry:query -- --q "<term>"`
- `npm run registry:describe -- --kind "<kind>" --id "<id>"`
- `npm run retrieve:query -- --q "<term>"`
- `npm run value:demo`

Guideline:

- use docs for stable truth
- use runtime context for transient task state
- keep watch log as evidence only

## Before Push

Expected minimum:

```bash
npm run docs:check
npm run ctx:check -- --strict
npm run coord:check
npm run sandbox:check
```

If project commands are configured, the hook will also run:

- configured `gate`
- configured `check`
- configured `build`

## Hooks

### pre-push

Performs:

- auto context snapshot
- strict context quality check
- coordination conflict check
- remote main-branch sync ancestry check
- context gate
- optional project gate/check/build

### post-merge

Performs:

- context gate
- optional project check
- auto context snapshot

## Worktree Strategy

The kit assumes:

- no direct work on the protected main branch
- per-task branches like `codex/<task-name>`
- clean worktrees are preferred over carrying large dirty trees for long periods
- one active claim per feature branch

Use:

```bash
npm run safe:worktree -- <task-name> [base-branch]
```

## Generated Docs Workflow

When the code shape changes:

```bash
npm run docs:refresh
npm run docs:check
```

This is especially important after:

- route additions
- API additions
- store ownership changes
- surface-spec changes

## Parallel-Work Rules

When multiple agents work at once:

- each agent gets its own branch/worktree
- each feature branch gets one active claim
- each feature-branch claim should declare at least one owned path prefix
- same-surface work must declare explicit non-overlapping `--path` boundaries
- handoff means checkpoint + brief + `coord:release -- --status handoff`

## Harness Workflow

Smoke only:

```bash
npm run harness:smoke -- --base-url http://localhost:4173
```

Browser only:

```bash
npm run harness:browser -- --base-url http://localhost:4173
```

Combined:

```bash
npm run harness:all -- --base-url http://localhost:4173
```

Repeated runtime benchmark:

```bash
npm run harness:benchmark -- --base-url http://localhost:4173
```

Artifacts land in:

- `.agent-context/harness/<run-id>/`
- `.agent-context/evaluations/<run-id>/`

Use both before calling the context design "final":

- `docs/generated/context-efficiency-report.md` for structural savings
- `docs/generated/agent-catalog.md` for reusable agent visibility
- `docs/generated/agent-usage-report.md` for measured time-saved evidence
- `docs/generated/context-ab-report.md` for routed-vs-baseline task evidence
- `docs/generated/contextual-retrieval.md` for query-time retrieval coverage
- `docs/generated/context-registry.md` for discovery visibility
- `docs/generated/context-value-demo.md` for the shortest shareable explanation of user-visible value
- `docs/generated/sandbox-policy-report.md` for execution-boundary visibility
- `.agent-context/evaluations/<run-id>/summary.md` for noise-controlled runtime validation

## Open-Source Visibility Workflow

If the repo is being shared for other teams to adopt:

```bash
npm run registry:query -- --q core
npm run registry:query -- --kind agent --q planner
npm run registry:describe -- --kind tool --id context-retrieve
npm run agent:new -- --id triage --role reviewer --surface core
npm run agent:start -- --agent planner --surface core
npm run agent:event -- --type doc_open --path docs/PLANS.md
npm run agent:finish -- --status success --baseline-minutes 30
npm run agent:report
npm run retrieve:query -- --q "routing rules"
npm run value:demo
npm run registry:serve
npm run eval:ab:refresh
npm run sandbox:check
```

That gives external users four concrete things to inspect:

- what the repo exposes
- which reusable agents the repo already ships
- whether measured agent runs show any real time-saved signal
- what commands it supports
- whether routed mode actually helped
- what execution boundary the maintainers intended

## When To Promote Rules

If the same instruction keeps reappearing in:

- checkpoints
- handoffs
- watch log
- repeated reviews

it should usually move into one of:

- `README.md`
- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/README.md`
- `docs/product-specs/*.md`
- `docs/design-docs/*.md`
- scripts or hooks
