# __AGENT_NAME__ Runtime Workspace

Platform: `__RUNTIME_PLATFORM__`

Summary: `__RUNTIME_SUMMARY__`

## Boundaries

- Core repo: `__CORE_REPO__`
- Memory workspace: `__MEMORY_WORKSPACE__`

## Purpose

This workspace is the runtime wiring layer for `__AGENT_NAME__`.

Use it for:

- building a session-boot bundle
- generating a memory index
- producing nightly distill reports
- formatting cross-agent relay payloads
- storing adapter-specific runtime notes

Do not store canonical project truth here.
Do not store long-term agent identity here.

## First Commands

```bash
node scripts/check-runtime-config.mjs
node scripts/build-project-context-bundle.mjs
node scripts/build-memory-index.mjs
node scripts/distill-memory.mjs
```
