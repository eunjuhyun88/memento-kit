# Kit Configuration

## Main Config File

The target repository is configured through:

- `context-kit.json`

This file is intentionally small and repo-local. It is the bridge between:

- generic scripts shipped by the kit
- the concrete shape of the target repository

## Schema Overview

```json
{
  "version": 1,
  "project": {
    "name": "MyProject",
    "slug": "myproject",
    "summary": "One-line summary",
    "stack": "TypeScript / Python",
    "phase": "initial bootstrap",
    "deadline": "TBD"
  },
  "git": {
    "mainBranch": "main"
  },
  "discovery": {
    "routesDir": "src/routes",
    "storesDir": "src/lib/stores",
    "apiDir": "src/routes/api"
  },
  "surfaces": [],
  "harness": {
    "pages": ["/"],
    "apis": [],
    "browserPages": ["/"]
  },
  "coordination": {
    "requireClaimOnFeatureBranches": true,
    "requirePathsOnFeatureBranches": true,
    "featureBranchPrefixes": ["codex/"],
    "defaultLeaseMinutes": 240,
    "lockStaleMinutes": 15,
    "failOnExpiredClaims": true,
    "failOnPathOverlap": true,
    "failOnUnscopedSurfaceOverlap": true,
    "sharedPathPrefixes": [
      "docs/AGENT_WATCH_LOG.md",
      "docs/generated/",
      ".agent-context/"
    ]
  },
  "orchestration": {
    "enabled": true,
    "workItemsDir": ".agent-context/orchestration/work-items",
    "boardPath": ".agent-context/orchestration/board.md",
    "summaryPath": ".agent-context/orchestration/summary.json",
    "defaultStatus": "planned",
    "readyStatuses": ["ready"],
    "activeStatuses": ["active"],
    "blockedStatuses": ["blocked", "handoff"],
    "terminalStatuses": ["done", "abandoned"],
    "enforceClaimSync": true
  },
  "autopilot": {
    "enabled": true,
    "allowReadyQueuePickup": true,
    "defaultAgent": "agent",
    "runSaveAfterStart": true,
    "runCompactAfterStart": true,
    "runCompactAfterSync": true,
    "runOrchestrationCheck": true
  },
  "registry": {
    "enabled": true,
    "manifestPath": "docs/generated/context-registry.json",
    "publicBaseUrl": "",
    "publishTags": ["myproject", "context-kit"],
    "searchKinds": ["surface", "doc", "command", "retrieval", "agent", "tool"]
  },
  "agents": {
    "enabled": true,
    "dir": "agents",
    "catalogPath": "docs/generated/agent-catalog.json",
    "defaultSurface": "core"
  },
  "tools": {
    "enabled": true,
    "dir": "tools",
    "catalogPath": "docs/generated/tool-catalog.json",
    "defaultSurface": "core"
  },
  "telemetry": {
    "enabled": true,
    "runsDir": ".agent-context/telemetry/runs",
    "eventsDir": ".agent-context/telemetry/events",
    "activeDir": ".agent-context/telemetry/active",
    "lockPath": ".agent-context/telemetry/telemetry.lock",
    "lockStaleMinutes": 5,
    "reportPath": "docs/generated/agent-usage-report.json",
    "defaults": {
      "taskComplexity": "moderate",
      "skillLevel": "experienced",
      "purpose": "product-development",
      "autonomy": "assisted"
    }
  },
  "retrieval": {
    "enabled": true,
    "includePaths": ["README.md", "docs/"],
    "excludePaths": ["docs/archive/", "docs/generated/"],
    "chunkWords": 120,
    "overlapWords": 30,
    "defaultTopK": 5,
    "contextualWeight": 0.65,
    "rawWeight": 0.35,
    "pathBoost": 0.8,
    "headingBoost": 0.5,
    "surfaceBoost": 0.75,
    "indexPath": "docs/generated/contextual-retrieval-index.json"
  },
  "sandbox": {
    "enabled": true,
    "allowReadPaths": ["README.md", "docs/", "src/"],
    "allowWritePaths": [".agent-context/", "docs/generated/"],
    "allowNetworkHosts": ["127.0.0.1", "localhost"],
    "denyCommandPrefixes": ["rm -rf", "git reset --hard"],
    "requireApprovalCommandPrefixes": ["git push", "npm publish"],
    "credentialEnvAllowlist": []
  },
  "evaluation": {
    "targets": {
      "smallMapReductionVsCanonicalPct": 40,
      "smallMapReductionVsAllDocsPct": 55,
      "surfaceReductionVsAllDocsPct": 50,
      "smallMapMaxApproxTokens": 3800,
      "smallMapMaxFiles": 6,
      "canonicalMaxApproxTokens": 12000,
      "noiseRateMaxPct": 10
    },
    "benchmark": {
      "runs": 3,
      "warmupRuns": 1,
      "mode": "smoke",
      "maxDurationCvPct": 15
    },
    "ab": {
      "minComparisons": 1,
      "targetDocsBeforeFirstEdit": 6,
      "targetResumeLatencyMinutes": 3
    }
  },
  "commands": {
    "check": "",
    "build": "",
    "gate": ""
  }
}
```

## `project`

Purpose:

- metadata for humans
- naming and documentation seed values

Used by:

- setup output
- docs authored after setup

## `git.mainBranch`

Purpose:

- the branch that hooks and sync scripts treat as the protected mainline

Used by:

- `safe-status.sh`
- `sync-branch.sh`
- `.githooks/pre-push`

If omitted, scripts fall back to `main`.

## `discovery`

Purpose:

- tell generated-doc scripts where to look

Fields:

- `routesDir`
- `storesDir`
- `apiDir`

These defaults fit Svelte-style repos. If a project uses a different structure, this is the first place to change.

## `surfaces`

Each surface entry can contain:

- `id`
- `label`
- `summary`
- `spec`
- `routes`
- `stores`
- `apis`

Example:

```json
{
  "id": "core",
  "label": "Core surface",
  "summary": "Primary user-facing workflow.",
  "spec": "docs/product-specs/core.md",
  "routes": ["/"],
  "stores": ["sessionStore"],
  "apis": ["/api/session"]
}
```

Used by:

- `refresh-generated-context.mjs`
- `refresh-doc-governance.mjs`
- `refresh-context-metrics.mjs`
- `check-docs-context.sh`
- the human authoring process for `docs/product-specs/*.md`

## `agents`

Purpose:

- tell the kit where editable agent manifests live
- control the generated public agent catalog

Fields:

- `enabled`
- `dir`
- `catalogPath`
- `defaultSurface`

Used by:

- `scaffold-agent.mjs`
- `refresh-agent-catalog.mjs`
- `refresh-context-registry.mjs`
- `check-docs-context.sh`

## `orchestration`

Purpose:

- keep dependency sequencing separate from raw path ownership
- expose a machine-readable ready queue for automation or supervisors
- keep handoff routing visible after the original chat is gone

Fields:

- `enabled`
- `workItemsDir`
- `boardPath`
- `summaryPath`
- `defaultStatus`
- `readyStatuses`
- `activeStatuses`
- `blockedStatuses`
- `terminalStatuses`
- `enforceClaimSync`

Used by:

- `orchestrate-work.mjs`
- `list-orchestration-work.mjs`
- `check-orchestration-work.mjs`
- `claim-work.mjs`
- `release-work.mjs`
- `context-restore.sh`

## `autopilot`

Purpose:

- add an opt-in session bootstrap above raw `ctx:*`, `coord:*`, and `orch:*` commands
- keep restart flow centered on a `workId`, not a long chat transcript
- let a repo safely pick the next ready item without adding merge or push automation

Fields:

- `enabled`
- `allowReadyQueuePickup`
- `defaultAgent`
- `runSaveAfterStart`
- `runCompactAfterStart`
- `runCompactAfterSync`
- `runOrchestrationCheck`

Used by:

- `autopilot-work.mjs`

## `tools`

Purpose:

- tell the kit where editable tool manifests live
- control the generated public tool catalog

Fields:

- `enabled`
- `dir`
- `catalogPath`
- `defaultSurface`

Used by:

- `scaffold-tool.mjs`
- `refresh-tool-catalog.mjs`
- `refresh-context-registry.mjs`
- `check-docs-context.sh`

## `telemetry`

Purpose:

- record measured agent runs
- summarize actual vs baseline time
- make public efficiency claims inspectable

Fields:

- `enabled`
- `runsDir`
- `eventsDir`
- `activeDir`
- `lockPath`
- `lockStaleMinutes`
- `reportPath`
- `defaults`

Used by:

- `start-agent-run.mjs`
- `log-agent-event.mjs`
- `finish-agent-run.mjs`
- `refresh-agent-usage-report.mjs`
- `serve-context-registry.mjs`

## `harness`

Fields:

- `pages`
- `apis`
- `browserPages`

Example:

```json
{
  "pages": ["/", "/dashboard"],
  "apis": [
    { "route": "/api/session", "expected": [200, 401] }
  ],
  "browserPages": ["/", "/dashboard"]
}
```

Used by:

- `run-context-harness.sh`
- `run-browser-context-harness.sh`
- `run-context-benchmark.mjs`

## `coordination`

Purpose:

- define whether feature branches must claim ownership
- describe what counts as a collision
- keep path/surface lease rules repo-local

Fields:

- `requireClaimOnFeatureBranches`
- `requirePathsOnFeatureBranches`
- `featureBranchPrefixes`
- `defaultLeaseMinutes`
- `lockStaleMinutes`
- `failOnExpiredClaims`
- `failOnPathOverlap`
- `failOnUnscopedSurfaceOverlap`
- `sharedPathPrefixes`

Used by:

- `claim-work.mjs`
- `list-work-claims.mjs`
- `check-agent-coordination.mjs`
- `release-work.mjs`
- `gate:context`

Recommended default posture:

- keep feature-branch claim enforcement on
- keep feature-branch path-boundary enforcement on
- require explicit `--path` boundaries for same-surface parallel work
- keep stale lock recovery on for local crash recovery

## `registry`

Purpose:

- define the portable manifest path
- define public discovery metadata and tags
- make local query/API behavior repo-local

Used by:

- `refresh-context-registry.mjs`
- `query-context-registry.mjs`
- `serve-context-registry.mjs`
- `docs/CONTEXT_PLATFORM.md`

## `retrieval`

Purpose:

- define the chunk corpus for contextual retrieval
- keep query-time retrieval deterministic and repo-local

Used by:

- `refresh-context-retrieval.mjs`
- `query-context-retrieval.mjs`
- `serve-context-registry.mjs`
- `docs/CONTEXTUAL_RETRIEVAL.md`

## `sandbox`

Purpose:

- keep execution boundaries explicit
- define read/write/network/command policy in repo-local config

Used by:

- `refresh-sandbox-policy-report.mjs`
- `docs/SANDBOX_POLICY.md`
- `gate:context`

## `evaluation`

Purpose:

- define what "good enough" means for the context system
- keep structural savings and runtime stability thresholds repo-local

Fields:

- `targets.smallMapReductionVsCanonicalPct`
- `targets.smallMapReductionVsAllDocsPct`
- `targets.surfaceReductionVsAllDocsPct`
- `targets.smallMapMaxApproxTokens`
- `targets.smallMapMaxFiles`
- `targets.canonicalMaxApproxTokens`
- `targets.noiseRateMaxPct`
- `benchmark.runs`
- `benchmark.warmupRuns`
- `benchmark.mode`
- `benchmark.maxDurationCvPct`
- `ab.minComparisons`
- `ab.targetDocsBeforeFirstEdit`
- `ab.targetResumeLatencyMinutes`

Used by:

- `refresh-context-metrics.mjs`
- `run-context-benchmark.mjs`
- `record-context-ab-eval.mjs`
- `refresh-context-ab-report.mjs`
- `docs/CONTEXT_EVALUATION.md`

Recommended default posture:

- keep bootstrap repos on the shipped defaults
- tighten thresholds as the repo grows and canonical docs deepen

## `commands`

Optional project integration points:

- `commands.check`
- `commands.build`
- `commands.gate`

If defined, hooks and sync scripts call these exact shell commands.

If empty:

- `run-configured-command.sh` falls back to `npm run <name> --if-present`
- context-only checks still run through `npm run gate:context`

## Recommended Customization Order

When adapting the kit to a real repository, customize in this order:

1. `git.mainBranch`
2. `discovery`
3. `surfaces`
4. `harness`
5. `registry`
6. `retrieval`
7. `sandbox`
8. `commands`

This order moves from structural correctness to deeper project enforcement.

## Failure Modes

If `context-kit.json` is wrong, common symptoms are:

- generated route/store/API docs missing expected entries
- contract report marking valid items as missing
- harness hitting wrong routes or no routes
- hooks checking against the wrong main branch

That means `context-kit.json` should be reviewed early whenever the kit is installed into a new repository.
