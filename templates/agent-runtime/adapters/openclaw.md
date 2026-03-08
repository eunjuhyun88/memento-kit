# OpenClaw Adapter Notes

Recommended uses for this runtime layer with OpenClaw:

- Project Context injection:
  - inject the bundle from `generated/project-context-bundle.md`
- Nightly jobs:
  - point nightly distill jobs at `scripts/distill-memory.mjs`
- Retrieval jobs:
  - rebuild the memory index before semantic lookup
- Cross-agent relay:
  - use `scripts/relay-crossview.mjs` to normalize outbound messages and block relay loops

This file is intentionally guidance-only.
Do not treat it as canonical project truth.
