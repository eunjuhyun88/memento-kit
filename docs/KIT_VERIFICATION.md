# Kit Verification

## Purpose

This document describes how to verify that the kit works after changes.

## Required Verification

At minimum, verify the following in a fresh target repository:

1. setup succeeds
2. generated docs are created
3. `npm run docs:check` passes
4. semantic context pipeline works:
   - `ctx:save`
   - `ctx:checkpoint`
   - `ctx:compact`
   - `ctx:check -- --strict`
5. coordination pipeline works:
   - `coord:claim`
   - `coord:check`
   - `coord:release`
   - at least one intentional overlap is blocked
6. harness works:
   - `harness:smoke`
   - `harness:browser`
7. context-efficiency report is generated and readable
8. repeated runtime benchmark passes:
   - `harness:benchmark`
9. registry and sandbox platform layers work:
   - `registry:query`
   - `registry:serve`
   - `sandbox:check`
10. agent blueprint layer works:
   - `agent:new`
   - `agent:refresh`
   - `registry:query -- --kind agent`
11. runtime telemetry layer works:
   - `agent:start`
   - `agent:event`
   - `agent:finish`
   - `agent:report`
   - `/agent-usage` endpoint from `registry:serve`
12. retrieval layer works:
   - `retrieve:query`
   - `/retrieve` endpoint from `registry:serve`
13. at least one routed-vs-baseline comparison can be recorded and summarized:
   - `eval:ab:record`
   - `eval:ab:refresh`
14. user-visible value summary can be generated:
   - `value:demo`
   - `docs/generated/context-value-demo.md`

## Fresh Repo Validation Flow

Example flow:

```bash
mkdir my-sample
cd my-sample
git init
bash /path/to/codex-context-kit/setup.sh \
  --target . \
  --project-name SampleKit \
  --summary "Sample repo for validation" \
  --surfaces core,admin
npm run docs:check
npm run ctx:save -- --title "sample bootstrap" --work-id "W-..." --agent "codex"
npm run ctx:checkpoint -- --work-id "W-..." --surface core --objective "verify pipeline"
npm run ctx:compact -- --work-id "W-..."
npm run ctx:check -- --strict
npm run coord:claim -- --work-id "W-..." --agent "codex-a" --surface core --summary "verify ownership" --path "src/routes"
npm run coord:check
npm run coord:release -- --work-id "W-..." --status done --note "verification cleanup"
npm run agent:new -- --id triage --role reviewer --surface core
npm run agent:refresh
npm run agent:start -- --agent planner --surface core
npm run agent:event -- --type doc_open --path docs/PLANS.md
npm run agent:finish -- --status success --baseline-minutes 30
npm run agent:report
npm run registry:query -- --kind agent --q triage
npm run registry:query -- --q core
npm run retrieve:query -- --q "core surface"
npm run sandbox:check
```

If a simple static server is enough:

```bash
python3 -m http.server 4173
npm run harness:smoke -- --base-url http://localhost:4173
npm run harness:browser -- --base-url http://localhost:4173
npm run harness:benchmark -- --base-url http://localhost:4173
```

## What Was Verified During Construction

On March 7, 2026, the kit was validated by applying it into a fresh empty git repository and confirming:

- setup completed
- generated docs were created
- `docs:check` passed
- `ctx:save` passed in a repo with no commits yet
- `ctx:checkpoint` passed
- `ctx:compact` passed
- `ctx:check -- --strict` passed
- `coord:claim` passed
- `coord:claim` rejected feature-branch claims without `--path`
- `coord:claim` rejected unknown surface ids
- `coord:check` passed with a single active claim
- `coord:check` failed on an intentional overlapping claim
- `coord:check` failed when branch changes escaped the claimed path boundary
- `coord:release` restored a clean coordination state
- `harness:smoke` passed against a local static server
- `harness:browser` passed against a local static server
- `harness:benchmark` passed against a local static server
- `docs/generated/context-efficiency-report.md` was generated for the sample repo
- `docs/generated/context-registry.md` and `.json` were generated
- `docs/generated/agent-catalog.md` and `.json` were generated
- `docs/generated/agent-usage-report.md` and `.json` were generated
- `docs/generated/contextual-retrieval.md` and its JSON index were generated
- `docs/generated/context-ab-report.md` was generated
- `docs/generated/context-value-demo.md` was generated
- `docs/generated/sandbox-policy-report.md` was generated
- `registry:query` returned matches from the generated manifest
- `registry:query -- --kind agent` returned agent blueprint matches
- `agent:report` produced runtime value metrics and estimated time-saved totals
- `retrieve:query` returned canonical doc chunks from the retrieval index
- `sandbox:check` passed against the repo-local policy

## Important Edge Cases Already Handled

The kit had to explicitly handle these cases:

- fresh repos with no `HEAD` commit yet
- generated docs checking their own outputs
- references to generated docs that do not exist until the first refresh
- empty API harness target lists under `set -u`
- headless Chrome returning non-zero while still producing valid DOM/screenshot artifacts on macOS

## Known Limits

The kit currently verifies:

- structure
- authority routing
- runtime context quality
- smoke/browser evidence

It does not yet verify:

- semantic correctness of every canonical doc against implementation intent
- interactive browser replay
- metrics/traces observability
- live model-token telemetry from the agent runtime itself
- automatic docs-opened telemetry from the agent runtime itself

In other words: the kit now verifies that the context design is structurally compact and runtime-stable, but it still does not prove that every task will retrieve the optimal doc subset without task-level A/B measurement.

Those are future expansion layers, not bootstrap blockers.
