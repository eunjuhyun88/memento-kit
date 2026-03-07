# Memento Kit Post-Install Checklist

This is the shortest checklist for confirming what "working as intended" means right after installation.

## 1. Immediate Commands

These commands should pass end-to-end:

```bash
npm run safe:hooks
npm run safe:git-config
npm run adopt:bootstrap
npm run docs:refresh
npm run docs:check
```

## 2. Files That Should Exist Immediately

- `docs/generated/project-truth-bootstrap.md`
- `docs/generated/context-value-demo.md`
- `docs/generated/route-map.md`
- `docs/generated/store-authority-map.md`
- `docs/generated/api-group-map.md`

## 3. Expected State

- An agent can start with `README -> AGENTS -> docs/README`
- `context-kit.json` has at least seeded `routes/stores/apis` for each surface
- `docs/product-specs/*.md` has non-empty Context Contracts
- `docs/ENGINEERING.md` contains an inventory snapshot
- `docs/GIT_WORKFLOW.md` exists and defines git rules
- repo-local git config has been applied

## 4. What To Check In Reports

`docs/generated/project-truth-bootstrap.md`

- what was auto-filled
- which docs are still too empty
- what should be filled next

`docs/generated/context-value-demo.md`

- whether the small map is materially smaller
- whether routes/stores/apis are visible before code scanning
- whether time-saved telemetry is still empty or already recorded

## 5. Expected Git State

These values should be set:

```bash
git config --local --get core.hooksPath
git config --local --get pull.ff
git config --local --get merge.conflictstyle
git config --local --get rerere.enabled
```

Expected values:

- `.githooks`
- `only`
- `zdiff3`
- `true`

## 6. What Should Feel Different

- You should not start by scanning `src/` blindly
- You should look at generated route/store/api docs first
- The next session should resume from checkpoints and briefs
- Branch/worktree/sync rules should already be clear

## 7. Signs That The Repo Is Still Underfilled

The kit is installed, but project truth is still thin if:

- `docs/ENGINEERING.md` is still mostly placeholder text
- `docs/product-specs/*.md` is only one or two sentences
- `context-kit.json` mappings are still inaccurate
- telemetry runs are still `0`

## 8. One-Line Standard

Healthy post-install state is not "more docs exist."
Healthy post-install state is "agents get lost less, resume faster, and enter the repo with less context cost."
