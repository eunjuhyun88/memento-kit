# Remaining Design

This document tracks what is still missing after the current kit reaches a usable open-source context-platform baseline.

## Done Enough Now

The current kit already has:

- canonical context routing
- mechanical docs enforcement
- semantic checkpoints, briefs, and handoffs
- contextual retrieval
- multi-agent coordination
- reusable agents
- reusable tool contracts
- registry and HTTP discovery APIs
- runtime telemetry and time-saved reporting
- routed-vs-baseline evaluation
- sandbox policy reporting

That means the remaining work is no longer "make context management exist".
It is "make the platform easier to adopt, safer to run, and harder to game".

The optional agent-memory workspace bootstrap is already available.
It should be treated as a separate layer, not as missing core functionality.

The optional runtime workspace bootstrap is also already available.
It should be treated as a separate layer for operational wiring, not as missing core functionality.

## Remaining Work

## 1. Productized CLI Surface

Current state:

- repo-local npm scripts and JSON manifests
- inspectable contracts through `registry:query`, `registry:describe`, and HTTP endpoints

Still missing:

- a standalone installable CLI binary
- consistent `--json` support across all core commands
- consistent `--dry-run` support for mutating commands
- stable machine-readable exit-code conventions
- command self-description like `tool describe`, `agent describe`, `surface describe`

Why it matters:

- open-source users feel tools faster through CLI ergonomics than through docs
- agent runtimes work better when every command is predictably introspectable

## 2. MCP Packaging

Current state:

- HTTP endpoints already expose discovery and retrieval
- command and tool contracts are explicit

Still missing:

- a dedicated MCP server wrapper for registry, retrieval, and tool contracts
- MCP-readable schemas for tool inputs and outputs
- examples for wiring the kit into external agent runtimes

Why it matters:

- this is the cleanest path from repo-local kit to multi-agent ecosystem integration

## 3. Stronger Retrieval

Current state:

- deterministic contextual retrieval
- cheap local regeneration

Still missing:

- embedding-based retrieval
- reranking
- retrieval evaluation on held-out ambiguous tasks
- per-surface retrieval quality dashboards

Why it matters:

- deterministic retrieval is a good baseline, but ambiguous repos will eventually need stronger ranking

## 4. Stronger Evaluations

Current state:

- routed-vs-baseline A/B records
- runtime-noise benchmark
- measured run telemetry

Still missing:

- held-out evaluation bundles that are difficult to game
- standardized task suites per repo type
- regression thresholds for agent/tool adoption quality
- confidence intervals or sample-size guidance for time-saved claims

Why it matters:

- public claims need to survive optimization pressure

## 5. Stronger Sandboxing

Current state:

- explicit sandbox policy
- mechanical sandbox-policy validation

Still missing:

- actual execution isolation wrapper
- scoped credential launcher
- network egress modes beyond simple allowlists
- safer publish/push policies for unattended runs

Why it matters:

- policy visibility is useful, but public autonomous use eventually needs stronger enforcement

## 6. Multi-Machine Coordination

Current state:

- shared-filesystem coordination works
- claims, leases, and overlap checks are in place

Still missing:

- distributed lease backend
- remote claim visibility
- machine identity in telemetry and coordination
- cross-machine stale-claim recovery

Why it matters:

- open-source teams will eventually run agents on more than one machine

## 7. Adoption Surface

Current state:

- zip distribution
- setup script
- kit documentation

Still missing:

- public repo packaging conventions
- versioning and changelog discipline
- compatibility matrix by repo type
- starter templates by framework
- example demo repos with before/after evidence

Why it matters:

- people adopt what is easy to try and easy to trust

## Recommended Order

If continuing from here, the best order is:

1. productized CLI surface
2. MCP packaging
3. stronger evaluations
4. stronger retrieval
5. stronger sandboxing
6. multi-machine coordination
7. adoption surface polish

## What To Treat As "V1 Complete"

Treat the kit as V1 complete when all of these are true:

1. a fresh repo can install it and pass `docs:check`
2. users can discover agents, tools, and surfaces through CLI or HTTP
3. at least one measured run produces believable non-zero time-saved evidence
4. one routed-vs-baseline comparison is recorded
5. the registry/tool surface is stable enough for external wrapping

Everything beyond that is V1.5 or V2 work, not a blocker for initial open-source release.
