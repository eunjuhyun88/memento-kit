# Kit Design Decisions

## Why This Exists

The kit was created because simpler starter kits solve only part of the problem:

- they create folders
- they provide prompt templates
- they provide a session note file

But they usually do not solve:

- canonical authority routing
- semantic handoff generation
- parallel ownership control
- mechanical drift checks
- hook-enforced behavior
- generated discovery artifacts
- local validation evidence

This kit tries to close that gap.

## Main Design Choices

### 1. `AGENTS.md` is intentionally short

Reason:

- large instruction blobs rot quickly
- they crowd out actual task context
- they are hard to validate mechanically

So the kit makes `AGENTS.md` a start-sequence and enforcement map, not an encyclopedia.

### 2. Stable truth is separated from runtime memory

Reason:

- a design doc and a branch-local handoff are different things
- mixing them creates silent authority drift

So the kit splits:

- canonical docs in `docs/`
- runtime memory in `.agent-context/`

### 3. `context-kit.json` is the only generic-to-local bridge

Reason:

- the scripts must be reusable
- the target repo shape is not reusable

So discovery paths, surfaces, harness targets, and branch policy are configuration, not hardcoded assumptions.

### 4. Generated docs are first-class

Reason:

- agents should not need to rediscover route/store/API shape from scratch every time
- authority classification should be inspectable

So generated docs are treated as part of the context system, not as optional extras.

That includes a generated context-efficiency report so bundle savings can be inspected numerically, plus a repeated runtime benchmark so structural wins are not confused with infrastructure noise.

### 5. Hooks enforce context discipline

Reason:

- documentation policy without mechanical enforcement decays
- teams forget to refresh or compact when pressure rises

So pre-push and post-merge hooks were included from the start.

### 6. Parallel work is explicit, not implicit

Reason:

- simultaneous agents drift into conflict unless ownership is visible
- branch names alone do not say which paths or surfaces are reserved
- handoffs need a durable ownership boundary, not just chat history

So the kit adds claim/lease files, path-boundary checks, and push-time coordination validation.

This is strongest for agents sharing the same repository filesystem. Cross-machine coordination needs the same ownership model promoted into tracked artifacts or an external scheduler.

### 7. Harness is local-first

Reason:

- a context system is stronger when the agent can also produce evidence
- browser and smoke artifacts are a practical minimum

So the kit ships local smoke/browser harness scripts and a repeated runtime benchmark even though they are still simpler than a full observability stack.

## What This Kit Deliberately Does Not Do

It does not try to:

- replace the target repo's application architecture
- prescribe a single frontend or backend framework
- guarantee semantic correctness of docs
- provide full observability or replay infrastructure

That scope limit is intentional. The kit is a context-management and enforcement substrate, not a full app framework.

## Tradeoffs

### Benefit

- much lower restart cost
- better agent navigation
- better mechanical hygiene
- stronger push-time discipline

### Cost

- more docs than a barebones starter
- more scripts to maintain
- more structure to understand upfront
- more explicit coordination work before multi-agent edits

This is acceptable when the goal is long-lived agent throughput rather than minimal bootstrap size.

## Intended Evolution

Likely next upgrades:

- metrics/traces harness
- interactive browser replay
- richer semantic doc/code consistency checks
- richer provider-specific CI presets
- more framework-specific discovery presets
