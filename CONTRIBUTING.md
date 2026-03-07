# Contributing

## Scope

This repository is a bootstrap kit for making repositories easier for coding agents to enter, resume, validate, and coordinate in.

Changes should improve at least one of these:

- context routing
- mechanical enforcement
- generated maps or catalogs
- runtime validation
- evaluation or value measurement
- agent/tool reuse

## Development Flow

1. Make the smallest coherent change.
2. Keep root docs concise.
3. Prefer changing templates and generators over hand-editing generated outputs.
4. Update kit docs when behavior changes.
5. Keep the installed-repo surface stable unless there is a clear migration path.

## Validation

Before opening a PR, verify at least:

```bash
bash setup.sh --target /tmp/context-kit-test --project-name TestKit --summary "test"
```

Then inside the sample repo:

```bash
npm run docs:refresh
npm run docs:check
npm run value:demo
```

If you touched retrieval, registry, telemetry, or coordination, run the specific flows those features depend on as well.

## Design Bar

- Keep the small-map entry surface short.
- Do not move authority back into giant manuals.
- Prefer generated views over duplicated static summaries.
- Prefer explicit contracts over hidden prompt assumptions.
- New features should justify their weight with either operational safety or measurable value.

## Pull Requests

PRs should explain:

- what changed
- why it improves agent usability
- what validation was run
- whether it changes installed-repo behavior
