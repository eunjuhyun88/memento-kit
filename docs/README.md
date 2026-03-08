# Memento Kit Docs

This folder documents the kit itself, not the docs that get installed into a target repository.

## Read Order

1. `README.md`
2. `docs/KIT_ARCHITECTURE.md`
3. `docs/KIT_SETUP_FLOW.md`
4. `docs/KIT_CONFIGURATION.md`
5. `docs/KIT_OPERATIONS.md`
6. `docs/KIT_VERIFICATION.md`
7. `docs/KIT_FILE_MANIFEST.md`
8. `docs/KIT_DESIGN_DECISIONS.md`
9. `docs/KIT_MEMORY_LAYER.md`
10. `docs/KIT_RUNTIME_LAYER.md`
11. `docs/KIT_REFERENCE_ALIGNMENT.md`
12. `docs/KIT_REMAINING_DESIGN.md`

## What Each Document Covers

- `docs/KIT_ARCHITECTURE.md`
  - system layout, layers, and boundaries
- `docs/KIT_SETUP_FLOW.md`
  - exactly what `setup.sh` does to a target repository
- `docs/KIT_CONFIGURATION.md`
  - `context-kit.json` schema and how generation/harness scripts use it
- `docs/KIT_OPERATIONS.md`
  - daily workflow after the kit is installed
- `docs/KIT_VERIFICATION.md`
  - validation flow and what was tested
- `docs/KIT_FILE_MANIFEST.md`
  - inventory of kit files and installed target files
- `docs/KIT_DESIGN_DECISIONS.md`
  - rationale and tradeoffs behind the kit
- `docs/KIT_MEMORY_LAYER.md`
  - optional agent identity and memory workspace layer, separate from repo-local core
- `docs/KIT_RUNTIME_LAYER.md`
  - optional runtime wiring layer, separate from both repo-local core and agent-local memory
- `docs/KIT_REFERENCE_ALIGNMENT.md`
  - how the kit maps to public context-engineering references and where gaps remain
- `docs/KIT_REMAINING_DESIGN.md`
  - what is still missing between the current kit and a more fully productized platform
