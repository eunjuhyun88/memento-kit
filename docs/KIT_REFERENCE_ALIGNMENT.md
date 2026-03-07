# Reference Alignment

This document records how the kit maps to the public context-engineering ideas it was compared against.

## Anthropic Alignment

### Effective context engineering for AI agents

Reflected in the kit through:

- small-map routing in installed `README.md`, `AGENTS.md`, and `docs/README.md`
- canonical-vs-generated-vs-archive separation
- semantic checkpoints, briefs, and handoffs
- `docs:check` mechanical enforcement

### Infrastructure noise

Reflected in the kit through:

- repeated-run benchmark under `.agent-context/evaluations/`
- duration CV and noise-rate gates
- explicit environment manifest capture

### Contextual retrieval

Reflected in the kit through:

- `docs/CONTEXTUAL_RETRIEVAL.md`
- deterministic contextual retrieval index
- `npm run retrieve:query`
- HTTP `/retrieve`

Current limitation:

- no embedding or reranker layer yet

### Claude think tool

Reflected in the kit through:

- `prompts/think-tool-prompt.md`
- routing rules that keep planning and retrieval explicit before edits

Current limitation:

- no first-class runtime think-event evaluator yet

### Writing tools for agents

Reflected in the kit through:

- `docs/TOOL_DESIGN.md`
- `tools/*.json`
- `docs/generated/tool-catalog.*`
- `npm run tool:new`
- registry `/tools` and `kind=tool`
- `registry:describe` and `/describe` for inspectable contracts

### Rewrite your CLI for AI agents

Reflected in the kit through:

- machine-readable registry and retrieval output
- inspectable tool and agent manifests
- `registry:describe` and `/describe` for contract introspection
- explicit safety metadata in tool manifests

Current limitation:

- the kit still expects repo-local scripts instead of a single polished standalone CLI binary

### Claude Code sandboxing

Reflected in the kit through:

- `docs/SANDBOX_POLICY.md`
- `context-kit.json -> sandbox`
- `docs/generated/sandbox-policy-report.md`

Current limitation:

- this is a visible policy layer, not a full kernel or VM sandbox

### Code execution with MCP

Reflected in the kit through:

- portable HTTP discovery endpoints
- explicit command and tool contracts
- registry and retrieval APIs that are easy to wrap as MCP tools

Current limitation:

- the kit does not ship a dedicated MCP server yet

### AI-resistant technical evaluations

Reflected in the kit through:

- routed-vs-baseline A/B records
- runtime noise control
- measurable final acceptance gates

Current limitation:

- no hidden held-out evaluator bundle yet

### Economic index primitives

Reflected in the kit through:

- telemetry primitives for task complexity, skill level, purpose, and autonomy
- primitive-level breakdowns in `agent-usage-report`

## What This Means

The kit is not trying to replicate any single external system exactly.

Instead, it turns the most reusable ideas into:

- repo-local docs
- generated reports
- queryable manifests
- reproducible validation commands

That is the intended bar for an open-source context platform kit.
