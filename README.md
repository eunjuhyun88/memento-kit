# Memento Kit

Agent Context Engineering Kit

Reusable bootstrap kit for turning a repository into an agent-first workspace with:

- canonical docs routing
- semantic context checkpoints, briefs, and handoffs
- multi-agent claims, leases, and conflict checks
- generated route/store/API maps
- legacy-doc hygiene checks
- smoke/browser harness scripts
- registry query and local HTTP manifest serving
- reusable agent manifests + scaffold workflow
- reusable tool contracts + scaffold workflow
- runtime agent telemetry + usage reporting
- contextual retrieval index + query API
- routed-vs-baseline task comparison recording
- sandbox policy validation and reporting
- git hooks that enforce context discipline
- push-time coordination checks for parallel agent work

This kit is extracted from the context-management system hardened in a real repo, then generalized so other teams can apply it with one setup step.

It now also includes:

- an explicit `CONTEXT_ENGINEERING.md` layer in installed repos
- a `CONTEXT_EVALUATION.md` measurement guide
- a generated `context-efficiency-report.md`
- a generated `context-registry.md` + `context-registry.json`
- a generated `contextual-retrieval.md` + `contextual-retrieval-index.json`
- a generated `agent-catalog.md` + `agent-catalog.json`
- a generated `tool-catalog.md` + `tool-catalog.json`
- a generated `agent-usage-report.md` + `agent-usage-report.json`
- a generated `context-ab-report.md`
- a generated `sandbox-policy-report.md`
- a generated `project-truth-bootstrap.md`
- a repeated `harness:benchmark` runtime/noise benchmark
- a `MULTI_AGENT_COORDINATION.md` coordination layer in installed repos
- a `CONTEXT_PLATFORM.md` + `SANDBOX_POLICY.md` layer for open-source discovery and execution boundaries
- line-budget enforcement for the small map
- noise-aware evaluation guidance inspired by Anthropic engineering notes

## Full Documentation

If you want the kit itself fully documented, start here:

- `MANUAL_KO.md`
- `docs/README.md`
- `docs/KIT_ARCHITECTURE.md`
- `docs/KIT_SETUP_FLOW.md`
- `docs/KIT_CONFIGURATION.md`
- `docs/KIT_OPERATIONS.md`
- `docs/KIT_VERIFICATION.md`
- `docs/KIT_FILE_MANIFEST.md`
- `docs/KIT_DESIGN_DECISIONS.md`
- `docs/KIT_REFERENCE_ALIGNMENT.md`
- `docs/KIT_REMAINING_DESIGN.md`

Example target config:

- `examples/context-kit.sample.json`

## What It Installs

- Root collaboration docs:
  - `README.md`
  - `AGENTS.md`
  - `CLAUDE.md`
  - `ARCHITECTURE.md`
  - `context-kit.json`
- Reusable agent layer:
  - `agents/*.json`
  - `docs/AGENT_FACTORY.md`
- Reusable tool layer:
  - `tools/*.json`
  - `docs/TOOL_DESIGN.md`
- Structured docs tree:
  - `docs/design-docs/`
  - `docs/product-specs/`
  - `docs/exec-plans/`
  - `docs/generated/`
  - `docs/references/`
  - `docs/archive/`
- Runtime/context tooling:
  - `scripts/dev/context-*.sh`
  - `scripts/dev/refresh-*.mjs`
  - `scripts/dev/run-*-harness.sh`
  - `.githooks/pre-push`
  - `.githooks/post-merge`
- Reusable prompts and lint helpers:
  - `prompts/feature-loop-template.md`
  - `prompts/think-tool-prompt.md`
  - `prompts/gc-loop-prompt.md`
  - `lint/eslint-architecture.js`

## Quick Start

Apply into the current repo:

```bash
bash /path/to/memento-kit/setup.sh \
  --target . \
  --project-name MyProject \
  --summary "One-line product summary" \
  --stack "SvelteKit / TypeScript / Python" \
  --surfaces core,admin,api
```

One-line install with post-setup verification:

```bash
bash /path/to/memento-kit/install.sh \
  --project-name MyProject \
  --summary "One-line product summary" \
  --stack "SvelteKit / TypeScript / Python" \
  --surfaces core,admin,api
```

Or create a new target first:

```bash
mkdir my-project
cd my-project
git init
bash /path/to/memento-kit/setup.sh \
  --target . \
  --project-name MyProject \
  --summary "One-line product summary"
```

## After Setup

1. Review `context-kit.json`
2. Review `docs/generated/project-truth-bootstrap.md`
3. Fill in the canonical docs with project-specific truth
4. Install hooks:
   ```bash
   npm run safe:hooks
   ```
5. Generate derived docs:
   ```bash
   npm run adopt:bootstrap
   npm run docs:refresh
   npm run docs:check
   ```
6. Validate the context system in two layers:
   ```bash
   npm run harness:benchmark -- --base-url http://localhost:4173
   ```
   Read:
   - `docs/generated/project-truth-bootstrap.md`
   - `docs/generated/context-efficiency-report.md`
   - `docs/generated/contextual-retrieval.md`
   - `docs/generated/context-ab-report.md`
   - `docs/generated/context-registry.md`
   - `docs/generated/sandbox-policy-report.md`
   - `.agent-context/evaluations/<run-id>/summary.md`
7. Try the discovery and safety surfaces:
   ```bash
   npm run agent:start -- --agent planner --surface core
   npm run agent:event -- --type doc_open --path docs/PLANS.md
   npm run agent:finish -- --status success --baseline-minutes 30
   npm run agent:report
   npm run registry:query -- --q core
   npm run registry:query -- --kind agent --q planner
   npm run registry:query -- --kind tool --q retrieve
   npm run agent:new -- --id triage --role reviewer --surface core
   npm run tool:new -- --id repo-search --surface core
   npm run tool:refresh
   npm run retrieve:query -- --q "routing rules"
   npm run value:demo
   npm run sandbox:check
   ```
8. Record at least one routed-vs-baseline comparison:
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
9. For parallel work, claim explicit ownership before edits:
   ```bash
   npm run coord:claim -- \
     --work-id "W-$(date +%Y%m%d-%H%M)-myproject-codex" \
     --agent "codex-a" \
     --surface "core" \
     --summary "describe the owned slice" \
     --path "src/routes/core"
   ```
   Feature branches should claim at least one explicit path boundary.
10. Start using semantic checkpoints:
   ```bash
   npm run ctx:checkpoint -- \
     --work-id "W-$(date +%Y%m%d-%H%M)-myproject-codex" \
     --surface "core" \
     --objective "describe the current task semantically"
   ```

## Design Principles

- `AGENTS.md` is a map, not an encyclopedia.
- Canonical truth lives in repo-local markdown and scripts.
- Runtime memory lives in `.agent-context/`, not in committed docs.
- Stable rules get promoted into canonical docs or enforcement scripts.
- Legacy docs stay visible but lose authority.
- Generated maps exist to reduce first-pass context cost.
- Agent manifests exist so outsiders can discover reusable workers without hidden prompts.
- Tool contracts exist so outsiders can discover reusable capabilities without hidden prompt glue.
- Runtime telemetry exists so time-saved claims are inspectable instead of anecdotal.
- Contextual retrieval exists to reduce ambiguous full-doc scans.
- Final context acceptance requires both structural savings and repeated runtime stability.
- Open-source adoption requires a visible registry, A/B evidence, and a visible sandbox boundary.
- Parallel work is safe only when ownership is declared as a claim before edits begin.

## Scope

This kit is strongest for TypeScript/Svelte-style repos because route/API/store discovery defaults to:

- `src/routes`
- `src/routes/api`
- `src/lib/stores`

If your repo differs, edit `context-kit.json` after setup.
