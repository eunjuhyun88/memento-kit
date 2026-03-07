# Kit File Manifest

## Top-Level Kit Files

### Bootstrap

- `setup.sh`
- `README.md`

### Kit-Level Documentation

- `docs/README.md`
- `docs/KIT_ARCHITECTURE.md`
- `docs/KIT_SETUP_FLOW.md`
- `docs/KIT_CONFIGURATION.md`
- `docs/KIT_OPERATIONS.md`
- `docs/KIT_VERIFICATION.md`
- `docs/KIT_FILE_MANIFEST.md`
- `docs/KIT_DESIGN_DECISIONS.md`
- `docs/KIT_REFERENCE_ALIGNMENT.md`

### Reusable Prompts

- `prompts/feature-loop-template.md`
- `prompts/think-tool-prompt.md`
- `prompts/gc-loop-prompt.md`

### Lint Helpers

- `lint/eslint-architecture.js`

### Installable Template

- `templates/repo/`

## Installed Target Repository Files

### Root Files

- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `ARCHITECTURE.md`
- `context-kit.json`
- `.gitignore`
- `agents/*`
- `tools/*`

### Docs

- `docs/README.md`
- `docs/SYSTEM_INTENT.md`
- `docs/CONTEXT_ENGINEERING.md`
- `docs/CONTEXT_EVALUATION.md`
- `docs/CONTEXT_PLATFORM.md`
- `docs/CONTEXTUAL_RETRIEVAL.md`
- `docs/AGENT_FACTORY.md`
- `docs/TOOL_DESIGN.md`
- `docs/AGENT_OBSERVABILITY.md`
- `docs/MULTI_AGENT_COORDINATION.md`
- `docs/SANDBOX_POLICY.md`
- `docs/DESIGN.md`
- `docs/ENGINEERING.md`
- `docs/PLANS.md`
- `docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md`
- `docs/SECURITY.md`
- `docs/HARNESS.md`
- `docs/AGENT_CONTEXT_PROTOCOL.md`
- `docs/AGENT_WATCH_LOG.md`
- `docs/design-docs/*`
- `docs/product-specs/*`
- `docs/exec-plans/*`
- `docs/generated/*`
- `docs/references/*`
- `docs/archive/README.md`

### Scripts

- `scripts/dev/context-save.sh`
- `scripts/dev/context-checkpoint.sh`
- `scripts/dev/context-compact.sh`
- `scripts/dev/check-context-quality.sh`
- `scripts/dev/context-restore.sh`
- `scripts/dev/context-pin.sh`
- `scripts/dev/context-auto.sh`
- `scripts/dev/coordination-lib.mjs`
- `scripts/dev/claim-work.mjs`
- `scripts/dev/list-work-claims.mjs`
- `scripts/dev/check-agent-coordination.mjs`
- `scripts/dev/release-work.mjs`
- `scripts/dev/context-config.mjs`
- `scripts/dev/run-configured-command.sh`
- `scripts/dev/inject-package-scripts.mjs`
- `scripts/dev/check-docs-context.sh`
- `scripts/dev/refresh-generated-context.mjs`
- `scripts/dev/refresh-doc-governance.mjs`
- `scripts/dev/refresh-context-metrics.mjs`
- `scripts/dev/context-registry-lib.mjs`
- `scripts/dev/context-retrieval-lib.mjs`
- `scripts/dev/refresh-context-retrieval.mjs`
- `scripts/dev/query-context-retrieval.mjs`
- `scripts/dev/agent-catalog-lib.mjs`
- `scripts/dev/tool-catalog-lib.mjs`
- `scripts/dev/agent-telemetry-lib.mjs`
- `scripts/dev/refresh-agent-catalog.mjs`
- `scripts/dev/refresh-tool-catalog.mjs`
- `scripts/dev/scaffold-agent.mjs`
- `scripts/dev/scaffold-tool.mjs`
- `scripts/dev/start-agent-run.mjs`
- `scripts/dev/log-agent-event.mjs`
- `scripts/dev/finish-agent-run.mjs`
- `scripts/dev/refresh-agent-usage-report.mjs`
- `scripts/dev/refresh-context-registry.mjs`
- `scripts/dev/query-context-registry.mjs`
- `scripts/dev/describe-context-entry.mjs`
- `scripts/dev/serve-context-registry.mjs`
- `scripts/dev/record-context-ab-eval.mjs`
- `scripts/dev/refresh-context-ab-report.mjs`
- `scripts/dev/refresh-context-value-demo.mjs`
- `scripts/dev/refresh-sandbox-policy-report.mjs`
- `scripts/dev/run-context-harness.sh`
- `scripts/dev/run-browser-context-harness.sh`
- `scripts/dev/run-full-context-harness.sh`
- `scripts/dev/run-context-benchmark.mjs`
- `scripts/dev/install-git-hooks.sh`
- `scripts/dev/safe-status.sh`
- `scripts/dev/sync-branch.sh`
- `scripts/dev/new-worktree.sh`
- `scripts/dev/post-merge-sync.sh`

### Hooks

- `.githooks/pre-push`
- `.githooks/post-merge`

### Prompt/Lint Copies

- `prompts/*`
- `lint/eslint-architecture.js`

## Generated At Setup Time

During setup, the target also gets:

- `docs/generated/route-map.md`
- `docs/generated/store-authority-map.md`
- `docs/generated/api-group-map.md`
- `docs/generated/docs-catalog.md`
- `docs/generated/legacy-doc-audit.md`
- `docs/generated/context-contract-report.md`
- `docs/generated/context-efficiency-report.md`
- `docs/generated/context-registry.md`
- `docs/generated/context-registry.json`
- `docs/generated/contextual-retrieval.md`
- `docs/generated/contextual-retrieval-index.json`
- `docs/generated/agent-catalog.md`
- `docs/generated/agent-catalog.json`
- `docs/generated/tool-catalog.md`
- `docs/generated/tool-catalog.json`
- `docs/generated/agent-usage-report.md`
- `docs/generated/agent-usage-report.json`
- `docs/generated/context-ab-report.md`
- `docs/generated/context-value-demo.md`
- `docs/generated/context-value-demo.json`
- `docs/generated/sandbox-policy-report.md`

## Runtime-Only Outputs

These are not installed as fixed files, but appear during usage:

- `.agent-context/snapshots/*`
- `.agent-context/checkpoints/*`
- `.agent-context/briefs/*`
- `.agent-context/handoffs/*`
- `.agent-context/compact/*`
- `.agent-context/runtime/*`
- `.agent-context/state/*`
- `.agent-context/harness/*`
- `.agent-context/evaluations/*`
- `.agent-context/coordination/*`
- `.agent-context/telemetry/runs/*`
- `.agent-context/telemetry/events/*`
- `.agent-context/telemetry/active/*`
- `.agent-context/telemetry/telemetry.lock`
