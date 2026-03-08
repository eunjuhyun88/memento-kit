# Memento Kit Manual

This is the shortest practical manual to ship with `memento-kit`.

## 1. What This Does

This kit turns a repository into a repo that agents can enter, resume, validate, and coordinate in with less context cost.

After installation, you get:

- short entry docs: `README.md`, `AGENTS.md`, `ARCHITECTURE.md`
- a concise `CLAUDE.md` plus Claude-native `.claude/` compatibility layer
- a canonical `docs/` structure
- generated route/store/API maps
- semantic resume tools: checkpoint / brief / handoff
- git workflow rules + repo-local git config bootstrap
- registry / retrieval / agent / tool catalogs
- value and validation reports
- a bootstrap guide for turning skeleton docs into project truth
- an optional separate memory workspace for agent identity and long-term memory
- an optional separate runtime workspace for session boot, nightly distill, memory indexing, and cross-agent relay

Core purpose:

- make it obvious where agents should read first
- reduce blind code scanning
- preserve working memory across sessions
- make context savings visible in reports

## 2. How To Install

Run this inside an existing repo or a new repo:

```bash
bash /absolute/path/to/memento-kit/setup.sh \
  --target . \
  --project-name MyProject \
  --summary "One-line summary" \
  --stack "TypeScript / SvelteKit" \
  --surfaces core,admin,api
```

Simpler one-line install:

```bash
bash /absolute/path/to/memento-kit/install.sh \
  --project-name MyProject \
  --summary "One-line summary" \
  --stack "TypeScript / SvelteKit" \
  --surfaces core,admin,api
```

Optional memory workspace bootstrap:

```bash
bash /absolute/path/to/memento-kit/setup-memory.sh \
  --target ./zeon-workspace \
  --agent-name Zeon \
  --agent-role "orchestrator" \
  --user-name "Simon"
```

Optional runtime workspace bootstrap:

```bash
bash /absolute/path/to/memento-kit/setup-runtime.sh \
  --target ./zeon-runtime \
  --agent-name Zeon \
  --core-repo /absolute/path/to/project-repo \
  --memory-workspace /absolute/path/to/zeon-workspace \
  --platform openclaw
```

Example:

```bash
mkdir my-project
cd my-project
git init
bash /Users/ej/Downloads/memento-kit/setup.sh \
  --target . \
  --project-name MyProject \
  --summary "Agent-friendly project"
```

## 3. What To Do Right After Install

```bash
npm run safe:hooks
npm run safe:git-config
npm run adopt:bootstrap
npm run docs:refresh
npm run docs:check
```

Then start filling these first:

- `context-kit.json`
- `README.md`
- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/SYSTEM_INTENT.md`
- `docs/product-specs/*.md`

Read this report immediately after install:

- `docs/generated/project-truth-bootstrap.md`
- `docs/generated/claude-compatibility-bootstrap.md`

That report tells you:

- what was auto-seeded
- which docs are still too empty
- which risky local directories were given a `CLAUDE.md`
- which canonical docs should be filled next

The rule is simple:

- do not write one giant manual
- use a short entry surface plus surface-specific source-of-truth docs
- keep agent identity and personal memory out of the project repo; use a separate memory workspace
- keep adapter-specific runtime wiring out of both the project repo and the memory workspace; use a separate runtime workspace

## 4. Reading Order During Real Work

Agents should start in this order:

1. `README.md`
2. `AGENTS.md`
3. `ARCHITECTURE.md`
4. `docs/README.md`
5. relevant `docs/product-specs/*.md`
6. relevant generated maps
7. then code

Before non-trivial work, leave a checkpoint:

```bash
npm run ctx:checkpoint -- \
  --work-id "W-$(date +%Y%m%d-%H%M)-myproject-codex" \
  --surface "core" \
  --objective "current objective"
```

If parallel work is possible, claim scope first:

```bash
npm run coord:claim -- \
  --work-id "W-$(date +%Y%m%d-%H%M)-myproject-codex" \
  --agent "codex-a" \
  --surface "core" \
  --summary "owned work slice" \
  --path "src/routes/core"
```

## 5. How To Check That It Works

First:

```bash
npm run docs:check
```

Search and discovery:

```bash
npm run registry:query -- --q core
npm run registry:describe -- --kind tool --id context-retrieve
npm run retrieve:query -- --q "routing rules"
```

Value report:

```bash
npm run value:demo
```

Generated reports:

- `docs/generated/context-value-demo.md`
- `docs/generated/project-truth-bootstrap.md`

What to look for:

- how much smaller the small map is than the broader docs set
- whether routes / stores / APIs are visible before code scanning
- whether spec alignment is passing
- whether checkpoints / harness scripts exist
- which skeleton docs still need real project truth

## 6. How To Measure Actual Time Saved

Telemetry example:

```bash
npm run agent:start -- --agent planner --surface core
npm run agent:event -- --type doc_open --path docs/PLANS.md
npm run agent:finish -- --status success --baseline-minutes 30
npm run agent:report
```

Result files:

- `docs/generated/agent-usage-report.md`
- `docs/generated/agent-usage-report.json`

You can also record routed-vs-baseline comparisons:

```bash
npm run eval:ab:record -- \
  --task-id "TASK-001" \
  --surface "core" \
  --routed-docs 4 \
  --baseline-docs 10 \
  --routed-minutes 2 \
  --baseline-minutes 6
npm run eval:ab:refresh
```

Read:

- `docs/generated/context-ab-report.md`

## 7. What To Share With Other People

Usually these are enough:

- this manual: `MANUAL.md`
- the post-install checklist: `POST_INSTALL_CHECKLIST.md`
- the zip file: `memento-kit.zip`

After extracting, the receiver can do:

1. run `install.sh`
2. run `npm run adopt:bootstrap`
3. run `npm run docs:refresh`
4. run `npm run docs:check`
5. run `npm run value:demo`

That is enough to prove the kit is alive in the target repo.

## 8. Where It Matters Most

Best fit:

- repos large enough that "where do I start reading?" is a real cost
- agent work that spans many sessions
- repos with multiple agents working in parallel
- repos with lots of docs but unclear authority

Lower value:

- tiny solo throwaway repos
- one-day experiments

## 9. One-Line Summary

This is not a tool for "writing more docs."
This is a tool for making agents enter a repo with less context, less drift, and less repeated rediscovery.
